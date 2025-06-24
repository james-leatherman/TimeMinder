# AHK2EXE Setup Script
# This script downloads and sets up AHK2EXE for TimeMinder packaging

param(
    [string]$InstallPath = "C:\Tools\Ahk2Exe"
)

$Ahk2ExeUrl = "https://www.autohotkey.com/download/ahk2exe.zip"
$TempZip = "$env:TEMP\ahk2exe.zip"

Write-Host "Setting up AHK2EXE for TimeMinder packaging..." -ForegroundColor Green
Write-Host "Install path: $InstallPath" -ForegroundColor Cyan

# Create installation directory
if (!(Test-Path $InstallPath)) {
    Write-Host "Creating installation directory..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
}

# Download AHK2EXE
Write-Host "Downloading AHK2EXE..." -ForegroundColor Cyan
try {
    Invoke-WebRequest -Uri $Ahk2ExeUrl -OutFile $TempZip
    Write-Host "  ✓ Download completed" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to download AHK2EXE: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Extract AHK2EXE
Write-Host "Extracting AHK2EXE..." -ForegroundColor Cyan
try {
    Expand-Archive -Path $TempZip -DestinationPath $InstallPath -Force
    Write-Host "  ✓ Extraction completed" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to extract AHK2EXE: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Clean up temporary file
Remove-Item $TempZip -Force

# Verify installation
$Ahk2ExePath = "$InstallPath\Ahk2Exe.exe"
if (Test-Path $Ahk2ExePath) {
    Write-Host "  ✓ AHK2EXE installed successfully" -ForegroundColor Green
    Write-Host "  Path: $Ahk2ExePath" -ForegroundColor Cyan
} else {
    Write-Host "ERROR: AHK2EXE not found after installation" -ForegroundColor Red
    exit 1
}

# Test AHK2EXE
Write-Host "Testing AHK2EXE..." -ForegroundColor Cyan
try {
    $Version = & $Ahk2ExePath --version 2>&1
    Write-Host "  ✓ AHK2EXE version: $Version" -ForegroundColor Green
} catch {
    Write-Host "  ⚠ Could not get AHK2EXE version" -ForegroundColor Yellow
}

# Update build scripts with correct path
Write-Host "Updating build scripts..." -ForegroundColor Cyan

$Scripts = @("build.ps1", "create_distribution.ps1")
foreach ($Script in $Scripts) {
    if (Test-Path $Script) {
        $Content = Get-Content $Script -Raw
        $UpdatedContent = $Content -replace 'C:\\Tools\\Ahk2Exe\\Ahk2Exe\.exe', $Ahk2ExePath.Replace('\', '\\')
        Set-Content $Script $UpdatedContent
        Write-Host "  ✓ Updated $Script" -ForegroundColor Green
    }
}

# Update batch file
if (Test-Path "build.bat") {
    $Content = Get-Content "build.bat" -Raw
    $UpdatedContent = $Content -replace 'C:\\Tools\\Ahk2Exe\\Ahk2Exe\.exe', $Ahk2ExePath.Replace('\', '\\')
    Set-Content "build.bat" $UpdatedContent
    Write-Host "  ✓ Updated build.bat" -ForegroundColor Green
}

Write-Host "`nAHK2EXE setup completed successfully!" -ForegroundColor Green
Write-Host "You can now use the build scripts to package TimeMinder:" -ForegroundColor Cyan
Write-Host "  .\build.ps1                    # Basic build" -ForegroundColor Gray
Write-Host "  .\build.ps1 -Compress          # Build with compression" -ForegroundColor Gray
Write-Host "  .\create_distribution.ps1      # Create complete distribution" -ForegroundColor Gray 