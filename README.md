# Ultimate
- Windows guide for power users
- Multiple scripts with revert options
- Reboot needed for scripts to apply

## Ultimate UI

This fork adds a native Windows Forms launcher for the complete PowerShell toolkit. The launcher discovers every original `.ps1` script, turns numeric menus into native radio controls, provides fields for account/USB/process/priority values, and runs the untouched script through a hidden PowerShell host. Users do not need to open a terminal or type menu choices.

The original toolkit scripts are kept byte-for-byte identical to the upstream repository. The UI does not translate, patch, or reimplement their commands: it starts the same Windows PowerShell engine and invokes the selected file directly. The UI supplies only the prompt and file-picker transport, so `Read-Host`, `Pause`, and the scripts' native `OpenFileDialog` calls do not require a visible console.

The application requests administrator rights because the original scripts change system settings. A Windows UAC prompt may still appear; that is the standard Windows security prompt, not a console window. Some scripts intentionally open Windows Settings, browsers, installers, or other graphical tools.

See [SCRIPT_GUIDE.md](SCRIPT_GUIDE.md) for a brief explanation of every bundled script.

### Download

Download the package that matches the Windows device from the fork's [Releases](../../releases) page:

- `Ultimate-UI-v*-win-x64.msi` for Intel/AMD 64-bit Windows.
- `Ultimate-UI-v*-win-arm64.msi` for Windows on ARM64.

Each package contains its own architecture-targeted GUI and a separate copy of the PowerShell script payload. The installer places the toolkit under Program Files, adds an Ultimate shortcut to the Start menu, and registers normal Windows uninstall/upgrade support.

### Build on Windows

The build uses the .NET Framework C# compiler already included with supported Windows installations and WiX Toolset 5.0.2 for the MSI:

```powershell
dotnet tool install --global wix --version 5.0.2
wix extension add -g WixToolset.UI.wixext/5.0.2
```

```powershell
.\build\build.ps1 -Version 0.1.6
```

The command writes both native MSIs and portable script/GUI bundles to `dist`:

- `Ultimate-UI-v0.1.6-win-x64.msi` and `.zip`
- `Ultimate-UI-v0.1.6-win-arm64.msi` and `.zip`

Use `-Architecture x64` or `-Architecture arm64` to build one target. Pushing a `v*` tag builds both targets and publishes all four artifacts as a GitHub release through [`.github/workflows/release.yml`](.github/workflows/release.yml).

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
[![Video](https://img.youtube.com/vi/zwPEDXteJYQ/maxresdefault.jpg)](https://youtu.be/zwPEDXteJYQY)
