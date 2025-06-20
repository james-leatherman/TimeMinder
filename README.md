# TimeMinder

## Overview
TimeMinder is an AutoHotkey (AHK) script designed to help you manage your time efficiently.

---

## Prerequisites
- **Windows OS**
- **AutoHotkey v2**

---

## Installation

1. **Download and Install AutoHotkey**
   - Visit the official AutoHotkey website: [https://www.autohotkey.com/](https://www.autohotkey.com/)
   - Click the **Download** button and follow the installation instructions for AutoHotkey v2.

2. **Clone or Download this Repository**
   - Download or clone this repository to your local machine.

---

## Running the Script

1. **Open PowerShell or Command Prompt**
2. **Navigate to the script directory:**
   ```powershell
   cd "C:\Users\james\Documents\GitHub\TimeMinder"
   ```
3. **Run the script using AutoHotkey:**
   - If you installed AutoHotkey to the default location, use:
     ```powershell
     & "C:\Program Files\AutoHotkey\v2\AutoHotkey.exe" "TimeMinder.ahk"
     ```
   - If AutoHotkey is installed elsewhere, adjust the path accordingly.

---

## Notes
- You can also run the script by right-clicking `TimeMinder.ahk` and selecting **Run with AutoHotkey**.
- For advanced usage or passing arguments, append them after the script name:
  ```powershell
  & "C:\Program Files\AutoHotkey\v2\AutoHotkey.exe" "TimeMinder.ahk" arg1 arg2
  ```

---

## Usage

- **Drag the Window:**
  - Click and hold on any text area (timer, clock, or labels) to drag the TimeMinder window to your preferred location.

- **Start a Break:**
  - When the session timer reaches zero or at any time, hover over the timer and click the "Take Break" button to begin your break.

- **End a Break:**
  - Click the green "On Break" button to end your break and resume your session timer.

---

## Command-Line Arguments

You can customize the timer durations by passing up to three arguments (in minutes) when launching the script:

```
& "C:\Program Files\AutoHotkey\v2\AutoHotkey.exe" "TimeMinder.ahk" [sessionTime] [breakTime] [totalTime]
```

- `sessionTime` (optional): Length of a work/play session in minutes. **Default:** 30
- `breakTime` (optional): Length of a break in minutes. **Default:** 10
- `totalTime` (optional): Total time before "Finish Up" warning in minutes. **Default:** 180 (3 hours)

**Examples:**
- 25-minute sessions, 5-minute breaks, 2-hour total:
  ```powershell
  & "C:\Program Files\AutoHotkey\v2\AutoHotkey.exe" "TimeMinder.ahk" 25 5 120
  ```
- 50-minute sessions, default break and total:
  ```powershell
  & "C:\Program Files\AutoHotkey\v2\AutoHotkey.exe" "TimeMinder.ahk" 50
  ```

---

## Hotkey Usage

While TimeMinder is running, you can use the following keyboard shortcuts:

| Hotkey           | Action                        |
|------------------|-------------------------------|
| Ctrl + Right     | Add 5 minutes to session      |
| Ctrl + Left      | Subtract 5 minutes from session|
| Ctrl + .         | Add 1 minute to session       |
| Ctrl + ,         | Subtract 1 minute from session|
| Ctrl + PgDn      | Set session time to limit     |
| Ctrl + PgUp      | Reset session time to zero    |
| Ctrl + End       | Set total time to limit       |
| Ctrl + Home      | Reset total time to zero      |
| Ctrl + Q         | Quit the app                  |

---

## More Information
- Official AutoHotkey documentation: [https://www.autohotkey.com/docs/](https://www.autohotkey.com/docs/) 