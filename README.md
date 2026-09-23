# Ultimate
- Windows guide for power users
- Multiple scripts with revert options
- Reboot needed for scripts to apply

## Ultimate UI

This fork adds a native Windows Forms launcher for the complete PowerShell toolkit. The launcher discovers every original `.ps1` script, turns numeric menus into native radio controls, provides fields for account/USB/process/priority values, and runs the untouched script through a hidden PowerShell host. Users do not need to open a terminal or type menu choices.

The UI does not translate or reimplement toolkit commands: it starts Windows PowerShell and invokes each selected script directly. Architecture-sensitive scripts share an operating-system architecture check so they can select a compatible program or package when the original binary cannot run on ARM64. The UI supplies only the prompt and file-picker transport, so `Read-Host`, `Pause`, and the scripts' native `OpenFileDialog` calls do not require a visible console.

The application requests administrator rights because the original scripts change system settings. A Windows UAC prompt may still appear; that is the standard Windows security prompt, not a console window. Some scripts intentionally open Windows Settings, browsers, installers, or other graphical tools.

See [SCRIPT_GUIDE.md](SCRIPT_GUIDE.md) for a brief explanation of every bundled script.

### Download

Download the package that matches the Windows device from the fork's [Releases](../../releases) page:

- `Ultimate-UI-v*-win-x64.msi` for Intel/AMD 64-bit Windows.
- `Ultimate-UI-v*-win-arm64.msi` for Windows on ARM64.

Each package contains its own architecture-targeted GUI and a separate copy of the PowerShell script payload. The installer places the toolkit under Program Files, adds an Ultimate shortcut to the Start menu, and registers normal Windows uninstall/upgrade support.

### Windows on ARM

Windows on Arm can emulate x86 applications; Windows 11 can also emulate x64 applications. Kernel drivers must be native ARM64. Scripts that include x64-only drivers direct those specific installs to Windows Update, and the CPU-affinity scripts use the processor topology reported by Windows on ARM. Other tuning settings and optimization choices remain available as before. Because Windows 10 on Arm does not emulate x64 apps, bundled x64 programs require Windows 11 on Arm.

### Build on Windows

The build uses the .NET Framework C# compiler already included with supported Windows installations and WiX Toolset 5.0.2 for the MSI:

```powershell
dotnet tool install --global wix --version 5.0.2
wix extension add -g WixToolset.UI.wixext/5.0.2
```

```powershell
.\build\build.ps1 -Version 0.1.8
```

The command writes both native MSIs and portable script/GUI bundles to `dist`:

- `Ultimate-UI-v0.1.8-win-x64.msi` and `.zip`
- `Ultimate-UI-v0.1.8-win-arm64.msi` and `.zip`

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
