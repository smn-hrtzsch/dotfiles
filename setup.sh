#!/bin/bash

# Beende das Skript bei Fehlern
set -e

echo ">>> Setting up new Mac..."

# --- Homebrew Installation ---
if ! command -v brew &> /dev/null; then
    echo ">>> Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Homebrew zum PATH hinzufügen für Apple Silicon (M-Chips)
    if [[ "$(uname -m)" == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc # Auch für aktuelle Shell
    # Für Intel Macs
    elif [[ "$(uname -m)" == "x86_64" ]]; then
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
         eval "$(/usr/local/bin/brew shellenv)"
         echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zshrc # Auch für aktuelle Shell
    fi
    echo ">>> Added Homebrew to PATH"
else
    echo ">>> Homebrew already installed. Updating..."
    brew update
fi

# --- Git Klonen (Nur nötig, wenn Skript *nicht* aus dem Repo läuft) ---
# Stellt sicher, dass wir im richtigen Verzeichnis sind, falls das Skript
# von woanders aufgerufen wird, nachdem das Repo geklont wurde.
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
echo ">>> Creating symlinks with stow..."

# Liste aller deiner Konfigurationspakete für stow
# Füge hier alle Ordner aus Schritt 2 hinzu, die du verwalten willst
STOW_PACKAGES=(
    git
    zsh
    ssh
    warp
    vscode
    conda
    config
    npm # Nur wenn du .npmrc hast
    # local # Wenn du .local/bin o.ä. nutzt
)

# Erstelle die Symlinks
for pkg in "${STOW_PACKAGES[@]}"; do
    echo "   Stowing $pkg..."
    # -R überschreibt vorhandene Symlinks, falls nötig
    # -t ~ setzt das Zielverzeichnis explizit auf das Home-Verzeichnis
    stow -R -t ~ "$pkg"
done

echo ">>> Symlinks created/updated."

# --- Anwendungen via Brewfile installieren ---
echo ">>> Installing applications from Brewfile..."
# Stelle sicher, dass der Pfad zum Brewfile korrekt ist (./Brewfile, wenn im Repo-Root)
if [ -f "./Brewfile" ]; then
    brew bundle install --file=./Brewfile
    echo ">>> Brew bundle install completed."
else
    echo ">>> WARNUNG: Brewfile nicht im Skriptverzeichnis gefunden."
fi

echo ">>> Installing VS Code extensions..."
if [ -f "./vscode/extensions.txt" ]; then
    cat ./vscode/extensions.txt | xargs -L 1 code --install-extension
else
    echo ">>> extensions.txt not found."
fi

# --- Finale Schritte ---
echo ">>> Setup script finished!"
echo ">>> Bitte starte dein Terminal neu oder logge dich aus und wieder ein, damit alle Änderungen wirksam werden."

exit 0
