@echo off
setlocal

set "ROOT=%~dp0"
set "SOURCE=%ROOT%buttons\vanilla"
set "DEST=%ROOT%src"

if not exist "%SOURCE%" (
    echo Vanilla button source folder not found: "%SOURCE%"
    exit /b 1
)

if not exist "%DEST%" (
    echo Source asset folder not found: "%DEST%"
    exit /b 1
)

echo.
echo ==> Copying vanilla button overrides into src
robocopy "%SOURCE%" "%DEST%" *.dds /S /R:1 /W:1 /NFL /NDL /NJH /NJS /NP
set "ROBOCOPY_EXIT=%ERRORLEVEL%"

if %ROBOCOPY_EXIT% GEQ 8 (
    echo Robocopy failed with exit code %ROBOCOPY_EXIT%.
    exit /b %ROBOCOPY_EXIT%
)

echo.
echo Vanilla button overrides copied successfully.
exit /b 0
