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
    cat ~/.ssh/id_ed25519.pub | pbcopy
    ```

    *   Kopiere den Output und füge ihn hier hinzu: [GitHub SSH Keys](https://github.com/settings/ssh/new).

2.  **Xcode Command Line Tools installieren:**
    Bevor du `git` nutzen kannst, musst du die Basis-Tools von Apple installieren:

    ```bash
    xcode-select --install
    ```
    *Folge dem Dialog am Bildschirm und warte, bis die Installation abgeschlossen ist.*

3.  **Repository klonen:**

    ```bash
    git clone git@github.com:smn-hrtzsch/dotfiles.git ~/dotfiles
    cd ~/dotfiles
    git checkout chore/nix-migration
    ```

4.  **Bootstrap-Skript starten:**
    Dieses Skript installiert automatisch Xcode Tools, Homebrew, Nix und wendet die Konfiguration an.

    ```bash
    chmod +x bootstrap_macos.sh
    ./bootstrap_macos.sh
    ```

## 🐧 Linux (Generic) Setup

Dieses Setup funktioniert auf den meisten Linux-Distributionen (getestet auf Ubuntu/Debian, Fedora, Arch).

1.  **Vorbereitung (Installiere curl & git):**
    Auf einem frischen System fehlen oft grundlegende Tools. Führe dies zuerst aus:

    *Ubuntu/Debian:*
    ```bash
    sudo apt update && sudo apt install -y curl git
    ```

    *Fedora:*
    ```bash
    sudo dnf install -y curl git
    ```

2.  **Lade das Bootstrap-Script herunter und führe es aus:**

    ```bash
    curl -sL https://raw.githubusercontent.com/smn-hrtzsch/dotfiles/feat/linux-support/bootstrap_linux.sh | bash
    ```

    *Hinweis: Ersetze `feat/linux-support` durch `main`, sobald der Branch gemergt ist.*

3.  **Folge den Anweisungen:**
    Das Skript installiert Nix, klont das Repo und fragt dich nach deinem Username und Git-Details, um die Konfiguration anzupassen.

    Falls `nix` danach nicht gefunden wird, fuehre einmal aus:

    ```bash
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    ```

    **GNOME Terminal Theme & Font:**
    Der Setup setzt den Coolnight‑Look und den Meslo Nerd Font automatisch per dconf.
    Falls du das Terminal offen hattest, starte es danach einmal neu.

**Hinweis zu ARM64 (Apple Silicon / aarch64):**
Einige proprietaere Apps sind auf ARM64 in nixpkgs nicht verfuegbar.
Auf ARM64 installiert das Setup daher Alternativen (z.B. Firefox und VSCodium) und laesst nicht-verfuegbare Apps aus.
Auf Ubuntu/Debian (ARM64) versucht das Bootstrap-Skript zusaetzlich, **Brave** und **VS Code** ueber die offiziellen Hersteller-Repos zu installieren.
Wenn du volle App-Paritaet moechtest, nutze eine x86_64 Linux VM.

## 🪟 Windows (WSL 2) Setup

### 1. Automatische Installation (Empfohlen)

Ich habe ein PowerShell-Skript erstellt, das eine neue WSL-Distro (`Ubuntu-Nix`) herunterlädt, importiert und vorbereitet.

1.  **PowerShell als Administrator** öffnen.
2.  Skript ausführen (lädt Ubuntu 24.04 Image und richtet User ein):

    ```powershell
    # Falls das Repo schon auf Windows liegt:
    cd \Pfad\Zu\dotfiles\scripts
    .\setup_wsl.ps1 -DistroName "Ubuntu-Nix"

    # ODER direkt aus dem Web (One-Liner):
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/smn-hrtzsch/dotfiles/main/scripts/setup_wsl.ps1'))
    ```

3.  **Setup abschließen:**
    Wechsle in die neue Distro und starte die Nix-Installation:

    ```powershell
    wsl -d Ubuntu-Nix
    ./finish_setup.sh
    ```
    *Das Skript generiert einen SSH-Key, pausiert damit du ihn bei GitHub hinzufügen kannst, und installiert dann alles via Nix.*

### 2. Manuelle Installation
Falls du es manuell machen möchtest:
1.  Ubuntu via `wsl --install` oder Import installieren.
2.  Nix installieren (Determinate Systems Installer).
3.  Repo klonen und `nix run home-manager/master -- switch --flake ./nix#wsl` ausführen.
4.  Zsh via `chsh -s $(which zsh)` aktivieren.

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
