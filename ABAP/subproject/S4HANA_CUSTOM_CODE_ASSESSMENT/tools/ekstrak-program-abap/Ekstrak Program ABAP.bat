@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File "%~dp0tools\ekstrak-program.ps1" "%~1"
if errorlevel 1 pause
