#!/bin/bash

# Beende das Skript bei Fehlern
set -e

echo ">>> Setting up new Mac..."

# --- Homebrew Installation ---
# Variable für den Homebrew-Pfad, je nach Architektur
HOMEBREW_PREFIX=""
if [[ "$(uname -m)" == "arm64" ]]; then
    HOMEBREW_PREFIX="/opt/homebrew"
elif [[ "$(uname -m)" == "x86_64" ]]; then
    HOMEBREW_PREFIX="/usr/local"
else
    echo ">>> ERROR: Unknown architecture $(uname -m)"
    exit 1
fi

if ! command -v brew &> /dev/null; then
    echo ">>> Homebrew not found. Installing Homebrew..."
    # Non-interactive install
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # WICHTIG: Homebrew *sofort* für den Rest des Skripts verfügbar machen
    echo ">>> Making Homebrew available for this script run..."
    eval "$(${HOMEBREW_PREFIX}/bin/brew shellenv)"
else
    echo ">>> Homebrew already installed. Updating..."
    brew update
fi

# --- Stelle sicher, dass wir im dotfiles Verzeichnis sind ---
# Geht davon aus, dass das Skript aus dem geklonten Repo ausgeführt wird
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$SCRIPT_DIR" || exit 1
echo ">>> Running setup from: $(pwd)"

# --- Stow installieren ---
if ! command -v stow &> /dev/null; then
    echo ">>> Installing stow..."
    brew install stow
else
    echo ">>> Stow already installed."
fi

# --- Symlinks mit Stow erstellen ---
# Wichtig: Führe dies aus dem dotfiles-Verzeichnis aus!
echo ">>> Creating symlinks with stow..."

# Liste aller Konfigurationspakete für stow
# Passe diese Liste ggf. an
STOW_PACKAGES_HOME=( git zsh conda npm ) # Pakete, die direkt nach ~ linken
STOW_PACKAGES_SUBDIR=( ssh warp vscode config ) # Pakete, die in Unterverzeichnisse linken

# Stow für Pakete, die direkt nach ~ linken sollen
echo ">>> Stowing packages for ~ ..."
for pkg in "${STOW_PACKAGES_HOME[@]}"; do
    echo "   Stowing $pkg to ~ ..."
    # -R überschreibt alte stow-Symlinks, -t ~ Ziel ist Home
    # Wichtig: Vorhandene *echte* Dateien werden NICHT überschrieben,
    # daher müssen wir sicherstellen, dass der Platz frei ist (was bei zsh nicht der Fall war).
    # Wir gehen davon aus, dass die Konflikte für git, conda, npm nicht existieren
    # oder bereits manuell gelöst wurden. Für zsh wird der Link jetzt erstellt.
    stow -R -v -t ~ "$pkg"
done

# Stow für Pakete, die in Unterverzeichnisse linken sollen (OHNE -t ~ !)
echo ">>> Stowing packages for subdirectories ..."
for pkg in "${STOW_PACKAGES_SUBDIR[@]}"; do
    echo "   Stowing $pkg (no target)..."
    # Hier gehen wir davon aus, dass die Ziel-Unterverzeichnisse (~/.ssh, ~/.config etc.)
    # nicht existieren oder dass Konflikte darin manuell gelöst wurden.
    stow -R -v "$pkg"
done

echo ">>> Symlinks created/updated."

# --- Homebrew zum PATH hinzufügen (JETZT in die gestowten Dateien!) ---
# Füge die brew shellenv Zeile zu den Zieldateien hinzu, falls sie fehlt.
ZPROFILE_TARGET="$SCRIPT_DIR/zsh/.zprofile" # Ziel im Repo
ZSHRC_TARGET="$SCRIPT_DIR/zsh/.zshrc"     # Ziel im Repo
SHELLENV_CMD="eval \"\$(${HOMEBREW_PREFIX}/bin/brew shellenv)\""

echo ">>> Ensuring Homebrew env is set in dotfiles..."

# Füge zu .zprofile hinzu (falls nicht schon vorhanden)
if [ -f "$ZPROFILE_TARGET" ] && ! grep -qF -- "$SHELLENV_CMD" "$ZPROFILE_TARGET"; then
    echo "   Adding brew shellenv to $ZPROFILE_TARGET"
    # Füge eine Leerzeile davor ein, falls die Datei nicht leer ist
    if [ -s "$ZPROFILE_TARGET" ]; then echo "" >> "$ZPROFILE_TARGET"; fi
    echo "# Add Homebrew to PATH" >> "$ZPROFILE_TARGET"
    echo "$SHELLENV_CMD" >> "$ZPROFILE_TARGET"
elif [ ! -f "$ZPROFILE_TARGET" ]; then
     echo "   Creating $ZPROFILE_TARGET and adding brew shellenv"
     echo "# Add Homebrew to PATH" > "$ZPROFILE_TARGET"
     echo "$SHELLENV_CMD" >> "$ZPROFILE_TARGET"
fi

# Füge zu .zshrc hinzu (falls nicht schon vorhanden - oft nicht nötig, wenn in .zprofile)
# Optional, je nach deiner Konfiguration. Hier zur Sicherheit hinzugefügt.
if [ -f "$ZSHRC_TARGET" ] && ! grep -qF -- "$SHELLENV_CMD" "$ZSHRC_TARGET"; then
    echo "   Adding brew shellenv to $ZSHRC_TARGET"
    if [ -s "$ZSHRC_TARGET" ]; then echo "" >> "$ZSHRC_TARGET"; fi
    echo "# Add Homebrew to PATH (sourced by interactive shells)" >> "$ZSHRC_TARGET"
    echo "$SHELLENV_CMD" >> "$ZSHRC_TARGET"
elif [ ! -f "$ZSHRC_TARGET" ]; then
     echo "   Creating $ZSHRC_TARGET and adding brew shellenv"
     echo "# Add Homebrew to PATH (sourced by interactive shells)" > "$ZSHRC_TARGET"
     echo "$SHELLENV_CMD" >> "$ZSHRC_TARGET"
fi

# --- Anwendungen via Brewfile installieren ---
echo ">>> Installing applications from Brewfile..."
if [ -f "./Brewfile" ]; then
    brew bundle install --file=./Brewfile
    echo ">>> Brew bundle install completed."
else
    echo ">>> WARNUNG: Brewfile nicht im Skriptverzeichnis gefunden."
fi

# --- VS Code Extensions installieren (optional) ---
VSCODE_EXTENSIONS_FILE="./vscode/extensions.txt"
if command -v code &> /dev/null && [ -f "$VSCODE_EXTENSIONS_FILE" ]; then
    echo ">>> Installing VS Code extensions from $VSCODE_EXTENSIONS_FILE..."
    # Verwende die verbesserte Version ohne 'cat'
    xargs -L 1 code --install-extension < "$VSCODE_EXTENSIONS_FILE"
    echo ">>> VS Code extensions installation attempted."
elif ! command -v code &> /dev/null; then
    echo ">>> Skipping VS Code extensions: 'code' command not found (might need restart or PATH adjustment)."
elif [ ! -f "$VSCODE_EXTENSIONS_FILE" ]; then
     echo ">>> Skipping VS Code extensions: $VSCODE_EXTENSIONS_FILE not found."
fi

# --- Finale Schritte ---
echo ">>> Setup script finished!"
echo ">>> Bitte starte dein Terminal neu oder logge dich aus und wieder ein, damit alle Änderungen wirksam werden."

exit 0
