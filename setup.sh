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
    # spezifische Vorab-Logik für ssh
    if [[ "$pkg" == "ssh" ]]; then
        echo "      Ensuring $HOME/.ssh directory exists and has correct permissions..."
        mkdir -p "$HOME/.ssh"
        chmod 700 "$HOME/.ssh"
        echo "      Stowing content of '$pkg' package into $HOME/.ssh ..."
        # Linkt den Inhalt von ~/dotfiles/ssh/* (also deine ~/dotfiles/ssh/config Datei)
        # nach $HOME/.ssh/config
        stow -R -v -t "$HOME/.ssh" "$pkg" 
        continue # Wichtig, damit der generische stow-Aufruf am Ende der Schleife für ssh übersprungen wird!
    fi

    # Führe stow für das Paket aus
    # -R (restow) sorgt dafür, dass existierende korrekte Links nicht als Fehler gelten
    # Das Ziel wird durch die Verzeichnisstruktur innerhalb des $pkg Ordners relativ zum Home-Verzeichnis bestimmt.
    echo "   Stowing $pkg..."
    stow -R -v "$pkg"
done

echo ">>> Symlinks created/updated."

# --- SSH Schlüssel generieren (optional) ---
echo ">>> SSH Schlüssel Generierung..."
# Überprüfe, ob bereits ein Standard ed25519 Schlüssel existiert
if [ -f "$HOME/.ssh/id_ed25519" ]; then
    echo "   INFO: Ein SSH Schlüssel ($HOME/.ssh/id_ed25519) existiert bereits."
    echo "   Möchtest du einen neuen Schlüssel generieren? (Ein existierender Schlüssel mit gleichem Namen wird NICHT überschrieben, ssh-keygen fragt dann nach einem anderen Dateinamen oder bricht ab)"
    read -r -p "   Neuen SSH Schlüssel generieren? (j/N): " response
    if [[ ! "$response" =~ ^([jJ][aA]|[jJ])$ ]]; then
        echo "   Überspringe Generierung eines neuen SSH Schlüssels."
        # Optional: Zeige den existierenden Public Key an
        if [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
            echo "   Dein existierender öffentlicher Schlüssel ($HOME/.ssh/id_ed25519.pub):"
            cat "$HOME/.ssh/id_ed25519.pub"
            echo "   Du kannst diesen ggf. bei GitHub hinzufügen: https://github.com/settings/keys"
        fi
        # Hier könnte man zum nächsten Schritt springen oder das Skript normal beenden lassen
    else
        # Benutzer will neuen Schlüssel generieren, obwohl einer existiert (oder für den Fall, dass die obige Abfrage verneint wurde und hier trotzdem generiert werden soll)
        NEUER_SCHLUESSEL_GENERIEREN=true
    fi
else
    # Kein Schlüssel existiert, also generieren
    NEUER_SCHLUESSEL_GENERIEREN=true
fi

if [ "$NEUER_SCHLUESSEL_GENERIEREN" = true ]; then
    echo "   Generiere neues SSH Schlüsselpaar (ed25519)..."
    read -r -p "   Bitte gib deine E-Mail-Adresse für den SSH Schlüssel ein (z.B. dein GitHub E-Mail): " user_email
    
    # Generiere den Schlüssel. -f gibt den Dateipfad an. Ohne -N "" würde nach einer Passphrase gefragt.
    # Wenn die Datei existiert, wird ssh-keygen fragen, ob überschrieben werden soll.
    # Um ein Überschreiben eines existierenden Schlüssels durch das Skript zu vermeiden, könnte man vorher prüfen oder einen anderen Namen wählen.
    # Für Einfachheit belassen wir es bei der Standardabfrage von ssh-keygen.
    ssh-keygen -t ed25519 -C "$user_email" -f "$HOME/.ssh/id_ed25519"
    
    if [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
        echo ""
        echo "------------------------------------------------------------------------------------"
        echo "   SSH Schlüssel erfolgreich generiert!"
        echo "   Dein öffentlicher Schlüssel ist:"
        echo ""
        cat "$HOME/.ssh/id_ed25519.pub"
        echo ""
        echo "   So fügst du ihn zu GitHub hinzu:"
        echo "   1. Kopiere den gesamten oben angezeigten öffentlichen Schlüssel"
        echo "      (von 'ssh-ed25519' bis zu deiner E-Mail-Adresse)."
        echo "   2. Öffne GitHub in deinem Browser: https://github.com/settings/keys"
        echo "   3. Klicke auf 'New SSH key'."
        echo "   4. Gib einen Titel für den Schlüssel ein (z.B. 'Mein MacBook Air M2')."
        echo "   5. Füge den kopierten Schlüssel in das 'Key'-Feld ein."
        echo "   6. Klicke auf 'Add SSH key'."
        echo ""
        echo "   Du kannst den SSH-Agent auch anweisen, deine Schlüssel-Passphrase (falls du eine festgelegt hast) im macOS Keychain zu speichern:"
        echo "   Füge dazu folgendes in deine ~/.ssh/config Datei ein (falls noch nicht vorhanden):"
        echo "   Host *"
        echo "     AddKeysToAgent yes"
        echo "     UseKeychain yes"
        echo "     IdentityFile ~/.ssh/id_ed25519"
        echo ""
        echo "   Und starte den SSH-Agenten neu oder füge den Schlüssel hinzu mit: ssh-add --apple-use-keychain ~/.ssh/id_ed25519"
        echo "------------------------------------------------------------------------------------"
    else
        echo "   FEHLER: SSH Schlüssel-Generierung scheint fehlgeschlagen zu sein. Datei $HOME/.ssh/id_ed25519.pub nicht gefunden."
    fi
fi

echo ">>> ssh-Key created/updated."

# --- Finale Schritte ---
echo ">>> Setup script finished!"
echo ">>> Bitte starte dein Terminal neu oder logge dich aus und wieder ein, damit alle Änderungen wirksam werden."
echo ">>> Für VS Code: Falls der 'code' Befehl nicht sofort funktionierte, starte VS Code einmal manuell und führe ggf. aus der Command Palette (Shift+Cmd+P) 'Shell Command: Install code command in PATH' aus."

exit 0