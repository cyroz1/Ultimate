        # SCRIPT RUN AS ADMIN
        If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
        {Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
        Exit}
        $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + " (Administrator)"
        $Host.UI.RawUI.BackgroundColor = "Black"
        $Host.PrivateData.ProgressBackgroundColor = "Black"
        $Host.PrivateData.ProgressForegroundColor = "White"
        Clear-Host

        # SCRIPT CHECK INTERNET
        if (!(Test-Connection -ComputerName "8.8.8.8" -Count 1 -Quiet -ErrorAction SilentlyContinue)) {
        Write-Host "Internet Connection Required`n" -ForegroundColor Red
        Pause
        exit
        }

        # SCRIPT SILENT
        $progresspreference = 'silentlycontinue'

. (Join-Path $PSScriptRoot '..\ui\UltimateArchitecture.ps1')
$arm64Windows10 = (Test-UltimateArm64) -and ((Get-UltimateWindowsBuild) -lt 22000)
$memoryInventory = @()

if ($arm64Windows10) {
    # Use native Windows memory inventory because Windows 10 on Arm cannot run the bundled x64 CPU-Z.
    $memoryInventory = @(Get-CimInstance -ClassName Win32_PhysicalMemory |
        Select-Object DeviceLocator,
            @{Name = 'CapacityGB'; Expression = { [math]::Round($_.Capacity / 1GB, 1) }},
            Speed, Manufacturer, PartNumber)
} else {
    Write-Host "Downloading: Cpu Z..."
    if (Test-UltimateArm64) {
        $cpuZip = "$env:SystemRoot\Temp\cpuz-arm64.zip"
        $cpuFolder = "$env:SystemRoot\Temp\cpuz-arm64"
        IWR "https://download.cpuid.com/cpu-z/arm64/cpuz-arm64_1.05.zip" -OutFile $cpuZip
        Expand-Archive -Path $cpuZip -DestinationPath $cpuFolder -Force
        Start-Process (Join-Path $cpuFolder 'cpuz_arm64.exe')
    } else {
        # download cpuz
        IWR "https://github.com/FR33THYFR33THY/Ultimate/releases/download/Files/cpuz.exe" -OutFile "$env:SystemRoot\Temp\cpuz.exe"

        # start cpuz
        Start-Process "$env:SystemRoot\Temp\cpuz.exe"
    }
}

Clear-Host
Write-Host "RAM CHECK"
Write-Host "---------"
if ($arm64Windows10 -and $memoryInventory.Count -gt 0) {
Write-Host "Windows 10 on ARM64 memory inventory:`n" -ForegroundColor Yellow
$memoryInventory | Format-Table -AutoSize
Write-Host ""
}
Write-Host "- Check RAM profile is enabled"
Write-Host "- Verify RAM is in the correct slots"
Write-Host "- Confirm there is no mismatch in RAM modules"
Write-Host "- At least two RAM sticks (dual channel) is ideal`n"

Pause
