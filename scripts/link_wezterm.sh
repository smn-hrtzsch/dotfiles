#!/bin/bash

# Definition der Pfade
WIN_USER=$(cmd.exe /c "echo %USERPROFILE%" 2>/dev/null | tr -d '\r')
WIN_CONFIG_DIR="${WIN_USER}\.config\wezterm"
WIN_CONFIG_FILE="${WIN_CONFIG_DIR}\wezterm.lua"

# Aktueller WSL Distro Name
DISTRO_NAME="${WSL_DISTRO_NAME:-WSL-Nix}"

# 1. Resolve the actual path (follow symlinks to Nix store)
# Windows often fails to follow Linux symlinks via \\wsl.localhost if they are absolute paths.
RAW_CONFIG_PATH="/home/$(whoami)/.config/wezterm/wezterm.lua"

if [ ! -f "$RAW_CONFIG_PATH" ]; then
  echo "❌ Config file not found at $RAW_CONFIG_PATH"
  exit 1
fi

REAL_CONFIG_PATH=$(readlink -f "$RAW_CONFIG_PATH")

# 2. Convert to Windows UNC Path
# Replace forward slashes with backslashes
WSL_PATH_CONVERTED=$(echo "$REAL_CONFIG_PATH" | sed 's|/|\\|g')
# Construct UNC path: \\wsl.localhost\Distro\Path
WSL_CONFIG_PATH="\\\\wsl.localhost\\${DISTRO_NAME}${WSL_PATH_CONVERTED}"

echo "🔗 Linking WezTerm Config via Proxy..."
echo "   Windows Path: $WIN_CONFIG_FILE"
echo "   Target (WSL): $WSL_CONFIG_PATH (Resolved)"

# PowerShell Command: Erstellt den Ordner und die Proxy-Datei
# dofile() lädt und führt die WSL-Datei aus.
PS_COMMAND="
\$ErrorActionPreference = 'Stop'
try {
    if (-not (Test-Path -Path '$WIN_CONFIG_DIR')) {
        New-Item -ItemType Directory -Force -Path '$WIN_CONFIG_DIR' | Out-Null
    }
    
    \$Content = \"-- Proxy for WSL WezTerm config\`r\`nreturn dofile([[$WSL_CONFIG_PATH]])\"
    Set-Content -Path '$WIN_CONFIG_FILE' -Value \$Content -Encoding utf8
    Write-Host '✅ Proxy config created successfully'
} catch {
    Write-Error \$_
    exit 1
}
"

# In einem neutralen Verzeichnis ausführen, um UNC-Warnungen zu vermeiden
cd /tmp && powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$PS_COMMAND"

if [ $? -eq 0 ]; then
    echo "✨ Success! WezTerm will now load its config from WSL."
else
    echo "❌ Failed to create proxy config."
fi


