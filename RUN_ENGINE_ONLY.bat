@echo off
setlocal EnableExtensions
title Air Touch - Engine Only
cd /d "%~dp0"

if not exist ".venv\Scripts\python.exe" (
    echo Air Touch is not installed yet.
    echo.
    echo Run START_AIR_TOUCH.bat first.
    set "RC=1"
    goto :end
)

echo Air Touch engine only ^(no developer console^).
echo Close the camera window with Q or ESC, or press Ctrl+C here.
echo.
set "PYTHONPATH=%~dp0src"
".venv\Scripts\python.exe" -m airtouch.cli
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" echo Air Touch stopped with exit code %RC%.

:end
echo.
if not defined AIRTOUCH_NO_PAUSE pause
exit /b %RC%
