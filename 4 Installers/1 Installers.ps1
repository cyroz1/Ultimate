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

        function show-menu {
	    Clear-Host
	    Write-Host "Game launchers, programs and web browsers"
		Write-Host "- Turn off cloud config/cloud sync"
        Write-Host "- Disable hardware acceleration"
        Write-Host "- Turn off running at startup"
        Write-Host "- Deactivate overlays`n"
        Write-Host "Lower GPU usage and higher framerates reduce latency"
        Write-Host "Optimize your game settings to achieve this"
        Write-Host "Further tuning can be done via config files or launch options`n"
        Write-Host " 1. 7-Zip"
	    Write-Host " 2. Battle.net"
	    Write-Host " 3. Brave"
        Write-Host " 4. Custom Resolution Utility"
        Write-Host " 5. Discord"
        Write-Host " 6. Electronic Arts"
        Write-Host " 7. Epic Games"
        Write-Host " 8. Escape From Tarkov"
        Write-Host " 9. Firefox"
        Write-Host "10. Frame View"
        Write-Host "11. GOG launcher"		
        Write-Host "12. Google Chrome"
        Write-Host "13. Helium"
        Write-Host "14. League Of Legends"
        Write-Host "15. More Clock Tool"
        Write-Host "16. Notepad ++"
        Write-Host "17. Nvidia App"
        Write-Host "18. Nvidia Profile Inspector"
		Write-Host "19. OBS Studio"		
        Write-Host "20. Onboard Memory Manager"
        Write-Host "21. Pot Player"
        Write-Host "22. Roblox"
        Write-Host "23. Rockstar Games"
        Write-Host "24. Spotify"
		Write-Host "25. Steam"
		Write-Host "26. Ubisoft Connect"
		Write-Host "27. Valorant"
		Write-Host "28. Exit`n"
	                  }
	    show-menu
        while ($true) {
        $choice = Read-Host " "
        if ($choice -match '^(2[0-8]|1[0-9]|[1-9])$') {

        switch ($choice) {
        1 {

Clear-Host

Write-Host "Installing: 7Zip..."

# download and install 7-zip
try {
Start-Process "winget" -ArgumentList "install `"7zip.7zip`" --silent --accept-package-agreements --accept-source-agreements --disable-interactivity --no-upgrade" -Wait -WindowStyle Hidden
} catch { }

# set config for 7zip
cmd /c "reg add `"HKEY_CURRENT_USER\Software\7-Zip\Options`" /v `"ContextMenu`" /t REG_DWORD /d `"259`" /f >nul 2>&1"
cmd /c "reg add `"HKEY_CURRENT_USER\Software\7-Zip\Options`" /v `"CascadedMenu`" /t REG_DWORD /d `"0`" /f >nul 2>&1"

# cleaner start menu shortcut path
Move-Item -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\7-Zip\7-Zip File Manager.lnk" -Destination "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" -Force -ErrorAction SilentlyContinue | Out-Null
Remove-Item "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\7-Zip" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null

# create desktop shortcut
$WshShell = New-Object -comObject WScript.Shell
$Desktop = (New-Object -ComObject Shell.Application).Namespace('shell:Desktop').Self.Path
$Shortcut = $WshShell.CreateShortcut("$Desktop\7-Zip File Manager.lnk")
$Shortcut.TargetPath = "$env:SystemDrive\Program Files\7-Zip\7zFM.exe"
$Shortcut.WorkingDirectory = "$env:SystemDrive\Program Files\7-Zip"
$Shortcut.Save()

show-menu

          }
        2 {

Clear-Host

Write-Host "Installing: Battle.net..."

# download and install battle.net
try {
Start-Process "winget" -ArgumentList "install `"Blizzard.BattleNet`" --silent --accept-package-agreements --accept-source-agreements --disable-interactivity --no-upgrade --location `"$env:SystemDrive\Program Files (x86)\Battle.net`"" -Wait -WindowStyle Hidden
} catch { }

Start-Sleep -Seconds 10

Get-Process -Name "getinstaller" -ErrorAction SilentlyContinue | Wait-Process -ErrorAction SilentlyContinue

# remove logon battle.net
cmd /c "reg delete `"HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run`" /v `"Battle.net`" /f >nul 2>&1"
cmd /c "reg delete `"HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run`" /v `"Battle.net`" /f >nul 2>&1"

# cleaner start menu shortcut path
Remove-Item "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Battle.net" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null

# create desktop shortcut
$WshShell = New-Object -comObject WScript.Shell
$Desktop = (New-Object -ComObject Shell.Application).Namespace('shell:Desktop').Self.Path
$Shortcut = $WshShell.CreateShortcut("$Desktop\Battle.net.lnk")
$Shortcut.TargetPath = "$env:SystemDrive\Program Files (x86)\Battle.net\Battle.net Launcher.exe"
$Shortcut.WorkingDirectory = "$env:SystemDrive\Program Files (x86)\Battle.net"
$Shortcut.Save()

# create start menu shortcut
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Battle.net.lnk")
$Shortcut.TargetPath = "$env:SystemDrive\Program Files (x86)\Battle.net\Battle.net Launcher.exe"
$Shortcut.WorkingDirectory = "$env:SystemDrive\Program Files (x86)\Battle.net"
$Shortcut.Save()

show-menu

          }
        3 {

Clear-Host

Write-Host "Installing: Brave..."

# download and install brave
try {
Start-Process "winget" -ArgumentList "install `"Brave.Brave`" --silent --accept-package-agreements --accept-source-agreements --disable-interactivity --no-upgrade" -Wait -WindowStyle Hidden
} catch { }

# install ublock origin
cmd /c "reg add `"HKLM\SOFTWARE\Policies\BraveSoftware\Brave\ExtensionInstallForcelist`" /v `"1`" /t REG_SZ /d `"ddkjiahejlhfcafbddmgiahcphecmpfh;https://clients2.google.com/service/update2/crx`" /f >nul 2>&1"

# add brave policies
cmd /c "reg add `"HKLM\SOFTWARE\Policies\BraveSoftware\Brave`" /v `"HardwareAccelerationModeEnabled`" /t REG_DWORD /d `"0`" /f >nul 2>&1"
cmd /c "reg add `"HKLM\SOFTWARE\Policies\BraveSoftware\Brave`" /v `"BackgroundModeEnabled`" /t REG_DWORD /d `"0`" /f >nul 2>&1"
cmd /c "reg add `"HKLM\SOFTWARE\Policies\BraveSoftware\Brave`" /v `"HighEfficiencyModeEnabled`" /t REG_DWORD /d `"1`" /f >nul 2>&1"

# remove logon brave
$basePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
Get-Item $basePath | ForEach-Object {
foreach ($valueName in $_.GetValueNames()) {
if ($valueName -like "*Brave*") {
Remove-ItemProperty -Path $_.PsPath -Name $valueName -Force -ErrorAction SilentlyContinue
}
}
}

# remove brave services
$services = Get-Service | Where-Object { $_.Name -match 'Brave' }
foreach ($service in $services) {
cmd /c "sc stop `"$($service.Name)`" >nul 2>&1"
cmd /c "sc delete `"$($service.Name)`" >nul 2>&1"
}

# remove brave scheduled tasks
Get-ScheduledTask | Where-Object { $_.TaskName -like '*Brave*' } | Unregister-ScheduledTask -Confirm:$false -ErrorAction SilentlyContinue

# cleaner start menu shortcut path
Move-Item -Path "$env:AppData\Microsoft\Windows\Start Menu\Programs\Brave.lnk" -Destination "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" -Force -ErrorAction SilentlyContinue | Out-Null

show-menu

          }
        4 {

Clear-Host

Write-Host "Installing: Custom Resolution Utility..."

# download custom resolution utility
IWR "https://www.monitortests.com/download/cru/cru-1.5.3.zip" -OutFile "$env:SystemRoot\Temp\cru.zip"

# extract file
Expand-Archive -Path "$env:SystemRoot\Temp\cru.zip" -DestinationPath "$env:SystemDrive\Program Files (x86)\CRUSRE" -Force

# download scaled resolution editor
IWR "https://www.monitortests.com/download/sre/sre-1.0.zip" -OutFile "$env:SystemRoot\Temp\sre.zip"

# extract file
Expand-Archive -Path "$env:SystemRoot\Temp\sre.zip" -DestinationPath "$env:SystemDrive\Program Files (x86)\CRUSRE" -Force

# create desktop shortcut
$WshShell = New-Object -comObject WScript.Shell
$Desktop = (New-Object -ComObject Shell.Application).Namespace('shell:Desktop').Self.Path
$Shortcut = $WshShell.CreateShortcut("$Desktop\Custom Resolution Utility.lnk")
$Shortcut.TargetPath = "$env:SystemDrive\Program Files (x86)\CRUSRE\CRU.exe"
$Shortcut.WorkingDirectory = "$env:SystemDrive\Program Files (x86)\CRUSRE"
$Shortcut.Save()

# create start menu shortcut
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Custom Resolution Utility.lnk")
$Shortcut.TargetPath = "$env:SystemDrive\Program Files (x86)\CRUSRE\CRU.exe"
$Shortcut.WorkingDirectory = "$env:SystemDrive\Program Files (x86)\CRUSRE"
$Shortcut.Save()

# create desktop shortcut
$WshShell = New-Object -comObject WScript.Shell
$Desktop = (New-Object -ComObject Shell.Application).Namespace('shell:Desktop').Self.Path
$Shortcut = $WshShell.CreateShortcut("$Desktop\Scaled Resolution Editor.lnk")
$Shortcut.TargetPath = "$env:SystemDrive\Program Files (x86)\CRUSRE\SRE.exe"
$Shortcut.WorkingDirectory = "$env:SystemDrive\Program Files (x86)\CRUSRE"
$Shortcut.Save()

# create start menu shortcut
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Scaled Resolution Editor.lnk")
$Shortcut.TargetPath = "$env:SystemDrive\Program Files (x86)\CRUSRE\SRE.exe"
$Shortcut.WorkingDirectory = "$env:SystemDrive\Program Files (x86)\CRUSRE"
$Shortcut.Save()

show-menu

          }
        5 {

Clear-Host

Write-Host "Installing: Discord..."

# set config for discord
New-Item -Path "$env:APPDATA\discord\settings.json" -ItemType File -Force | Out-Null
$DiscordSettings = @'
{
    "SKIP_HOST_UPDATE": true,
    "DEVELOPER_MODE": true,
    "enableHardwareAcceleration": false,
    "MINIMIZE_TO_TRAY": true,
    "OPEN_ON_STARTUP": false,
    "START_MINIMIZED": false,
    "IS_MAXIMIZED": true,
    "IS_MINIMIZED": false,
    "debugLogging": false
}
'@
Set-Content -Path "$env:APPDATA\discord\settings.json" -Value $DiscordSettings -Force | Out-Null

# download and install discord
try {
Start-Process "winget" -ArgumentList "install `"Discord.Discord`" --silent --accept-package-agreements --accept-source-agreements --disable-interactivity --no-upgrade" -Wait -WindowStyle Hidden
} catch { }

Start-Sleep -Seconds 10

Get-Process -Name "Update" -ErrorAction SilentlyContinue | Wait-Process -ErrorAction SilentlyContinue

# remove logon discord
cmd /c "reg delete `"HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run`" /v `"Discord`" /f >nul 2>&1"
cmd /c "reg delete `"HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run`" /v `"Discord`" /f >nul 2>&1"

# cleaner start menu shortcut path
Move-Item -Path "$env:AppData\Microsoft\Windows\Start Menu\Programs\Discord.lnk" -Destination "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" -Force -ErrorAction SilentlyContinue | Out-Null
Remove-Item "$env:AppData\Microsoft\Windows\Start Menu\Programs\Discord Inc" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null

show-menu

          }
        6 {

Clear-Host

Write-Host "Installing: Electronic Arts..."

# download and install electronic arts
try {
Start-Process "winget" -ArgumentList "install `"ElectronicArts.EADesktop`" --silent --accept-package-agreements --accept-source-agreements --disable-interactivity --no-upgrade" -Wait -WindowStyle Hidden
} catch { }

Start-Sleep -Seconds 10

Get-Process -Name "EAappInstaller" -ErrorAction SilentlyContinue | Wait-Process -ErrorAction SilentlyContinue

# remove logon electronic arts
cmd /c "reg delete `"HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run`" /v `"EADM`" /f >nul 2>&1"
cmd /c "reg delete `"HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run`" /v `"EADM`" /f >nul 2>&1"

# cleaner start menu shortcut path
Move-Item -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\EA\EA.lnk" -Destination "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" -Force -ErrorAction SilentlyContinue | Out-Null
Remove-Item "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\EA" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null

show-menu

          }
        7 {

Clear-Host

Write-Host "Installing: Epic Games..."

# download and install epic games
try {
Start-Process "winget" -ArgumentList "install `"EpicGames.EpicGamesLauncher`" --silent --accept-package-agreements --accept-source-agreements --disable-interactivity --no-upgrade" -Wait -WindowStyle Hidden
} catch { }

# remove logon epic games
cmd /c "reg delete `"HKCU\Software\Microsoft\Windows\CurrentVersion\Run`" /v `"EpicGamesLauncher`" /f >nul 2>&1"

show-menu

          }
        8 {

Clear-Host

Write-Host "Installing: Escape From Tarkov..."

# download escape from tarkov
IWR "https://launcher.escapefromtarkov.com/launcher/download" -OutFile "$env:SystemRoot\Temp\Escape From Tarkov.exe"

# install escape from tarkov
Start-Process -Wait "$env:SystemRoot\Temp\Escape From Tarkov.exe" -ArgumentList "/VERYSILENT /NORESTART"

# create desktop shortcut
$WshShell = New-Object -comObject WScript.Shell
$Desktop = (New-Object -ComObject Shell.Application).Namespace('shell:Desktop').Self.Path
$Shortcut = $WshShell.CreateShortcut("$Desktop\Battlestate Games Launcher.lnk")
$Shortcut.TargetPath = "$env:SystemDrive\Battlestate Games\BsgLauncher\BsgLauncher.exe"
$Shortcut.WorkingDirectory = "$env:SystemDrive\Battlestate Games\BsgLauncher"
$Shortcut.Save()

# cleaner start menu shortcut path
Move-Item -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Battlestate Games\Battlestate Games Launcher.lnk" -Destination "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" -Force -ErrorAction SilentlyContinue | Out-Null
Remove-Item "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Battlestate Games" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null

show-menu

          }
        9 {

Clear-Host

Write-Host "Installing: Firefox..."

# download and install firefox
try {
Start-Process "winget" -ArgumentList "install `"Mozilla.Firefox`" --silent --accept-package-agreements --accept-source-agreements --disable-interactivity --no-upgrade" -Wait -WindowStyle Hidden
} catch { }

# uninstall mozilla maintenance service
Start-Process -FilePath "C:\Program Files (x86)\Mozilla Maintenance Service\uninstall.exe" -ArgumentList "/S" -WindowStyle Hidden -Wait

# remove firefox scheduled tasks
Get-ScheduledTask | Where-Object {$_.Taskname -match 'Firefox'} | Unregister-ScheduledTask -Confirm:$false -ErrorAction SilentlyContinue

# install ublock origin
$uBlockDir = "C:\Program Files\Mozilla Firefox\distribution\extensions"
If (!(Test-Path $ublockDir)) { New-Item -ItemType Directory -Path $ublockDir -Force | Out-Null }
IWR "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi" -OutFile "$uBlockDir\uBlock0@raymondhill.net.xpi"

# disable firefox updates
cmd /c "reg add `"HKLM\SOFTWARE\Policies\Mozilla\Firefox`" /v `"AppAutoUpdate`" /t REG_DWORD /d `"0`" /f >nul 2>&1"

# start and close firefox hidden to create profiles folder
Start-Process -FilePath "$env:SystemDrive\Program Files\Mozilla Firefox\firefox.exe" -ArgumentList "--headless"
Start-Sleep -Seconds 5
Stop-Process -Name "firefox" -Force -ErrorAction SilentlyContinue

# disable firefox hardware acceleration
$JsFile = @'
user_pref("layers.acceleration.disabled", true);
user_pref("gfx.direct2d.disabled", true);
'@
$FireFoxProfile = Get-ChildItem "$env:APPDATA\Mozilla\Firefox\Profiles" -Directory | Where-Object { $_.Name -match '\.default-release$' } | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($FireFoxProfile) {
[System.IO.File]::WriteAllText("$($FireFoxProfile.FullName)\user.js", $JsFile, [System.Text.UTF8Encoding]::new($false))
}

# remove logon firefox
$basePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
Get-Item $basePath | ForEach-Object {
foreach ($valueName in $_.GetValueNames()) {
if ($valueName -like "*Firefox*") {
Remove-ItemProperty -Path $_.PsPath -Name $valueName -Force -ErrorAction SilentlyContinue
}
}
}

# cleaner start menu shortcut path
Remove-Item "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Firefox Private Browsing.lnk" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
Remove-Item "$env:AppData\Microsoft\Windows\Start Menu\Programs\Firefox.lnk" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null

show-menu

          }
       10 {

Clear-Host

Write-Host "Installing: Frame View..."

# download and install frameview
try {
Start-Process "winget" -ArgumentList "install `"Nvidia.FrameView`" --silent --accept-package-agreements --accept-source-agreements --disable-interactivity --no-upgrade" -Wait -WindowStyle Hidden
} catch { }

# cleaner start menu shortcut path
Move-Item -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\NVIDIA FrameView\FrameView.lnk" -Destination "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" -Force -ErrorAction SilentlyContinue | Out-Null
Remove-Item "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\NVIDIA FrameView" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null

show-menu

          }
       11 {

Clear-Host

Write-Host "Installing: GOG launcher..."

# download and install gog launcher
try {
Start-Process "winget" -ArgumentList "install `"GOG.Galaxy`" --silent --accept-package-agreements --accept-source-agreements --disable-interactivity --no-upgrade" -Wait -WindowStyle Hidden
} catch { }

# remove logon gog launcher
cmd /c "reg delete `"HKCU\Software\Microsoft\Windows\CurrentVersion\Run`" /v `"GalaxyClient`" /f >nul 2>&1"
cmd /c "reg delete `"HKCU\Software\Microsoft\Windows\CurrentVersion\Run`" /v `"GogGalaxy`" /f >nul 2>&1"

# cleaner start menu shortcut path
Move-Item -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\GOG.com\GOG GALAXY\GOG GALAXY.lnk" -Destination "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" -Force -ErrorAction SilentlyContinue | Out-Null
Remove-Item "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\GOG.com" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null

show-menu

          }
       12 {

Clear-Host

Write-Host "Installing: Google Chrome..."

# download and install google chrome
try {
Start-Process "winget" -ArgumentList "install `"Google.Chrome`" --silent --accept-package-agreements --accept-source-agreements --disable-interactivity --no-upgrade" -Wait -WindowStyle Hidden
} catch { }

# install ublock origin lite
cmd /c "reg add `"HKLM\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist`" /v `"1`" /t REG_SZ /d `"ddkjiahejlhfcafbddmgiahcphecmpfh;https://clients2.google.com/service/update2/crx`" /f >nul 2>&1"

# add chrome policies
cmd /c "reg add `"HKLM\SOFTWARE\Policies\Google\Chrome`" /v `"HardwareAccelerationModeEnabled`" /t REG_DWORD /d `"0`" /f >nul 2>&1"
cmd /c "reg add `"HKLM\SOFTWARE\Policies\Google\Chrome`" /v `"BackgroundModeEnabled`" /t REG_DWORD /d `"0`" /f >nul 2>&1"
cmd /c "reg add `"HKLM\SOFTWARE\Policies\Google\Chrome`" /v `"HighEfficiencyModeEnabled`" /t REG_DWORD /d `"1`" /f >nul 2>&1"

# remove logon chrome
$basePath = "HKLM:\Software\Microsoft\Active Setup\Installed Components"
Get-ChildItem $basePath | ForEach-Object {
$val = (Get-ItemProperty $_.PsPath)."(default)"
if ($val -like "*Chrome*") {
Remove-Item $_.PsPath -Force -ErrorAction SilentlyContinue
}
}

# remove chrome services
$services = Get-Service | Where-Object { $_.Name -match 'Google' }
foreach ($service in $services) {
cmd /c "sc stop `"$($service.Name)`" >nul 2>&1"
cmd /c "sc delete `"$($service.Name)`" >nul 2>&1"
}

# remove chrome scheduled tasks
Get-ScheduledTask | Where-Object { $_.TaskName -like '*Google*' } | Unregister-ScheduledTask -Confirm:$false -ErrorAction SilentlyContinue

show-menu

          }
       13 {

Clear-Host

Write-Host "Installing: Helium..."

# download and install helium
try {
Start-Process "winget" -ArgumentList "install `"ImputNet.Helium`" --silent --accept-package-agreements --accept-source-agreements --disable-interactivity --no-upgrade" -Wait -WindowStyle Hidden
} catch { }

# add helium policies
cmd /c "reg add `"HKLM\SOFTWARE\Policies\Helium`" /v `"HardwareAccelerationModeEnabled`" /t REG_DWORD /d `"0`" /f >nul 2>&1"
cmd /c "reg add `"HKLM\SOFTWARE\Policies\Helium`" /v `"BackgroundModeEnabled`" /t REG_DWORD /d `"0`" /f >nul 2>&1"
cmd /c "reg add `"HKLM\SOFTWARE\Policies\Helium`" /v `"HighEfficiencyModeEnabled`" /t REG_DWORD /d `"1`" /f >nul 2>&1"

# remove logon helium
$basePath = "HKLM:\Software\Microsoft\Active Setup\Installed Components"
Get-ChildItem $basePath | ForEach-Object {
$val = (Get-ItemProperty $_.PsPath)."(default)"
if ($val -like "*Helium*") {
Remove-Item $_.PsPath -Force -ErrorAction SilentlyContinue
}
}

# remove helium services
$services = Get-Service | Where-Object { $_.Name -match 'Helium' }
foreach ($service in $services) {
cmd /c "sc stop `"$($service.Name)`" >nul 2>&1"
cmd /c "sc delete `"$($service.Name)`" >nul 2>&1"
}

# remove helium scheduled tasks
Get-ScheduledTask | Where-Object { $_.TaskName -like '*Helium*' } | Unregister-ScheduledTask -Confirm:$false -ErrorAction SilentlyContinue

# cleaner start menu shortcut path
Move-Item -Path "$env:AppData\Microsoft\Windows\Start Menu\Programs\Helium.lnk" -Destination "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" -Force -ErrorAction SilentlyContinue | Out-Null

show-menu

          }
       14 {

Clear-Host

Write-Host "Installing: League Of Legends..."

# download and install league of legends
try {
Start-Process "winget" -ArgumentList "install `"RiotGames.LeagueOfLegends.NA`" --silent --accept-package-agreements --accept-source-agreements --disable-interactivity --no-upgrade" -Wait -WindowStyle Hidden
} catch { }

# remove logon league of legends
cmd /c "reg delete `"HKCU\Software\Microsoft\Windows\CurrentVersion\Run`" /v `"RiotClient`" /f >nul 2>&1"

# cleaner start menu shortcut path
Move-Item -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Riot Games\*" -Destination "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" -Force -ErrorAction SilentlyContinue | Out-Null
Remove-Item "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Riot Games" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
Remove-Item "$env:AppData\Microsoft\Windows\Start Menu\Programs\Riot Games" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null

show-menu

          }
       15 {

Clear-Host

Write-Host "Installing: More Clock Tool..."

# download more clock tool
curl.exe -s -L -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" "https://www.igorslab.de/installer/MoreClockTool_v1111_2.zip" -o "$env:SystemRoot\Temp\mct.zip"

# extract file
Expand-Archive -Path "$env:SystemRoot\Temp\mct.zip" -DestinationPath "$env:SystemDrive\Program Files (x86)\More Clock Tool" -Force

# create desktop shortcut
$WshShell = New-Object -comObject WScript.Shell
$Desktop = (New-Object -ComObject Shell.Application).Namespace('shell:Desktop').Self.Path
$Shortcut = $WshShell.CreateShortcut("$Desktop\More Clock Tool.lnk")
$Shortcut.TargetPath = "$env:SystemDrive\Program Files (x86)\More Clock Tool\MoreClockTool.exe"
$Shortcut.WorkingDirectory = "$env:SystemDrive\Program Files (x86)\More Clock Tool"
$Shortcut.Save()

# create start menu shortcut
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:ProgramData\Microsoft\Windows\Start Menu\Programs\More Clock Tool.lnk")
$Shortcut.TargetPath = "$env:SystemDrive\Program Files (x86)\More Clock Tool\MoreClockTool.exe"
$Shortcut.WorkingDirectory = "$env:SystemDrive\Program Files (x86)\More Clock Tool"
$Shortcut.Save()

show-menu

          }
       16 {

Clear-Host

Write-Host "Installing: Notepad ++..."

# download and install notepad++
try {
Start-Process "winget" -ArgumentList "install `"Notepad++.Notepad++`" --silent --accept-package-agreements --accept-source-agreements --disable-interactivity --no-upgrade" -Wait -WindowStyle Hidden
} catch { }

# new notepad++ folder
New-Item -Path "$env:AppData" -Name "Notepad++" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

# create config for notepad ++
$NotePadConfig = @'
<?xml version="1.0" encoding="UTF-8" ?>
<NotepadPlus>
    <ProjectPanels>
        <ProjectPanel id="0" workSpaceFile="" />
        <ProjectPanel id="1" workSpaceFile="" />
        <ProjectPanel id="2" workSpaceFile="" />
    </ProjectPanels>
    <ColumnEditor choice="number">
        <text content="" />
        <number initial="-1" increase="-1" repeat="-1" formatChoice="dec" leadingChoice="none" />
    </ColumnEditor>
    <GUIConfigs>
        <GUIConfig name="ToolBar" visible="yes" fluentColor="0" fluentCustomColor="16229943" fluentMono="no">small</GUIConfig>
        <GUIConfig name="StatusBar">show</GUIConfig>
        <GUIConfig name="TabBar" dragAndDrop="yes" drawTopBar="yes" drawInactiveTab="yes" reduce="yes" closeButton="yes" pinButton="yes" showOnlyPinnedButton="no" buttonsOninactiveTabs="no" doubleClick2Close="no" vertical="no" multiLine="no" hide="no" quitOnEmpty="no" iconSetNumber="0" tabCompactLabelLen="0" />
        <GUIConfig name="ScintillaViewsSplitter">vertical</GUIConfig>
        <GUIConfig name="UserDefineDlg" position="undocked">hide</GUIConfig>
        <GUIConfig name="TabSetting" replaceBySpace="no" size="4" backspaceUnindent="no" />
        <GUIConfig name="AppPosition" x="0" y="0" width="1024" height="700" isMaximized="no" />
        <GUIConfig name="FindWindowPosition" left="0" top="0" right="0" bottom="0" isLessModeOn="no" />
        <GUIConfig name="FinderConfig" wrappedLines="no" purgeBeforeEverySearch="no" showOnlyOneEntryPerFoundLine="yes" />
        <GUIConfig name="noUpdate" intervalDays="15" nextUpdateDate="20260401" autoUpdateMode="0">yes</GUIConfig>
        <GUIConfig name="Auto-detection">yes</GUIConfig>
        <GUIConfig name="CheckHistoryFiles">no</GUIConfig>
        <GUIConfig name="TrayIcon">0</GUIConfig>
        <GUIConfig name="MaintainIndent">1</GUIConfig>
        <GUIConfig name="TagsMatchHighLight" TagAttrHighLight="yes" HighLightNonHtmlZone="no">yes</GUIConfig>
        <GUIConfig name="RememberLastSession">no</GUIConfig>
        <GUIConfig name="KeepSessionAbsentFileEntries">no</GUIConfig>
        <GUIConfig name="DetectEncoding">yes</GUIConfig>
        <GUIConfig name="SaveAllConfirm">yes</GUIConfig>
        <GUIConfig name="NewDocDefaultSettings" format="0" encoding="4" lang="0" codepage="-1" openAnsiAsUTF8="yes" addNewDocumentOnStartup="no" useContentAsTabName="no" />
        <GUIConfig name="langsExcluded" gr0="0" gr1="0" gr2="0" gr3="0" gr4="0" gr5="0" gr6="0" gr7="0" gr8="0" gr9="0" gr10="0" gr11="0" gr12="0" langMenuCompact="yes" />
        <GUIConfig name="Print" lineNumber="yes" printOption="3" headerLeft="" headerMiddle="" headerRight="" footerLeft="" footerMiddle="" footerRight="" headerFontName="" headerFontStyle="0" headerFontSize="0" footerFontName="" footerFontStyle="0" footerFontSize="0" margeLeft="0" margeRight="0" margeTop="0" margeBottom="0" />
        <GUIConfig name="Backup" action="0" useCustumDir="no" dir="" isSnapshotMode="no" snapshotBackupTiming="7000" />
        <GUIConfig name="TaskList">yes</GUIConfig>
        <GUIConfig name="MRU">yes</GUIConfig>
        <GUIConfig name="URL">0</GUIConfig>
        <GUIConfig name="uriCustomizedSchemes">svn:// cvs:// git:// imap:// irc:// irc6:// ircs:// ldap:// ldaps:// news: telnet:// gopher:// ssh:// sftp:// smb:// skype: snmp:// spotify: steam:// sms: slack:// chrome:// bitcoin:</GUIConfig>
        <GUIConfig name="globalOverride" fg="no" bg="no" font="no" fontSize="no" bold="no" italic="no" underline="no" />
        <GUIConfig name="auto-completion" autoCAction="3" triggerFromNbChar="1" autoCIgnoreNumbers="yes" insertSelectedItemUseENTER="yes" insertSelectedItemUseTAB="yes" autoCBrief="no" funcParams="yes" />
        <GUIConfig name="auto-insert" parentheses="no" brackets="no" curlyBrackets="no" quotes="no" doubleQuotes="no" htmlXmlTag="no" />
        <GUIConfig name="sessionExt"></GUIConfig>
        <GUIConfig name="workspaceExt"></GUIConfig>
        <GUIConfig name="MenuBar">show</GUIConfig>
        <GUIConfig name="Caret" width="1" blinkRate="600" />
        <GUIConfig name="openSaveDir" value="0" defaultDirPath="" lastUsedDirPath="" />
        <GUIConfig name="titleBar" short="no" />
        <GUIConfig name="insertDateTime" customizedFormat="yyyy-MM-dd HH:mm:ss" reverseDefaultOrder="no" />
        <GUIConfig name="wordCharList" useDefault="yes" charsAdded="" />
        <GUIConfig name="delimiterSelection" leftmostDelimiter="40" rightmostDelimiter="41" delimiterSelectionOnEntireDocument="no" />
        <GUIConfig name="largeFileRestriction" fileSizeMB="200" isEnabled="yes" allowAutoCompletion="no" allowBraceMatch="no" allowSmartHilite="no" allowClickableLink="no" deactivateWordWrap="yes" suppress2GBWarning="no" />
        <GUIConfig name="multiInst" setting="0" clipboardHistory="no" documentList="no" characterPanel="no" folderAsWorkspace="no" projectPanels="no" documentMap="no" fuctionList="no" pluginPanels="no" />
        <GUIConfig name="MISC" fileSwitcherWithoutExtColumn="no" fileSwitcherExtWidth="50" fileSwitcherWithoutPathColumn="yes" fileSwitcherPathWidth="50" fileSwitcherNoGroups="no" backSlashIsEscapeCharacterForSql="yes" writeTechnologyEngine="1" isFolderDroppedOpenFiles="no" docPeekOnTab="no" docPeekOnMap="no" sortFunctionList="no" saveDlgExtFilterToAllTypes="no" muteSounds="yes" enableFoldCmdToggable="no" hideMenuRightShortcuts="no" />
        <GUIConfig name="Searching" monospacedFontFindDlg="no" fillFindFieldWithSelected="yes" fillFindFieldSelectCaret="yes" findDlgAlwaysVisible="no" confirmReplaceInAllOpenDocs="yes" replaceStopsWithoutFindingNext="no" inSelectionAutocheckThreshold="1024" fillFindWhatThreshold="1024" fillDirFieldFromActiveDoc="no" />
        <GUIConfig name="searchEngine" searchEngineChoice="2" searchEngineCustom="" />
        <GUIConfig name="MarkAll" matchCase="no" wholeWordOnly="yes" />
        <GUIConfig name="SmartHighLight" matchCase="no" wholeWordOnly="yes" useFindSettings="no" onAnotherView="no">yes</GUIConfig>
        <GUIConfig name="DarkMode" enable="yes" colorTone="0" customColorTop="2105376" customColorMenuHotTrack="4539717" customColorActive="3684408" customColorMain="2105376" customColorError="176" customColorText="14737632" customColorDarkText="12632256" customColorDisabledText="8421504" customColorLinkText="65535" customColorEdge="6579300" customColorHotEdge="10197915" customColorDisabledEdge="4737096" enableWindowsMode="no" darkThemeName="DarkModeDefault.xml" darkToolBarIconSet="0" darkTbFluentColor="0" darkTbFluentCustomColor="16229943" darkTbFluentMono="no" darkTabIconSet="2" darkTabUseTheme="no" lightThemeName="" lightToolBarIconSet="4" lightTbFluentColor="0" lightTbFluentCustomColor="12873472" lightTbFluentMono="no" lightTabIconSet="0" lightTabUseTheme="yes" />
        <GUIConfig name="ScintillaPrimaryView" lineNumberMargin="show" lineNumberDynamicWidth="yes" bookMarkMargin="show" indentGuideLine="show" folderMarkStyle="box" isChangeHistoryEnabled="1" lineWrapMethod="aligned" currentLineIndicator="1" currentLineFrameWidth="1" virtualSpace="no" scrollBeyondLastLine="yes" rightClickKeepsSelection="no" selectedTextForegroundSingleColor="no" disableAdvancedScrolling="no" wrapSymbolShow="hide" Wrap="no" borderEdge="yes" isEdgeBgMode="no" edgeMultiColumnPos="" zoom="0" zoom2="0" whiteSpaceShow="hide" eolShow="hide" eolMode="1" npcShow="hide" npcMode="1" npcCustomColor="no" npcIncludeCcUniEOL="no" npcNoInputC0="yes" ccShow="yes" borderWidth="2" smoothFont="no" paddingLeft="0" paddingRight="0" distractionFreeDivPart="4" lineCopyCutWithoutSelection="yes" multiSelection="yes" columnSel2MultiEdit="yes" />
        <GUIConfig name="DockingManager" leftWidth="200" rightWidth="200" topHeight="200" bottomHeight="200">
            <ActiveTabs cont="0" activeTab="-1" />
            <ActiveTabs cont="1" activeTab="-1" />
            <ActiveTabs cont="2" activeTab="-1" />
            <ActiveTabs cont="3" activeTab="-1" />
        </GUIConfig>
    </GUIConfigs>
    <FindHistory nbMaxFindHistoryPath="10" nbMaxFindHistoryFilter="10" nbMaxFindHistoryFind="10" nbMaxFindHistoryReplace="10" matchWord="no" matchCase="no" wrap="yes" directionDown="yes" fifRecuisive="yes" fifInHiddenFolder="no" fifProjectPanel1="no" fifProjectPanel2="no" fifProjectPanel3="no" fifFilterFollowsDoc="no" searchMode="0" transparencyMode="1" transparency="150" dotMatchesNewline="no" isSearch2ButtonsMode="no" regexBackward4PowerUser="no" bookmarkLine="no" purge="no" />
    <History nbMaxFile="0" inSubMenu="no" customLength="-1" />
</NotepadPlus>

'@
Set-Content -Path "$env:AppData\Notepad++\config.xml" -Value $NotePadConfig -Force

# create desktop shortcut
$WshShell = New-Object -comObject WScript.Shell
$Desktop = (New-Object -ComObject Shell.Application).Namespace('shell:Desktop').Self.Path
$Shortcut = $WshShell.CreateShortcut("$Desktop\Notepad++.lnk")
$Shortcut.TargetPath = "$env:SystemDrive\Program Files\Notepad++\notepad++.exe"
$Shortcut.WorkingDirectory = "$env:SystemDrive\Program Files\Notepad++"
$Shortcut.Save()

# cleaner start menu shortcut path
Move-Item -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Notepad++\Notepad++.lnk" -Destination "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" -Force -ErrorAction SilentlyContinue | Out-Null
Remove-Item "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Notepad++" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null

show-menu

          }
       17 {

Clear-Host

Write-Host "Installing: Nvidia App..."

# download and install nvidia app
try {
Start-Process "winget" -ArgumentList "install `"XP8CLZL93F5Z4P`" --silent --accept-package-agreements --accept-source-agreements --disable-interactivity --no-upgrade" -Wait -WindowStyle Hidden
} catch { }

# cleaner start menu shortcut path
Move-Item -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\NVIDIA Corporation\NVIDIA App.lnk" -Destination "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" -Force -ErrorAction SilentlyContinue | Out-Null
Remove-Item "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\NVIDIA Corporation" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null

show-menu

          }
       18 {

Clear-Host

Write-Host "Installing: Nvidia Profile Inspector..."

# remove winget app from install entry to force upgrade/install/fix
try {
Start-Process "winget" -ArgumentList "uninstall --product-code Orbmu2k.nvidiaProfileInspector_Microsoft.Winget.Source_8wekyb3d8bbwe --silent" -Wait -WindowStyle Hidden
} catch { }

# download and install nvidia profile inspector
try {
Start-Process "winget" -ArgumentList "install `"Orbmu2k.nvidiaProfileInspector`" --silent --accept-package-agreements --accept-source-agreements --disable-interactivity --no-upgrade" -Wait -WindowStyle Hidden
} catch { }

# create desktop shortcut
$WshShell = New-Object -comObject WScript.Shell
$Desktop = (New-Object -ComObject Shell.Application).Namespace('shell:Desktop').Self.Path
$Shortcut = $WshShell.CreateShortcut("$Desktop\Nvidia Profile Inspector.lnk")
$Shortcut.TargetPath = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\Orbmu2k.nvidiaProfileInspector_Microsoft.Winget.Source_8wekyb3d8bbwe\nvidiaProfileInspector.exe"
$Shortcut.WorkingDirectory = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\Orbmu2k.nvidiaProfileInspector_Microsoft.Winget.Source_8wekyb3d8bbwe"
$Shortcut.Save()

# create start menu shortcut
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Nvidia Profile Inspector.lnk")
$Shortcut.TargetPath = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\Orbmu2k.nvidiaProfileInspector_Microsoft.Winget.Source_8wekyb3d8bbwe\nvidiaProfileInspector.exe"
$Shortcut.WorkingDirectory = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\Orbmu2k.nvidiaProfileInspector_Microsoft.Winget.Source_8wekyb3d8bbwe"
$Shortcut.Save()

show-menu

          }
       19 {

Clear-Host

Write-Host "Installing: OBS Studio..."

# download and install obs studio 
try {
Start-Process "winget" -ArgumentList "install `"OBSProject.OBSStudio`" --silent --accept-package-agreements --accept-source-agreements --disable-interactivity --no-upgrade" -Wait -WindowStyle Hidden
} catch { }                  

show-menu

          }
       20 {

Clear-Host

Write-Host "Installing: Onboard Memory Manager..."

# remove winget app from install entry to force upgrade/install/fix
try {
Start-Process "winget" -ArgumentList "uninstall --product-code Logitech.OnboardMemoryManager_Microsoft.Winget.Source_8wekyb3d8bbwe --silent" -Wait -WindowStyle Hidden
} catch { }

# download and install onboard memory manager 
try {
Start-Process "winget" -ArgumentList "install `"Logitech.OnboardMemoryManager`" --silent --accept-package-agreements --accept-source-agreements --disable-interactivity --no-upgrade" -Wait -WindowStyle Hidden
} catch { }

# create desktop shortcut
$WshShell = New-Object -comObject WScript.Shell
$Desktop = (New-Object -ComObject Shell.Application).Namespace('shell:Desktop').Self.Path
$Shortcut = $WshShell.CreateShortcut("$Desktop\Onboard Memory Manager.lnk")
$Shortcut.TargetPath = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\Logitech.OnboardMemoryManager_Microsoft.Winget.Source_8wekyb3d8bbwe\OnboardMemoryManager.exe"
$Shortcut.WorkingDirectory = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\Logitech.OnboardMemoryManager_Microsoft.Winget.Source_8wekyb3d8bbwe"
$Shortcut.Save()

# create start menu shortcut
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Onboard Memory Manager.lnk")
$Shortcut.TargetPath = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\Logitech.OnboardMemoryManager_Microsoft.Winget.Source_8wekyb3d8bbwe\OnboardMemoryManager.exe"
$Shortcut.WorkingDirectory = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\Logitech.OnboardMemoryManager_Microsoft.Winget.Source_8wekyb3d8bbwe"
$Shortcut.Save()

show-menu

          }
       21 {

Clear-Host

Write-Host "Installing: Pot Player..."

# download and install pot player 
try {
Start-Process "winget" -ArgumentList "install `"Daum.PotPlayer`" --silent --accept-package-agreements --accept-source-agreements --disable-interactivity --no-upgrade" -Wait -WindowStyle Hidden
} catch { }

# cleaner start menu shortcut path
Move-Item -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\PotPlayer\PotPlayer 64 bit.lnk" -Destination "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" -Force -ErrorAction SilentlyContinue | Out-Null
Remove-Item "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\PotPlayer" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null

show-menu

          }
       22 {

Clear-Host

Write-Host "Installing: Roblox..."

# download and install roblox
try {
Start-Process "winget" -ArgumentList "install `"Roblox.Roblox`" --silent --accept-package-agreements --accept-source-agreements --disable-interactivity --no-upgrade" -Wait -WindowStyle Hidden
} catch { }

# create start menu shortcut
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Roblox.url")
$Shortcut.TargetPath = "roblox://placeId=0"
$Shortcut.Save()

# create desktop shortcut
$WshShell = New-Object -comObject WScript.Shell
$Desktop = (New-Object -ComObject Shell.Application).Namespace('shell:Desktop').Self.Path
$Shortcut = $WshShell.CreateShortcut("$Desktop\Roblox.url")
$Shortcut.TargetPath = "roblox://placeId=0"
$Shortcut.Save()

# cleaner start menu shortcut path
Remove-Item "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Roblox" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null

show-menu

          }
       23 {

Clear-Host

Write-Host "Installing: Rockstar Games..."

# download and install rockstar games
try {
Start-Process "winget" -ArgumentList "install `"RockstarGames.Launcher`" --silent --accept-package-agreements --accept-source-agreements --disable-interactivity --no-upgrade" -Wait -WindowStyle Hidden
} catch { }

# cleaner start menu shortcut path
Move-Item -Path "$env:AppData\Microsoft\Windows\Start Menu\Programs\Rockstar Games\Rockstar Games Launcher.lnk" -Destination "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" -Force -ErrorAction SilentlyContinue | Out-Null
Remove-Item "$env:AppData\Microsoft\Windows\Start Menu\Programs\Rockstar Games" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null

show-menu

          }
       24 {

Clear-Host

Write-Host "Installing: Spotify..."

# set config for spotify
New-Item -Path "$env:APPDATA\Spotify\prefs" -ItemType File -Force | Out-Null
$SpotifySettingsPrefs = @'
app.autostart-configured=true
app.autostart-mode="off"
ui.hardware_acceleration=false
'@
Set-Content -Path "$env:APPDATA\Spotify\prefs" -Value $SpotifySettingsPrefs -Force | Out-Null

# fix path for space in username
$Global:tempDir = (([System.IO.Path]::GetTempPath())).trimend('\')

# download spotify
IWR "https://download.scdn.co/SpotifySetup.exe" -OutFile "$tempDir\Spotify.exe"

# install spotify
Start-Process "explorer.exe" -ArgumentList "$tempDir\Spotify.exe"

Start-Sleep -Seconds 5

Get-Process -Name "Spotify" -ErrorAction SilentlyContinue | Wait-Process -ErrorAction SilentlyContinue

# cleaner start menu shortcut path
Move-Item -Path "$env:AppData\Microsoft\Windows\Start Menu\Programs\Spotify.lnk" -Destination "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" -Force -ErrorAction SilentlyContinue | Out-Null

show-menu

          }
       25 {

Clear-Host

Write-Host "Installing: Steam..."

# download and install steam
try {
Start-Process "winget" -ArgumentList "install `"Valve.Steam`" --silent --accept-package-agreements --accept-source-agreements --disable-interactivity --no-upgrade" -Wait -WindowStyle Hidden
} catch { }

# remove logon steam
cmd /c "reg delete `"HKCU\Software\Microsoft\Windows\CurrentVersion\Run`" /v `"Steam`" /f >nul 2>&1"

# cleaner start menu shortcut path
Move-Item -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Steam\Steam.lnk" -Destination "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" -Force -ErrorAction SilentlyContinue | Out-Null
Remove-Item "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Steam" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null

show-menu

          }
       26 {

Clear-Host

Write-Host "Installing: Ubisoft Connect..."

# download and install ubisoft connect
try {
Start-Process "winget" -ArgumentList "install `"Ubisoft.Connect`" --silent --accept-package-agreements --accept-source-agreements --disable-interactivity --no-upgrade" -Wait -WindowStyle Hidden
} catch { }

# cleaner start menu shortcut path
Move-Item -Path "$env:AppData\Microsoft\Windows\Start Menu\Programs\Ubisoft\Ubisoft Connect\Ubisoft Connect.lnk" -Destination "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" -Force -ErrorAction SilentlyContinue | Out-Null
Remove-Item "$env:AppData\Microsoft\Windows\Start Menu\Programs\Ubisoft" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null

show-menu

          }
       27 {

Clear-Host

Write-Host "Installing: Valorant..."

# download and install valorant 
try {
Start-Process "winget" -ArgumentList "install `"RiotGames.Valorant.NA`" --silent --accept-package-agreements --accept-source-agreements --disable-interactivity --no-upgrade" -Wait -WindowStyle Hidden
} catch { }

# remove logon valorant
cmd /c "reg delete `"HKCU\Software\Microsoft\Windows\CurrentVersion\Run`" /v `"RiotClient`" /f >nul 2>&1"

# cleaner start menu shortcut path
Move-Item -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Riot Games\*" -Destination "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" -Force -ErrorAction SilentlyContinue | Out-Null
Remove-Item "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Riot Games" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
Remove-Item "$env:AppData\Microsoft\Windows\Start Menu\Programs\Riot Games" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null

show-menu

          }
       28 {

Clear-Host

exit

          }
        } } else { Write-Host "Invalid input. Please select a valid option (1-28)." } }