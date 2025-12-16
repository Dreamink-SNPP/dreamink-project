# PowerShell script equivalent to bin/dev
# Starts the Rails development server with Foreman
# Compatible with Windows 10/11 (PowerShell 5.1+)

# Check if foreman is installed
$foremanInstalled = Get-Command foreman -ErrorAction SilentlyContinue
if (-not $foremanInstalled) {
    Write-Host "Installing foreman..."
    gem install foreman
}

# Default to port 3000 if not specified
if (-not $env:PORT) {
    $env:PORT = "3000"
}

# Let the debug gem allow remote connections,
# but avoid loading until `debugger` is called
$env:RUBY_DEBUG_OPEN = "true"
$env:RUBY_DEBUG_LAZY = "true"

# Start foreman with Procfile.dev
Write-Host "Starting development server on port $env:PORT..."
foreman start -f Procfile.dev $args
