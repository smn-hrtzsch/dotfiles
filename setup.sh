#!/bin/bash

# Beende das Skript bei Fehlern
set -e

echo ">>> Setting up new Mac..."

# --- Stelle sicher, dass wir im dotfiles Verzeichnis sind ---
# Geht davon aus, dass das Skript aus dem geklonten Repo ausgeführt wird
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$SCRIPT_DIR" || exit 1
echo ">>> Running setup from: $(pwd)"

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

    echo ">>> Making Homebrew available for this script run..."
    eval "$(${HOMEBREW_PREFIX}/bin/brew shellenv)"
else
    echo ">>> Homebrew already installed. Updating..."
    # Stelle sicher, dass Homebrew auch für den Rest des Skripts verfügbar ist, falls es gerade erst initialisiert wurde
    eval "$(${HOMEBREW_PREFIX}/bin/brew shellenv)"
    brew update
fi

# --- Stow installieren ---
if ! command -v stow &> /dev/null; then
    echo ">>> Installing stow..."
    brew install stow
else
    echo ">>> Stow already installed."
fi

# --- Homebrew zum PATH hinzufügen (in die Konfigurationsdateien im Repo schreiben) ---
# Dies geschieht, bevor 'stow' die zsh-Konfigurationen linkt.
ZPROFILE_TARGET="$SCRIPT_DIR/zsh/.zprofile" # Ziel im Repo
ZSHRC_TARGET="$SCRIPT_DIR/zsh/.zshrc"     # Ziel im Repo
SHELLENV_CMD="eval \"\$(${HOMEBREW_PREFIX}/bin/brew shellenv)\""

echo ">>> Ensuring Homebrew env is set in dotfiles (zsh config in repo)..."

# Füge zu .zprofile hinzu (falls nicht schon vorhanden)
if [ -f "$ZPROFILE_TARGET" ]; then
    if ! grep -qF -- "$SHELLENV_CMD" "$ZPROFILE_TARGET"; then
        echo "   Adding brew shellenv to $ZPROFILE_TARGET"
        if [ -s "$ZPROFILE_TARGET" ]; then echo "" >> "$ZPROFILE_TARGET"; fi
        echo "# Add Homebrew to PATH" >> "$ZPROFILE_TARGET"
        echo "$SHELLENV_CMD" >> "$ZPROFILE_TARGET"
    else
        echo "   Brew shellenv already in $ZPROFILE_TARGET."
    fi
elif [ -d "$SCRIPT_DIR/zsh" ]; then # Nur erstellen, wenn das zsh-Verzeichnis existiert
     echo "   Creating $ZPROFILE_TARGET and adding brew shellenv"
     echo "# Add Homebrew to PATH" > "$ZPROFILE_TARGET"
     echo "$SHELLENV_CMD" >> "$ZPROFILE_TARGET"
else
    echo "   WARN: zsh directory not found in dotfiles, skipping .zprofile update for Homebrew."
fi

# Füge zu .zshrc hinzu (falls nicht schon vorhanden)
if [ -f "$ZSHRC_TARGET" ]; then
    if ! grep -qF -- "$SHELLENV_CMD" "$ZSHRC_TARGET"; then
        echo "   Adding brew shellenv to $ZSHRC_TARGET"
        if [ -s "$ZSHRC_TARGET" ]; then echo "" >> "$ZSHRC_TARGET"; fi
        echo "# Add Homebrew to PATH (sourced by interactive shells)" >> "$ZSHRC_TARGET"
        echo "$SHELLENV_CMD" >> "$ZSHRC_TARGET"
    else
        echo "   Brew shellenv already in $ZSHRC_TARGET."
    fi
elif [ -d "$SCRIPT_DIR/zsh" ]; then # Nur erstellen, wenn das zsh-Verzeichnis existiert
     echo "   Creating $ZSHRC_TARGET and adding brew shellenv"
     echo "# Add Homebrew to PATH (sourced by interactive shells)" > "$ZSHRC_TARGET"
     echo "$SHELLENV_CMD" >> "$ZSHRC_TARGET"
else
    echo "   WARN: zsh directory not found in dotfiles, skipping .zshrc update for Homebrew."
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
    # Stellt sicher, dass jede Zeile als separates Argument behandelt wird, auch wenn sie Leerzeichen enthält (sollte bei Extension-IDs nicht der Fall sein)
    while IFS= read -r extension || [[ -n "$extension" ]]; do
        if [[ -n "$extension" && ! "$extension" =~ ^\s*# ]]; then # Überspringe leere Zeilen und Kommentare
            echo "   Installing $extension..."
            code --install-extension "$extension"
        fi
    done < "$VSCODE_EXTENSIONS_FILE"
    echo ">>> VS Code extensions installation attempted."
elif ! command -v code &> /dev/null; then
    echo ">>> Skipping VS Code extensions: 'code' command not found. VS Code might need to be started once, or 'Install code command in PATH' executed from VS Code."
elif [ ! -f "$VSCODE_EXTENSIONS_FILE" ]; then
     echo ">>> Skipping VS Code extensions: $VSCODE_EXTENSIONS_FILE not found."
fi

# --- Symlinks mit Stow erstellen ---
echo ">>> Creating symlinks with stow..."

# Liste aller Konfigurationspakete für stow
# Passe diese Liste ggf. an
STOW_PACKAGES_HOME=( git zsh conda ) # Pakete, die direkt nach ~ linken
STOW_PACKAGES_SUBDIR=( ssh warp vscode config ) # Pakete, die in Unterverzeichnisse linken (Zielstruktur im Paket definiert)

# Stow für Pakete, die direkt nach ~ linken sollen
echo ">>> Stowing packages for ~ ..."
for pkg in "${STOW_PACKAGES_HOME[@]}"; do
    if [ -d "$SCRIPT_DIR/$pkg" ]; then # Prüfen ob das Stow-Paket Verzeichnis existiert
        echo "   Stowing $pkg to ~ ..."
        stow -R -v -t ~ "$pkg"
    else
        echo "   WARN: Stow package directory '$SCRIPT_DIR/$pkg' not found. Skipping."
    fi
done

# Stow für Pakete, die in Unterverzeichnisse linken sollen
echo ">>> Stowing packages for subdirectories (targets defined by package structure)..."
for pkg in "${STOW_PACKAGES_SUBDIR[@]}"; do
    if [ ! -d "$SCRIPT_DIR/$pkg" ]; then # Prüfen ob das Stow-Paket Verzeichnis existiert
        echo "   WARN: Stow package directory '$SCRIPT_DIR/$pkg' not found. Skipping $pkg."
        continue
    fi

    echo "   Processing stow package $pkg..."

    # --- Spezifische Vorab-Logik für bestimmte Pakete ---
    if [[ "$pkg" == "config" ]]; then
        # Annahme: ghostty Konfiguration ist Teil des 'config' stow Pakets
        # Pfad zur Konfigurationsdatei *innerhalb* des 'config' Stow-Pakets im Repo:
        # z.B. dotfiles/config/Library/Application Support/com.mitchellh.ghostty/config
        # Zielpfad im Home-Verzeichnis des Benutzers:
        GHOSTTY_CONFIG_DIR_IN_REPO="$SCRIPT_DIR/$pkg/Library/Application Support/com.mitchellh.ghostty" # Pfad bis zum Ordner *im Repo*
        GHOSTTY_TARGET_PARENT_DIR="$HOME/Library/Application Support"
        GHOSTTY_TARGET_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
        GHOSTTY_TARGET_CONFIG_FILE="$GHOSTTY_TARGET_DIR/config" # Die eigentliche Zieldatei

        # Prüfen, ob die App (ghostty) installiert ist (optional, aber empfohlen)
        # Ersetze 'ghostty' mit dem tatsächlichen Brew-Namen, falls abweichend
        if brew list ghostty &>/dev/null; then
            echo "      Performing pre-stow checks for ghostty (expected within '$pkg' package)..."

            # 1. Sicherstellen, dass das übergeordnete Zielverzeichnis existiert (z.B. ~/Library/Application Support)
            #    `stow` würde das normalerweise beim Linken der Ordnerstruktur tun, aber explizit ist sicherer.
            if [ ! -d "$GHOSTTY_TARGET_PARENT_DIR" ]; then
                echo "         Creating parent target directory: $GHOSTTY_TARGET_PARENT_DIR"
                mkdir -p "$GHOSTTY_TARGET_PARENT_DIR"
            fi
            
            # 2. Sicherstellen, dass das spezifische App-Konfigurationsverzeichnis existiert
            #    Dies ist wichtig, falls die App es nicht selbst erstellt hat oder `stow` nur eine Datei linken soll.
            #    Wenn deine `dotfiles/config/Library/Application Support/com.mitchellh.ghostty/` Struktur existiert,
            #    wird `stow` diesen Ordner sowieso anlegen/linken. Diese Prüfung ist also doppelt sicher,
            #    insbesondere wenn du eine einzelne Datei direkt in ein schon bestehendes Verzeichnis linken würdest.
            if [ -d "$GHOSTTY_CONFIG_DIR_IN_REPO" ] && [ ! -d "$GHOSTTY_TARGET_DIR" ]; then
                 echo "         Target directory $GHOSTTY_TARGET_DIR does not exist. Stow will attempt to create it based on package structure."
                 # Optional: mkdir -p "$GHOSTTY_TARGET_DIR" # Wenn du sicherstellen willst, dass es existiert, bevor stow es tut.
            fi

            # 3. Vorhandene *echte* Konfigurationsdatei prüfen und ggf. Backup erstellen
            #    Dies betrifft den Fall, wo `~/Library/Application Support/com.mitchellh.ghostty/config` eine normale Datei ist.
            if [ -f "$GHOSTTY_TARGET_CONFIG_FILE" ] && [ ! -L "$GHOSTTY_TARGET_CONFIG_FILE" ]; then
                BACKUP_FILE="${GHOSTTY_TARGET_CONFIG_FILE}.backup_$(date +%Y%m%d%H%M%S)"
                echo "         Existing real config file found at $GHOSTTY_TARGET_CONFIG_FILE. Backing up to $BACKUP_FILE"
                mv "$GHOSTTY_TARGET_CONFIG_FILE" "$BACKUP_FILE"
            elif [ -L "$GHOSTTY_TARGET_CONFIG_FILE" ]; then
                echo "         Config at $GHOSTTY_TARGET_CONFIG_FILE is already a symlink. Stow will manage it."
            fi
            # Hier könnten weitere spezifische Überprüfungen für andere Konfigurationen im 'config'-Paket folgen
        else
            echo "      WARN: ghostty not found via Homebrew. Stow for its config might have no effect or link to an unused path."
        fi
    fi
    # Ende der spezifischen Logik für 'config'

    # Führe stow für das Paket aus
    # -R (restow) sorgt dafür, dass existierende korrekte Links nicht als Fehler gelten
    # Das Ziel wird durch die Verzeichnisstruktur innerhalb des $pkg Ordners relativ zum Home-Verzeichnis bestimmt.
    echo "   Stowing $pkg..."
    stow -R -v "$pkg"
done

echo ">>> Symlinks created/updated."

# --- Finale Schritte ---
echo ">>> Setup script finished!"
echo ">>> Bitte starte dein Terminal neu oder logge dich aus und wieder ein, damit alle Änderungen wirksam werden."
echo ">>> Für VS Code: Falls der 'code' Befehl nicht sofort funktionierte, starte VS Code einmal manuell und führe ggf. aus der Command Palette (Shift+Cmd+P) 'Shell Command: Install code command in PATH' aus."

exit 0