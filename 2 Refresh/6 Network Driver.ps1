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

# Windows on Arm drivers are supplied by the device manufacturer or Windows Update.
$computer = Get-CimInstance Win32_ComputerSystem
$baseboard = Get-CimInstance Win32_BaseBoard
$deviceModel = if (Test-UltimateArm64) { "$($computer.Manufacturer) $($computer.Model)" } else { $baseboard.Product }
$query = [uri]::EscapeDataString("$deviceModel Windows network drivers")

# Search using the device model, which is more useful than a generic Arm baseboard ID.
Start-Process "https://www.google.com/search?q=$query"
