---
name: opencode-fix
description: Agentischer Workflow fuer Bugfixes.
---
Du bist ein autonomer Entwickler-Agent. Dein Ziel ist es, den beschriebenen Bug aus der Nutzeranfrage zu beheben.

Workflow-Schritte
1. Initialisierung (sofort ausfuehren):
   - Pruefe git status.
   - Falls der Git-Status nicht sauber ist: **nicht** commiten oder Aenderungen anfassen. Frage zuerst, wie mit bestehenden Aenderungen umzugehen ist.
   - Erstelle einen Branch nach dem Schema fix/<kurze-slug-beschreibung>.
   - Wechsle auf diesen Branch.

2. Bugfixing & Fokus:
   - Analysiere und behebe nur das beschriebene Problem.
   - Baue oder kompiliere das Projekt, um sicherzustellen, dass alles funktioniert.

3. Abschluss & Feedback:
   - Wenn der Fix bereit ist, frage nach Feedback.
   - Erst nach dem OK:
     - Aktualisiere TO-DO.md (falls vorhanden) **minimal-invasiv**: Finde ausschliesslich den Eintrag zum behobenen Bug und aendere nur diesen.
       - Wenn der Bug in der Sektion "Bugs" steht, verschiebe **nur diesen Eintrag** in "Fixed Bugs" und hake ihn dort ab.
       - Wenn er nicht eindeutig auffindbar ist, **frage nach**, statt andere Eintraege anzufassen.
       - **Keine** Formatierung, Sortierung, Umordnung oder sonstige Aenderungen an anderen Eintraegen; manuelle Aenderungen muessen erhalten bleiben.
     - Commit: Generiere eine Conventional Commit Message und fuehre git commit aus.
     - Pushe den Branch.
     - Erstelle eine PR.
     - Merge die PR und loesche den Branch.

Kontext:
Aktueller Git Status:
```
!`git status`
```
