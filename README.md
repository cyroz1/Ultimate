# Ultimate
- Windows guide for power users
- Multiple scripts with revert options
- Reboot needed for scripts to apply

## Ultimate UI

This fork adds a native Windows Forms launcher for the complete PowerShell toolkit. The launcher discovers every original `.ps1` script, turns numeric menus into native radio controls, provides fields for account/USB/process/priority values, and runs the untouched script through a hidden PowerShell host. Users do not need to open a terminal or type menu choices.

The original toolkit scripts are kept byte-for-byte identical to the upstream repository. The UI does not translate, patch, or reimplement their commands: it starts the same Windows PowerShell engine and invokes the selected file directly. Only the prompt transport is supplied by the UI so `Read-Host` and `Pause` do not require a visible console.

The application requests administrator rights because the original scripts change system settings. A Windows UAC prompt may still appear; that is the standard Windows security prompt, not a console window. Some scripts intentionally open Windows Settings, browsers, installers, or other graphical tools.

### Download

Download the latest `Ultimate-UI-v*-win-x64.zip` from the fork's [Releases](../../releases) page, extract it, and launch `UltimateUI.exe`.

### Build on Windows

The build uses the .NET Framework C# compiler already included with supported Windows installations:

```powershell
.\build\build.ps1 -Version 0.1.0
```

The portable ZIP is written to `dist\Ultimate-UI-v0.1.0-win-x64.zip`. Pushing a `v*` tag runs the Windows build and publishes the ZIP as a GitHub release through [`.github/workflows/release.yml`](.github/workflows/release.yml).

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
