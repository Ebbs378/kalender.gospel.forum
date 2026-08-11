# Gospel Forum Kalender 2027 – V7 Admin + Supabase

## Enthalten
- Terminvorschläge statt „Freigabe“
- Terminvorschläge sind öffentlich gestrichelt markiert
- Kategorien im Formular: Event, Gottesdienst, Leitertermin
- Admins können weitere Kategorien hinzufügen
- Orte:
  - Gospel Forum Stuttgart - großer Saal
  - Gospel Forum Stuttgart - kleiner Saal
  - Andere → eigenes Textfeld
- Admin-Login direkt im Kalender
- Adminbereich für offene Terminvorschläge:
  - Veröffentlichen
  - Ablehnen
- Fußzeile ohne „Alle Angaben ohne Gewähr“
- Supabase-Verbindung ist in `config.js` bereits eingetragen

## Wichtig: Supabase V7 Migration ausführen
Führe den kompletten Inhalt von `supabase-setup.sql` im Supabase SQL Editor aus.

## Admin-Konto einrichten
1. Supabase → Authentication → Users.
2. `Add user` wählen und Admin-E-Mail + Passwort anlegen.
3. Danach im SQL Editor ausführen:

```sql
insert into public.calendar_admins(user_id)
select id from auth.users
where lower(email)=lower('DEINE-ADMIN-EMAIL@gospel-forum.de')
on conflict (user_id) do nothing;
```

Danach kann sich dieses Konto über den Admin-Button im Kalender anmelden.

## GitHub
Die Dateien aus dieser ZIP ersetzen die bisherigen Dateien im Repository.
GitHub Pages übernimmt die Änderung nach dem Commit automatisch.


## V8 Fix
Der öffentliche INSERT verwendet jetzt `Prefer: return=minimal`.
Dadurch muss Supabase nach dem Speichern nicht den vollständigen Datensatz inklusive
der geschützten `created_by_email`-Spalte zurückgeben.

Falls du V7 bereits eingerichtet hast, kannst du zusätzlich `supabase-repair-v8.sql`
im SQL Editor ausführen.
