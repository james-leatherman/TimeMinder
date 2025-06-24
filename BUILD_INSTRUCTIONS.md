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