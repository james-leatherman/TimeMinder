@echo off
setlocal enabledelayedexpansion

REM TimeMinder Build Script
REM Usage: build.bat [architecture] [compress] [output_name]

REM Parse command line arguments
set ARCH=64
set COMPRESS=0
set OUTPUT=TimeMinder.exe

if not "%1"=="" set ARCH=%1
if not "%2"=="" set COMPRESS=%2
if not "%3"=="" set OUTPUT=%3

REM Configuration
set AHK2EXE=C:\Tools\Ahk2Exe\Ahk2Exe.exe
set SOURCE=TimeMinder.ahk
set ICON=images\TimeMinderIcon.ico

echo Building TimeMinder...
echo Architecture: %ARCH%-bit
echo Compression: %COMPRESS%
echo Output: %OUTPUT%

REM Check if Ahk2Exe exists
if not exist "%AHK2EXE%" (
    echo ERROR: Ahk2Exe not found at: %AHK2EXE%
    echo Please install Ahk2Exe or update the path in this script.
    echo Download from: https://www.autohotkey.com/download/ahk2exe.zip
    pause
    exit /b 1
)

REM Check if source file exists
if not exist "%SOURCE%" (
    echo ERROR: Source file not found: %SOURCE%
    pause
    exit /b 1
)

REM Check if icon file exists
if not exist "%ICON%" (
    echo WARNING: Icon file not found: %ICON%
    echo Will use default AutoHotkey icon.
    set ICON=
)

REM Build command
set COMMAND="%AHK2EXE%" /in %SOURCE% /out %OUTPUT% /bin %ARCH%

if not "%ICON%"=="" (
    set COMMAND=%COMMAND% /icon %ICON%
)

if "%COMPRESS%"=="1" (
    set COMMAND=%COMMAND% /compress 1
)

echo Command: %COMMAND%

REM Execute build
%COMMAND%

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Build successful!
    echo Output file: %OUTPUT%
    
    REM Show file size
    if exist "%OUTPUT%" (
        for %%A in ("%OUTPUT%") do (
            set SIZE=%%~zA
            set /a SIZE_KB=!SIZE!/1024
            set /a SIZE_MB=!SIZE!/1048576
            if !SIZE_MB! GTR 0 (
                echo File size: !SIZE_MB! MB
            ) else (
                echo File size: !SIZE_KB! KB
            )
        )
    )
) else (
    echo.
    echo Build failed with exit code: %ERRORLEVEL%
    pause
    exit /b 1
)

echo.
pause 