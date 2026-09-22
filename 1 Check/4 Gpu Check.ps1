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

        # SCRIPT CHECK INTERNET
        if (!(Test-Connection -ComputerName "8.8.8.8" -Count 1 -Quiet -ErrorAction SilentlyContinue)) {
        Write-Host "Internet Connection Required`n" -ForegroundColor Red
        Pause
        exit
        }

        # SCRIPT SILENT
        $progresspreference = 'silentlycontinue'

if (Test-UltimateArm64) {
    Write-Host "GPU-Z supports ARM64, but this toolkit's pinned copy may predate its ARM64 support." -ForegroundColor Yellow
    Write-Host "Open the current TechPowerUp download page and use its latest release:"
    Start-Process "https://www.techpowerup.com/download/techpowerup-gpu-z/"
} else {
    Write-Host "Downloading: Gpu Z..."
    IWR "https://github.com/FR33THYFR33THY/Ultimate/releases/download/Files/gpuz.exe" -OutFile "$env:SystemRoot\Temp\gpuz.exe"
    Start-Process "$env:SystemRoot\Temp\gpuz.exe"
}

Clear-Host
Write-Host "GPU CHECK"
Write-Host "---------"
if (Test-UltimateArm64) {
    Write-Host "- Check the GPU, display driver and shared-memory details reported by GPU-Z"
    Write-Host "- PCIe slot and Resizable BAR checks only apply when the device has a discrete PCIe GPU"
    Write-Host "- Use the device manufacturer's diagnostic tools if GPU-Z cannot read an OEM-specific sensor`n"
} else {
    Write-Host "- Check Video Bus is at maximum"
    Write-Host "- Check Resizable BAR is enabled"
    Write-Host "- Verify monitor cable is connected to the GPU"
    Write-Host "- Confirm GPU is in the top PCIe motherboard slot"
    Write-Host "- Running multiple graphics cards is not recommended`n"
}

Pause
