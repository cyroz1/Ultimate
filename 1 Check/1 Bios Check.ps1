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

# allow password sign in
cmd /c "reg add `"HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PasswordLess\Device`" /v `"DevicePasswordLessBuildVersion`" /t REG_DWORD /d `"0`" /f >nul 2>&1"

# ARM devices often report generic baseboard products; search the OEM model instead.
if (Test-UltimateArm64) {
    $computerSystem = Get-CimInstance Win32_ComputerSystem
    $instanceID = "$($computerSystem.Manufacturer) $($computerSystem.Model)".Trim()
    if ([string]::IsNullOrWhiteSpace($instanceID)) {
        $instanceID = (Get-CimInstance Win32_BaseBoard).Product
    }
} else {
    $instanceID = (Get-CimInstance Win32_BaseBoard).Product
}
$query = [uri]::EscapeDataString($instanceID)

# search motherboard id in web browser
Start-Process "https://www.google.com/search?q=$query"

Write-Host "BIOS CHECK"
Write-Host "----------"
Write-Host "UPDATE BIOS & OPTIMIZE SETTINGS`n"
if (Test-UltimateArm64) {
Write-Host "WINDOWS ON ARM"
Write-Host "- Follow the device manufacturer's firmware guidance"
Write-Host "- Check firmware updates and device drivers through the OEM and Windows Update"
Write-Host "- Memory is commonly soldered/shared; XMP, EXPO, PBO and desktop PCIe tuning may not apply"
Write-Host "- Keep TPM and Secure Boot enabled when required by Windows or your apps`n"
} else {
Write-Host "INTEL CPU"
Write-Host "- ENABLE ram profile (XMP DOCP EXPO)"
Write-Host "- DISABLE c-state (K CHIPS ONLY)"
Write-Host "- ENABLE resizable bar (REBAR C.A.M)`n"
Write-Host "AMD CPU"
Write-Host "- ENABLE ram profile (XMP DOCP EXPO)"
Write-Host "- ENABLE precision boost overdrive (PBO)"
Write-Host "- ENABLE resizable bar (REBAR C.A.M)`n"
Write-Host "DISABLE unused features (BT/WIFI/IGPU/ETC)`n"
Write-Host "DISABLE driver installer software"
Write-Host "- Asus armory crate"
Write-Host "- MSI driver utility"
Write-Host "- Gigabyte update utility"
Write-Host "- Asrock motherboard utility`n"
Write-Host "MAX pump and set fans to performance`n"
Write-Host "ENABLE for anticheat games"
Write-Host "- TPM"
Write-Host "- Secure boot`n"
}

Write-Host "Press Enter to Restart to BIOS" -ForegroundColor Red
Pause

# restart to bios
cmd /c C:\Windows\System32\shutdown.exe /r /fw /t 0
