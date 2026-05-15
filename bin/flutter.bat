@echo off
powershell -ExecutionPolicy Bypass -File "%~dp0flutter.ps1" %*
exit /b %errorlevel%
