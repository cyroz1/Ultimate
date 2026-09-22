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

if (Test-UltimateArm64) {
    Write-Host "Windows Media Creation Tool does not create Arm64 bootable media." -ForegroundColor Yellow
    Write-Host "For this device, use its manufacturer recovery image or download the Windows 11 Arm64 ISO." -ForegroundColor Yellow
    Start-Process "https://www.microsoft.com/software-download/windows11arm64"
    Pause
    exit
}

        # SCRIPT CHECK INTERNET
        if (!(Test-Connection -ComputerName "8.8.8.8" -Count 1 -Quiet -ErrorAction SilentlyContinue)) {
        Write-Host "Internet Connection Required`n" -ForegroundColor Red
        Pause
        exit
        }

        # SCRIPT SILENT
        $progresspreference = 'silentlycontinue'

        Write-Host "1. Reinstall: W10"
        Write-Host "2. Reinstall: W11`n"
        while ($true) {
        $choice = Read-Host " "
        if ($choice -match '^[1-2]$') {
        switch ($choice) {
        1 {

Clear-Host

Write-Host "Downloading: Media Creation Tool Win 10..."

# download media creation tool win 10
IWR "https://github.com/FR33THYFR33THY/Ultimate/releases/download/Files/mediacreationtoolw10.exe" -OutFile "$env:SystemRoot\Temp\mediacreationtoolw10.exe"

# start media creation tool win 10
Start-Process "$env:SystemRoot\Temp\mediacreationtoolw10.exe"

exit

          }
        2 {

Clear-Host

Write-Host "Downloading: Media Creation Tool Win 11..."

# download media creation tool win 11
IWR "https://github.com/FR33THYFR33THY/Ultimate/releases/download/Files/mediacreationtoolw11.exe" -OutFile "$env:SystemRoot\Temp\mediacreationtoolw11.exe"

# start media creation tool win 11
Start-Process "$env:SystemRoot\Temp\mediacreationtoolw11.exe"

exit

          }
        } } else { Write-Host "Invalid input. Please select a valid option (1-2)." } }
