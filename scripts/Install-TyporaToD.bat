@echo off
setlocal
:: Install Typora to D:\Program Files (x86)\Typora (mirrors C:\Program Files (x86)\...)
:: Right-click this file -> Run as administrator

net session >nul 2>&1
if errorlevel 1 (
  echo Please Run as administrator.
  pause
  exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install-TyporaToD.ps1" %*
set EXITCODE=%ERRORLEVEL%
if not %EXITCODE%==0 (
  echo Install failed with exit code %EXITCODE%.
  pause
  exit /b %EXITCODE%
)

echo.
pause
exit /b 0
