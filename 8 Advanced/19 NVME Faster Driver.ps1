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
    Write-Host "Use the storage driver and NVMe configuration supplied by Windows Update or the device manufacturer on ARM64." -ForegroundColor Yellow
}

        Write-Host "BREAKS MICROSOFT DIRECT STORAGE" -ForegroundColor Red
        Write-Host "1. NVME: Faster Driver (Recommended)"
        Write-Host "2. NVME: Default`n"
        while ($true) {
        $choice = Read-Host " "
        if ($choice -match '^[1-2]$') {
        switch ($choice) {
        1 {

Clear-Host

if (Test-UltimateArm64) {
    Write-Host "The forced NVMe driver feature override is not validated for ARM64 device storage controllers." -ForegroundColor Yellow
    Pause
    exit
}

Write-Host "NVME: Faster Driver..."

# enable new nvme driver
cmd /c "reg add `"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Policies\Microsoft\FeatureManagement\Overrides`" /v `"735209102`" /t REG_DWORD /d `"1`" /f >nul 2>&1"
cmd /c "reg add `"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Policies\Microsoft\FeatureManagement\Overrides`" /v `"3244671118`" /t REG_DWORD /d `"1`" /f >nul 2>&1"
cmd /c "reg add `"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Policies\Microsoft\FeatureManagement\Overrides`" /v `"1853569164`" /t REG_DWORD /d `"1`" /f >nul 2>&1"
cmd /c "reg add `"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Policies\Microsoft\FeatureManagement\Overrides`" /v `"156965516`" /t REG_DWORD /d `"1`" /f >nul 2>&1"

# enable safe & safe network boot fix for new nvme driver
cmd /c "reg add `"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SafeBoot\Network\{75416E63-5912-4DFA-AE8F-3EFACCAFFB14}`" /ve /d `"Storage disks`" /f >nul 2>&1"
cmd /c "reg add `"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SafeBoot\Minimal\{75416E63-5912-4DFA-AE8F-3EFACCAFFB14}`" /ve /d `"Storage disks`" /f >nul 2>&1"

exit

          }
        2 {

Clear-Host

Write-Host "NVME: Default..."

# revert new nvme driver
$overridePath = "HKLM:\SYSTEM\CurrentControlSet\Policies\Microsoft\FeatureManagement\Overrides"
foreach ($featureId in @("735209102", "3244671118", "1853569164", "156965516")) {
    Remove-ItemProperty -LiteralPath $overridePath -Name $featureId -ErrorAction SilentlyContinue
}

# revert safe & safe network boot fix for new nvme driver
cmd /c "reg delete `"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SafeBoot\Network\{75416E63-5912-4DFA-AE8F-3EFACCAFFB14}`" /f >nul 2>&1"
cmd /c "reg delete `"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SafeBoot\Minimal\{75416E63-5912-4DFA-AE8F-3EFACCAFFB14}`" /f >nul 2>&1"

exit

          }
        } } else { Write-Host "Invalid input. Please select a valid option (1-2)." } }
