# Mein System Setup (Nix Edition)

Dieses Repository enthält meine persönlichen Konfigurationen (Dotfiles) und ein vollständig reproduzierbares System-Setup basierend auf **Nix**. Es unterstützt sowohl **macOS** (Apple Silicon) als auch **Windows (WSL 2)**.

## Vision

Ziel ist es, das komplette System – von Systemeinstellungen über installierte Programme bis hin zu Dotfiles – deklarativ und reproduzierbar zu verwalten. Ein einziger Befehl soll genügen, um eine neue Maschine exakt wie die aktuelle einzurichten.

## 🍎 macOS Setup

### Voraussetzungen
*   Frisches macOS.
*   Internetverbindung.

### Installation

Da dieses Repository privat ist, richte zuerst einen SSH-Key ein, um das Repository klonen zu können. Das integrierte Bootstrap-Skript übernimmt danach die restliche Einrichtung.

1.  **SSH Key für GitHub einrichten:**
    Generiere einen Key und füge ihn zu deinem GitHub Account hinzu.

    ```bash
    ssh-keygen -t ed25519 -C "simon@hoertzsch.de"
    cat ~/.ssh/id_ed25519.pub
    ```

    *   Kopiere den Output und füge ihn hier hinzu: [GitHub SSH Keys](https://github.com/settings/ssh/new).

2.  **Repository klonen:**

    ```bash
    git clone git@github.com:smn-hrtzsch/dotfiles.git ~/dotfiles
    cd ~/dotfiles
    git checkout chore/nix-migration
    ```

3.  **Bootstrap-Skript starten:**
    Dieses Skript installiert automatisch Xcode Tools, Homebrew, Nix und wendet die Konfiguration an.

    ```bash
    chmod +x bootstrap_macos.sh
    ./bootstrap_macos.sh
    ```

## 🪟 Windows (WSL 2) Setup

### 1. Windows Apps & Fonts (Host)
Installiere GUI-Apps (VS Code, Spotify, Fonts) via Winget. Öffne **PowerShell als Administrator**:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/smn-hrtzsch/dotfiles/main/scripts/install_windows_apps.ps1'))
```
(Oder klone das Repo manuell und führe das Skript aus `scripts/install_windows_apps.ps1` aus).

### 2. WSL Umgebung (Nix)
Führe folgende Schritte **in deiner WSL-Distro (Ubuntu)** aus.

1.  **SSH Key für GitHub einrichten:**
    Damit du das Repo klonen und pushen kannst.

    ```bash
    ssh-keygen -t ed25519 -C "deine-email@beispiel.de"
    cat ~/.ssh/id_ed25519.pub
    ```
    *   Füge den Key auf [GitHub](https://github.com/settings/ssh/new) hinzu.

2.  **Nix installieren:**

    ```bash
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    ```

3.  **Repo klonen:**

    ```bash
    git clone git@github.com:smn-hrtzsch/dotfiles.git ~/dotfiles
    cd ~/dotfiles
    ```

4.  **Setup anwenden:**

    ```bash
    nix run home-manager/master -- switch --flake ./nix#wsl
    ```

5.  **Abschluss:**
    Setze Zsh als Standardshell:
    ```bash
    # Zsh zur Liste erlaubter Shells hinzufügen
    command -v zsh | sudo tee -a /etc/shells
    # Zsh als Standard setzen
    chsh -s $(command -v zsh)
    ```
    Starten nun dein Terminal neu.

## 🎨 Theme & Fonts (Windows)

Nix konfiguriert deine Shell (Inhalt), aber **Windows** verwaltet das Fenster (Farben, Fonts).

1.  **Font:** Stelle sicher, dass "MesloLGS NF" in deinem Windows-Terminal (Einstellungen -> Profile -> Ubuntu -> Darstellung -> Schriftart) ausgewählt ist.
2.  **Theme (Coolnight):**
    *   **Windows Terminal:** Du musst das Farbschema manuell in den Einstellungen hinzufügen (JSON).
    *   **Ghostty (Windows):** Kopiere die Config aus `~/dotfiles/config/.config/ghostty/config` nach `%APPDATA%/ghostty/config`.

## Verwaltung

Das System wird deklarativ über Nix Flakes in `~/dotfiles/nix/` gesteuert.

*   **`flake.nix`**: Der Einstiegspunkt für alle Systeme.
*   **`darwin-configuration.nix`**: macOS-spezifische Einstellungen (System, Homebrew).
*   **`home.nix`**: Geteilte Konfiguration (Shell, CLI-Tools, Dotfiles) für macOS und Linux.

### Änderungen vornehmen

1.  Bearbeite die `.nix` Dateien.
2.  Wende die Änderungen an:
    *   **macOS:** `darwin-rebuild switch --flake ~/dotfiles/nix`
    *   **WSL:** `home-manager switch --flake ~/dotfiles/nix#wsl`

---
Viel Spaß mit deinem reproduzierbaren Setup!
