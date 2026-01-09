#!/bin/bash

# Beende bei Fehler
set -e

# Farben für Output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}>>> Start Bootstrap für macOS Dotfiles Setup (Nix Edition)...${NC}"

# --- 1. Xcode Command Line Tools ---
echo -e "${BLUE}>>> 1. Überprüfe Xcode Command Line Tools...${NC}"
if ! xcode-select -p &>/dev/null; then
    echo -e "${YELLOW}   Xcode Command Line Tools nicht gefunden. Starte Installation...${NC}"
    xcode-select --install
    echo -e "${YELLOW}   Bitte folge den Anweisungen im Popup-Fenster!${NC}"
    echo -e "${YELLOW}   Drücke [ENTER], wenn die Installation abgeschlossen ist...${NC}"
    read -r
else
    echo -e "${GREEN}   ✓ Xcode Command Line Tools bereits installiert.${NC}"
fi

# --- 2. Homebrew Installation (Voraussetzung für nix-darwin Homebrew Modul) ---
echo -e "${BLUE}>>> 2. Überprüfe Homebrew...${NC}"
if ! command -v brew &> /dev/null; then
    echo -e "${YELLOW}   Homebrew nicht gefunden. Installiere Homebrew...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Homebrew Shellenv für diese Session laden
    if [[ "$(uname -m)" == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    echo -e "${GREEN}   ✓ Homebrew bereits installiert.${NC}"
fi

# --- 3. Nix Installation ---
echo -e "${BLUE}>>> 3. Überprüfe Nix Installation...${NC}"
if ! command -v nix &> /dev/null; then
    echo -e "${YELLOW}   Nix nicht gefunden. Installiere Nix (Determinate Systems)...${NC}"
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    
    # Nix Shellenv laden
    if [ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
        . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
    fi
else
    echo -e "${GREEN}   ✓ Nix bereits installiert.${NC}"
fi

# --- 4. SSH Key Setup ---
echo -e "${BLUE}>>> 4. SSH Setup für GitHub...${NC}"
SSH_KEY_PATH="$HOME/.ssh/id_ed25519"
if [ ! -f "$SSH_KEY_PATH" ]; then
    echo -e "${YELLOW}   Kein SSH Key gefunden. Generiere neuen Key...${NC}"
    read -p "   Bitte gib deine E-Mail für den Key ein: " email
    ssh-keygen -t ed25519 -C "$email" -f "$SSH_KEY_PATH"
    
    echo -e "${GREEN}   ✓ SSH Key generiert.${NC}"
    echo -e "\n${YELLOW}   BITTE FÜGE FOLGENDEN PUBLIC KEY ZU GITHUB HINZU:${NC}"
    echo -e "${YELLOW}   https://github.com/settings/ssh/new${NC}\n"
    cat "$SSH_KEY_PATH.pub"
    echo -e "\n"
    echo -e "${YELLOW}   Drücke [ENTER], sobald du den Key auf GitHub hinzugefügt hast...${NC}"
    read -r
else
    echo -e "${GREEN}   ✓ SSH Key existiert bereits.${NC}"
    # Optional: Fragen ob er schon auf GitHub ist?
    echo -e "${YELLOW}   Falls noch nicht geschehen, stelle sicher, dass dieser Key auf GitHub hinterlegt ist:${NC}"
    cat "$SSH_KEY_PATH.pub"
    echo -e "${YELLOW}   (Drücke [ENTER] zum Fortfahren)${NC}"
    read -r
fi

# --- 5. Repository Klonen ---
REPO_DIR="$HOME/dotfiles"
echo -e "${BLUE}>>> 5. Dotfiles Setup...${NC}"

if [ -d "$REPO_DIR" ]; then
    echo -e "${YELLOW}   Ordner ~/dotfiles existiert bereits.${NC}"
    read -p "   Soll er gelöscht und neu geklont werden? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$REPO_DIR"
        echo -e "${GREEN}   Gelöscht.${NC}"
    fi
fi

if [ ! -d "$REPO_DIR" ]; then
    echo -e "${YELLOW}   Klone Repository via SSH...${NC}"
    # StrictHostKeyChecking=no verhindert die "Are you sure..." Frage beim ersten Connect
    git clone git@github.com:smn-hrtzsch/dotfiles.git "$REPO_DIR"
else
    echo -e "${GREEN}   ✓ Repository bereits vorhanden.${NC}"
fi

cd "$REPO_DIR"

# Branch wechseln (NUR FÜR DIE MIGRATIONSPHASE WICHTIG)
CURRENT_BRANCH=$(git branch --show-current)
TARGET_BRANCH="chore/nix-migration"

if [ "$CURRENT_BRANCH" != "$TARGET_BRANCH" ]; then
    echo -e "${YELLOW}   Wechsle auf Branch $TARGET_BRANCH...${NC}"
    git fetch origin
    git checkout "$TARGET_BRANCH"
fi


# --- 6. Nix Build anwenden ---
echo -e "${BLUE}>>> 6. Wende System-Konfiguration an (nix-darwin)...${NC}"
echo -e "${YELLOW}   Hinweis: sudo Passwort wird ggf. abgefragt.${NC}"

# Workaround für "initExtra is deprecated" Warning ignorieren wir erstmal
# Der Befehl wird mit sudo ausgeführt, um Berechtigungsprobleme zu vermeiden
# Wir entfernen --extra-experimental-features, da der Determinate Installer Flakes bereits aktiviert
nix run nix-darwin -- switch --flake ./nix#MacBook-Air-von-Simon

echo -e "${GREEN}>>> Bootstrap erfolgreich abgeschlossen! 🚀${NC}"
echo -e "${GREEN}>>> Bitte starte dein Terminal neu oder logge dich aus und wieder ein.${NC}"