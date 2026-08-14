@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0agent-ctl.ps1" %*
