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

TimeMinder now stores all custom/downloaded sound files in `%APPDATA%\TimeMinder\sounds` and configuration in `%APPDATA%\TimeMinder\TimeMinder.ini`. This avoids permissions issues and works for all users.

### Quick Start with Sound Management

1. **Press `Ctrl+Shift+S`** to open the sound management menu
2. **Choose an option:**
   - "Download from URL" to download a sound file from the internet
   - "Select Local File" to choose an existing sound file
   - "Select from Downloaded" to choose from previously downloaded files
   - "Clear Custom Sound" to use the default beep
3. **Press `Ctrl+Shift+I`** to view sound information and status

---

## Building from Source

If you have cloned the repository and wish to build the executable yourself, you can use the provided PowerShell build script.

For detailed instructions on using the build script, including prerequisites and command options, please see the dedicated guide:

- **[build/README.md](build/README.md)**

---

## Project Structure

Repository Layout:
TimeMinder/
├── TimeMinder.ahk              # Main script (source)
├── images/                     # Images and icons
│   ├── TimeMinderIcon.ico
│   └── TimeMinderLogo.png
├── build/                      # Build scripts and installer definition
│   ├── build.ps1
│   ├── TimeMinder.iss
│   └── ...
├── README.md                   # Project documentation
├── SOUND_MANAGEMENT.md         # Sound management documentation
├── BUILD_INSTRUCTIONS.md       # Build instructions
└── PACKAGING_GUIDE.md          # Packaging guide

User Data (created at runtime, not in repo):
%APPDATA%/TimeMinder/
├── TimeMinder.ini              # User configuration file
└── sounds/                     # User's custom/downloaded sound files
    └── quack.mp3               # Default sound file (copied on first run)

*Note: As of v1.0.2, all configuration and sound files are stored in the user's AppData folder, not the install directory or repository.*
*The installer (TimeMinderSetup.exe) and portable EXE are available on the [Releases page](https://github.com/james-leatherman/TimeMinder/releases).*

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

## Important Changes in v1.0.2

- All configuration and sound files are now stored in `%APPDATA%\TimeMinder` (per-user, no admin rights needed)
- On first run, any old config or sound files in the install directory are automatically migrated to AppData
- The uninstaller will remove all AppData data for a clean uninstall
- The build script now cleans up old `.exe` files before building
- Download the latest installer or EXE from the [Releases page](https://github.com/james-leatherman/TimeMinder/releases)
