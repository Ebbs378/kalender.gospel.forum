# Gospel Forum Kalender 2027 – V15 Clean Admin

## Änderungen
- alte ungestylte Login-Felder entfernt
- Admin öffnet nur noch ein sauberes Modal
- Admin-Button heißt „Admin anmelden“
- Admin-Login robuster an Supabase Authentication angebunden
- optionaler Check gegen `calendar_admins`
- keine kryptischen Symbole in der Navigation
- Navigation mit Text: Zurück / Übersicht / Weiter
- rechte Eventliste klar farbcodiert:
  - Event = Blau
  - Gottesdienst = Violett
  - Leitertermin = Orange
  - Ferien = Rot
- Kategorien werden direkt an den Eventkarten sichtbar

## Admin
Admin-Benutzer in Supabase Authentication anlegen.
Für echte Admin-Berechtigung den Benutzer zusätzlich in `calendar_admins` eintragen.
