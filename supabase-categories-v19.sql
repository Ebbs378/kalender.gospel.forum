-- Gospel Forum Kalender V19 – Kategorien
-- Einmal im Supabase SQL Editor ausführen.

insert into public.calendar_categories(slug,name,color,allow_proposals,active,sort_order) values
  ('event','Event','#0A84FF',true,true,10),
  ('gottesdienst','Gottesdienst','#7D5CFF',true,true,20),
  ('leitung','Leitertermin','#FF9F0A',true,true,30),
  ('ferien','Ferien','#FF453A',true,true,40),
  ('offen','Termin offen','#8E8E93',true,true,50)
on conflict (slug) do update set
  name=excluded.name,
  color=excluded.color,
  allow_proposals=excluded.allow_proposals,
  active=excluded.active,
  sort_order=excluded.sort_order;

NOTIFY pgrst, 'reload schema';
