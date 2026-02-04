# Plan: Sicherheits- & Kompatibilitäts-Check für Linux & Public Release

## Ziel
Sicherstellen, dass das Repository sicher veröffentlicht werden kann (keine Secrets) und die Linux-Konfiguration vollständig ist (Apps, Shell, Configs).

## Schritte

### 1. Sicherheits-Audit (Secrets Scan)
*   **Aktueller Stand:** Durchsuchen aller Dateien nach verdächtigen Keywords (`password`, `secret`, `token`, `key`, `api_key`, `private_key`, `.env`).
*   **Git Historie:** Überprüfen der Commit-Historie auf versehentlich committete und wieder gelöschte Secrets (`git log -p -S "secret"` etc.).
*   **Ignorierte Dateien:** Prüfen der `.gitignore` und sicherstellen, dass sensible Dateien (z.B. `.zshrc_secrets`, `.ssh/`) wirklich ausgeschlossen sind.
*   **SSH/GPG:** Prüfen, ob private Schlüssel im Repo liegen.

### 2. Kompatibilitäts-Check (Apps & Configs)
*   **GUI Apps:**
    *   Abgleich zwischen `nix/darwin-configuration.nix` (Homebrew Casks) und `nix/home.nix`.
    *   Identifizieren fehlender Linux-Pendants für wichtige Apps (VS Code, Browser, Spotify, etc.) in der `home.nix`.
*   **CLI Tools:** Verifizieren, dass NPM Globals und CLI-Tools korrekt übernommen werden.
*   **Shell Setup:**
    *   Prüfen, wie `zsh` als Standard-Shell auf Linux gesetzt wird (fehlt evtl. im Bootstrap-Skript).
*   **Configs:**
    *   Analyse der `config/.config/ghostty/config` auf macOS-spezifische Tasten/Pfade.
    *   Prüfen der `wezterm` Config auf Linux-Kompatibilität.

### 3. Berichterstattung & Maßnahmen
*   Zusammenfassung der gefundenen Sicherheitsrisiken (falls vorhanden).
*   Auflistung fehlender Apps für Linux.
*   Vorschlag für Anpassungen (z.B. Ergänzen von `pkgs.vscode`, `pkgs.spotify` in `home.nix` für Linux).
*   Bestätigung, ob das Repo "safe to public" ist.

## Risiken
*   **Git History:** Wenn Secrets in der Historie sind, müssen diese via `git filter-repo` oder `BFG` entfernt werden (destruktiv, Rewriting History).
*   **Fehlende Pakete:** Manche macOS Apps (z.B. Raycast) haben kein direktes Linux-Äquivalent. Hier müssen Alternativen besprochen oder Lücken akzeptiert werden.

## Nächster Schritt
Nach Bestätigung dieses Plans werde ich den Audit durchführen.
