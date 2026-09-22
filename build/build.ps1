param(
    [string]$Version = "0.1.6",
    [ValidateSet("all", "x64", "arm64")]
    [string]$Architecture = "all"
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$distRoot = Join-Path $repoRoot "dist"
$versionText = ($Version -replace '^v', '').Trim()
if ($versionText -notmatch '^\d+(\.\d+){0,3}$') {
    throw "Version must contain only numeric components, for example 0.1.6."
}

$versionParts = @($versionText.Split('.'))
while ($versionParts.Count -lt 3) {
    $versionParts += '0'
}
if ($versionParts.Count -eq 3) {
    $versionParts += '0'
}
$installerVersion = $versionParts -join '.'

$targets = if ($Architecture -eq "all") {
    @("x64", "arm64")
} else {
    @($Architecture)
}

function Get-ArchitectureSettings {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Target
    )

    if ($Target -eq "x64") {
        return @{
            Name = "x64"
            CompilerPlatform = "x64"
            Define = "ULTIMATE_X64"
            ExpectedMachine = 0x8664
        }
    }

    return @{
        Name = "arm64"
        CompilerPlatform = "arm64"
        Define = "ULTIMATE_ARM64"
        ExpectedMachine = 0xAA64
    }
}

function Get-FrameworkRoot {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Target
    )

    $roots = @(
        (Join-Path $env:WINDIR "Microsoft.NET\Framework64\v4.0.30319"),
        (Join-Path $env:WINDIR "Microsoft.NET\Framework\v4.0.30319")
    )
    $root = $roots | Where-Object {
        (Test-Path (Join-Path $_ "mscorlib.dll")) -and
        (Test-Path (Join-Path $_ "System.Windows.Forms.dll"))
    } | Select-Object -First 1
    if (-not $root) {
        throw "The .NET Framework reference assemblies were not found."
    }
    return $root
}

function Get-PeMachine {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $bytes = [System.IO.File]::ReadAllBytes($Path)
    if ($bytes.Length -lt 64 -or $bytes[0] -ne 0x4D -or $bytes[1] -ne 0x5A) {
        throw "The generated file is not a valid Windows executable: $Path"
    }
    $peOffset = [System.BitConverter]::ToInt32($bytes, 0x3C)
    if ($peOffset -lt 0 -or $peOffset + 6 -gt $bytes.Length) {
        throw "The generated executable has an invalid PE header: $Path"
    }
    if ($bytes[$peOffset] -ne 0x50 -or $bytes[$peOffset + 1] -ne 0x45) {
        throw "The generated file has an invalid PE signature: $Path"
    }
    return [System.BitConverter]::ToUInt16($bytes, $peOffset + 4)
}

function Invoke-CSharpBuild {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Settings,
        [Parameter(Mandatory = $true)]
        [string]$FrameworkRoot,
        [Parameter(Mandatory = $true)]
        [string]$SourcePath,
        [Parameter(Mandatory = $true)]
        [string]$ManifestPath,
        [Parameter(Mandatory = $true)]
        [string]$ExePath
    )

    $compilerCandidates = @(
        (Join-Path $env:WINDIR "Microsoft.NET\Framework64\v4.0.30319\csc.exe"),
        (Join-Path $env:WINDIR "Microsoft.NET\Framework\v4.0.30319\csc.exe")
    )
    $compiler = $compilerCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $compiler) {
        throw "The .NET Framework C# compiler (csc.exe) was not found."
    }

    $references = @(
        (Join-Path $FrameworkRoot "mscorlib.dll"),
        (Join-Path $FrameworkRoot "System.dll"),
        (Join-Path $FrameworkRoot "System.Drawing.dll"),
        (Join-Path $FrameworkRoot "System.Windows.Forms.dll")
    )
    foreach ($reference in $references) {
        if (-not (Test-Path $reference)) {
            throw "The .NET Framework reference is missing: $reference"
        }
    }

    $arguments = @(
        "/nologo",
        "/codepage:65001",
        "/target:winexe",
        "/optimize+",
        "/platform:$($Settings.CompilerPlatform)",
        "/define:$($Settings.Define)",
        "/out:$ExePath",
        "/win32manifest:$ManifestPath"
    )
    $arguments += $references | ForEach-Object { "/reference:$_" }
    $arguments += $SourcePath

    & $compiler @arguments
    if ($LASTEXITCODE -eq 0) {
        return
    }

    # Older .NET Framework csc.exe versions do not understand ARM64 even
    # though the current C# compiler does. Retry ARM64 with the Roslyn
    # compiler shipped in the Windows runner's .NET SDK when necessary.
    if ($Settings.Name -ne "arm64") {
        throw "C# compilation failed with exit code $LASTEXITCODE."
    }

    $dotnet = Get-Command dotnet -ErrorAction SilentlyContinue
    if (-not $dotnet) {
        throw "ARM64 C# compilation failed with exit code $LASTEXITCODE and the .NET SDK was not found."
    }
    $sdkRoot = Join-Path $env:ProgramFiles "dotnet\sdk"
    $roslynCompiler = Get-ChildItem -Path $sdkRoot -Filter "csc.dll" -Recurse -File -ErrorAction SilentlyContinue |
        Sort-Object FullName |
        Select-Object -Last 1
    if (-not $roslynCompiler) {
        throw "ARM64 C# compilation failed with exit code $LASTEXITCODE and the Roslyn compiler was not found."
    }

    $roslynArguments = @(
        $roslynCompiler.FullName,
        "/nologo",
        "/noconfig",
        "/nostdlib+",
        "/codepage:65001",
        "/target:winexe",
        "/optimize+",
        "/platform:$($Settings.CompilerPlatform)",
        "/define:$($Settings.Define)",
        "/out:$ExePath",
        "/win32manifest:$ManifestPath"
    )
    $roslynArguments += $references | ForEach-Object { "/reference:$_" }
    $roslynArguments += $SourcePath

    & $dotnet.Source @roslynArguments
    if ($LASTEXITCODE -ne 0) {
        throw "ARM64 C# compilation failed with exit code $LASTEXITCODE."
    }
}

function Copy-ToolkitPayload {
    param(
        [Parameter(Mandatory = $true)]
        [string]$StageRoot
    )

    $itemsToCopy = @(
        "1 Check", "2 Refresh", "3 Setup", "4 Installers", "5 Graphics", "6 Windows", "7 Hardware", "8 Advanced",
        "AllowScripts.cmd", "IWR.ps1", "README.md", "SCRIPT_GUIDE.md", "LICENSE"
    )
    foreach ($item in $itemsToCopy) {
        $source = Join-Path $repoRoot $item
        if (Test-Path $source) {
            Copy-Item -Path $source -Destination $StageRoot -Recurse -Force
        }
    }
    New-Item -Path (Join-Path $StageRoot "ui") -ItemType Directory -Force | Out-Null
    Copy-Item -Path (Join-Path $repoRoot "ui\PowerShellHost.ps1") -Destination (Join-Path $StageRoot "ui\PowerShellHost.ps1") -Force
}

if ($Architecture -eq "all") {
    if (Test-Path $distRoot) {
        Remove-Item -Path $distRoot -Recurse -Force
    }
} else {
    New-Item -Path $distRoot -ItemType Directory -Force | Out-Null
    $targetPrefix = "Ultimate-UI-v$versionText-win-$Architecture"
    Get-ChildItem -Path $distRoot -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -eq $targetPrefix -or $_.Name -like "$targetPrefix.*" } |
        Remove-Item -Recurse -Force
}
New-Item -Path $distRoot -ItemType Directory -Force | Out-Null

$sourcePath = Join-Path $repoRoot "ui\UltimateUi.cs"
$manifestPath = Join-Path $repoRoot "ui\UltimateUi.manifest"
$wix = Get-Command wix -ErrorAction SilentlyContinue
if (-not $wix) {
    throw "WiX was not found. Install WiX 5.0.2 with 'dotnet tool install --global wix --version 5.0.2', then add WixToolset.UI.wixext/5.0.2 to the WiX extension cache."
}

foreach ($target in $targets) {
    $settings = Get-ArchitectureSettings -Target $target
    $artifactPrefix = "Ultimate-UI-v$versionText-win-$($settings.Name)"
    $stageRoot = Join-Path $distRoot $artifactPrefix
    $installerPath = Join-Path $distRoot "$artifactPrefix.msi"
    $zipPath = Join-Path $distRoot "$artifactPrefix.zip"

    if (Test-Path $stageRoot) {
        Remove-Item -Path $stageRoot -Recurse -Force
    }
    New-Item -Path $stageRoot -ItemType Directory -Force | Out-Null

    $frameworkRoot = Get-FrameworkRoot -Target $target
    $exePath = Join-Path $stageRoot "UltimateUI.exe"
    Invoke-CSharpBuild `
        -Settings $settings `
        -FrameworkRoot $frameworkRoot `
        -SourcePath $sourcePath `
        -ManifestPath $manifestPath `
        -ExePath $exePath

    $machine = Get-PeMachine -Path $exePath
    if ($machine -ne $settings.ExpectedMachine) {
        throw "The generated $target GUI has PE machine 0x$('{0:X4}' -f $machine), expected 0x$('{0:X4}' -f $settings.ExpectedMachine)."
    }

    Copy-ToolkitPayload -StageRoot $stageRoot
    @(
        "Ultimate toolkit build",
        "Version: $versionText",
        "Architecture: $($settings.Name)",
        "GUI PE machine: 0x$('{0:X4}' -f $machine)",
        "The script payload in this folder belongs to this architecture-specific build."
    ) | Set-Content -Path (Join-Path $stageRoot "BUILD_ARCHITECTURE.txt") -Encoding ASCII

    $wixSource = Join-Path $repoRoot "installer\Ultimate.wxs"
    $wixArguments = @(
        "build",
        "-arch", $settings.Name,
        "-ext", "WixToolset.UI.wixext",
        "-d", "ProductVersion=$installerVersion",
        "-d", "StageDir=$stageRoot",
        "-o", $installerPath,
        $wixSource
    )
    & $wix.Source @wixArguments
    if ($LASTEXITCODE -ne 0) {
        throw "WiX $target MSI compilation failed with exit code $LASTEXITCODE."
    }

    Compress-Archive -Path (Join-Path $stageRoot "*") -DestinationPath $zipPath -Force
    Write-Output "Built $installerPath"
    Write-Output "Built $zipPath"
}
