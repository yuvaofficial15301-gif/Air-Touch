@echo off
setlocal EnableExtensions
title Air Touch - Update
cd /d "%~dp0"

echo ================================================================
echo                     AIR TOUCH UPDATE
echo  Upgrades dependencies within the pinned limits in requirements.txt
echo  (MediaPipe stays at 0.10.14) and re-verifies the runtime.
echo ================================================================

for %%F in (bootstrap\find_python.bat bootstrap\install_runtime.py bootstrap\pycheck.py bootstrap\install_python.ps1 requirements.txt src\airtouch\cli.py) do (
    if not exist "%~dp0%%F" (
        echo.
        echo INSTALLATION FAILED
        echo Your copy of Air Touch is incomplete: missing %%F
        echo Re-clone the repository. If you pushed it yourself, make sure ALL files and
        echo folders were committed ^(run: git status  and  git ls-files^).
        set "RC=1"
        goto :end
    )
)

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
