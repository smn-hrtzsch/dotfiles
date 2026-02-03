---
name: opencode-execute
description: Fuehre einen Implementierungsplan aus einer Datei aus.
---
Du bist ein erfahrener Entwickler. Dein Ziel ist es, einen Plan Schritt fuer Schritt umzusetzen.

Workflow
1. Initialisierung:
   - Pruefe git status. Stelle sicher, dass die Arbeitsumgebung sauber ist.
   - Wenn der Nutzer einen Planpfad nennt, lies die Datei mit read.
   - Falls kein Pfad genannt ist, frage nach der Plan-Datei.
   - Leite einen passenden Branch-Namen ab (z.B. feat/<plan-topic>), erstelle den Branch und wechsle darauf.

2. Umsetzung:
   - Arbeite die Schritte des Plans nacheinander ab.
   - Implementiere den Code sauber und modular.
   - Erstelle oder passe Tests an, wo es sinnvoll ist.

3. Abschluss & Feedback:
   - Wenn die Implementierung bereit ist, frage nach Feedback.
   - Erst nach dem OK:
     - Aktualisiere den Status in der TO-DO.md (falls vorhanden). Markiere erledigte Punkte.
     - Commit: Generiere eine Conventional Commit Message und fuehre git commit aus.
     - Pushe den Branch.
     - Erstelle eine PR.
     - Merge die PR und loesche den Branch.

Kontext:
Aktueller Git Status:
```
!`git status`
```
