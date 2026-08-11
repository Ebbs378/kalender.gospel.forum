# Gospel Forum Kalender 2027 – GitHub Pages + Supabase

## Neu in V4
- „+ Termin eintragen“-Fenster
- Datum von / bis
- Uhrzeit von / bis
- Kategorie
- Ort
- Beschreibung
- Angelegt von + E-Mail
- Speicherung in Supabase
- sichere Freigabe: neue Termine starten als `pending`
- veröffentlichte Supabase-Termine werden beim Laden automatisch in den Kalender übernommen

## 1. Supabase einrichten
1. Neues Supabase-Projekt anlegen.
2. **SQL Editor** öffnen.
3. Inhalt aus `supabase-setup.sql` einfügen und ausführen.
4. In **Project Settings → API** die Project URL und den **Publishable Key** (oder Legacy Anon Key) kopieren.
5. `config.js` öffnen und beide Platzhalter ersetzen.

**Niemals einen `service_role`/Secret Key in GitHub oder in `config.js` eintragen.**

## 2. GitHub Pages
Alle Dateien und den `assets`-Ordner in dein Repository hochladen.

Dann:
Settings → Pages → Deploy from a branch → `main` → `/ (root)`.

## 3. Termine freigeben
Neue Einträge werden mit `status = pending` gespeichert.
Im Supabase Dashboard:
Table Editor → `calendar_events` → gewünschten Eintrag öffnen → `status` auf `published` setzen.

Danach erscheint der Termin auf der öffentlichen Kalenderseite.

## Dateien
- `index.html` – Kalender
- `config.js` – Supabase Project URL + Publishable/Anon Key
- `supabase-setup.sql` – Tabelle und RLS-Regeln
- `assets/` – Logo und Bilder
