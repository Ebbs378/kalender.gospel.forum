# Gospel Forum Kalender 2027 – GitHub Pages + Supabase V5

## Wichtig
Diese Version benötigt **keinen assets-Ordner mehr**. Logo und Bilder sind direkt in `index.html` eingebettet.

## Terminanfragen
- Neue Termine werden als `pending` gespeichert.
- `pending`-Termine erscheinen sofort öffentlich als **gestrichelte Anfrage**.
- Freigegebene Termine (`published`) erscheinen normal.
- Abgelehnte Termine (`rejected`) verschwinden aus der öffentlichen Ansicht.

## Supabase einrichten
1. `supabase-setup.sql` im Supabase SQL Editor ausführen.
2. In `config.js` deine Supabase Project URL und den Publishable/Anon Key eintragen.
3. Niemals `service_role` oder einen Secret Key in GitHub eintragen.

## GitHub Pages
Du brauchst nur:
- `index.html`
- `config.js`
- `supabase-setup.sql`
- `README.md`
- `.nojekyll`

Die Bilder sind bereits in `index.html` enthalten.
