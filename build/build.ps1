# TimeMinder Build Script
#
# Default (no parameters): Builds TimeMinder.exe to the project root.
# Usage: .\build\build.ps1
#
# Distribution Mode: Creates a complete distribution package in the /dist folder.
# Usage: .\build\build.ps1 -Distribution

param(
    [switch]$Distribution,
    [string]$Ahk2ExePath,
    [switch]$VerboseLogs
)

# --- Configuration ---
# Get the directory of the script itself
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Helper function to download Ahk2Exe if needed
function Download-Ahk2Exe {
    param([string]$TargetPath)
    
    Write-Host "Downloading Ahk2Exe.exe from AutoHotkey website..." -ForegroundColor Cyan
    
    # Try multiple sources
    $urls = @(
        "https://github.com/AutoHotkey/Ahk2Exe/releases/download/v1.1.36.02/Ahk2Exe.exe",
        "https://github.com/AutoHotkey/Ahk2Exe/releases/download/v2.0.2/Ahk2Exe.exe"
    )
    
    foreach ($url in $urls) {
        try {
            Write-Host "  Trying: $url" -ForegroundColor Gray
            $tempExe = Join-Path $env:TEMP "Ahk2Exe_temp.exe"
            Invoke-WebRequest -Uri $url -OutFile $tempExe -ErrorAction Stop
            Copy-Item -Path $tempExe -Destination $TargetPath -Force -ErrorAction Stop
            Remove-Item -Path $tempExe -Force -ErrorAction SilentlyContinue
            Write-Host "  ✓ Successfully downloaded Ahk2Exe.exe" -ForegroundColor Green
            return $true
        } catch {
            Write-Host "    (Failed: $($_.Exception.Message))" -ForegroundColor Gray
        }
    }
    
    Write-Host "  ✗ Could not download from any source" -ForegroundColor Red
    return $false
}

# Define project root relative to the script's location
$ProjectRoot = Resolve-Path -Path (Join-Path -Path $ScriptDir -ChildPath "..")

# Define all paths relative to the project root
$SourceFile = Join-Path -Path $ProjectRoot -ChildPath "TimeMinder.ahk"
$IconFile = Join-Path -Path $ProjectRoot -ChildPath "images\TimeMinderIcon.ico"
$OutputFile = Join-Path -Path $ProjectRoot -ChildPath "TimeMinder.exe"
$DistributionFolder = Join-Path -Path $ProjectRoot -ChildPath "dist"

# Define potential compiler paths
$CompilerPaths = @(
    "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe",
    "C:\Program Files\AutoHotkey\v2\Compiler\Ahk2Exe.exe"
)

# --- Prerequisite Checks ---

# Find the AutoHotkey compiler. Respect a user-provided override path via the `-Ahk2ExePath` parameter.
$SelectedAhk2Exe = $null
if ($Ahk2ExePath) {
    if (Test-Path $Ahk2ExePath) {
        $SelectedAhk2Exe = $Ahk2ExePath
        Write-Host "Using Ahk2Exe.exe from override: $SelectedAhk2Exe"
    }
    else {
        Write-Error "Provided Ahk2Exe path not found: $Ahk2ExePath"
        exit 1
    }
}
else {
    foreach ($path in $CompilerPaths) {
        if (Test-Path $path) {
            $SelectedAhk2Exe = $path
            Write-Host "Found Ahk2Exe.exe at: $SelectedAhk2Exe"
            break
        }
    }

    if (-not $SelectedAhk2Exe) {
        Write-Error "Could not find Ahk2Exe.exe in any of the expected locations. Please install AutoHotkey v2 or pass the compiler path with -Ahk2ExePath 'C:\\Path\\To\\Ahk2Exe.exe'. See https://www.autohotkey.com/ for downloads."
        exit 1
    }
}

# Normalise to the variable name used later
$Ahk2ExePath = $SelectedAhk2Exe

# Check for source file
if (-not (Test-Path $SourceFile)) {
    Write-Error "Source file not found: $SourceFile"
    exit 1
}

# --- Clean up old executables ---
Get-ChildItem -Path $ProjectRoot -Filter '*.exe' | Where-Object { $_.Name -ne 'build.ps1' } | ForEach-Object { Remove-Item $_.FullName -Force }

# --- Build Logic ---

# Clean up previous build executable
if (Test-Path $OutputFile) {
    Remove-Item -Path $OutputFile -Force
    Write-Host "Removed old executable: $OutputFile"
}

# Set up compiler arguments
# Build compiler arguments as plain strings (Start-Process will handle quoting)
$CompilerArgs = @(
    "/in", $SourceFile,
    "/out", $OutputFile,
    "/icon", $IconFile,
    "/base", "C:\Program Files\AutoHotkey\v2\AutoHotkey.exe",
    "/silent"
)

# Change to the project root directory for the build process
Push-Location $ProjectRoot

Write-Host "Current directory: $(Get-Location)"
Write-Host "Compiling TimeMinder.ahk..."
Write-Host "Running command: `"$Ahk2ExePath`" $($CompilerArgs -join ' ')"

# Execute the compiler directly via Start-Process. Start-Process handles argument quoting
# correctly when passed an array of argument strings. Capture stdout/stderr to temp logs
# so we can diagnose errors without using a temporary batch file.
$outLog = Join-Path $env:TEMP "ahk2exe_stdout_$([System.IO.Path]::GetRandomFileName()).txt"
$errLog = Join-Path $env:TEMP "ahk2exe_stderr_$([System.IO.Path]::GetRandomFileName()).txt"

Write-Host "Invoking compiler (capturing stdout/stderr):" -ForegroundColor Gray
Write-Host "  $Ahk2ExePath $($CompilerArgs -join ' ')" -ForegroundColor Gray

# When verbose logging is requested, run the compiler under cmd.exe with
# stdout/stderr redirected to a temp log file so we always capture its output.
if ($VerboseLogs) {
    $logFile = Join-Path $env:TEMP ("ahk2exe_verbose_" + ([System.IO.Path]::GetRandomFileName()) + ".log")
    $quotedArgs = $CompilerArgs | ForEach-Object { '"' + ($_ -replace '"','\"') + '"' }
    $commandString = '"' + $Ahk2ExePath + '"' + ' ' + ($quotedArgs -join ' ')
    $redir = " > `"$logFile`" 2>&1"
    Write-Host "Verbose logging enabled — writing compiler output to: $logFile" -ForegroundColor Yellow
    Write-Host "Running: cmd.exe /c $commandString$redir" -ForegroundColor Gray

    & cmd.exe /c ($commandString + $redir)
    $exit = $LASTEXITCODE
    Write-Host "Compiler exit code: $exit"
    Write-Host "Compiler output saved: $logFile"
    if ($exit -ne 0) {
        Write-Error "Compiler failed with exit code $exit. See log: $logFile"
        exit $exit
    }

    # Return to caller (build successful)
    Pop-Location
    Write-Host "Build successful! $OutputFile created." -ForegroundColor Green
    exit 0
}

## Some builds (Ahk2Exe) behave differently when launched from PowerShell vs cmd.exe.
## Run the full command under cmd.exe (/c) so the compiler sees the environment it expects,
## without creating a temporary batch file on disk.
$quotedArgs = $CompilerArgs | ForEach-Object { '"' + ($_ -replace '"','\"') + '"' }
$commandString = '"' + $Ahk2ExePath + '"' + ' ' + ($quotedArgs -join ' ')

Write-Host "Running under cmd.exe: $commandString" -ForegroundColor Gray

## Try invoking the compiler directly. If it fails or returns a non-zero exit code,
## fall back to running the same command under cmd.exe /c. This avoids creating
## temporary batch files while improving compatibility with Ahk2Exe's expected
## execution environment.
$didFallback = $false
try {
    $proc = Start-Process -FilePath $Ahk2ExePath -ArgumentList $CompilerArgs -Wait -PassThru
} catch {
    Write-Host "Start-Process direct invocation failed: $($_.Exception.Message) -- attempting cmd.exe fallback." -ForegroundColor Yellow
    $proc = $null
    $didFallback = $true
}

if (-not $didFallback -and $proc -and $proc.ExitCode -eq 0) {
    # Direct invocation succeeded
} else {
    if (-not $didFallback) { Write-Host "Direct invocation returned non-zero exit code; attempting cmd.exe fallback..." -ForegroundColor Yellow }

    $quotedArgs = $CompilerArgs | ForEach-Object { '"' + ($_ -replace '"','\"') + '"' }
    $commandString = '"' + $Ahk2ExePath + '"' + ' ' + ($quotedArgs -join ' ')

    Write-Host "Fallback: running under cmd.exe: $commandString" -ForegroundColor Gray
    try {
        $proc2 = Start-Process -FilePath 'cmd.exe' -ArgumentList "/c $commandString" -Wait -PassThru
    } catch {
        Write-Host "Failed to run fallback via cmd.exe: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "You can try running the following manually:" -ForegroundColor Yellow
        Write-Host "  $commandString" -ForegroundColor Gray
        exit 1
    }

    if ($proc2 -and $proc2.ExitCode -ne 0) {
        Write-Error "Compiler (cmd.exe fallback) failed with exit code $($proc2.ExitCode)."
        if ($proc2.ExitCode -eq 52) {
            Write-Host "`nERROR: Ahk2Exe returned exit code 52 (compiler/runtime issue)." -ForegroundColor Red
            Write-Host "Possible solutions:" -ForegroundColor Yellow
            Write-Host "  1. Reinstall AutoHotkey v2 from: https://www.autohotkey.com/" -ForegroundColor Gray
            Write-Host "  2. Remove the bundled Ahk2Exe.exe to use the system installation" -ForegroundColor Gray
            Write-Host "  3. Try running the exact command shown above manually to inspect any GUI modal errors" -ForegroundColor Gray
        }
        exit $proc2.ExitCode
    }

    # Use proc2 as the final process result
    $proc = $proc2
}

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