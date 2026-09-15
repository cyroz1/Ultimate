param(
    [string]$Version = "0.1.0"
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$distRoot = Join-Path $repoRoot "dist"
$stageRoot = Join-Path $distRoot "Ultimate-UI"
$versionText = ($Version -replace '^v', '').Trim()
if ($versionText -notmatch '^\d+(\.\d+){0,3}$') {
    throw "Version must contain only numeric components, for example 0.1.2."
}
$versionParts = @($versionText.Split('.'))
while ($versionParts.Count -lt 3) {
    $versionParts += '0'
}
if ($versionParts.Count -eq 3) {
    $versionParts += '0'
}
$installerVersion = $versionParts -join '.'
$installerName = "Ultimate-UI-v$versionText-win-x64.msi"
$installerPath = Join-Path $distRoot $installerName

if (Test-Path $distRoot) {
    Remove-Item -Path $distRoot -Recurse -Force
}
New-Item -Path $stageRoot -ItemType Directory -Force | Out-Null

$compilerCandidates = @(
    "$env:WINDIR\Microsoft.NET\Framework64\v4.0.30319\csc.exe",
    "$env:WINDIR\Microsoft.NET\Framework\v4.0.30319\csc.exe"
)
$compiler = $compilerCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $compiler) {
    throw "The .NET Framework C# compiler (csc.exe) was not found."
}

$exePath = Join-Path $stageRoot "UltimateUI.exe"
$sourcePath = Join-Path $repoRoot "ui\UltimateUi.cs"
$manifestPath = Join-Path $repoRoot "ui\UltimateUi.manifest"
$references = @(
    "$env:WINDIR\Microsoft.NET\Framework64\v4.0.30319\System.dll",
    "$env:WINDIR\Microsoft.NET\Framework64\v4.0.30319\System.Drawing.dll",
    "$env:WINDIR\Microsoft.NET\Framework64\v4.0.30319\System.Windows.Forms.dll"
)
if (-not (Test-Path $references[0])) {
    $references = @(
        "$env:WINDIR\Microsoft.NET\Framework\v4.0.30319\System.dll",
        "$env:WINDIR\Microsoft.NET\Framework\v4.0.30319\System.Drawing.dll",
        "$env:WINDIR\Microsoft.NET\Framework\v4.0.30319\System.Windows.Forms.dll"
    )
}

$arguments = @(
    "/nologo",
    "/codepage:65001",
    "/target:winexe",
    "/optimize+",
    "/out:$exePath",
    "/win32manifest:$manifestPath"
)
$arguments += $references | ForEach-Object { "/reference:$_" }
$arguments += $sourcePath

& $compiler @arguments
if ($LASTEXITCODE -ne 0) {
    throw "C# compilation failed with exit code $LASTEXITCODE."
}

$itemsToCopy = @(
    "1 Check", "2 Refresh", "3 Setup", "4 Installers", "5 Graphics", "6 Windows", "7 Hardware", "8 Advanced",
    "AllowScripts.cmd", "IWR.ps1", "README.md", "LICENSE"
)
foreach ($item in $itemsToCopy) {
    $source = Join-Path $repoRoot $item
    if (Test-Path $source) {
        Copy-Item -Path $source -Destination $stageRoot -Recurse -Force
    }
}
New-Item -Path (Join-Path $stageRoot "ui") -ItemType Directory -Force | Out-Null
Copy-Item -Path (Join-Path $repoRoot "ui\PowerShellHost.ps1") -Destination (Join-Path $stageRoot "ui\PowerShellHost.ps1") -Force

$wix = Get-Command wix -ErrorAction SilentlyContinue
if (-not $wix) {
    throw "WiX was not found. Install WiX 5.0.2 with 'dotnet tool install --global wix --version 5.0.2', then add WixToolset.UI.wixext/5.0.2 to the WiX extension cache."
}

$wixSource = Join-Path $repoRoot "installer\Ultimate.wxs"
$wixArguments = @(
    "build",
    "-arch", "x64",
    "-ext", "WixToolset.UI.wixext",
    "-d", "ProductVersion=$installerVersion",
    "-d", "StageDir=$stageRoot",
    "-o", $installerPath,
    $wixSource
)
& $wix.Source @wixArguments
if ($LASTEXITCODE -ne 0) {
    throw "WiX MSI compilation failed with exit code $LASTEXITCODE."
}

Write-Output "Built $installerPath"
