#!/bin/bash

# Beende das Skript bei Fehlern
set -e

# --- Konfiguration ---
GITHUB_USERNAME="smn-hrtzsch" 
REPO_NAME="dotfiles"
DOTFILES_DIR="$HOME/$REPO_NAME"
REPO_URL="https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"

echo ">>> Start Bootstrap für macOS Dotfiles Setup (Nix Edition)..."

# --- 1. Xcode Command Line Tools ---
echo ">>> 1. Überprüfe Xcode Command Line Tools..."
if ! xcode-select -p &>/dev/null; then
    echo "   Xcode Command Line Tools nicht gefunden. Starte Installation..."
    xcode-select --install
    
    echo "   Bitte folge den Anweisungen im Fenster, um die Xcode Command Line Tools zu installieren."
    echo "   Drücke Enter, sobald die Installation abgeschlossen ist."
    read -r
    
    if ! xcode-select -p &>/dev/null; then
        echo "   FEHLER: Xcode Command Line Tools immer noch nicht gefunden."
        exit 1
    fi
else
    echo "   Xcode Command Line Tools bereits installiert."
fi

# --- 2. Nix Installation ---
echo ">>> 2. Überprüfe Nix Installation..."
if ! command -v nix &> /dev/null; then
    echo "   Nix nicht gefunden. Installiere Nix (Determinate Systems Installer)..."
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    
    # Source nix setup for current shell if needed, though installer usually handles it.
    if [ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
        . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
    fi
else
    echo "   Nix bereits installiert."
fi

# --- 3. Repository Klonen ---
echo ">>> 3. Klone Dotfiles Repository..."
if [ -d "$DOTFILES_DIR" ]; then
    echo "   Verzeichnis $DOTFILES_DIR existiert bereits. Überspringe Klonen."
else
    git clone "$REPO_URL" "$DOTFILES_DIR"
    echo "   Repository geklont."
fi

# --- 4. Nix Build anwenden ---
echo ">>> 4. Wende Nix Konfiguration an..."
cd "$DOTFILES_DIR"

echo "   Starte nix-darwin switch..."
# Use --extra-experimental-features to ensure flakes are enabled even if not set in config yet
nix run nix-darwin -- switch --flake ./nix#MacBook-Air-von-Simon

echo ">>> Bootstrap abgeschlossen!"
echo ">>> Bitte starte dein Terminal neu oder logge dich aus und wieder ein."