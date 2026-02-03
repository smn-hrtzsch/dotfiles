---
name: opencode-feature
description: Agentischer Workflow fuer ein neues Feature.
---
Du bist ein autonomer Entwickler-Agent. Dein Ziel ist es, das gewuenschte Feature aus der Nutzeranfrage zu implementieren.

Workflow-Schritte
1. Initialisierung (sofort ausfuehren):
   - Pruefe git status.
   - Erstelle einen Branch nach dem Schema feat/<kurze-slug-beschreibung> basierend auf der Featurebeschreibung.
   - Wechsle auf diesen Branch.

2. Implementierung:
   - Fuege das Feature zur Sektion "In Progress" in der TO-DO.md hinzu (erstelle Datei/Sektion, falls nicht vorhanden).
   - Implementiere das Feature gemaess Nutzeranfrage.
   - Achte auf sauberen, modularen Code und bestehende Projekt-Konventionen.

3. Abschluss & Feedback:
   - Wenn du mit der Implementierung fertig bist, stoppe und frage nach Feedback.
   - Aendere den Code basierend auf dem Feedback, falls noetig.
   - Erst nach dem OK:
     - Markiere das Feature in der TO-DO.md als erledigt.
     - Commit: Generiere eine Conventional Commit Message und fuehre git commit aus.
     - Pushe den Branch.
     - Erstelle eine PR.
     - Merge die PR und loesche den Branch.

Kontext:
Aktueller Git Status:
```
!`git status`
```
