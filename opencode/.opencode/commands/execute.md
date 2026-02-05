---
description: Führt einen existierenden Implementierungsplan aus einer Datei aus.
---
Du bist ein erfahrener Entwickler. Dein Ziel ist es, den Plan aus der Datei "$ARGUMENTS" Schritt für Schritt umzusetzen.

# Workflow

1. **Initialisierung:**
   - Prüfe `git status`. Stelle sicher, dass die Arbeitsumgebung sauber ist.
   - Falls der Git-Status nicht sauber ist: **nicht** commiten oder Änderungen anfassen. Frage mich zuerst, wie wir mit den bestehenden Änderungen umgehen sollen.
   - Lies den Inhalt des Plans aus der Datei "$ARGUMENTS" (nutze `read`).
   - Analysiere den Plan und leite einen passenden Branch-Namen ab (z.B. `feat/<plan-topic>`).
   - Erstelle den Branch und wechsle darauf (`git checkout -b ...`).

2. **Umsetzung:**
   - Arbeite die Schritte des Plans nacheinander ab.
   - Implementiere den Code sauber und modular.
   - Erstelle oder passe Tests an, wo es sinnvoll ist.

3. **Abschluss & Feedback:**
   - Wenn die Implementierung bereit ist, **frage mich nach Feedback**.
   - **Erst nach meinem "OK":**
     - Aktualisiere den Status in der `TO-DO.md` (falls vorhanden) **minimal-invasiv**:
       - Finde ausschließlich die Einträge zu den erledigten Punkten und ändere nur diese.
       - Wenn nicht eindeutig auffindbar, **frage nach**, statt andere Einträge anzufassen.
       - **Keine** Formatierung, Sortierung, Umordnung oder sonstige Änderungen an anderen Einträgen; manuelle Änderungen müssen erhalten bleiben.
     - **Commit:** Generiere eine Conventional Commit Message und führe `git commit` direkt aus.
     - Pushe den Branch.
     - Erstelle eine PR.
     - Merge die PR und lösche den Branch.

# Kontext
Plan Datei: "$ARGUMENTS"
Aktueller Git Status:
!`git status`
