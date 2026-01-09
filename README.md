# Mein macOS Dotfiles Setup (Nix Edition)

Dieses Repository enthält meine persönlichen Konfigurationen (Dotfiles) und ein vollständig reproduzierbares System-Setup basierend auf **Nix** und **nix-darwin**.

## Vision

Ziel ist es, das komplette System – von Systemeinstellungen über installierte Programme bis hin zu Dotfiles – deklarativ und reproduzierbar zu verwalten. Ein einziger Befehl soll genügen, um eine neue Maschine exakt wie die aktuelle einzurichten.

## Voraussetzungen

* Ein frisch installiertes macOS.
* Internetverbindung.
* **Nix Package Manager**:

  Installation (Determinate Systems Installer empfohlen):
  ```bash
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh
  ```

## Installationsanleitung

1. **Dieses Repository klonen:**
    Klone das Repository in dein Home-Verzeichnis:

    ```bash
    git clone https://github.com/smn-hrtzsch/dotfiles.git ~/dotfiles
    ```

2. **Setup anwenden:**
    Wechsle in das `dotfiles` Verzeichnis und starte den Build-Prozess mit `nix`. Dies installiert alle Pakete (inkl. Homebrew Casks), setzt Systemeinstellungen und verlinkt Dotfiles.

    ```bash
    cd ~/dotfiles
    nix run nix-darwin -- switch --flake ./nix#MacBook-Air-von-Simon
    ```

    *Hinweis:* Beim ersten Ausführen wird `nix-darwin` installiert und `darwin-rebuild` verfügbar gemacht. Zukünftige Updates können einfach mit `darwin-rebuild switch --flake ./nix` durchgeführt werden.

3. **Neustart:**
    Ein Neustart oder Neuanmelden ist empfohlen, damit alle Änderungen (z.B. Zsh als Standard-Shell, Umgebungsvariablen) wirksam werden.

## Verwaltung

Das System wird nun deklarativ über Nix Flakes gesteuert.

* **Hauptkonfiguration:** `nix/flake.nix` – Der Einstiegspunkt.
* **System (macOS):** `nix/darwin-configuration.nix`
    * Verwaltet macOS Defaults (Dock, Finder, Keyboard...).
    * Installiert System-Pakete und Homebrew Casks (Apps).
* **User (Home Manager):** `nix/home.nix`
    * Verwaltet User-Tools (CLI-Tools wie `fzf`, `bat`, `eza`).
    * Konfiguriert Programme (`git`, `zsh`).
    * Symlinkt Dotfiles aus dem Repo an die richtigen Stellen (via `home.file`).

### Änderungen vornehmen

1. Bearbeite die entsprechenden `.nix` Dateien in `~/dotfiles/nix/`.
2. Wende die Änderungen an:
    ```bash
    darwin-rebuild switch --flake ~/dotfiles/nix
    ```

## Ordnerstruktur

* `nix/`: Enthält die gesamte Nix-Logik (`flake.nix`, `darwin-configuration.nix`, `home.nix`).
* `zsh/`, `config/`: Die eigentlichen Konfigurationsdateien, auf die von Nix verlinkt wird.
* `scripts/`: Hilfsskripte (falls noch nötig).

---
Viel Spaß mit deinem reproduzierbaren Mac!
