---
name: opencode-ship
description: Alle Aenderungen committen (Conventional Commit), pusht den Branch, erstellt eine PR und mergt diese.
---
Fuehre den gesamten Release-Workflow fuer deine Aenderungen durch: Committen, Pushen, PR erstellen und in main mergen.

Aufgabe:
1. Aenderungen stagen & committen:
   - Pruefe git status. Falls ungestagte Aenderungen vorhanden sind, fuege sie mit git add hinzu.
   - Generiere eine perfekte Commit-Message nach Conventional Commits basierend auf den ungestagten (git diff) und gestagten (git diff --staged) Aenderungen.
     - Format: <type>(<scope>): <description>
     - Types: feat, fix, docs, style, refactor, test, chore.
     - Verwende eine kurze, praegnante englische Beschreibung im Imperativ (z. B. "add ship command" oder "fix crash on startup").
   - Fuehre den Commit aus: git commit -m "...".
2. Branch pushen:
   - Ermittle den aktuellen Branch-Namen. Falls du auf main oder master bist, frage zuerst nach, da ein direkter Merge per PR auf dieselbe Branch nicht moeglich ist.
   - Pushe den aktuellen Branch zu origin. Falls der Remote-Branch noch nicht existiert, verwende git push -u origin <branch-name>.
3. PR erstellen & mergen:
   - Erstelle einen Pull Request nach main mit der GitHub CLI (gh pr create --fill oder gib einen passenden Titel und Beschreibung an).
   - Merge den Pull Request und loesche den lokalen sowie Remote-Branch mit gh pr merge --merge --delete-branch.

Kontext:
```
!`git status`
```

Ungestagte Aenderungen:
```diff
!`git diff`
```

Gestagte Aenderungen:
```diff
!`git diff --staged`
```
