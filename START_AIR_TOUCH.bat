@echo off
setlocal EnableExtensions
title Air Touch - Installer and Launcher
cd /d "%~dp0"

echo.
echo ================================================================
echo                          AIR TOUCH
echo               One-Click Installation and Launcher
echo ================================================================
echo.
echo  This will: find or install Python 3.10-3.12, create .venv,
echo  install dependencies + MediaPipe 0.10.14, verify everything,
echo  then start Air Touch. Later runs only verify (fast).
echo.

set "MISSING="
if not exist "%~dp0MANIFEST.txt" set "MISSING= MANIFEST.txt"
if exist "%~dp0MANIFEST.txt" for /f "usebackq eol=# delims=" %%F in ("%~dp0MANIFEST.txt") do if not exist "%~dp0%%F" call set "MISSING=%%MISSING%% %%F"
if defined MISSING goto :incomplete

set "AT_ALLOW_INSTALL=1"
call "%~dp0bootstrap\find_python.bat"
if not defined AT_PY (
    echo.
    echo ================================================================
    echo  INSTALLATION FAILED
    echo ================================================================
    echo  Compatible Python was not found. Air Touch was NOT started.
    set "RC=3"
    goto :end
)

"%AT_PY%" "%~dp0bootstrap\install_runtime.py" --mode install
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" (
    echo.
    echo Air Touch was NOT started because installation failed ^(exit code %RC%^).
    goto :end
)

echo.
echo Starting Air Touch...  ^(close the camera window with Q/ESC, stop the console with Ctrl+C^)
echo.
set "PYTHONPATH=%~dp0src"
".venv\Scripts\python.exe" -m airtouch.cli --ui
set "RC=%ERRORLEVEL%"
echo.
if "%RC%"=="0" (echo Air Touch closed normally.) else (echo Air Touch stopped with exit code %RC%.)

goto :end

:incomplete
echo.
echo ================================================================
echo  INSTALLATION FAILED - your copy of Air Touch is INCOMPLETE
echo ================================================================
echo  These files are missing:
for %%M in (%MISSING%) do echo    %%M
echo.
echo  Cause: not every file/folder reached GitHub (or your clone). Fix:
echo    1. Re-extract the Air-Touch zip and run START_AIR_TOUCH.bat from there, or
echo    2. Push ALL files:  git add -A  then  git commit  then  git push
echo       and check with:  git ls-files
set "RC=1"

:end
echo.
if not defined AIRTOUCH_NO_PAUSE pause
exit /b %RC%
