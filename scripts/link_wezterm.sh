#!/bin/bash

# Definition der Pfade
WIN_USER=$(cmd.exe /c "echo %USERPROFILE%" 2>/dev/null | tr -d '\r')
WIN_CONFIG_DIR="${WIN_USER}\.config\wezterm"
WIN_CONFIG_FILE="${WIN_CONFIG_DIR}\wezterm.lua"

# Aktueller WSL Distro Name
DISTRO_NAME="${WSL_DISTRO_NAME:-Ubuntu-Test}"
# WSL Config Path (UNC Path für Windows)
# Use forward slashes for Lua compatibility
WSL_CONFIG_PATH="//wsl.localhost/${DISTRO_NAME}/home/$(whoami)/.config/wezterm/wezterm.lua"

echo "🔗 Linking WezTerm Config via Proxy..."
echo "   Windows Path: $WIN_CONFIG_FILE"
echo "   Target (WSL): $WSL_CONFIG_PATH"

# PowerShell Command: Erstellt den Ordner und die Proxy-Datei
# dofile() lädt und führt die WSL-Datei aus. Da die Home-Manager Config 'return config' nutzt,
# gibt dofile() dieses Objekt zurück.
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


