# Mein System Setup (Nix Edition)

Dieses Repository enthält meine persönlichen Konfigurationen (Dotfiles) und ein vollständig reproduzierbares System-Setup basierend auf **Nix**. Es unterstützt sowohl **macOS** (Apple Silicon) als auch **Windows (WSL 2)**.

## Vision

Ziel ist es, das komplette System – von Systemeinstellungen über installierte Programme bis hin zu Dotfiles – deklarativ und reproduzierbar zu verwalten. Ein einziger Befehl soll genügen, um eine neue Maschine exakt wie die aktuelle einzurichten.

## 🍎 macOS Setup

### Voraussetzungen
*   Frisches macOS.
*   Internetverbindung.

### Installation

1.  **SSH Key einrichten (Empfohlen für GitHub Zugriff):**
    Damit du das Repository klonen und später pushen kannst, richte einen SSH Key ein.

    ```bash
    ssh-keygen -t ed25519 -C "simon@hoertzsch.de"
    cat ~/.ssh/id_ed25519.pub
    ```

    *   Füge den kopierten Key auf GitHub hinzu: [Settings -> SSH Keys -> New SSH Key](https://github.com/settings/ssh/new).

2.  **Xcode Command Line Tools installieren:**

    ```bash
    xcode-select --install
    ```

3.  **Nix installieren (Determinate Systems Installer):**

    ```bash
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    ```

4.  **Nix in aktueller Shell aktivieren:**

    ```bash
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    ```

5.  **Repository klonen (SSH):**
    ```bash
    git clone git@github.com:smn-hrtzsch/dotfiles.git ~/dotfiles
    cd ~/dotfiles
    git checkout chore/nix-migration
    ```

6.  **Setup anwenden:**
    Starte den Build-Prozess mit `nix-darwin`. Dies installiert Apps, setzt Systemeinstellungen, verlinkt Dotfiles und konfiguriert Git automatisch.
    ```bash
    nix run nix-darwin -- switch --flake ./nix#MacBook-Air-von-Simon
    ```


## 🪟 Windows (WSL 2) Setup

### 1. Windows Apps & Fonts (Host)
Installiere GUI-Apps (VS Code, Spotify, Fonts) via Winget. Öffne **PowerShell als Administrator**:

```powershell
cd ~\dotfiles\scripts
.\install_windows_apps.ps1
```

### 2. WSL Umgebung (Nix)
Installiere Nix innerhalb deiner WSL-Distro (z.B. Ubuntu) für die CLI-Tools (zsh, git, neovim).

1.  **Nix installieren:**

    ```bash
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    ```

2.  **Repo klonen:**

    ```bash
    git clone https://github.com/smn-hrtzsch/dotfiles.git ~/dotfiles
    cd ~/dotfiles
    ```

3.  **Setup anwenden:**

    ```bash
    nix run home-manager/master -- switch --flake ./nix#wsl
    ```

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
