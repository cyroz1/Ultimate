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
    Write-Host "The bundled FurMark program is an x64 build; this script does not assume it can stress every ARM64 GPU driver correctly." -ForegroundColor Yellow
    Write-Host "Use your device manufacturer's ARM64 graphics diagnostics for GPU stress testing."
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

Write-Host "Downloading: FurMark..."

# download furmark
IWR "https://github.com/FR33THYFR33THY/Ultimate/releases/download/Files/furmark.zip" -OutFile "$env:SystemRoot\Temp\furmark.zip"

# extract files
Expand-Archive "$env:SystemRoot\Temp\furmark.zip" -DestinationPath "$env:SystemRoot\Temp\furmark" -ErrorAction SilentlyContinue

# start furmark
Start-Process "$env:SystemRoot\Temp\furmark\FurMark_win64\FurMark_GUI.exe"

Clear-Host
Write-Host "GPU TEST"
Write-Host "--------"
Write-Host "Run GPU stress test`n"
Write-Host "TROUBLESHOOTING"
Write-Host "---------------"
Write-Host "Basic troubleshooting items to monitor"
Write-Host "- Temps"
Write-Host "- Framerate"
Write-Host "- Artifacts"
Write-Host "- Freezing"
Write-Host "- Driver crashes"
Write-Host "- Shutdowns"
Write-Host "- Blue screens`n"
Write-Host "GPU BENCH"
Write-Host "---------"
Write-Host "Run a GPU benchmark"
Write-Host "- Compare results"
Write-Host "- Confirm GPU is performing optimally`n"

Pause
