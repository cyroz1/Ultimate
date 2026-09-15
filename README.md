# Ultimate
- Windows guide for power users
- Multiple scripts with revert options
- Reboot needed for scripts to apply

## Ultimate UI

This fork adds a native Windows Forms launcher for the complete PowerShell toolkit. The launcher discovers every original `.ps1` script, turns numeric menus into native radio controls, provides fields for account/USB/process/priority values, and runs the untouched script through a hidden PowerShell host. Users do not need to open a terminal or type menu choices.

The original toolkit scripts are kept byte-for-byte identical to the upstream repository. The UI does not translate, patch, or reimplement their commands: it starts the same Windows PowerShell engine and invokes the selected file directly. The UI supplies only the prompt and file-picker transport, so `Read-Host`, `Pause`, and the scripts' native `OpenFileDialog` calls do not require a visible console.

The application requests administrator rights because the original scripts change system settings. A Windows UAC prompt may still appear; that is the standard Windows security prompt, not a console window. Some scripts intentionally open Windows Settings, browsers, installers, or other graphical tools.

### Download

Download and run the latest `Ultimate-UI-v*-win-x64.msi` from the fork's [Releases](../../releases) page. The installer places the toolkit under Program Files, adds an Ultimate shortcut to the Start menu, and registers normal Windows uninstall/upgrade support.

### Build on Windows

The build uses the .NET Framework C# compiler already included with supported Windows installations and WiX Toolset 5.0.2 for the MSI:

```powershell
dotnet tool install --global wix --version 5.0.2
wix extension add -g WixToolset.UI.wixext/5.0.2
```

```powershell
.\build\build.ps1 -Version 0.1.2
```

The native MSI is written to `dist\Ultimate-UI-v0.1.2-win-x64.msi`. Pushing a `v*` tag runs the Windows build and publishes the MSI as a GitHub release through [`.github/workflows/release.yml`](.github/workflows/release.yml).

# Requirements
- Windows 10/11 Home/Pro/LTSC/IoT/Server
- Windows updates unblocked
- Online access

# IWR
- Paste this code into an elevated Administrator PowerShell/Terminal window
```
iwr https://github.com/cyroz1/Ultimate/raw/refs/heads/main/IWR.ps1 -useb | iex
```

# Guide
[![Video](https://img.youtube.com/vi/zwPEDXteJYQ/maxresdefault.jpg)](https://youtu.be/zwPEDXteJYQ)
