# scripts/install_windows_apps.ps1
# Run this in PowerShell to install GUI apps on Windows from the shared packages.json

$PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$PackageFile = Join-Path $PSScriptRoot "..\windows\packages.json"

if (Test-Path $PackageFile) {
    Write-Host ">>> Installing Windows Apps via winget import..." -ForegroundColor Cyan
    winget import --import-file $PackageFile --accept-package-agreements --accept-source-agreements
} else {
    Write-Error ">>> packages.json not found at $PackageFile. Run 'winget export -o windows\packages.json' first."
}

Write-Host ">>> Windows Apps installation finished!" -ForegroundColor Green