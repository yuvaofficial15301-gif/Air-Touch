@echo off
setlocal EnableExtensions
title Air Touch - Update
cd /d "%~dp0"

echo ================================================================
echo                     AIR TOUCH UPDATE
echo  Upgrades dependencies within the pinned limits in requirements.txt
echo  (MediaPipe stays at 0.10.14) and re-verifies the runtime.
echo ================================================================

set "AT_ALLOW_INSTALL=1"
call "%~dp0bootstrap\find_python.bat"
if not defined AT_PY (
    echo.
    echo UPDATE FAILED: compatible Python was not found.
    set "RC=3"
    goto :end
)

"%AT_PY%" "%~dp0bootstrap\install_runtime.py" --mode update
set "RC=%ERRORLEVEL%"
echo.
if "%RC%"=="0" (echo UPDATE COMPLETE) else (echo UPDATE FAILED ^(exit code %RC%^))

:end
echo.
if not defined AIRTOUCH_NO_PAUSE pause
exit /b %RC%
