@echo off
REM N8N Universal Docker Manager - Windows Batch Wrapper
REM This script provides a convenient way to run the universal Python script on Windows

REM Check if Python is available
python --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.7+ and try again
    echo Download from: https://www.python.org/downloads/
    pause
    exit /b 1
)

REM Get the directory where this batch file is located
set SCRIPT_DIR=%~dp0

REM Change to script directory
cd /d "%SCRIPT_DIR%"

REM Run the Python script with all arguments
python n8n-universal.py %*

REM Pause if there was an error (except for help command)
if %ERRORLEVEL% NEQ 0 if not "%1"=="help" (
    echo.
    echo Script finished with error code %ERRORLEVEL%
    pause
)