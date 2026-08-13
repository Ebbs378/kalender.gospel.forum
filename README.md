# Gospel Forum Kalender 2027 – V12 Intern

## Neu
- komplette Kalenderansicht erst nach Supabase-Login
- interne Nutzung statt Besucheransicht
- Kategorie-Filter:
  - Events
  - Gottesdienste
  - Leitertermine
  - Ferien
- eigene Farben pro Kategorie
- einfacheres Terminformular
- große Datums- und Uhrzeitfelder
- Schnellwahl für häufige Uhrzeiten
- Footer mit „Termin vorschlagen“
- kein E-Mail-Aufruf mehr

## Wichtig
Die bestehende Supabase-Verbindung bleibt erhalten.

## Interne Benutzer anlegen
Supabase → Authentication → Users → Add user

Jeder angelegte Benutzer kann sich am internen Login anmelden.

## Admin
Die Admin-Funktionen aus der vorherigen Version bleiben bestehen.
Admin-Zuordnung weiterhin über `calendar_admins`.
