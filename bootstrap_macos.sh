#!/bin/bash

# Beende das Skript bei Fehlern
set -e

# --- Konfiguration ---
GITHUB_USERNAME="smn-hrtzsch" # Bitte anpassen, falls nötig
REPO_NAME="dotfiles"
DOTFILES_DIR="$HOME/$REPO_NAME"
REPO_URL="https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"

echo ">>> Start Bootstrap für macOS Dotfiles Setup..."

# --- 1. Xcode Command Line Tools ---
echo ">>> 1. Überprüfe Xcode Command Line Tools..."
if ! xcode-select -p &>/dev/null; then
    echo "   Xcode Command Line Tools nicht gefunden. Starte Installation..."
    # Dieser Befehl öffnet ein GUI-Fenster für die Installation.
    # Das Skript wird hier warten, bis der Benutzer die Installation abgeschlossen oder abgebrochen hat.
    xcode-select --install
    
    # Kurze Pause, damit der Benutzer reagieren kann und um sicherzustellen, dass der Prozess abgeschlossen ist
    # In einer idealen Welt würde man hier auf den Erfolg warten, aber xcode-select --install gibt nicht direkt Feedback.
    echo "   Bitte folge den Anweisungen im Fenster, um die Xcode Command Line Tools zu installieren."
    echo "   Wenn die Installation abgeschlossen ist, drücke Enter, um fortzufahren, oder brich das Skript mit Ctrl+C ab, falls es Probleme gab."
    read -r
    
    if ! xcode-select -p &>/dev/null; then
        echo "   FEHLER: Xcode Command Line Tools immer noch nicht gefunden. Bitte manuell installieren und Skript erneut starten."
        exit 1
    fi
    echo "   Xcode Command Line Tools erfolgreich installiert/gefunden."
else
    echo "   Xcode Command Line Tools bereits installiert."
fi

# --- 2. Homebrew ---
echo ">>> 2. Überprüfe Homebrew..."
HOMEBREW_PREFIX=""
if [[ "$(uname -m)" == "arm64" ]]; then
    HOMEBREW_PREFIX="/opt/homebrew"
elif [[ "$(uname -m)" == "x86_64" ]]; then
    HOMEBREW_PREFIX="/usr/local"
else
    echo "   FEHLER: Unbekannte Architektur $(uname -m)"
    exit 1
fi

if ! command -v brew &> /dev/null; then
    echo "   Homebrew nicht gefunden. Installiere Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "   Stelle Homebrew für diese Skript-Sitzung bereit..."
    eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"
    echo "   Homebrew installiert."
else
    echo "   Homebrew bereits installiert. Stelle sicher, dass es für diese Sitzung bereit ist..."
    eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"
    echo "   Homebrew wird aktualisiert..."
    brew update
fi

# --- 3. GitHub CLI (gh) ---
echo ">>> 3. Überprüfe GitHub CLI (gh)..."
if ! command -v gh &> /dev/null; then
    echo "   GitHub CLI (gh) nicht gefunden. Installiere gh via Homebrew..."
    brew install gh
    echo "   gh installiert."
else
    echo "   GitHub CLI (gh) bereits installiert."
fi

# --- 4. GitHub Authentifizierung via gh ---
echo ">>> 4. GitHub Authentifizierung..."
if ! gh auth status &>/dev/null; then
    echo "   Nicht bei GitHub authentifiziert. Starte 'gh auth login'..."
    echo "   Bitte folge den Anweisungen, um dich bei GitHub zu authentifizieren."
    echo "   Wähle HTTPS als bevorzugtes Protokoll für Git-Operationen, wenn du dazu aufgefordert wirst."
    echo "   Wähle 'Login with a web browser'."
    gh auth login --hostname github.com --git-protocol https --web
    echo "   Authentifizierung abgeschlossen (hoffentlich!)."
else
    echo "   Bereits bei GitHub authentifiziert."
fi

# --- 5. Dotfiles Repository klonen ---
echo ">>> 5. Klone Dotfiles Repository ($REPO_URL)..."
if [ -d "$DOTFILES_DIR" ]; then
    echo "   Verzeichnis $DOTFILES_DIR existiert bereits. Überspringe Klonen."
    echo "   Hinweis: Wenn du eine frische Kopie willst, lösche das Verzeichnis manuell und starte das Skript neu."
else
    echo "   Klone $REPO_URL nach $DOTFILES_DIR..."
    git clone "$REPO_URL" "$DOTFILES_DIR"
    echo "   Repository geklont."
fi

# --- 6. Zum Dotfiles Verzeichnis wechseln und setup.sh ausführen ---
echo ">>> 6. Wechsle zu $DOTFILES_DIR und führe setup.sh aus..."
cd "$DOTFILES_DIR" || { echo "FEHLER: Konnte nicht zu $DOTFILES_DIR wechseln."; exit 1; }

if [ -f "./setup.sh" ]; then
    echo "   Führe ./setup.sh aus..."
    # Stelle sicher, dass setup.sh ausführbar ist
    chmod +x ./setup.sh
    ./setup.sh
    echo "   setup.sh wurde ausgeführt."
else
    echo "   FEHLER: setup.sh nicht in $DOTFILES_DIR gefunden!"
    exit 1
fi

echo ">>> Bootstrap für macOS Dotfiles Setup abgeschlossen!"
echo ">>> Bitte überprüfe die Ausgaben und starte dein Terminal neu, um alle Änderungen zu übernehmen."

exit 0