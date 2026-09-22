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

Write-Host "STORAGE CHECK"
Write-Host "-------------"
Write-Host "- Keep SSD's at least 10% free"
if (Test-UltimateArm64) {
    Write-Host "- Follow the device manufacturer's storage guidance (ARM64 devices may use UFS, eMMC, or NVMe)"
    Write-Host "- Avoid installing Windows and games on external drives`n"
} else {
    Write-Host "- Stick with internal SSD's or NVME's"
    Write-Host "- Avoid installing windows & games on HDD's & external drives`n"
}

# show space for all drives
Get-Volume | Where-Object {$_.DriveLetter} | Sort-Object DriveLetter | ForEach-Object {
try {
$percentRemain = ($_.SizeRemaining / $_.Size) * 100
Write-Host "$($_.DriveLetter): Free space = $($percentRemain.ToString().substring(0,4))%"
} catch {}
}

# open file explorer
Start-Process explorer shell:MyComputerFolder

Write-Host ""

Pause
