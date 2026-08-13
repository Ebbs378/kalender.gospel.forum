# Gospel Forum Kalender 2027 – V18 Admin Final

## Adminbereich
Der Adminbereich besitzt jetzt genau zwei Bereiche:

### Terminvorschläge
- offene Vorschläge laden
- veröffentlichen
- ablehnen
- Statusänderung erfolgt über geschützte Supabase-RPC-Funktionen

### Konfiguration
- vorhandene Kategorien umbenennen
- Farbe jeder Kategorie ändern
- Kategorie im Formular „Termin vorschlagen“ ein-/ausblenden
- Kategorie aktivieren/deaktivieren
- neue Kategorie mit eigener Farbe anlegen

## Wichtig nach dem Upload
Führe in Supabase einmal die Datei `supabase-admin-v18.sql` im SQL Editor aus.

Die Migration löscht keine bestehenden Termine.

## Admin-Benutzer
Der Benutzer muss:
1. unter Supabase → Authentication → Users existieren
2. in `calendar_admins` eingetragen sein

```sql
insert into public.calendar_admins(user_id)
select id from auth.users
where lower(email)=lower('DEINE-ADMIN-EMAIL@gospel-forum.de')
on conflict (user_id) do nothing;
```

## GitHub
Alle Dateien aus der ZIP in den Root deines GitHub-Repositorys hochladen und die bisherigen Dateien ersetzen.
