# Gospel Forum Kalender 2027 – V10 Complete

Diese ZIP ist vollständig für GitHub Pages + Supabase.

## Enthalten
- `index.html` – Kalender mit eingebettetem Logo/Bildern
- `config.js` – Supabase-Verbindung
- `supabase-setup.sql` – komplette Datenbank, RLS, Kategorien und Adminrechte
- `supabase-repair.sql` – optionaler Reparatur-SQL für öffentliche Vorschläge
- `.nojekyll` – GitHub Pages
- `README.md`

## GitHub
Alle Dateien direkt in den Root deines Repositorys hochladen:
`kalender.gospel.forum`

Nicht die ZIP selbst hochladen.

## Supabase
`supabase-setup.sql` einmal komplett im SQL Editor ausführen.

## Admin
1. Supabase → Authentication → Users → Add user
2. Danach im SQL Editor:

```sql
insert into public.calendar_admins(user_id)
select id from auth.users
where lower(email)=lower('DEINE-ADMIN-EMAIL@gospel-forum.de')
on conflict (user_id) do nothing;
```

## Wichtig
Nur der Publishable Key befindet sich in `config.js`.
Niemals einen Secret- oder service_role-Key in GitHub eintragen.


## V11 – Safari Fix
- korrekte Supabase Project URL eingetragen
- Formularreferenz wird vor dem asynchronen Request gespeichert
- `form.reset()` statt `ev.currentTarget.reset()` nach `await`
- verhindert Safari-Fehler: `null is not an object (evaluating 'ev.currentTarget.reset')`
