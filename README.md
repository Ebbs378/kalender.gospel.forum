# Gospel Forum Kalender 2027 – V19 Kategorien Final

## Kategorien
Die fünf festen System-Kategorien sind:
- Event
- Gottesdienst
- Leitertermin
- Ferien
- Termin offen

Alle fünf Kategorien sind im Formular „Termin vorschlagen“ auswählbar.

## Terminvorschläge
„Terminvorschlag“ ist **keine normale Kategorie**, sondern ein Status/Filter.
Dadurch kann ein Vorschlag z. B. gleichzeitig:
- Kategorie = Gottesdienst
- Status = Terminvorschlag

sein.

Im Kalender gibt es deshalb zusätzlich den Filter **Terminvorschläge**.
Dieser zeigt alle offenen Vorschläge unabhängig von ihrer eigentlichen Kategorie.

## Supabase
Einmal `supabase-categories-v19.sql` im SQL Editor ausführen.
Danach sind die fünf Kategorien sicher in `calendar_categories` vorhanden.
