# 📋 Plan: Sichere WSL-Testumgebung einrichten

Ich möchte mein neues Nix-basiertes Dotfiles-Setup testen, ohne meine aktuelle, funktionierende WSL-Installation zu überschreiben.

## Ziele
1.  Analysiere den Status aller WSL-Installationen.
2.  Identifiziere meine "Haupt"-Instanz (die mit Zsh/P10k/Aliassen).
3.  Installiere eine neue, saubere Ubuntu-Instanz parallel dazu (z.B. "Ubuntu-Test").
4.  Bereite diese neue Instanz vor, damit ich mein Nix-Setup dort testen kann.

## Schritt-für-Schritt Anleitung

### 1. Status prüfen (PowerShell)
Zeige mir alle installierten Distributionen an:
```powershell
wsl --list --verbose
```

### 2. Haupt-Instanz identifizieren (PowerShell)
Prüfe in der Standard-Distro (markiert mit `*`), ob sie eingerichtet ist:
```powershell
wsl --exec zsh -c "ls -la ~/.p10k.zsh"
```
*(Wenn die Datei existiert, ist das meine produktive Umgebung -> NICHT LÖSCHEN!)*

### 3. Neue Test-Distro installieren (PowerShell)
Installiere eine frische Ubuntu-Version parallel. Wir nutzen den Import-Befehl, um sie sauber zu benennen und Konflikte zu vermeiden.

```powershell
# 1. Image herunterladen (Ubuntu 24.04 Noble Numbat)
Invoke-WebRequest -Uri https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64-wsl.rootfs.tar.gz -OutFile ubuntu-test.tar.gz

# 2. Neuen Ordner für die VM erstellen
mkdir C:\WSL\Ubuntu-Test

# 3. Importieren als "Ubuntu-Test"
wsl --import Ubuntu-Test C:\WSL\Ubuntu-Test ubuntu-test.tar.gz
```

### 4. Test-Distro starten & vorbereiten
Starte die neue Distro:
```powershell
wsl -d Ubuntu-Test
```

**Innerhalb der neuen Distro (Ubuntu-Test):**

1.  **User anlegen:** (Da der Import standardmäßig Root ist)
    ```bash
    # User 'simon' erstellen und zur sudo-Gruppe hinzufügen
    useradd -m -s /bin/bash simon
    passwd simon
    usermod -aG sudo simon
    
    # Zu User wechseln
    su - simon
    ```

2.  **Basics installieren:**
    ```bash
    sudo apt update && sudo apt install -y curl git xz-utils
    ```

3.  **Nix-Setup starten:**
    Folge nun der Anleitung aus dem Repo:
    ```bash
    # Nix installieren
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

    # Repo klonen & anwenden
    git clone https://github.com/smn-hrtzsch/dotfiles.git ~/dotfiles
    cd ~/dotfiles
    git checkout chore/nix-migration
    
    # Nix Config anwenden
    nix run home-manager/master -- switch --flake ./nix#wsl
    ```

4.  **Abschluss:**
    *   `chsh -s $(which zsh)` ausführen, um Zsh als Default zu setzen.
    *   Terminal neu starten.
