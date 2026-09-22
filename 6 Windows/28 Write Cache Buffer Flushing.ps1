        # SCRIPT RUN AS ADMIN
        If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
        {Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
        Exit}
        $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + " (Administrator)"
        $Host.UI.RawUI.BackgroundColor = "Black"
        $Host.PrivateData.ProgressBackgroundColor = "Black"
        $Host.PrivateData.ProgressForegroundColor = "White"
        Clear-Host

. (Join-Path $PSScriptRoot '..\ui\UltimateArchitecture.ps1')

        Write-Host "If using 'NVME Faster Driver.ps1' apply that"
        Write-Host "and restart first before proceeding with this`n"
        Write-Host "1. Write Cache Buffer Flushing: Off (Recommended)"
        Write-Host "2. Write Cache Buffer Flushing: Default`n"
        while ($true) {
        $choice = Read-Host " "
        if ($choice -match '^[1-2]$') {
        switch ($choice) {
        1 {

if (Stop-UltimateArm64UnsupportedFeature -Feature 'The write-cache override' -Reason 'ARM64 devices may use OEM-managed storage and power-loss protection settings. Keep the storage policy supplied by Windows or the device manufacturer.') {
    exit
}

Clear-Host

Write-Host "Write Cache Buffer Flushing: Off..."

# turn off windows write-cache buffer flushing on the device on all connected scsi devices
$basePath = "HKLM:\SYSTEM\CurrentControlSet\Enum\SCSI"
Get-ChildItem -Path $basePath -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.PSChildName -eq "Device Parameters" } | ForEach-Object {
$diskPath = Join-Path $_.PSPath "Disk"
New-Item -Path $diskPath -Force -ErrorAction SilentlyContinue | Out-Null
New-ItemProperty -LiteralPath $diskPath -Name "CacheIsPowerProtected" -Value 1 -PropertyType DWord -Force -ErrorAction SilentlyContinue | Out-Null
}

# turn off windows write-cache buffer flushing on the device on all connected nvme devices
$basePath = "HKLM:\SYSTEM\CurrentControlSet\Enum\NVME"
Get-ChildItem -Path $basePath -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.PSChildName -eq "Device Parameters" } | ForEach-Object {
$diskPath = Join-Path $_.PSPath "Disk"
New-Item -Path $diskPath -Force -ErrorAction SilentlyContinue | Out-Null
New-ItemProperty -LiteralPath $diskPath -Name "CacheIsPowerProtected" -Value 1 -PropertyType DWord -Force -ErrorAction SilentlyContinue | Out-Null
}

exit

          }
        2 {

Clear-Host

Write-Host "Write Cache Buffer Flushing: Default..."

# revert turn off windows write-cache buffer flushing on the device on all connected scsi devices
$basePath = "HKLM:\SYSTEM\CurrentControlSet\Enum\SCSI"
Get-ChildItem -Path $basePath -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.PSChildName -eq "Disk" } | ForEach-Object {
Remove-ItemProperty -LiteralPath $_.PSPath -Name "CacheIsPowerProtected" -Force -ErrorAction SilentlyContinue
}

# revert turn off windows write-cache buffer flushing on the device on all connected nvme devices
$basePath = "HKLM:\SYSTEM\CurrentControlSet\Enum\NVME"
Get-ChildItem -Path $basePath -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.PSChildName -eq "Disk" } | ForEach-Object {
Remove-ItemProperty -LiteralPath $_.PSPath -Name "CacheIsPowerProtected" -Force -ErrorAction SilentlyContinue
}

exit

          }
        } } else { Write-Host "Invalid input. Please select a valid option (1-2)." } }
