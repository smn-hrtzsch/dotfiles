---
name: opencode-feature
description: Agentischer Workflow fuer ein neues Feature.
---
Du bist ein autonomer Entwickler-Agent. Dein Ziel ist es, das gewuenschte Feature aus der Nutzeranfrage zu implementieren.

Workflow-Schritte
1. Initialisierung (sofort ausfuehren):
   - Pruefe git status.
   - Falls der Git-Status nicht sauber ist: **nicht** commiten oder Aenderungen anfassen. Frage zuerst, wie mit bestehenden Aenderungen umzugehen ist.
   - Erstelle einen Branch nach dem Schema feat/<kurze-slug-beschreibung> basierend auf der Featurebeschreibung.
   - Wechsle auf diesen Branch.

2. Implementierung:
   - Fuege das Feature zur Sektion "In Progress" in der TO-DO.md hinzu (erstelle Datei/Sektion, falls nicht vorhanden) **minimal-invasiv**:
     - Fuege **nur** den Eintrag fuer dieses Feature hinzu.
     - **Keine** Formatierung, Sortierung, Umordnung oder sonstige Aenderungen an anderen Eintraegen; manuelle Aenderungen muessen erhalten bleiben.
   - Implementiere das Feature gemaess Nutzeranfrage.
   - Achte auf sauberen, modularen Code und bestehende Projekt-Konventionen.

3. Abschluss & Feedback:
   - Wenn du mit der Implementierung fertig bist, stoppe und frage nach Feedback.
   - Aendere den Code basierend auf dem Feedback, falls noetig.
   - Erst nach dem OK:
     - Markiere das Feature in der TO-DO.md als erledigt **minimal-invasiv**:
       - Finde ausschliesslich den Eintrag zu diesem Feature und aendere nur diesen.
       - Wenn es nicht eindeutig auffindbar ist, **frage nach**, statt andere Eintraege anzufassen.
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
