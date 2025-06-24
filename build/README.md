# Building TimeMinder from Source

This directory contains the script required to build the `TimeMinder.exe` executable from source.

## Prerequisites

1.  **PowerShell:** The build script is a PowerShell script (`.ps1`). This is installed by default on modern Windows systems.
2.  **AutoHotkey v2:** You must have AutoHotkey v2 installed, including the `Ahk2Exe.exe` compiler. The script expects to find the compiler in one of the following standard locations:
    -   `C:\Program Files\AutoHotkey\v2\Compiler\Ahk2Exe.exe`
    -   `C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe`

## How to Build

Open a PowerShell terminal in the root directory of the TimeMinder project.

### Simple Build

To compile `TimeMinder.ahk` into `TimeMinder.exe` in the project root, run the following command:

```powershell
.\build\build.ps1
```

### Creating a Distribution Package

To create a complete distribution package (which includes the executable, sounds, and README), run the script with the `-Distribution` flag. The output will be placed in a `dist/` folder in the project root.

```powershell
.\build\build.ps1 -Distribution
``` 