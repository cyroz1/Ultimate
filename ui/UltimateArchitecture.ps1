function Get-UltimateArchitecture {
    # Prefer the OS architecture over the launcher architecture. This also
    # handles the x64 launcher if it is run under Windows on Arm emulation.
    try {
        $runtimeArchitecture = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString()
        switch ($runtimeArchitecture.ToUpperInvariant()) {
            { $_ -in @('ARM64', 'AARCH64') } { return 'arm64' }
            { $_ -in @('X64', 'AMD64') } { return 'x64' }
            { $_ -in @('X86', 'I386') } { return 'x86' }
        }
    } catch { }

    try {
        $machineArchitecture = (Get-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' -Name PROCESSOR_ARCHITECTURE -ErrorAction Stop).PROCESSOR_ARCHITECTURE
        switch (([string]$machineArchitecture).ToUpperInvariant()) {
            { $_ -in @('ARM64', 'AARCH64') } { return 'arm64' }
            { $_ -in @('AMD64', 'X64') } { return 'x64' }
            { $_ -in @('X86', 'I386') } { return 'x86' }
        }
    } catch { }

    foreach ($candidate in @($env:PROCESSOR_ARCHITEW6432, $env:PROCESSOR_ARCHITECTURE, $env:ULTIMATE_TOOLKIT_ARCHITECTURE)) {
        switch (([string]$candidate).ToUpperInvariant()) {
            { $_ -in @('ARM64', 'AARCH64') } { return 'arm64' }
            { $_ -in @('AMD64', 'X64') } { return 'x64' }
            { $_ -in @('X86', 'I386') } { return 'x86' }
        }
    }

    return 'unknown'
}

function Test-UltimateArm64 {
    return (Get-UltimateArchitecture) -eq 'arm64'
}

function Get-UltimateWindowsBuild {
    try {
        return [int](Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name 'CurrentBuildNumber' -ErrorAction Stop)
    } catch {
        return [Environment]::OSVersion.Version.Build
    }
}

function Get-Ultimate7ZipInstallerUri {
    if (Test-UltimateArm64) {
        return 'https://github.com/ip7z/7zip/releases/download/26.03/7z2603-arm64.exe'
    }

    return 'https://github.com/FR33THYFR33THY/Ultimate/releases/download/Files/7zip.exe'
}

function Get-UltimateUnattendArchitecture {
    switch ((Get-UltimateArchitecture)) {
        'arm64' { return 'arm64' }
        'x64' { return 'amd64' }
        'x86' { return 'x86' }
        default { throw 'Unable to determine the Windows architecture for the unattended setup file.' }
    }
}

function Stop-UltimateArm64UnsupportedFeature {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Feature,
        [Parameter(Mandatory = $true)]
        [string]$Reason
    )

    if (-not (Test-UltimateArm64)) {
        return $false
    }

    Write-Host "$Feature is unavailable in this toolkit on Windows on Arm." -ForegroundColor Yellow
    Write-Host $Reason -ForegroundColor Yellow
    return $true
}
