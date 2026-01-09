# Mein macOS Dotfiles Setup

Dieses Repository enthält meine persönlichen Konfigurationen (Dotfiles) und ein Setup-Skript, um einen neuen Mac (oder ein frisches macOS) schnell und einfach einzurichten.

## Vision

Ziel ist es, alle wichtigen Einstellungen, Aliase, Funktionen und installierten Programme über dieses Repository zu verwalten und die Einrichtung eines neuen Systems zu automatisieren.

## Voraussetzungen

* Ein frisch installiertes macOS.
* Internetverbindung.
* Xcode Command Line Tools (enthalten Git).

## Installationsanleitung

1. **Xcode Command Line Tools installieren:**
    Öffne das Terminal (`Programme` > `Dienstprogramme` > `Terminal`) und führe folgenden Befehl aus. Folge den Anweisungen im erscheinenden Fenster:

    ```bash
    xcode-select --install
    ```

2. **Dieses Repository klonen:**
    Klone das Repository in dein Home-Verzeichnis:

    ```bash
    git clone https://github.com/smn-hrtzsch/dotfiles.git ~/dotfiles
    ```

3. **Setup-Skript ausführen:**
    Wechsle in das geklonte Verzeichnis und starte das Setup-Skript. Es kümmert sich um die Installation von Homebrew, die Einrichtung der Symlinks mittels `stow` und die Installation aller im `Brewfile` definierten Programme und Fonts.

    ```bash
    cd ~/dotfiles
    ./setup.sh
    ```

    *Hinweis:* Das Skript benötigt möglicherweise dein Benutzerpasswort für die Installation von Homebrew oder anderen Komponenten. Die Installation der Programme via Homebrew kann je nach Internetverbindung einige Zeit dauern.

4. **Neustart / Neuanmeldung:**
    Nachdem das Skript erfolgreich durchgelaufen ist, starte dein Terminal neu oder logge dich aus und wieder ein, damit alle Shell-Einstellungen und Pfade korrekt geladen werden.

## Verwaltung

* **Dotfiles:** Konfigurationsdateien werden mit `stow` verwaltet.
    * `zsh/`: Enthält die `.zshrc` und den Ordner `config/` mit modularen Einstellungen (`aliases.zsh`, `exports.zsh`, `functions.zsh`).
    * `macos/`: Enthält Skripte für macOS-Systemeinstellungen (z.B. Dock, Finder).
    * Andere Ordner (`git/`, `config/`) enthalten spezifische Configs.
* **Programme:** Verwaltet über Homebrew und `Brewfile`.
    * Neue Programme hinzufügen: `Brewfile` bearbeiten und `./setup.sh` (oder `brew bundle`) ausführen.
* **macOS Einstellungen:** Das Skript `macos/settings.sh` setzt sinnvolle Defaults (schnelles Keyboard, aufgeräumtes Dock). Es kann via `./setup.sh` oder direkt ausgeführt werden.

## Enthaltene Programme (Auszug aus Brewfile)

* Brave Browser
* Warp Terminal
* Notion
* Thunderbird
* WhatsApp
* Spotify
* VS Code
* Android Studio
* Google Drive
* Maccy
* Rectangle
* MesloLGS Nerd Font
* ... (und Kommandozeilen-Tools wie `git`, `stow`, `pyenv`)

---
Viel Spaß beim Einrichten!
