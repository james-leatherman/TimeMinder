# TimeMinder Build Script
#
# Default (no parameters): Builds TimeMinder.exe to the project root.
# Usage: .\build\build.ps1
#
# Distribution Mode: Creates a complete distribution package in the /dist folder.
# Usage: .\build\build.ps1 -Distribution

param(
    [switch]$Distribution
)

# --- Configuration ---
# Get the directory of the script itself
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Define project root relative to the script's location
$ProjectRoot = Resolve-Path -Path (Join-Path -Path $ScriptDir -ChildPath "..")

# Define all paths relative to the project root
$SourceFile = Join-Path -Path $ProjectRoot -ChildPath "TimeMinder.ahk"
$IconFile = Join-Path -Path $ProjectRoot -ChildPath "images\TimeMinderIcon.ico"
$OutputFile = Join-Path -Path $ProjectRoot -ChildPath "TimeMinder.exe"
$DistributionFolder = Join-Path -Path $ProjectRoot -ChildPath "dist"

# Define potential compiler paths
$CompilerPaths = @(
    "C:\Program Files\AutoHotkey\v2\Compiler\Ahk2Exe.exe",
    "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe"
)

# --- Prerequisite Checks ---

# Find the AutoHotkey compiler
$Ahk2ExePath = $null
foreach ($path in $CompilerPaths) {
    if (Test-Path $path) {
        $Ahk2ExePath = $path
        Write-Host "Found Ahk2Exe.exe at: $Ahk2ExePath"
        break
    }
}

if (-not $Ahk2ExePath) {
    Write-Error "Could not find Ahk2Exe.exe in any of the expected locations. Please install AutoHotkey v2 or update the path in this script."
    exit 1
}

# Check for source file
if (-not (Test-Path $SourceFile)) {
    Write-Error "Source file not found: $SourceFile"
    exit 1
}

# --- Build Logic ---

# Clean up previous build executable
if (Test-Path $OutputFile) {
    Remove-Item -Path $OutputFile -Force
    Write-Host "Removed old executable: $OutputFile"
}

# Set up compiler arguments
$CompilerArgs = @(
    "/in", "`"$SourceFile`"",
    "/out", "`"$OutputFile`"",
    "/icon", "`"$IconFile`"",
    "/base", "`"C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe`"",
    "/silent"
)

# Change to the project root directory for the build process
Push-Location $ProjectRoot

Write-Host "Current directory: $(Get-Location)"
Write-Host "Compiling TimeMinder.ahk..."
Write-Host "Running command: & `"$Ahk2ExePath`" $($CompilerArgs -join ' ')"

# Execute the compiler
& $Ahk2ExePath $CompilerArgs

# Wait a moment for the file to be written
Start-Sleep -Seconds 3

# Return to the original directory
Pop-Location

# Verify that the executable was created
if (-not (Test-Path $OutputFile)) {
    Write-Error "Build failed. The output file was not created. Try running the command manually to see compiler errors."
    exit 1
}

Write-Host "Build successful! $OutputFile created." -ForegroundColor Green


# --- Distribution Logic ---

if ($Distribution) {
    Write-Host "Creating distribution package..."

    # Clean up old distribution folder
    if (Test-Path $DistributionFolder) {
        Remove-Item -Path $DistributionFolder -Recurse -Force
        Write-Host "Removed old distribution folder: $DistributionFolder"
    }
    
    # Create the distribution folder structure
    New-Item -Path $DistributionFolder -ItemType Directory -Force | Out-Null
    $SoundsDestination = Join-Path -Path $DistributionFolder -ChildPath "sounds"
    New-Item -Path $SoundsDestination -ItemType Directory -Force | Out-Null

    # Move the executable to the distribution folder
    Move-Item -Path $OutputFile -Destination $DistributionFolder -Force
    
    # Copy supporting files
    $SoundsSource = Join-Path -Path $ProjectRoot -ChildPath "sounds"
    Copy-Item -Path (Join-Path -Path $SoundsSource -ChildPath "quack.mp3") -Destination $SoundsDestination -Force
    Copy-Item -Path (Join-Path -Path $ProjectRoot -ChildPath "README.md") -Destination $DistributionFolder -Force
    
    Write-Host "Distribution package created successfully in $DistributionFolder" -ForegroundColor Green
} 