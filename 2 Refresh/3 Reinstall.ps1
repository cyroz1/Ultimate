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

        Write-Host "1. Reinstall: W10"
        Write-Host "2. Reinstall: W11`n"
        while ($true) {
        $choice = Read-Host " "
        if ($choice -match '^[1-2]$') {
        switch ($choice) {
        1 {

Clear-Host

Write-Host "Downloading: Media Creation Tool Win 10..."

# remove winget app from install entry to force upgrade/install/fix
try {
Start-Process "winget" -ArgumentList "uninstall --product-code Microsoft.MediaCreationTool.Windows10_Microsoft.Winget.Source_8wekyb3d8bbwe --silent" -Wait -WindowStyle Hidden
} catch { }

# download media creation tool win 10
try {
Start-Process "winget" -ArgumentList "install `"Microsoft.MediaCreationTool.Windows10`" --silent --accept-package-agreements --accept-source-agreements --disable-interactivity --no-upgrade" -Wait -WindowStyle Hidden
} catch { }

# start media creation tool win 10
Start-Process "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\Microsoft.MediaCreationTool.Windows10_Microsoft.Winget.Source_8wekyb3d8bbwe\MediaCreationTool10.exe"

exit

          }
        2 {

Clear-Host

Write-Host "Downloading: Media Creation Tool Win 11..."

# remove winget app from install entry to force upgrade/install/fix
try {
Start-Process "winget" -ArgumentList "uninstall --product-code Microsoft.MediaCreationTool_Microsoft.Winget.Source_8wekyb3d8bbwe --silent" -Wait -WindowStyle Hidden
} catch { }

# download media creation tool win 11
try {
Start-Process "winget" -ArgumentList "install `"Microsoft.MediaCreationTool`" --silent --accept-package-agreements --accept-source-agreements --disable-interactivity --no-upgrade" -Wait -WindowStyle Hidden
} catch { }

# start media creation tool win 11
Start-Process "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\Microsoft.MediaCreationTool_Microsoft.Winget.Source_8wekyb3d8bbwe\MediaCreationTool.exe"

exit

          }
        } } else { Write-Host "Invalid input. Please select a valid option (1-2)." } }