@echo off
REM Windows batch script equivalent to bin/dev
REM Starts the Rails development server with Foreman

REM Check if foreman is installed
where foreman >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Installing foreman...
    gem install foreman
)

REM Default to port 3000 if not specified
if "%PORT%"=="" set PORT=3000

REM Let the debug gem allow remote connections,
REM but avoid loading until `debugger` is called
set RUBY_DEBUG_OPEN=true
set RUBY_DEBUG_LAZY=true

REM Start foreman with Procfile.dev
echo Starting development server on port %PORT%...
foreman start -f Procfile.dev %*
