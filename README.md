# Gospel Forum Kalender 2027 – V20 Mitarbeiter Final

## Neu
- Mitarbeiter-Login vor der Kalenderansicht mit Gospel-Forum-Logo
- Kalender erst nach erfolgreicher Supabase-Anmeldung sichtbar
- Tag / Woche / Monat / Jahr auswählbar
- keine „Monat öffnen“-Beschriftungen mehr
- Hell/Dunkel über Mond-/Sonnen-Icon
- oben kein „Baden-Württemberg“
- Adminbereich nur noch Genehmigen / Ablehnen
- Konflikthinweis, wenn im gleichen Zeitraum schon ein Termin oder Terminvorschlag liegt

## Supabase
1. `supabase-admin-v20.sql` ausführen.
2. `supabase-mitarbeiter-v20.sql` ausführen.
3. Mitarbeiter unter Authentication → Users anlegen.
4. Admins zusätzlich in `calendar_admins` eintragen.
