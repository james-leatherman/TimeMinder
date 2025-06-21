# TimeMinder

![TimeMinder Logo](images/TimeMinderLogo.png)

## Overview
TimeMinder is a lightweight, customizable timer designed to help you manage your work and break intervals effectively. Built with AutoHotkey v2, it provides a simple, always-on-top interface to keep you mindful of your screen time.

---

## Features
- **Customizable Timers:** Set session, break, and total time limits via command line.
- **Always-On-Top:** The timer window stays visible over other applications.
- **Visual Alerts:** The timer changes color and flashes to notify you when it's time for a break or to wrap up.
- **Draggable Interface:** Click and drag the timer anywhere on your screen.
- **Hotkey Support:** Adjust timers, start/end breaks, and quit the app with keyboard shortcuts.

---

## Getting Started

You have three options to get started with TimeMinder:

### Option 1: Download the EXE (Recommended)
For a plug-and-play experience without any dependencies, download the compiled `.exe` file.

- **[Download TimeMinder.exe](https://github.com/USERNAME/TimeMinder/releases/latest/download/TimeMinder.exe)**

Simply run the downloaded file to start the timer.

### Option 2: Download the Script
If you have AutoHotkey v2 installed, you can download the script file directly.

- **[Download TimeMinder.ahk](TimeMinder.ahk?raw=true)**

Run the script by right-clicking it and selecting `Run with AutoHotkey`, or run it from the command line.

### Option 3: Clone the Repository
To get the full source code, including the logo and README, clone the repository using Git.

```sh
git clone https://github.com/USERNAME/TimeMinder.git
cd TimeMinder
```

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

---

## More Information
- Official AutoHotkey documentation: [https://www.autohotkey.com/docs/](https://www.autohotkey.com/docs/) 