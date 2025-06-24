# TimeMinder Packaging Guide

This guide explains how to package TimeMinder into a standalone executable using AHK2EXE.

## Prerequisites

### 1. Install AHK2EXE

AHK2EXE is the official AutoHotkey compiler. You can install it in several ways:

#### Option A: Download from AutoHotkey Website (Recommended)
1. Go to [https://www.autohotkey.com/download/](https://www.autohotkey.com/download/)
2. Scroll down to "Ahk2Exe" section
3. Download the latest version (usually named `Ahk2Exe.zip`)
4. Extract the ZIP file to a convenient location (e.g., `C:\Tools\Ahk2Exe\`)
5. Add the directory to your system PATH or use the full path

#### Option B: Use the Online Compiler
If you prefer not to install locally, you can use the online compiler at [https://www.autohotkey.com/ahk2exe/](https://www.autohotkey.com/ahk2exe/)

#### Option C: Manual Installation
1. Create directory: `C:\Tools\Ahk2Exe\`
2. Download Ahk2Exe from the AutoHotkey website
3. Extract all files to the created directory
4. Verify `Ahk2Exe.exe` exists in the directory

### 2. Verify Installation

After installation, verify AHK2EXE is available:
```powershell
# If added to PATH
ahk2exe --version

# Or use full path
"C:\Tools\Ahk2Exe\Ahk2Exe.exe" --version
```

## Quick Start

### 1. Install AHK2EXE
Follow the installation instructions above.

### 2. Update Build Scripts
If you installed AHK2EXE in a different location, update the path in the build scripts:
- `build.ps1` - Line 8: `$Ahk2ExePath = "C:\Tools\Ahk2Exe\Ahk2Exe.exe"`
- `build.bat` - Line 12: `set AHK2EXE=C:\Tools\Ahk2Exe\Ahk2Exe.exe`
- `create_distribution.ps1` - Line 8: `$Ahk2ExePath = "C:\Tools\Ahk2Exe\Ahk2Exe.exe"`

### 3. Build TimeMinder
```powershell
# Basic build
.\build.ps1

# Build with compression
.\build.ps1 -Compress

# Create complete distribution
.\create_distribution.ps1
```

## Packaging Methods

### Method 1: Command Line (Recommended)

#### Basic Packaging
```powershell
# Navigate to TimeMinder directory
cd C:\Users\james\Documents\GitHub\TimeMinder

# Basic compilation
ahk2exe /in TimeMinder.ahk /out TimeMinder.exe
```

#### Advanced Packaging with Icon
```powershell
# Compile with custom icon
ahk2exe /in TimeMinder.ahk /out TimeMinder.exe /icon images/TimeMinderIcon.ico

# Compile with compression
ahk2exe /in TimeMinder.ahk /out TimeMinder.exe /icon images/TimeMinderIcon.ico /compress 1

# Compile for specific architecture (32-bit or 64-bit)
ahk2exe /in TimeMinder.ahk /out TimeMinder.exe /icon images/TimeMinderIcon.ico /bin 64
```

#### Using the Provided Build Scripts
```powershell
# PowerShell build script
.\build.ps1                    # Basic build
.\build.ps1 -Compress          # Build with compression
.\build.ps1 -Architecture 32   # Build 32-bit version
.\build.ps1 -OutputName "TimeMinder_v1.0.exe"  # Custom output name

# Batch build script
.\build.bat                    # Basic build
.\build.bat 64 1              # 64-bit with compression
.\build.bat 32 0 "TimeMinder_x86.exe"  # 32-bit without compression, custom name
```

### Method 2: GUI Compiler

If you prefer a graphical interface:

1. **Download Ahk2Exe GUI**: From [https://www.autohotkey.com/download/](https://www.autohotkey.com/download/)
2. **Extract and run** `Ahk2Exe.exe`
3. **Configure settings**:
   - Source: `TimeMinder.ahk`
   - Destination: `TimeMinder.exe`
   - Custom Icon: `images\TimeMinderIcon.ico`
   - Base File: Choose appropriate base file (32-bit or 64-bit)
   - Compression: Enable if desired
4. **Click Convert**

### Method 3: Online Compiler

1. Go to [https://www.autohotkey.com/ahk2exe/](https://www.autohotkey.com/ahk2exe/)
2. Upload your `TimeMinder.ahk` file
3. Configure options (icon, compression, etc.)
4. Download the compiled executable

## Packaging Options

### 1. Architecture Selection
- **32-bit**: `/bin 32` - Smaller file size, broader compatibility
- **64-bit**: `/bin 64` - Better performance on 64-bit systems (recommended)

### 2. Compression
- **Enabled**: `/compress 1` - Smaller executable, slower startup
- **Disabled**: No compression - Larger file, faster startup

### 3. Icon Customization
- **Custom Icon**: `/icon path\to\icon.ico`
- **Default Icon**: No icon parameter (uses AutoHotkey default)

### 4. Output Naming
- **Standard**: `TimeMinder.exe`
- **Versioned**: `TimeMinder_v1.0.exe`
- **Architecture-specific**: `TimeMinder_x64.exe`

## Distribution Package

### Create a Complete Distribution

1. **Compile the executable**
2. **Create distribution folder structure**:
```
TimeMinder_Distribution/
├── TimeMinder.exe
├── sounds/
│   └── quack.mp3
├── images/
│   ├── TimeMinderIcon.ico
│   └── TimeMinderLogo.png
├── README.md
├── SOUND_MANAGEMENT.md
└── PACKAGING_GUIDE.md
```

### Using the Distribution Script

```powershell
# Create basic distribution
.\create_distribution.ps1

# Create distribution with specific version
.\create_distribution.ps1 -Version "1.1"

# Create distribution with compression
.\create_distribution.ps1 -Compress

# Create 32-bit distribution
.\create_distribution.ps1 -Architecture "32"
```

## Troubleshooting

### Common Issues

1. **"Ahk2Exe not found"**
   - Verify AHK2EXE is installed and in PATH
   - Use full path to Ahk2Exe.exe
   - Update the path in build scripts

2. **"Icon file not found"**
   - Verify icon file exists at specified path
   - Use relative or absolute path
   - Check file permissions

3. **"Compilation failed"**
   - Check for syntax errors in TimeMinder.ahk
   - Verify all required files are present
   - Check file permissions

4. **"Executable doesn't run"**
   - Test on target system architecture
   - Check for missing dependencies
   - Verify antivirus isn't blocking execution

### Testing the Package

1. **Test on clean system** (without AutoHotkey installed)
2. **Verify all features work**:
   - Timer functionality
   - Sound management
   - Configuration persistence
   - Hotkeys
3. **Check file associations** and permissions

## Best Practices

### 1. Version Management
- Use semantic versioning (e.g., v1.0.0)
- Include version in executable name
- Document changes in README

### 2. Distribution
- Include all necessary files
- Provide clear installation instructions
- Test on multiple Windows versions

### 3. Security
- Sign executables if possible
- Scan for malware before distribution
- Use trusted compilation tools

### 4. Performance
- Test startup time
- Verify memory usage
- Check CPU usage during operation

## Advanced Packaging

### Multi-Architecture Build

```powershell
# Build both 32-bit and 64-bit versions
$Architectures = @("32", "64")

foreach ($Arch in $Architectures) {
    $OutputName = "TimeMinder_x$Arch.exe"
    Write-Host "Building $Arch-bit version..."
    
    & "C:\Tools\Ahk2Exe\Ahk2Exe.exe" /in TimeMinder.ahk /out $OutputName /icon images\TimeMinderIcon.ico /bin $Arch /compress 1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Successfully built: $OutputName"
    } else {
        Write-Host "Failed to build $Arch-bit version"
    }
}
```

### Automated CI/CD

For continuous integration, you can create GitHub Actions workflows or similar automation to build and distribute TimeMinder automatically when code changes.

This packaging guide provides comprehensive instructions for creating professional distributions of TimeMinder that users can run without needing AutoHotkey installed. 