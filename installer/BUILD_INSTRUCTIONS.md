# TimeMinder Build Instructions

## Quick Build Guide

### Step 1: Install AHK2EXE

1. **Download AHK2EXE**:
   - Go to [https://www.autohotkey.com/download/](https://www.autohotkey.com/download/)
   - Scroll down to find "Ahk2Exe" section
   - Download the latest version (usually `Ahk2Exe.zip`)

2. **Install AHK2EXE**:
   - Create folder: `C:\Tools\Ahk2Exe\`
   - Extract the downloaded ZIP to this folder
   - Verify `Ahk2Exe.exe` exists in the folder

### Step 2: Build TimeMinder

#### Option A: Using PowerShell Script (Recommended)
```powershell
# Basic build
.\build.ps1

# Build with compression (smaller file)
.\build.ps1 -Compress

# Build 32-bit version
.\build.ps1 -Architecture 32

# Custom output name
.\build.ps1 -OutputName "TimeMinder_v1.0.exe"
```

#### Option B: Using Batch Script
```cmd
# Basic build
.\build.bat

# 64-bit with compression
.\build.bat 64 1

# 32-bit without compression
.\build.bat 32 0
```

#### Option C: Manual Command
```cmd
"C:\Tools\Ahk2Exe\Ahk2Exe.exe" /in TimeMinder.ahk /out TimeMinder.exe /icon images\TimeMinderIcon.ico /bin 64 /compress 1
```

### Step 3: Create Distribution Package

```powershell
# Create complete distribution with all files
.\create_distribution.ps1

# Create distribution with specific version
.\create_distribution.ps1 -Version "1.1"

# Create compressed distribution
.\create_distribution.ps1 -Compress
```

## Troubleshooting

### "Ahk2Exe not found"
- Verify AHK2EXE is installed at `C:\Tools\Ahk2Exe\Ahk2Exe.exe`
- Update the path in build scripts if installed elsewhere
- Download from: https://www.autohotkey.com/download/

### "Icon file not found"
- The build will continue with default AutoHotkey icon
- Ensure `images\TimeMinderIcon.ico` exists for custom icon

### "Build failed"
- Check that `TimeMinder.ahk` exists in the current directory
- Verify AHK2EXE is properly installed
- Check file permissions

## Output Files

After successful build, you'll have:
- `TimeMinder.exe` - Standalone executable (no AutoHotkey required)
- `TimeMinder_v1.0/` - Complete distribution folder
- `TimeMinder_v1.0.zip` - Compressed distribution package

## Testing

1. **Test the executable** on a clean system (without AutoHotkey)
2. **Verify all features work**:
   - Timer functionality
   - Sound management (`Ctrl+Shift+S`)
   - Configuration persistence
   - All hotkeys
3. **Check file size** and startup time

## Distribution

The distribution package includes:
- Compiled executable
- Sound files
- Images and icons
- Documentation (README, SOUND_MANAGEMENT.md)
- Configuration files (created on first run)

Users can run TimeMinder without installing AutoHotkey! 

## Inno Setup

### 1. Download and Install Inno Setup

- Go to: https://jrsoftware.org/isinfo.php
- Download and install Inno Setup on your Windows machine.

### 2. Prepare Your Files

Make sure your build output and all required files are in a single folder, e.g.:
```
TimeMinder\
  TimeMinder.exe
  images\
  sounds\
  README.md
  SOUND_MANAGEMENT.md
```
(You can use your distribution folder or create a new one for the installer.)

### 3. Create the Inno Setup Script

Here's a script tailored for your project. Save this as `TimeMinder.iss` in your project root:

```inno
[Setup]
AppName=TimeMinder
AppVersion=1.0
DefaultDirName={pf}\TimeMinder
DefaultGroupName=TimeMinder
OutputDir=.
OutputBaseFilename=TimeMinderSetup
Compression=lzma
SolidCompression=yes

[Files]
Source: "TimeMinder.exe"; DestDir: "{app}"
Source: "images\*"; DestDir: "{app}\images"; Flags: recursesubdirs createallsubdirs
Source: "sounds\*"; DestDir: "{app}\sounds"; Flags: recursesubdirs createallsubdirs
Source: "README.md"; DestDir: "{app}"
Source: "SOUND_MANAGEMENT.md"; DestDir: "{app}"

[Icons]
Name: "{group}\TimeMinder"; Filename: "{app}\TimeMinder.exe"
Name: "{userdesktop}\TimeMinder"; Filename: "{app}\TimeMinder.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop icon"; GroupDescription: "Additional icons:"

[Run]
Filename: "{app}\TimeMinder.exe"; Description: "Launch TimeMinder"; Flags: nowait postinstall skipifsilent
```

### 4. Build the Installer

1. Open Inno Setup.
2. Open your `TimeMinder.iss` script.
3. Click "Compile".
4. The output will be `TimeMinderSetup.exe` in your project root.

### 5. Test the Installer

- Run `TimeMinderSetup.exe` on a test machine (or VM) to ensure it installs everything correctly.
- Check that shortcuts are created and the app runs.

**You can further customize the script (version, icons, uninstall, etc.) as needed. Let me know if you want to add more features or need help with any step!** 