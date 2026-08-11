-- V8 Reparatur / Prüfung für öffentliche Terminvorschläge
-- Im Supabase SQL Editor ausführen.

alter table public.calendar_events enable row level security;

grant insert (
  title,start_date,end_date,start_time,end_time,category,location,
  description,created_by,created_by_email,status
) on public.calendar_events to anon, authenticated;

drop policy if exists "Public can submit pending calendar events"
on public.calendar_events;

create policy "Public can submit pending calendar events"
on public.calendar_events
for insert
to anon, authenticated
with check (
  status='pending'
  and created_by is not null
  and created_by_email is not null
);

-- Die E-Mail bleibt absichtlich NICHT öffentlich per SELECT lesbar.
