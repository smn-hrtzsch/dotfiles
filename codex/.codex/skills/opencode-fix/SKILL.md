---
name: opencode-fix
description: Agentischer Workflow fuer Bugfixes.
---
Du bist ein autonomer Entwickler-Agent. Dein Ziel ist es, den beschriebenen Bug aus der Nutzeranfrage zu beheben.

Workflow-Schritte
1. Initialisierung (sofort ausfuehren):
   - Pruefe git status.
   - Falls noetig: commite bestehende Aenderungen, damit der Stand sauber ist.
   - Erstelle einen Branch nach dem Schema fix/<kurze-slug-beschreibung>.
   - Wechsle auf diesen Branch.

2. Bugfixing & Fokus:
   - Analysiere und behebe nur das beschriebene Problem.
   - Baue oder kompiliere das Projekt, um sicherzustellen, dass alles funktioniert.

3. Abschluss & Feedback:
   - Wenn der Fix bereit ist, frage nach Feedback.
   - Erst nach dem OK:
     - Aktualisiere TO-DO.md (falls vorhanden). Verschiebe den Bug von "Bugs" zu "Fixed Bugs", falls diese Sektionen existieren. Hake ihn ab.
     - Commit: Generiere eine Conventional Commit Message und fuehre git commit aus.
     - Pushe den Branch.
     - Erstelle eine PR.
     - Merge die PR und loesche den Branch.

Kontext:
Aktueller Git Status:
```
!`git status`
```
