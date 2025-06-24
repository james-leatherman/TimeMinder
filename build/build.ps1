# TimeMinder Build Script
# Usage: .\build.ps1 [-Architecture 64] [-Compress] [-OutputName "TimeMinder.exe"]

param(
    [string]$Architecture = "64",
    [switch]$Compress,
    [string]$OutputName = "..\TimeMinder.exe"
)

# Configuration
$Ahk2ExePath = "C:\Tools\Ahk2Exe\Ahk2Exe.exe"
$SourceFile = "..\TimeMinder.ahk"
$IconFile = "..\images\TimeMinderIcon.ico"

# Check if Ahk2Exe exists
if (!(Test-Path $Ahk2ExePath)) {
    Write-Host "Ahk2Exe not found at: $Ahk2ExePath" -ForegroundColor Red
    Write-Host "Please install Ahk2Exe or update the path in this script." -ForegroundColor Yellow
    Write-Host "Download from: https://www.autohotkey.com/download/ahk2exe.zip" -ForegroundColor Cyan
    exit 1
}

# Check if source file exists
if (!(Test-Path $SourceFile)) {
    Write-Host "Source file not found: $SourceFile" -ForegroundColor Red
    exit 1
}

# Check if icon file exists
if (!(Test-Path $IconFile)) {
    Write-Host "Warning: Icon file not found: $IconFile" -ForegroundColor Yellow
    Write-Host "Will use default AutoHotkey icon." -ForegroundColor Yellow
    $IconFile = ""
}

# Build command
$Command = "$Ahk2ExePath /in $SourceFile /out $OutputName /bin $Architecture"

if ($IconFile -ne "") {
    $Command += " /icon $IconFile"
}

if ($Compress) {
    $Command += " /compress 1"
}

Write-Host "Building TimeMinder..." -ForegroundColor Green
Write-Host "Architecture: $Architecture-bit" -ForegroundColor Cyan
Write-Host "Compression: $(if ($Compress) { 'Enabled' } else { 'Disabled' })" -ForegroundColor Cyan
Write-Host "Output: $OutputName" -ForegroundColor Cyan
Write-Host "Command: $Command" -ForegroundColor Gray

# Execute build
try {
    Invoke-Expression $Command
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Build successful!" -ForegroundColor Green
        Write-Host "Output file: $OutputName" -ForegroundColor Green
        
        # Show file size
        if (Test-Path $OutputName) {
            $FileSize = (Get-Item $OutputName).Length
            if ($FileSize -gt 1MB) {
                Write-Host "File size: $([math]::Round($FileSize / 1MB, 2)) MB" -ForegroundColor Cyan
            } else {
                Write-Host "File size: $([math]::Round($FileSize / 1KB, 2)) KB" -ForegroundColor Cyan
            }
        }
    } else {
        Write-Host "Build failed with exit code: $LASTEXITCODE" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Build failed with error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} 