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

Write-Host "Downloading: OCCT..."

# remove winget app from install entry to force upgrade/install/fix
try {
Start-Process "winget" -ArgumentList "uninstall --product-code OCBase.OCCT.Personal_Microsoft.Winget.Source_8wekyb3d8bbwe --silent" -Wait -WindowStyle Hidden
} catch { }

# download and install occt
try {
Start-Process "winget" -ArgumentList "install `"OCBase.OCCT.Personal`" --silent --accept-package-agreements --accept-source-agreements --disable-interactivity --no-upgrade" -Wait -WindowStyle Hidden
} catch { }

# create start menu shortcut
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:ProgramData\Microsoft\Windows\Start Menu\Programs\OCCT.lnk")
$Shortcut.TargetPath = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\OCBase.OCCT.Personal_Microsoft.Winget.Source_8wekyb3d8bbwe\OCCT.exe"
$Shortcut.WorkingDirectory = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\OCBase.OCCT.Personal_Microsoft.Winget.Source_8wekyb3d8bbwe"
$Shortcut.Save()

# create desktop shortcut
$WshShell = New-Object -comObject WScript.Shell
$Desktop = (New-Object -ComObject Shell.Application).Namespace('shell:Desktop').Self.Path
$Shortcut = $WshShell.CreateShortcut("$Desktop\OCCT.lnk")
$Shortcut.TargetPath = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\OCBase.OCCT.Personal_Microsoft.Winget.Source_8wekyb3d8bbwe\OCCT.exe"
$Shortcut.WorkingDirectory = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\OCBase.OCCT.Personal_Microsoft.Winget.Source_8wekyb3d8bbwe"
$Shortcut.Save()

# start occt
Start-Process "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\OCBase.OCCT.Personal_Microsoft.Winget.Source_8wekyb3d8bbwe\OCCT.exe"
Clear-Host

Write-Host "DRIVES"
Write-Host "- Keep drives at least 10% free"
Write-Host "- Check drive errors and device health"

# show space for all drives
Get-Volume | Where-Object {$_.DriveLetter} | Sort-Object DriveLetter | ForEach-Object {
try {
$percentRemain = ($_.SizeRemaining / $_.Size) * 100
Write-Host "$($_.DriveLetter): Free space = $($percentRemain.ToString().substring(0,4))%"
} catch {}
}
Write-Host ""

Write-Host "RAM"
Write-Host "- Check RAM profile is enabled"
Write-Host "- Verify RAM is in the correct slots"
Write-Host "- Confirm there is no mismatch in RAM modules"
Write-Host "- At least two RAM sticks (dual channel) is ideal`n"
Write-Host "GPU"
Write-Host "- Check Video Bus is at maximum"
Write-Host "- Check Resizable BAR is enabled"
Write-Host "- Verify monitor cable is connected to the GPU"
Write-Host "- Confirm GPU is in the top PCIe motherboard slot"
Write-Host "- Running multiple graphics cards is not recommended`n"
Write-Host "TEST"
Write-Host "Run a CPU, RAM & GPU stress test to check for errors"
Write-Host "Keep an eye on temps and WHEA errors during this test"
Write-Host "Errors should not be ignored as they can lead to"
Write-Host "- Stutters and hitches"
Write-Host "- Corrupted Windows"
Write-Host "- Poor performance"
Write-Host "- Corrupted files"
Write-Host "- Black screens"
Write-Host "- Blue screens"
Write-Host "- Input lag"
Write-Host "- Shutdowns`n"
Write-Host "TROUBLESHOOTING"
Write-Host "Basic troubleshooting for errors or issues"
Write-Host "- RAM overheating? Typically over 55deg. (fix case flow/ram fan)"
Write-Host "- Unlucky CPU memory controller? (lower RAM speed)"
Write-Host "- CPU overheating? (repaste/retighten/RMA cooler)"
Write-Host "- Overclock? (turn it off/dial it down)"
Write-Host "- CPU cooler over tightened? (loosen)"
Write-Host "- RAM in wrong slots? (check manual)"
Write-Host "- BIOS bugged out? (clear CMOS)"
Write-Host "- Incompatible RAM? (check QVL)"
Write-Host "- BIOS out of date? (update)"
Write-Host "- Mismatched RAM? (replace)"
Write-Host "- Faulty motherboard? (RMA)"
Write-Host "- Faulty RAM stick? (RMA)"
Write-Host "- Bent CPU pin? (RMA)"
Write-Host "- Faulty CPU? (RMA)`n"

Pause