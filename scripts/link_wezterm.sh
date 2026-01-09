#!/bin/bash

# Definition der Pfade
# Windows User Profile Pfad (in WSL Schreibweise konvertiert für Zugriff, aber wir brauchen den Windows-Pfad für mklink)
WIN_USER=$(cmd.exe /c "echo %USERPROFILE%" 2>/dev/null | tr -d '\r')
WIN_CONFIG_DIR="$WIN_USER\.config\wezterm"
WIN_CONFIG_FILE="$WIN_CONFIG_DIR\wezterm.lua"

# Aktueller WSL Distro Name
DISTRO_NAME="${WSL_DISTRO_NAME:-Ubuntu-Test}"
WSL_CONFIG_PATH="\\wsl.localhost\$DISTRO_NAME\home\$(whoami)\.config\wezterm\wezterm.lua"

echo "🔗 Linking WezTerm Config..."
echo "   Windows Path: $WIN_CONFIG_FILE"
echo "   Target (WSL): $WSL_CONFIG_PATH"

# 1. Ordner auf Windows erstellen (via PowerShell für Einfachheit)
powershell.exe -Command "New-Item -ItemType Directory -Force -Path '$WIN_CONFIG_DIR' | Out-Null"

# 2. Symlink erstellen (via cmd mklink)
# Wir löschen erst eine existierende Datei, falls nötig
if [ -f "/mnt/c/Users/$(whoami)/.config/wezterm/wezterm.lua" ]; then
    echo "⚠️  Removing existing config..."
    cmd.exe /c "del $WIN_CONFIG_FILE"
fi

echo "✨ Creating Symlink..."
cmd.exe /c "mklink $WIN_CONFIG_FILE $WSL_CONFIG_PATH"

echo "✅ Done! Restart WezTerm to see changes."
