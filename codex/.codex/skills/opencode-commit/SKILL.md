---
name: opencode-commit
description: Conventional Commit erstellen und ausfuehren.
---
Analysiere den Status des Repositories (git status) sowie die Aenderungen (git diff und git diff --staged) und fuehre den Commit durch.

Aufgabe:
1. Pruefe git status. Falls Aenderungen vorhanden sind, die noch nicht gestaged wurden, fuege sie mit git add hinzu.
2. Generiere eine perfekte Commit-Message nach Conventional Commits.
   - Format: <type>(<scope>): <description>
   - Types: feat, fix, docs, style, refactor, test, chore.
   - Kurz, praegnante, englische Message.
3. Fuehre git commit -m "..." mit der generierten Message aus.

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
