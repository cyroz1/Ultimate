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
if ((Test-UltimateArm64) -and (Get-UltimateWindowsBuild) -lt 22000) {
    Write-Host "The bundled controller test is not validated as an x86 app for Windows 10 on Arm. Use device-native or browser-based input diagnostics." -ForegroundColor Yellow
    Pause
    exit
}
if (Test-UltimateArm64) {
    Write-Host "The bundled controller test build is not ARM64-native. Treat high-rate timing results as indicative." -ForegroundColor Yellow
}

        # SCRIPT CHECK INTERNET
        if (!(Test-Connection -ComputerName "8.8.8.8" -Count 1 -Quiet -ErrorAction SilentlyContinue)) {
        Write-Host "Internet Connection Required`n" -ForegroundColor Red
        Pause
        exit
        }

        # SCRIPT SILENT
        $progresspreference = 'silentlycontinue'

Write-Host "Installing: Polling..."

# new folder
New-Item -Path "$env:SystemDrive\Program Files (x86)\Polling" -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null

# download gamepadla
IWR "https://github.com/FR33THYFR33THY/Ultimate/releases/download/Files/polling.exe" -OutFile "$env:SystemDrive\Program Files (x86)\Polling\Polling.exe"

# create desktop shortcut
$WshShell = New-Object -comObject WScript.Shell
$Desktop = (New-Object -ComObject Shell.Application).Namespace('shell:Desktop').Self.Path
$Shortcut = $WshShell.CreateShortcut("$Desktop\Polling.lnk")
$Shortcut.TargetPath = "$env:SystemDrive\Program Files (x86)\Polling\Polling.exe"
$Shortcut.WorkingDirectory = "$env:SystemDrive\Program Files (x86)\Polling"
$Shortcut.Save()

# create start menu shortcut
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Polling.lnk")
$Shortcut.TargetPath = "$env:SystemDrive\Program Files (x86)\Polling\Polling.exe"
$Shortcut.WorkingDirectory = "$env:SystemDrive\Program Files (x86)\Polling"
$Shortcut.Save()

# open gamepadla
Start-Process "$env:SystemDrive\Program Files (x86)\Polling\Polling.exe"
