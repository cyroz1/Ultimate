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

Write-Host "Downloading: C++..."

# download and install c++
try {
$packages = @(
"Microsoft.VCRedist.2005.x86",
"Microsoft.VCRedist.2005.x64",
"Microsoft.VCRedist.2008.x86",
"Microsoft.VCRedist.2008.x64",
"Microsoft.VCRedist.2010.x86",
"Microsoft.VCRedist.2010.x64",
"Microsoft.VCRedist.2012.x86",
"Microsoft.VCRedist.2012.x64",
"Microsoft.VCRedist.2013.x86",
"Microsoft.VCRedist.2013.x64",
"Microsoft.VCRedist.2015+.x86",
"Microsoft.VCRedist.2015+.x64"
)
foreach ($pkg in $packages) {
Start-Process "winget" -ArgumentList "install `"$pkg`" --silent --accept-package-agreements --accept-source-agreements --disable-interactivity --no-upgrade" -Wait -WindowStyle Hidden
}
} catch { }