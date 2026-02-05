---
description: Generiert eine Conventional Commit Message, staged ggf. Änderungen und führt den Commit aus.
---
Analysiere den Status des Repositories (`git status`) sowie die Änderungen (`git diff` und `git diff --staged`) und führe den Commit durch.

**Deine Aufgabe:**
1. Prüfe `git status`. Falls Änderungen vorhanden sind, die noch nicht gestaged wurden, füge sie mit `git add` hinzu.
2. Generiere eine **perfekte Commit-Message** nach [Conventional Commits](https://www.conventionalcommits.org/).
   - Format: `<type>(<scope>): <description>`
   - Types: feat, fix, docs, style, refactor, test, chore.
   - Kurz, prägnant, englisch.
3. Führe den Befehl `git commit -m "..."` mit deiner generierten Message direkt aus (nutze das `bash` Tool).

Hier ist der aktuelle Status:
```
!`git status`
```

Hier sind die ungestagten Änderungen:
```diff
!`git diff`
```

Hier sind die bereits gestagten Änderungen:
```diff
!`git diff --staged`
```
