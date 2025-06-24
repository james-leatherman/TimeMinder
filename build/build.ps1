# TimeMinder Build & Distribution Script
#
# Default (no parameters): Builds TimeMinder.exe to the project root.
# Usage: .\build\build.ps1 [-Compress]
#
# Distribution Mode: Creates a complete, versioned distribution package.
# Usage: .\build\build.ps1 -Distribution [-Version "1.0"] [-Architecture "64"] [-Compress]

param(
    # --- General Parameters ---
    [string]$Architecture = "64",
    [switch]$Compress,

    # --- Distribution Parameters ---
    [switch]$Distribution,
    [string]$Version = "1.0"
)

# --- Configuration ---
$Ahk2ExePath = ".\Ahk2Exe.exe"
$SourceFile = "..\TimeMinder.ahk"
$IconFile = "..\images\TimeMinderIcon.ico"


# --- Prerequisite Checks ---
if (!(Test-Path $Ahk2ExePath)) {
    Write-Host "ERROR: Ahk2Exe not found at: $Ahk2ExePath" -ForegroundColor Red
    Write-Host "Please install Ahk2Exe or update the path in this script." -ForegroundColor Yellow
    Write-Host "Download from: https://github.com/AutoHotkey/Ahk2Exe/releases" -ForegroundColor Cyan
    exit 1
}

if (!(Test-Path $SourceFile)) {
    Write-Host "ERROR: Source file not found: $SourceFile" -ForegroundColor Red
    exit 1
}


# --- Main Logic ---
if ($Distribution) {
    # --- DISTRIBUTION MODE ---
    Create-Distribution -Version $Version -Architecture $Architecture -Compress:$Compress
}
else {
    # --- SIMPLE BUILD MODE ---
    Build-Executable -Architecture $Architecture -Compress:$Compress
}


# --- Function Definitions ---

function Build-Executable {
    param(
        [string]$Architecture,
        [switch]$Compress
    )
    $OutputName = "..\TimeMinder.exe"

    Write-Host "Building TimeMinder Executable..." -ForegroundColor Green
    Write-Host "Architecture: $Architecture-bit" -ForegroundColor Cyan
    Write-Host "Compression: $(if ($Compress) { 'Enabled' } else { 'Disabled' })" -ForegroundColor Cyan
    Write-Host "Output: $OutputName" -ForegroundColor Cyan

    $BuildCommand = "$Ahk2ExePath /in `"$SourceFile`" /out `"$OutputName`" /bin $Architecture"
    if ($IconFile -ne "" -and (Test-Path $IconFile)) {
        $BuildCommand += " /icon `"$IconFile`""
    }
    if ($Compress) {
        $BuildCommand += " /compress 1"
    }

    Write-Host "Command: $BuildCommand" -ForegroundColor Gray
    Invoke-Command -Command $BuildCommand
}

function Create-Distribution {
    param(
        [string]$Version,
        [string]$Architecture,
        [switch]$Compress
    )

    # Distribution settings
    $DistDir = "..\TimeMinder_v$Version"
    $ExeName = "TimeMinder_v$Version.exe"
    $ZipName = "..\TimeMinder_v$Version.zip"
    $DistExePath = "$DistDir\$ExeName"

    Write-Host "Creating TimeMinder Distribution v$Version" -ForegroundColor Green
    
    # Clean previous distribution
    if (Test-Path $DistDir) {
        Write-Host "Cleaning previous distribution..." -ForegroundColor Yellow
        Remove-Item $DistDir -Recurse -Force
    }
    if (Test-Path $ZipName) {
        Remove-Item $ZipName -Force
    }

    # Create directory structure
    Write-Host "Creating distribution directory..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $DistDir | Out-Null
    New-Item -ItemType Directory -Path "$DistDir\sounds" | Out-Null
    New-Item -ItemType Directory -Path "$DistDir\images" | Out-Null

    # Compile executable
    Write-Host "Compiling TimeMinder..." -ForegroundColor Cyan
    $BuildCommand = "$Ahk2ExePath /in `"$SourceFile`" /out `"$DistExePath`" /bin $Architecture"
    if ($IconFile -ne "" -and (Test-Path $IconFile)) {
        $BuildCommand += " /icon `"$IconFile`""
    }
    if ($Compress) {
        $BuildCommand += " /compress 1"
    }
    
    Write-Host "Build command: $BuildCommand" -ForegroundColor Gray
    Invoke-Command -Command $BuildCommand
    
    # Copy supporting files
    Write-Host "Copying supporting files..." -ForegroundColor Cyan
    Copy-Item "..\sounds\*" "$DistDir\sounds\" -Recurse -Force
    Copy-Item "..\images\*" "$DistDir\images\" -Recurse -Force
    Copy-Item "..\README.md" "$DistDir\" -Force

    # Create ZIP archive
    Write-Host "Creating ZIP archive..." -ForegroundColor Cyan
    Compress-Archive -Path $DistDir -DestinationPath $ZipName -CompressionLevel Optimal

    Write-Host "`nDistribution created successfully!" -ForegroundColor Green
    Write-Host "Output Folder: $DistDir" -ForegroundColor Cyan
    Write-Host "ZIP Archive: $ZipName" -ForegroundColor Cyan
}

function Invoke-Command {
    param([string]$Command)
    try {
        Invoke-Expression $Command
        if ($LASTEXITCODE -ne 0) {
            Write-Host "ERROR: Operation failed with exit code: $LASTEXITCODE" -ForegroundColor Red
            exit 1
        }
        Write-Host "Operation successful!" -ForegroundColor Green
    } catch {
        Write-Host "ERROR: Operation failed with error: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
} 