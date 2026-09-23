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

Write-Host "Downloading: C++..."

$arm64Windows10 = (Test-UltimateArm64) -and ((Get-UltimateWindowsBuild) -lt 22000)
if ($arm64Windows10) {
    Write-Host "Windows 10 on Arm emulates x86 apps but not x64 apps; installing the x86 and ARM64 runtimes." -ForegroundColor Yellow
}

# download c++
IWR "https://github.com/FR33THYFR33THY/Ultimate/releases/download/Files/vcredist2005_x86.exe" -OutFile "$env:SystemRoot\Temp\vcredist2005_x86.exe"
IWR "https://github.com/FR33THYFR33THY/Ultimate/releases/download/Files/vcredist2008_x86.exe" -OutFile "$env:SystemRoot\Temp\vcredist2008_x86.exe"
IWR "https://github.com/FR33THYFR33THY/Ultimate/releases/download/Files/vcredist2010_x86.exe" -OutFile "$env:SystemRoot\Temp\vcredist2010_x86.exe"
IWR "https://github.com/FR33THYFR33THY/Ultimate/releases/download/Files/vcredist2012_x86.exe" -OutFile "$env:SystemRoot\Temp\vcredist2012_x86.exe"
IWR "https://github.com/FR33THYFR33THY/Ultimate/releases/download/Files/vcredist2013_x86.exe" -OutFile "$env:SystemRoot\Temp\vcredist2013_x86.exe"

if (-not $arm64Windows10) {
    IWR "https://github.com/FR33THYFR33THY/Ultimate/releases/download/Files/vcredist2005_x64.exe" -OutFile "$env:SystemRoot\Temp\vcredist2005_x64.exe"
    IWR "https://github.com/FR33THYFR33THY/Ultimate/releases/download/Files/vcredist2008_x64.exe" -OutFile "$env:SystemRoot\Temp\vcredist2008_x64.exe"
    IWR "https://github.com/FR33THYFR33THY/Ultimate/releases/download/Files/vcredist2010_x64.exe" -OutFile "$env:SystemRoot\Temp\vcredist2010_x64.exe"
    IWR "https://github.com/FR33THYFR33THY/Ultimate/releases/download/Files/vcredist2012_x64.exe" -OutFile "$env:SystemRoot\Temp\vcredist2012_x64.exe"
    IWR "https://github.com/FR33THYFR33THY/Ultimate/releases/download/Files/vcredist2013_x64.exe" -OutFile "$env:SystemRoot\Temp\vcredist2013_x64.exe"
}

if (Test-UltimateArm64) {
    IWR "https://aka.ms/vc14/vc_redist.x86.exe" -OutFile "$env:SystemRoot\Temp\vcredist2015_2017_2019_2022_x86.exe"
    if ($arm64Windows10) {
        $latestRuntime64File = "$env:SystemRoot\Temp\vcredist2015_2017_2019_2022_arm64.exe"
        IWR "https://aka.ms/vc14/vc_redist.arm64.exe" -OutFile $latestRuntime64File
    } else {
        # The official x64 package also installs ARM64 runtime binaries on ARM64 Windows.
        $latestRuntime64File = "$env:SystemRoot\Temp\vcredist2015_2017_2019_2022_x64.exe"
        IWR "https://aka.ms/vc14/vc_redist.x64.exe" -OutFile $latestRuntime64File
    }
} else {
    IWR "https://github.com/FR33THYFR33THY/Ultimate/releases/download/Files/vcredist2015_2017_2019_2022_x86.exe" -OutFile "$env:SystemRoot\Temp\vcredist2015_2017_2019_2022_x86.exe"
    $latestRuntime64File = "$env:SystemRoot\Temp\vcredist2015_2017_2019_2022_x64.exe"
    IWR "https://github.com/FR33THYFR33THY/Ultimate/releases/download/Files/vcredist2015_2017_2019_2022_x64.exe" -OutFile $latestRuntime64File
}

Clear-Host
Write-Host "Installing: C++..."

# install c++
Start-Process -Wait "$env:SystemRoot\Temp\vcredist2005_x86.exe" -ArgumentList "/Q /C:`"msiexec /i vcredist.msi /qn /norestart`"" -WindowStyle Hidden
Start-Process -Wait "$env:SystemRoot\Temp\vcredist2008_x86.exe" -ArgumentList "/q" -WindowStyle Hidden
Start-Process -Wait "$env:SystemRoot\Temp\vcredist2010_x86.exe" -ArgumentList "/quiet /norestart" -WindowStyle Hidden
Start-Process -Wait "$env:SystemRoot\Temp\vcredist2012_x86.exe" -ArgumentList "/quiet /norestart" -WindowStyle Hidden
Start-Process -Wait "$env:SystemRoot\Temp\vcredist2013_x86.exe" -ArgumentList "/quiet /norestart" -WindowStyle Hidden

if (-not $arm64Windows10) {
    Start-Process -Wait "$env:SystemRoot\Temp\vcredist2005_x64.exe" -ArgumentList "/Q /C:`"msiexec /i vcredist.msi /qn /norestart`"" -WindowStyle Hidden
    Start-Process -Wait "$env:SystemRoot\Temp\vcredist2008_x64.exe" -ArgumentList "/q" -WindowStyle Hidden
    Start-Process -Wait "$env:SystemRoot\Temp\vcredist2010_x64.exe" -ArgumentList "/quiet /norestart" -WindowStyle Hidden
    Start-Process -Wait "$env:SystemRoot\Temp\vcredist2012_x64.exe" -ArgumentList "/quiet /norestart" -WindowStyle Hidden
    Start-Process -Wait "$env:SystemRoot\Temp\vcredist2013_x64.exe" -ArgumentList "/quiet /norestart" -WindowStyle Hidden
}

Start-Process -Wait "$env:SystemRoot\Temp\vcredist2015_2017_2019_2022_x86.exe" -ArgumentList "/quiet /norestart" -WindowStyle Hidden
Start-Process -Wait $latestRuntime64File -ArgumentList "/quiet /norestart" -WindowStyle Hidden
