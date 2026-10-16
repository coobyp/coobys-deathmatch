@echo off
rem Double-click me. Runs the installer without Windows blocking the script.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
if errorlevel 1 pause
