# TimeMinder Distribution Creator
# Usage: .\create_distribution.ps1 [-Version "1.0"] [-Architecture "64"] [-Compress]

param(
    [string]$Version = "1.0",
    [string]$Architecture = "64",
    [switch]$Compress
)

# Configuration
$Ahk2ExePath = "C:\Tools\Ahk2Exe\Ahk2Exe.exe"
$SourceFile = "TimeMinder.ahk"
$IconFile = "images\TimeMinderIcon.ico"

# Distribution settings
$DistDir = "TimeMinder_v$Version"
$ExeName = "TimeMinder_v$Version.exe"
$ZipName = "TimeMinder_v$Version.zip"

Write-Host "Creating TimeMinder Distribution v$Version" -ForegroundColor Green
Write-Host "Architecture: $Architecture-bit" -ForegroundColor Cyan
Write-Host "Compression: $(if ($Compress) { 'Enabled' } else { 'Disabled' })" -ForegroundColor Cyan

# Check prerequisites
if (!(Test-Path $Ahk2ExePath)) {
    Write-Host "ERROR: Ahk2Exe not found at: $Ahk2ExePath" -ForegroundColor Red
    Write-Host "Please install Ahk2Exe or update the path in this script." -ForegroundColor Yellow
    Write-Host "Download from: https://www.autohotkey.com/download/ahk2exe.zip" -ForegroundColor Cyan
    exit 1
}

if (!(Test-Path $SourceFile)) {
    Write-Host "ERROR: Source file not found: $SourceFile" -ForegroundColor Red
    exit 1
}

# Clean previous distribution
if (Test-Path $DistDir) {
    Write-Host "Cleaning previous distribution..." -ForegroundColor Yellow
    Remove-Item $DistDir -Recurse -Force
}

# Create distribution directory structure
Write-Host "Creating distribution directory..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path $DistDir | Out-Null
New-Item -ItemType Directory -Path "$DistDir\sounds" | Out-Null
New-Item -ItemType Directory -Path "$DistDir\images" | Out-Null

# Compile executable
Write-Host "Compiling TimeMinder..." -ForegroundColor Cyan
$BuildCommand = "$Ahk2ExePath /in $SourceFile /out `"$DistDir\$ExeName`" /bin $Architecture"

if (Test-Path $IconFile) {
    $BuildCommand += " /icon `"$IconFile`""
}

if ($Compress) {
    $BuildCommand += " /compress 1"
}

Write-Host "Build command: $BuildCommand" -ForegroundColor Gray

try {
    Invoke-Expression $BuildCommand
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Build failed with exit code: $LASTEXITCODE" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "ERROR: Build failed with error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Copy supporting files
Write-Host "Copying supporting files..." -ForegroundColor Cyan

# Copy sounds directory
if (Test-Path "sounds") {
    Copy-Item "sounds\*" "$DistDir\sounds\" -Recurse -Force
    Write-Host "  ✓ Copied sounds directory" -ForegroundColor Green
} else {
    Write-Host "  ⚠ No sounds directory found" -ForegroundColor Yellow
}

# Copy images directory
if (Test-Path "images") {
    Copy-Item "images\*" "$DistDir\images\" -Force
    Write-Host "  ✓ Copied images directory" -ForegroundColor Green
} else {
    Write-Host "  ⚠ No images directory found" -ForegroundColor Yellow
}

# Copy documentation
$DocsToCopy = @("README.md", "SOUND_MANAGEMENT.md", "PACKAGING_GUIDE.md")
foreach ($Doc in $DocsToCopy) {
    if (Test-Path $Doc) {
        Copy-Item $Doc "$DistDir\" -Force
        Write-Host "  ✓ Copied $Doc" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ $Doc not found" -ForegroundColor Yellow
    }
}

# Create ZIP archive
Write-Host "Creating ZIP archive..." -ForegroundColor Cyan
if (Test-Path $ZipName) {
    Remove-Item $ZipName -Force
}

try {
    Compress-Archive -Path $DistDir -DestinationPath $ZipName -CompressionLevel Optimal
    Write-Host "  ✓ Created $ZipName" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to create ZIP archive: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Show results
Write-Host "`nDistribution created successfully!" -ForegroundColor Green
Write-Host "Distribution folder: $DistDir" -ForegroundColor Cyan
Write-Host "ZIP archive: $ZipName" -ForegroundColor Cyan

# Show file sizes
if (Test-Path "$DistDir\$ExeName") {
    $ExeSize = (Get-Item "$DistDir\$ExeName").Length
    if ($ExeSize -gt 1MB) {
        Write-Host "Executable size: $([math]::Round($ExeSize / 1MB, 2)) MB" -ForegroundColor Cyan
    } else {
        Write-Host "Executable size: $([math]::Round($ExeSize / 1KB, 2)) KB" -ForegroundColor Cyan
    }
}

if (Test-Path $ZipName) {
    $ZipSize = (Get-Item $ZipName).Length
    if ($ZipSize -gt 1MB) {
        Write-Host "ZIP size: $([math]::Round($ZipSize / 1MB, 2)) MB" -ForegroundColor Cyan
    } else {
        Write-Host "ZIP size: $([math]::Round($ZipSize / 1KB, 2)) KB" -ForegroundColor Cyan
    }
}

# Show distribution contents
Write-Host "`nDistribution contents:" -ForegroundColor Cyan
Get-ChildItem $DistDir -Recurse | ForEach-Object {
    $Indent = "  " * ($_.FullName.Split('\').Count - $DistDir.Split('\').Count)
    Write-Host "$Indent$($_.Name)" -ForegroundColor Gray
}

Write-Host "`nDistribution ready for release!" -ForegroundColor Green 