@echo off
setlocal
powershell -ExecutionPolicy Bypass -File "%~dp0bootstrap_tools.ps1" %*
set EXITCODE=%ERRORLEVEL%
endlocal & exit /b %EXITCODE%
