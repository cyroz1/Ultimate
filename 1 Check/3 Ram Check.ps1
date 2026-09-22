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
    if ((Get-UltimateWindowsBuild) -ge 22000) {
        Write-Host "Downloading native ARM64 CPU-Z..."
        $cpuZip = "$env:SystemRoot\Temp\cpuz-arm64.zip"
        $cpuFolder = "$env:SystemRoot\Temp\cpuz-arm64"
        IWR "https://www.cpuid.com/downloads/cpu-z/arm64/cpuz-arm64_1.05.zip" -OutFile $cpuZip
        Expand-Archive -Path $cpuZip -DestinationPath $cpuFolder -Force
        Start-Process (Join-Path $cpuFolder 'cpuz.exe')
    } else {
        Write-Host "The bundled native ARM64 CPU-Z requires Windows 11. Use the device firmware or OEM diagnostics on this Windows version." -ForegroundColor Yellow
    }
} else {
    Write-Host "Downloading: Cpu Z..."
    IWR "https://github.com/FR33THYFR33THY/Ultimate/releases/download/Files/cpuz.exe" -OutFile "$env:SystemRoot\Temp\cpuz.exe"
    Start-Process "$env:SystemRoot\Temp\cpuz.exe"
}

Clear-Host
Write-Host "RAM CHECK"
Write-Host "---------"
if (Test-UltimateArm64) {
    Write-Host "- Check memory configuration and health with the device firmware or OEM tools"
    Write-Host "- Many ARM devices use soldered LPDDR or unified memory; XMP/EXPO and DIMM slot checks may not apply`n"
} else {
    Write-Host "- Check RAM profile is enabled"
    Write-Host "- Verify RAM is in the correct slots"
    Write-Host "- Confirm there is no mismatch in RAM modules"
    Write-Host "- At least two RAM sticks (dual channel) is ideal`n"
}

Pause
