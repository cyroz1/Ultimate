# Ultimate Script Guide

This is a brief reference for the scripts shipped with Ultimate. It covers all 104 numbered toolkit scripts, the two bootstrap/helper scripts, and the native UI/build support scripts added by this fork.

Descriptions are high-level summaries of the behavior in each script. Many scripts require administrator rights, an internet connection, or a restart, and some intentionally open Windows Settings, a browser, an installer, or another graphical tool. The original toolkit scripts are unchanged.

The Scope column describes direct effects of the script itself:

- User — changes the current user's profile or per-user settings, usually under HKCU or AppData.
- System — changes machine-wide Windows state, services, drivers, policies, or shared locations.
- Both — changes both current-user and machine-wide state.
- Process-only — changes a selected process while it runs, without a persistent user/system setting.
- External media — writes installer files to a selected USB or other external medium, not to the current Windows installation.
- None / external — reads information or opens another UI/site; it makes no direct persistent user/system change.
- Build tooling — creates build artifacts in the development workspace.

## 1 Check

| Script | Scope | What it does |
| --- | --- | --- |
| [1 Bios Check.ps1](<1 Check/1 Bios Check.ps1>) | System | Reads the motherboard details, opens a web search, displays BIOS tuning guidance for Intel and AMD systems, and can restart into firmware settings. |
| [2 Storage Check.ps1](<1 Check/2 Storage Check.ps1>) | None / external | Reports free space on local drives, opens This PC in File Explorer, and displays storage guidance. |
| [3 Ram Check.ps1](<1 Check/3 Ram Check.ps1>) | None / external | Downloads and opens CPU-Z, then displays RAM profile, slot, module-matching, and dual-channel guidance. |
| [4 Gpu Check.ps1](<1 Check/4 Gpu Check.ps1>) | None / external | Downloads and opens GPU-Z, then displays graphics-bus, Resizable BAR, cabling, and PCIe-slot guidance. |
| [5 Storage Ram Cpu Test & Bench.ps1](<1 Check/5 Storage Ram Cpu Test & Bench.ps1>) | None / external | Downloads and opens OCCT, then displays storage, RAM, and CPU stress-test, troubleshooting, and benchmark guidance. |
| [6 Gpu Test & Bench.ps1](<1 Check/6 Gpu Test & Bench.ps1>) | None / external | Downloads and opens FurMark, then displays GPU stress-test, troubleshooting, and benchmark guidance. |

## 2 Refresh

| Script | Scope | What it does |
| --- | --- | --- |
| [1 Factory Reset.ps1](<2 Refresh/1 Factory Reset.ps1>) | None / external | Opens Windows Settings at the Recovery page. |
| [2 Account Local.ps1](<2 Refresh/2 Account Local.ps1>) | None / external | Opens the classic netplwiz local-account and user-management dialog. |
| [3 Reinstall.ps1](<2 Refresh/3 Reinstall.ps1>) | User | Downloads and launches the selected Windows 10 or Windows 11 Media Creation Tool. |
| [4 Autounattend.ps1](<2 Refresh/4 Autounattend.ps1>) | External media | Collects an account and USB drive, generates unattended Windows setup files, and writes them to the selected USB drive. |
| [5 Updates Drivers Block.ps1](<2 Refresh/5 Updates Drivers Block.ps1>) | System | Provides options to block or unblock Windows Update and driver updates, including bootable-USB setup variants. |
| [6 Network Driver.ps1](<2 Refresh/6 Network Driver.ps1>) | None / external | Reads the motherboard product ID and opens a web search for the matching vendor driver page. |
| [7 To Bios.ps1](<2 Refresh/7 To Bios.ps1>) | System | Restarts the computer into UEFI/BIOS firmware after confirmation. |

## 3 Setup

| Script | Scope | What it does |
| --- | --- | --- |
| [1 BitLocker.ps1](<3 Setup/1 BitLocker.ps1>) | System | Turns BitLocker off or on. |
| [2 Memory Compression.ps1](<3 Setup/2 Memory Compression.ps1>) | System | Checks the memory-compression state and provides options to disable or enable it. |
| [3 Convert Home To Pro.ps1](<3 Setup/3 Convert Home To Pro.ps1>) | System | Changes Windows Home to Pro using the built-in edition-change workflow and a default Pro key, with an instruction to disconnect from the internet. |
| [4 Keys.ps1](<3 Setup/4 Keys.ps1>) | None / external | Opens the Microsoft Activation Scripts project in a web browser. |
| [5 Activation.ps1](<3 Setup/5 Activation.ps1>) | None / external | Opens Windows activation settings. |
| [6 Date Language Region Time.ps1](<3 Setup/6 Date Language Region Time.ps1>) | None / external | Opens Windows date, language, region, and time settings. |
| [7 Startup Apps.ps1](<3 Setup/7 Startup Apps.ps1>) | None / external | Opens Windows startup-app settings. |
| [8 Startup Apps.ps1](<3 Setup/8 Startup Apps.ps1>) | None / external | Opens the Startup tab in Task Manager. |
| [9 Background Apps.ps1](<3 Setup/9 Background Apps.ps1>) | Both | Disables or restores background-app execution through registry settings. |
| [10 Edge Settings.ps1](<3 Setup/10 Edge Settings.ps1>) | System | Applies or restores Edge settings and policies, including extension, background, and startup behavior. |
| [11 Store Settings.ps1](<3 Setup/11 Store Settings.ps1>) | Both | Applies or restores Microsoft Store and app-update settings and can reset Store components. |
| [12 Updates Pause.ps1](<3 Setup/12 Updates Pause.ps1>) | System | Pauses or resumes Windows Updates using the script's policy and service settings. |

## 4 Installers

| Script | Scope | What it does |
| --- | --- | --- |
| [1 Installers.ps1](<4 Installers/1 Installers.ps1>) | Both | Installs and configures selected game launchers, browsers, tools, and programs. Per-application actions commonly disable cloud sync, hardware acceleration, startup launch, or overlays. |
| [2 MSI Afterburner.ps1](<4 Installers/2 MSI Afterburner.ps1>) | Both | Downloads and configures MSI Afterburner and RivaTuner to remove GPU power-limit and power-logging behavior identified by the script as affecting frame-time performance. |

## 5 Graphics

| Script | Scope | What it does |
| --- | --- | --- |
| [1 Driver Clean.ps1](<5 Graphics/1 Driver Clean.ps1>) | System | Uses Display Driver Uninstaller in automatic or manual mode to remove display drivers, with Safe Mode and restart support. |
| [2 Driver Updated Install.ps1](<5 Graphics/2 Driver Updated Install.ps1>) | System | Downloads and installs a current graphics driver for the selected NVIDIA, AMD, or Intel vendor. |
| [3 Driver Updated Install & Settings.ps1](<5 Graphics/3 Driver Updated Install & Settings.ps1>) | Both | Downloads and installs the selected vendor's graphics driver, then applies the corresponding vendor settings. |
| [4 Driver Debloat Install & Settings.ps1](<5 Graphics/4 Driver Debloat Install & Settings.ps1>) | Both | Downloads or lets the user select a driver package, removes unwanted components, installs the driver, and applies vendor settings for NVIDIA, AMD, or Intel. |
| [5 Nvidia Settings.ps1](<5 Graphics/5 Nvidia Settings.ps1>) | Both | Installs the legacy NVIDIA Control Panel and applies or restores NVIDIA registry and driver settings. |
| [6 Amd Settings.ps1](<5 Graphics/6 Amd Settings.ps1>) | Both | Applies or restores AMD settings covering issue detection, hotkeys, tray behavior, overlays, browser features, advertising, and notifications. |
| [7 Intel Settings.ps1](<5 Graphics/7 Intel Settings.ps1>) | Both | Creates or restores Intel graphics settings and adjusts the related variable-refresh behavior. |
| [8 Hdcp.ps1](<5 Graphics/8 Hdcp.ps1>) | System | Disables or restores NVIDIA HDCP. |
| [9 P0 State.ps1](<5 Graphics/9 P0 State.ps1>) | System | Forces NVIDIA GPUs to their highest-performance P0 state or restores the default behavior. |
| [10 Msi Mode.ps1](<5 Graphics/10 Msi Mode.ps1>) | System | Enables or disables MSI mode for supported graphics devices through registry settings. |
| [11 DirectX.ps1](<5 Graphics/11 DirectX.ps1>) | System | Downloads and installs DirectX components. |
| [12 C++.ps1](<5 Graphics/12 C++.ps1>) | System | Downloads and installs the Microsoft Visual C++ redistributables. |
| [13 Resolution Refresh Rate.ps1](<5 Graphics/13 Resolution Refresh Rate.ps1>) | None / external | Opens Windows display settings for resolution and refresh-rate changes. |
| [14 Hags Windowed.ps1](<5 Graphics/14 Hags Windowed.ps1>) | None / external | Opens advanced graphics settings for hardware-accelerated GPU scheduling and windowed-game optimizations. |

## 6 Windows

| Script | Scope | What it does |
| --- | --- | --- |
| [1 Start Menu Taskbar.ps1](<6 Windows/1 Start Menu Taskbar.ps1>) | Both | Applies a customized Start menu and taskbar layout or restores the defaults. |
| [2 Start Menu Layout.ps1](<6 Windows/2 Start Menu Layout.ps1>) | Both | Applies the Windows 24H2 or 25H2 Start menu layout. |
| [3 Start Menu Shortcuts.ps1](<6 Windows/3 Start Menu Shortcuts.ps1>) | Both | Creates Start menu and startup shortcuts, including a Recycle Bin shortcut. |
| [4 Context Menu.ps1](<6 Windows/4 Context Menu.ps1>) | Both | Applies or restores the classic context menu and selected context-menu entries. |
| [5 Theme Black.ps1](<6 Windows/5 Theme Black.ps1>) | Both | Applies black or dark Windows theme settings or restores the defaults. |
| [6 Signout Lockscreen Wallpaper Black.ps1](<6 Windows/6 Signout Lockscreen Wallpaper Black.ps1>) | Both | Applies a black sign-out and lock-screen wallpaper with related sign-in appearance settings, or restores the defaults. |
| [7 User Account Pictures Black.ps1](<6 Windows/7 User Account Pictures Black.ps1>) | System | Sets user-account pictures to black or restores the default account pictures. |
| [8 Widgets.ps1](<6 Windows/8 Widgets.ps1>) | System | Disables or restores Windows Widgets and its taskbar entry. |
| [9 Copilot.ps1](<6 Windows/9 Copilot.ps1>) | Both | Disables or restores Windows Copilot. |
| [10 Gamemode.ps1](<6 Windows/10 Gamemode.ps1>) | None / external | Opens Windows Gaming > Game Mode settings. |
| [11 Pointer Precision.ps1](<6 Windows/11 Pointer Precision.ps1>) | None / external | Opens Mouse Properties at the pointer-options page. |
| [12 Scaling.ps1](<6 Windows/12 Scaling.ps1>) | None / external | Opens advanced Windows display-scaling settings. |
| [13 Bloatware.ps1](<6 Windows/13 Bloatware.ps1>) | Both | Removes selected or all bloatware, or reinstalls Store, UWP, legacy-app, and optional-feature packages for supported Windows versions. |
| [14 Bloatware Legacy Apps Check.ps1](<6 Windows/14 Bloatware Legacy Apps Check.ps1>) | None / external | Opens Programs and Features and lists installed packages. |
| [15 Bloatware Legacy Features Check.ps1](<6 Windows/15 Bloatware Legacy Features Check.ps1>) | None / external | Opens Optional Features and lists Windows features. |
| [16 Bloatware UWP Apps Check.ps1](<6 Windows/16 Bloatware UWP Apps Check.ps1>) | None / external | Opens Apps & features and lists installed AppX packages. |
| [17 Bloatware UWP Features Check.ps1](<6 Windows/17 Bloatware UWP Features Check.ps1>) | None / external | Opens Optional Features and lists Windows capabilities. |
| [18 Bloatware TaskMgr Check.ps1](<6 Windows/18 Bloatware TaskMgr Check.ps1>) | None / external | Opens Task Manager for a running-process and startup check. |
| [19 Gamebar.ps1](<6 Windows/19 Gamebar.ps1>) | Both | Disables or restores Xbox Game Bar and Game Bar Presence Writer. |
| [20 Edge & WebView.ps1](<6 Windows/20 Edge & WebView.ps1>) | Both | Uninstalls or restores Microsoft Edge and WebView, including the associated region and uninstaller handling. |
| [21 Notepad Settings.ps1](<6 Windows/21 Notepad Settings.ps1>) | User | Applies or restores Notepad settings. |
| [22 Control Panel Settings.ps1](<6 Windows/22 Control Panel Settings.ps1>) | Both | Applies or restores a broad set of Control Panel and Windows settings. |
| [23 Sound.ps1](<6 Windows/23 Sound.ps1>) | None / external | Opens the classic Windows Sound control panel. |
| [24 Loudness EQ.ps1](<6 Windows/24 Loudness EQ.ps1>) | System | Unhides the audio Enhancements tab and displays troubleshooting guidance for loudness equalization. |
| [25 Device Manager Power Savings & Wake.ps1](<6 Windows/25 Device Manager Power Savings & Wake.ps1>) | System | Disables or restores device power-saving and wake behavior for selected ACPI, HID, PCI, and USB devices. |
| [26 Network Adapter Power Savings & Wake.ps1](<6 Windows/26 Network Adapter Power Savings & Wake.ps1>) | System | Disables or restores network-adapter power-saving and wake features, including energy-efficient and green-Ethernet options. |
| [27 Network IPv4 Only.ps1](<6 Windows/27 Network IPv4 Only.ps1>) | System | Disables or restores IPv6 to provide an IPv4-only network configuration. |
| [28 Write Cache Buffer Flushing.ps1](<6 Windows/28 Write Cache Buffer Flushing.ps1>) | System | Disables or restores storage write-cache buffer flushing. |
| [29 Power Plan.ps1](<6 Windows/29 Power Plan.ps1>) | System | Configures the Ultimate Performance power plan and related sleep, hibernate, fast-boot, throttling, and power-button settings, or restores defaults. |
| [30 Timer Resolution.ps1](<6 Windows/30 Timer Resolution.ps1>) | System | Installs or removes a timer-resolution service and toggles global timer-resolution requests. |
| [31 UAC.ps1](<6 Windows/31 UAC.ps1>) | System | Disables or restores User Account Control. |
| [32 Core Isolation.ps1](<6 Windows/32 Core Isolation.ps1>) | None / external | Opens System Information and Windows Security Core Isolation settings. |
| [33 Defender Optimize.ps1](<6 Windows/33 Defender Optimize.ps1>) | Both | Applies or restores Microsoft Defender optimizations through a staged Safe Mode and restart workflow. |
| [34 Autoruns Startup Tasks & Apps Check.ps1](<6 Windows/34 Autoruns Startup Tasks & Apps Check.ps1>) | Both | Creates a restore point, audits and removes selected third-party startup apps and tasks, and downloads/configures Autoruns as a helper. |
| [35 Cleanup.ps1](<6 Windows/35 Cleanup.ps1>) | Both | Clears user and Windows temporary files, removes selected logs and old folders, clears the Windows Update cache, and opens Disk Cleanup. |
| [36 Restore Point.ps1](<6 Windows/36 Restore Point.ps1>) | System | Enables System Restore and creates a restore point. |

## 7 Hardware

| Script | Scope | What it does |
| --- | --- | --- |
| [1 Scaling Higher No Accel.ps1](<7 Hardware/1 Scaling Higher No Accel.ps1>) | User | Offers display-scaling choices above 100% while keeping the script's no-acceleration configuration. |
| [2 Background Polling Rate Cap.ps1](<7 Hardware/2 Background Polling Rate Cap.ps1>) | User | Removes or restores the Windows background mouse-polling cap; the script's default setting is 125 Hz. |
| [3 Mouse Polling Rate Test.ps1](<7 Hardware/3 Mouse Polling Rate Test.ps1>) | None / external | Opens an online mouse polling-rate test and displays mouse setup and low-latency guidance. |
| [4 Controller Overclock.ps1](<7 Hardware/4 Controller Overclock.ps1>) | Both | Downloads HIDUSBF and creates shortcuts for controller polling-rate overclocking. |
| [5 Controller Polling Rate Test.ps1](<7 Hardware/5 Controller Polling Rate Test.ps1>) | Both | Downloads Gamepadla's controller polling-rate test and creates shortcuts for it. |
| [6 Monitor Optimization.ps1](<7 Hardware/6 Monitor Optimization.ps1>) | None / external | Displays a monitor-tuning checklist covering refresh rate, overclocking, sync, brightness, color, and overdrive. |
| [7 Network Bufferbloat Test.ps1](<7 Hardware/7 Network Bufferbloat Test.ps1>) | None / external | Opens Waveform's online bufferbloat test. |
| [8 PC Build Guide.ps1](<7 Hardware/8 PC Build Guide.ps1>) | None / external | Opens the linked PCPartPicker build guide. |

## 8 Advanced

| Script | Scope | What it does |
| --- | --- | --- |
| [1 Defender.ps1](<8 Advanced/1 Defender.ps1>) | System | Disables or enables Microsoft Defender through a staged Safe Mode and RunOnce workflow, with a restart. |
| [2 Firewall.ps1](<8 Advanced/2 Firewall.ps1>) | System | Disables or enables Windows Firewall. |
| [3 Spectre Meltdown.ps1](<8 Advanced/3 Spectre Meltdown.ps1>) | System | Disables or enables the Windows CPU Spectre and Meltdown mitigations. |
| [4 Data Execution Prevention.ps1](<8 Advanced/4 Data Execution Prevention.ps1>) | System | Disables or enables Data Execution Prevention; the script warns that Secure Boot must be off to disable it. |
| [5 File Download Security Warning.ps1](<8 Advanced/5 File Download Security Warning.ps1>) | Both | Disables or enables the Attachment Manager warning shown for downloaded files. |
| [6 MMAgent Features.ps1](<8 Advanced/6 MMAgent Features.ps1>) | System | Checks and disables or restores selected Windows memory-management agent features. |
| [7 ReBar Force.ps1](<8 Advanced/7 ReBar Force.ps1>) | Both | Configures NVIDIA Resizable BAR whitelisting and forced on/off states, or sends the user to firmware settings; it may install NVIDIA Profile Inspector. |
| [8 Smt Ht.ps1](<8 Advanced/8 Smt Ht.ps1>) | Process-only | Temporarily disables SMT or Hyper-Threading for a selected running or startup application. |
| [9 Core 1 Thread 1.ps1](<8 Advanced/9 Core 1 Thread 1.ps1>) | Process-only | Temporarily changes CPU affinity for a selected running or startup application to exclude core 1 and thread 1. |
| [10 Priority.ps1](<8 Advanced/10 Priority.ps1>) | Process-only | Sets a temporary process priority for a selected running or startup application. |
| [11 Mpo.ps1](<8 Advanced/11 Mpo.ps1>) | Both | Enables or disables Multiplane Overlay and related windowed-game optimizations. |
| [12 Hardware Legacy Flip.ps1](<8 Advanced/12 Hardware Legacy Flip.ps1>) | User | Switches between fullscreen-optimization hardware flip behavior and the legacy fullscreen-exclusive path. |
| [13 Hardware Composed Independent Flip.ps1](<8 Advanced/13 Hardware Composed Independent Flip.ps1>) | System | Toggles hardware-composed independent flip versus hardware independent flip behavior. |
| [14 Ulps.ps1](<8 Advanced/14 Ulps.ps1>) | System | Enables, disables, or restores AMD ULPS; the script notes its interaction with HAGS. |
| [15 Driver Whql Secure Boot Bypass.ps1](<8 Advanced/15 Driver Whql Secure Boot Bypass.ps1>) | System | Enables or disables the script's driver WHQL and Secure Boot bypass configuration. |
| [16 Keyboard Shortcuts.ps1](<8 Advanced/16 Keyboard Shortcuts.ps1>) | Both | Restores or disables selected Windows keyboard shortcuts for gaming, while retaining the script's copy/paste handling. |
| [17 Services.ps1](<8 Advanced/17 Services.ps1>) | System | Disables or restores selected Windows services, creates a restore point, and uses a staged Safe Mode and restart workflow. |
| [18 Start Search Shell Mobsync.ps1](<8 Advanced/18 Start Search Shell Mobsync.ps1>) | Both | Disables or restores selected Start/search, taskbar search, Shell, and Mobsync-related behavior. |
| [19 NVME Faster Driver.ps1](<8 Advanced/19 NVME Faster Driver.ps1>) | System | Enables or restores the script's alternate NVMe driver configuration; it warns about DirectStorage compatibility and restart/recovery requirements. |

## Bootstrap and project support scripts

| Script | Scope | What it does |
| --- | --- | --- |
| [IWR.ps1](<IWR.ps1>) | Both | Downloads the upstream toolkit into a folder on the desktop and opens that folder. |
| [AllowScripts.cmd](<AllowScripts.cmd>) | Both | Elevates itself through UAC and toggles the PowerShell execution policy and file-unblocking/file-association setup on or off. |
| [PowerShellHost.ps1](<ui/PowerShellHost.ps1>) | None / external | Runs an original toolkit script behind the native UI, forwarding prompts, pauses, and file-picker requests without showing a console window. |
| [build.ps1](<build/build.ps1>) | Build tooling | Compiles the native UI and packages it with the toolkit into the Windows MSI installer. |
