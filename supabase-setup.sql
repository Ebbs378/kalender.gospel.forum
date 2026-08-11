-- Gospel Forum Kalender – Supabase Setup
-- Im Supabase Dashboard unter SQL Editor ausführen.

create extension if not exists pgcrypto;

create table if not exists public.calendar_events (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(title) between 2 and 160),
  start_date date not null,
  end_date date,
  start_time time,
  end_time time,
  category text not null default 'event'
    check (category in ('event','gottesdienst','leitung','ferien')),
  location text,
  description text,
  created_by text not null,
  created_by_email text not null,
  status text not null default 'pending'
    check (status in ('pending','published','rejected')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint calendar_events_date_order check (end_date is null or end_date >= start_date)
);

alter table public.calendar_events enable row level security;

-- Besucher dürfen nur veröffentlichte Termine lesen.
drop policy if exists "Public can read published calendar events" on public.calendar_events;
create policy "Public can read published calendar events"
on public.calendar_events
for select
to anon, authenticated
using (status = 'published');

-- Besucher dürfen neue Termine ausschließlich als "pending" einreichen.
drop policy if exists "Public can submit pending calendar events" on public.calendar_events;
create policy "Public can submit pending calendar events"
on public.calendar_events
for insert
to anon, authenticated
with check (
  status = 'pending'
  and created_by is not null
  and created_by_email is not null
);

-- Kein öffentliches Update/Delete-Policy:
-- Änderungen/Freigaben erfolgen im Supabase Table Editor oder später über einen geschützten Adminbereich.

create or replace function public.set_calendar_event_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_calendar_event_updated_at on public.calendar_events;
create trigger set_calendar_event_updated_at
before update on public.calendar_events
for each row execute function public.set_calendar_event_updated_at();

-- Beispiel:
-- Nach einer Prüfung im Table Editor den Status von "pending" auf "published" setzen.
