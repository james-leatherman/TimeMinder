# TimeMinder

![TimeMinder Logo](images/TimeMinderLogo.png)

## Overview
TimeMinder is a lightweight, customizable timer designed to help you manage your work and break intervals effectively. Built with AutoHotkey v2, it provides a simple, always-on-top interface to keep you mindful of your screen time.


---

## Features
- **Customizable Timers:** Set session, break, and total time limits via command line. Defaults: 60 min session, 30 min break, 180 min total.
- **Always-On-Top:** The timer window stays visible over other applications.
- **Visual Alerts:** The timer changes color and flashes to notify you when it's time for a break or to wrap up.
- **Draggable Interface:** Click and drag the timer anywhere on your screen.
- **Hotkey Support:** Adjust timers, start/end breaks, and quit the app with keyboard shortcuts.
- **Break Timer Display:** When on break, the break button shows a live-updating timer of elapsed break time.
- **Advanced Sound Management:** Download, store, and organize custom notification sounds with persistent settings between restarts.
- **Notification Sounds:** When session or total time elapses, a notification sound will play every 15 seconds until you click the break/finish button. You can set a custom sound file (WAV, MP3, etc) or use the default beep.
- **Custom Sound Hotkey:** Press Ctrl+Shift+S to open the sound management menu with options to download, select, and manage sound files.

---

## Screenshots

| Start | Unscheduled Break | Scheduled Break |
|---|---|---|
| ![Start](images/start.jpg) | ![Unscheduled Break](images/unsched-break.jpg) | ![Scheduled Break](images/sched-break.jpg) |

| On Break  | End of Day | Day is Done |
|---|---|---|
| ![On Break](images/on-break.jpg) | ![End of Day](images/end-of-day.jpg) | ![Day is Done](images/day-is-done.jpg) |



---

## Getting Started

You have several options to get started with TimeMinder, listed from easiest to most advanced:

### Option 1: Use the Windows Installer (Recommended)

For the simplest setup, download and run the all-in-one installer:

- **[Download TimeMinderSetup.exe](https://github.com/james-leatherman/TimeMinder/releases/latest/download/TimeMinderSetup.exe)**

This will install TimeMinder, create shortcuts, and place all required files in the appropriate location.
Just double-click the installer and follow the prompts.

---

### Option 2: Download the Standalone EXE

If you prefer a portable version without installation:

- **[Download TimeMinder.exe](https://github.com/james-leatherman/TimeMinder/releases/latest/download/TimeMinder.exe)**

Simply run the downloaded file to start the timer.
*Note: This may trigger Windows Defender SmartScreen.*

---

### Option 3: Download the Script

If you have AutoHotkey v2 installed, you can run the script directly:

- **[Download TimeMinder.ahk](https://github.com/james-leatherman/TimeMinder/blob/main/TimeMinder.ahk)**

Run the script by right-clicking it and selecting `Run with AutoHotkey`, or run it from the command line.

---

### Option 4: Clone the Repository and Build from Source

To get the full source code, including all assets and documentation, clone the repository using Git:

```sh
git clone https://github.com/james-leatherman/TimeMinder.git
cd TimeMinder
```

You can then build the executable or distribution package yourself. See the "Building from Source" section below for details.

---

## Prerequisites
If you choose to use the `.ahk` script (Option 2 or 3), you will need:
- **Windows OS**
- **[AutoHotkey v2](https://www.autohotkey.com/v2/)**

---

## How to Run the Script

1. **Open PowerShell or Command Prompt.**
2. **Navigate to the script's directory.**
3. **Run the script using AutoHotkey:**
   ```powershell
   # If AutoHotkey is in your system's PATH
   AutoHotkey.exe TimeMinder.ahk

   # Or provide the full path
   & "C:\Program Files\AutoHotkey\v2\AutoHotkey.exe" "TimeMinder.ahk"
   ```

---

## Command-Line Arguments

You can customize the timer durations by passing up to three arguments (in minutes) when launching the script:

```powershell
# For the .exe
TimeMinder.exe [sessionTime] [breakTime] [totalTime]

# For the .ahk script
AutoHotkey.exe TimeMinder.ahk [sessionTime] [breakTime] [totalTime]
```

| Argument      | Description                                     | Default |
|---------------|-------------------------------------------------|---------|
| `sessionTime` | Length of a work session in minutes.            | 30      |
| `breakTime`   | Length of a break in minutes.                   | 10      |
| `totalTime`   | Total time before "Finish Up" warning (in minutes). | 180     |

**Examples:**
- 25-minute sessions, 5-minute breaks, 2-hour total:
  ```powershell
  TimeMinder.exe 25 5 120
  ```
- 50-minute sessions with default break and total times:
  ```powershell
  TimeMinder.exe 50
  ```

---

## Hotkeys

While TimeMinder is running, you can use the following keyboard shortcuts:

| Hotkey           | Action                        |
|------------------|-------------------------------|
| `Ctrl` + `Right` | Add 5 minutes to the session  |
| `Ctrl` + `Left`  | Subtract 5 minutes from the session |
| `Ctrl` + `.`     | Add 1 minute to the session   |
| `Ctrl` + `,`     | Subtract 1 minute from the session |
| `Ctrl` + `PgDn`  | Set session time to its limit |
| `Ctrl` + `PgUp`  | Reset session time to zero    |
| `Ctrl` + `End`   | Set total time to its limit   |
| `Ctrl` + `Home`  | Reset total time to zero      |
| `Ctrl` + `Q`     | Quit the application          |
| `Ctrl` + `]`     | Add 1 minute to elapsed break time (if on break) |
| `Ctrl` + `[`     | Subtract 1 minute from elapsed break time (if on break) |
| `Ctrl` + `Shift` + `S` | Open sound management menu |
| `Ctrl` + `Shift` + `I` | Show sound information and status |

---

## Sound Management

TimeMinder includes comprehensive sound management features that allow you to:

- **Download sound files** directly from URLs
- **Store sound files locally** in a dedicated `sounds/` directory
- **Persist sound settings** between application restarts
- **Organize and manage** multiple sound files
- **Copy external files** to the sounds directory for better organization

### Quick Start with Sound Management

1. **Press `Ctrl+Shift+S`** to open the sound management menu
2. **Choose an option:**
   - "Download from URL" to download a sound file from the internet
   - "Select Local File" to choose an existing sound file
   - "Select from Downloaded" to choose from previously downloaded files
   - "Clear Custom Sound" to use the default beep
3. **Press `Ctrl+Shift+I`** to view sound information and status

For detailed information about sound management features, see **[SOUND_MANAGEMENT.md](SOUND_MANAGEMENT.md)**.

---

## Building from Source

### For Developers

If you want to build TimeMinder from source or create your own distribution:

#### Prerequisites
- **Windows OS**
- **AHK2EXE** (AutoHotkey compiler)

#### Quick Build

1. **Install AHK2EXE**:
   - Download from [https://www.autohotkey.com/download/](https://www.autohotkey.com/download/)
   - Extract to `C:\Tools\Ahk2Exe\`

2. **Build TimeMinder**:
   ```powershell
   # Basic build
   .\build.ps1

   # Build with compression (smaller file)
   .\build.ps1 -Compress

   # Create complete distribution
   .\create_distribution.ps1
   ```

#### Build Options

```powershell
# 32-bit version
.\build.ps1 -Architecture 32

# Custom output name
.\build.ps1 -OutputName "TimeMinder_v1.0.exe"

# Complete distribution with version
.\create_distribution.ps1 -Version "1.1" -Compress
```

#### Alternative Build Methods

```cmd
# Using batch script
.\build.bat

# Manual compilation
"C:\Tools\Ahk2Exe\Ahk2Exe.exe" /in TimeMinder.ahk /out TimeMinder.exe /icon images\TimeMinderIcon.ico /bin 64 /compress 1
```

For detailed build instructions, see **[BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md)** and **[PACKAGING_GUIDE.md](PACKAGING_GUIDE.md)**.

### Build Scripts

The repository includes several build scripts:

- **`build.ps1`** - PowerShell build script with advanced options
- **`build.bat`** - Batch file build script for simple compilation
- **`create_distribution.ps1`** - Complete distribution package creator
- **`BUILD_INSTRUCTIONS.md`** - Quick start guide for building
- **`PACKAGING_GUIDE.md`** - Comprehensive packaging documentation

### Distribution Package

The build process creates:
- **Standalone executable** (no AutoHotkey required)
- **Complete distribution folder** with all files
- **ZIP archive** for easy distribution
- **Documentation** and configuration files

---

## Project Structure

```
TimeMinder/
├── TimeMinder.ahk              # Main script
├── TimeMinder.ini              # Configuration file (auto-created)
├── sounds/                     # Sound files directory
│   └── quack.mp3              # Default sound file
├── images/                     # Images and icons
│   ├── TimeMinderIcon.ico     # Application icon
│   └── TimeMinderLogo.png     # Logo
├── build.ps1                   # PowerShell build script
├── build.bat                   # Batch build script
├── create_distribution.ps1     # Distribution creator
├── README.md                   # This file
├── SOUND_MANAGEMENT.md         # Sound management documentation
├── BUILD_INSTRUCTIONS.md       # Build instructions
└── PACKAGING_GUIDE.md          # Comprehensive packaging guide
```

---

## Contributing

1. **Fork the repository**
2. **Create a feature branch**
3. **Make your changes**
4. **Test thoroughly**
5. **Submit a pull request**

### Development Guidelines

- Follow AutoHotkey v2 syntax
- Test on both 32-bit and 64-bit systems
- Ensure all features work in compiled executable
- Update documentation for new features

---

## More Information
- Official AutoHotkey documentation: [https://www.autohotkey.com/docs/](https://www.autohotkey.com/docs/) 
