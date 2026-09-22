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
    Write-Host "On ARM64, only the reset option is available. Keep driver code-integrity policy under Windows and the device manufacturer policy." -ForegroundColor Yellow
}

        Write-Host "Driver WHQL Secure Boot Bypass:"
        Write-Host "1. Off (Default)"
        Write-Host "2. On`n"
        while ($true) {
        $choice = Read-Host " "
        if ($choice -match '^[1-2]$') {
        switch ($choice) {
        1 {

Clear-Host

# revert driver whql secure boot bypass
cmd.exe /c "reg delete `"HKLM\SYSTEM\CurrentControlSet\Control\CI\Policy`" /v `"WHQLSettings`" /f >nul 2>&1"

exit

          }
        2 {

Clear-Host

if (Test-UltimateArm64) {
    Write-Host "Enabling this driver code-integrity bypass is unavailable on Windows on Arm." -ForegroundColor Yellow
    Pause
    exit
}

# driver whql secure boot bypass
cmd /c "reg add `"HKLM\SYSTEM\CurrentControlSet\Control\CI\Policy`" /v `"WHQLSettings`" /t REG_DWORD /d `"1`" /f >nul 2>&1"

exit

          }
        } } else { Write-Host "Invalid input. Please select a valid option (1-2)." } }
