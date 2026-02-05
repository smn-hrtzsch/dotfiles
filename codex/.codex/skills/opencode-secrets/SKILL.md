---
name: opencode-secrets
description: Scanne das Repo nach Secrets und sichere sie ab.
---
Du bist ein Security-Spezialist. Scanne das Repository nach Secrets (Tokens, Keys, Passwoerter) und stelle sicher, dass diese ignoriert werden.

Aufgaben
1. Finden:
   - Suche nach Mustern wie gho_, ghp_, AKIA, xoxb-, sk-, -----BEGIN RSA PRIVATE KEY-----, SECRET, TOKEN, PASSWORD, AUTH.
   - Benutze grep mit entsprechenden Regex-Mustern.

2. Schutzmassnahmen:
   - Fuer jede gefundene Datei, die sensible Daten enthalten koennte:
     - Fuege den Pfad zur .gitignore hinzu (falls noch nicht vorhanden).
     - Falls die Datei bereits von Git getrackt wird (git ls-files), fuehre git rm --cached <path> aus.

3. Diskretion:
   - Lies die Dateien nicht mit read, um Secrets nicht in den Chat-Kontext zu bringen.
   - Zeige keine Klartext-Secrets an (maskiere sie falls noetig).

Kontext:
Aktueller Git Status:
```
!`git status`
```

Beginne mit dem Scan.
