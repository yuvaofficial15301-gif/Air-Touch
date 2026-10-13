@echo off
setlocal EnableExtensions
title Air Touch - Update
cd /d "%~dp0"

echo ================================================================
echo                     AIR TOUCH UPDATE
echo  Upgrades dependencies within the pinned limits in requirements.txt
echo  (MediaPipe stays at 0.10.14) and re-verifies the runtime.
echo ================================================================

set "MISSING="
if not exist "%~dp0MANIFEST.txt" set "MISSING= MANIFEST.txt"
if exist "%~dp0MANIFEST.txt" for /f "usebackq eol=# delims=" %%F in ("%~dp0MANIFEST.txt") do if not exist "%~dp0%%F" call set "MISSING=%%MISSING%% %%F"
if defined MISSING goto :incomplete

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
