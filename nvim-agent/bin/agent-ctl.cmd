@echo off
rem PowerShell/cmd shim: forwards to the bash implementation via Git Bash.
rem Keeps `agent-ctl ...` working for agents whose shell is PowerShell (e.g. codex on Windows).
where bash >nul 2>nul
if errorlevel 1 (
  echo agent-ctl: bash not found on PATH ^(install Git for Windows^) 1>&2
  exit /b 1
)
bash "%~dp0agent-ctl" %*
