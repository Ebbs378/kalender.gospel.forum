# Gospel Forum Kalender 2027 – FINAL V17

## Fertiger Funktionsumfang
- Kalender ist ohne Anmeldung sichtbar
- Jahres-, Monats-, Wochen- und Terminübersicht
- rechte Eventübersicht mit Suche
- Kategorien können einzeln ein-/ausgeschaltet werden
- jede Kategorie hat eine eigene Farbe
- Terminvorschläge sind gestrichelt markiert
- „Termin vorschlagen“-Formular mit:
  - Datum von/bis
  - Uhrzeit von/bis
  - Schnellwahl häufiger Uhrzeiten
  - Kategorie
  - Ort: großer Saal / kleiner Saal / Andere
  - Name, E-Mail und Beschreibung
- kein E-Mail-Aufruf im Footer
- Footer öffnet direkt das Vorschlagsformular
- Admin-Login nur im Admin-Popup
- Admin kann Terminvorschläge veröffentlichen oder ablehnen
- Admin kann Kategorien hinzufügen
- Admin kann Kategorie-Bezeichnungen ändern
- Admin kann Kategorie-Farben ändern

## GitHub Pages
Alle Dateien aus der ZIP direkt in den Root des Repositorys hochladen.

## Supabase
`supabase-setup.sql` im SQL Editor ausführen. Das Script kann auch über eine bestehende Installation laufen.

## Admin einrichten
1. Supabase → Authentication → Users → Benutzer anlegen.
2. Danach im SQL Editor:

```sql
insert into public.calendar_admins(user_id)
select id from auth.users
where lower(email)=lower('DEINE-ADMIN-EMAIL@gospel-forum.de')
on conflict (user_id) do nothing;
```

## Sicherheit
In `config.js` befindet sich ausschließlich der Publishable Key.
Niemals einen Secret- oder service_role-Key in GitHub eintragen.
