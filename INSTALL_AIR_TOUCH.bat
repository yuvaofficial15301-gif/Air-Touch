@echo off
setlocal EnableExtensions
title Air Touch - Install Only
cd /d "%~dp0"

echo ================================================================
echo                          AIR TOUCH
echo        Install / repair the runtime (does NOT start Air Touch)
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
    echo INSTALLATION FAILED: compatible Python was not found.
    set "RC=3"
    goto :end
)

"%AT_PY%" "%~dp0bootstrap\install_runtime.py" --mode install
set "RC=%ERRORLEVEL%"
if "%RC%"=="0" (
    echo.
    echo Installation complete. Start Air Touch with START_AIR_TOUCH.bat
)

:end
echo.
if not defined AIRTOUCH_NO_PAUSE pause
exit /b %RC%
