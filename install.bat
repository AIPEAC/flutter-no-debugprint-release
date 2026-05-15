@echo off
setlocal EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
set "WRAPPER_DIR=%USERPROFILE%\.flutter-ndrelease"

REM Check if flutter is installed
where flutter >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo Error: flutter not found in PATH. Please install Flutter first.
    exit /b 1
)

REM Create wrapper directory
if not exist "%WRAPPER_DIR%" mkdir "%WRAPPER_DIR%"

REM Copy wrappers
copy /Y "%SCRIPT_DIR%\bin\flutter.bat" "%WRAPPER_DIR%\flutter.bat" >nul
copy /Y "%SCRIPT_DIR%\bin\flutter.ps1" "%WRAPPER_DIR%\flutter.ps1" >nul

REM Add wrapper directory to PATH if not already present
echo %PATH% | find /I "%WRAPPER_DIR%" >nul
if %ERRORLEVEL% neq 0 (
    setx PATH "%WRAPPER_DIR%;%PATH%" >nul 2>&1
    echo Added wrapper to PATH.
    echo Please restart your terminal for changes to take effect.
) else (
    echo Wrapper directory already in PATH.
)

echo.
echo Installation complete!
echo.
echo Usage:
echo   flutter build ^<target^> --ndrelease
echo.
echo Examples:
echo   flutter build windows --ndrelease
echo   flutter build linux --ndrelease
echo   flutter build macos --ndrelease
echo.
