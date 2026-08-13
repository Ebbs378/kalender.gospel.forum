-- Gospel Forum Kalender V10 – Supabase Setup
-- Im Supabase SQL Editor vollständig ausführen.

create extension if not exists pgcrypto;

create table if not exists public.calendar_events (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  start_date date not null,
  end_date date,
  start_time time,
  end_time time,
  category text not null default 'event',
  location text,
  description text,
  created_by text not null,
  created_by_email text not null,
  status text not null default 'pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.calendar_events drop constraint if exists calendar_events_status_check;
alter table public.calendar_events add constraint calendar_events_status_check
  check (status in ('pending','published','rejected'));

alter table public.calendar_events drop constraint if exists calendar_events_date_order;
alter table public.calendar_events add constraint calendar_events_date_order
  check (end_date is null or end_date >= start_date);

alter table public.calendar_events drop constraint if exists calendar_events_category_check;

create table if not exists public.calendar_categories (
  slug text primary key,
  name text not null unique,
  color text not null default '#0A84FF',
  allow_proposals boolean not null default true,
  active boolean not null default true,
  sort_order integer not null default 100,
  created_at timestamptz not null default now()
);

alter table public.calendar_categories
  add column if not exists color text not null default '#0A84FF';

insert into public.calendar_categories(slug,name,color,allow_proposals,active,sort_order) values
  ('event','Event','#0A84FF',true,true,10),
  ('gottesdienst','Gottesdienst','#7D5CFF',true,true,20),
  ('leitung','Leitertermin','#FF9F0A',true,true,30),
  ('ferien','Ferien','#FF453A',false,true,40)
on conflict (slug) do update set
  name=excluded.name,
  color=excluded.color,
  allow_proposals=excluded.allow_proposals,
  active=excluded.active,
  sort_order=excluded.sort_order;

create table if not exists public.calendar_admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.calendar_events enable row level security;
alter table public.calendar_categories enable row level security;
alter table public.calendar_admins enable row level security;

create or replace function public.is_calendar_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists(
    select 1
    from public.calendar_admins a
    where a.user_id = auth.uid()
  );
$$;

drop policy if exists "Public can read calendar requests" on public.calendar_events;
drop policy if exists "Public can submit pending calendar events" on public.calendar_events;
drop policy if exists "Admins can update calendar events" on public.calendar_events;
drop policy if exists "Admins can delete calendar events" on public.calendar_events;

create policy "Public can read calendar requests"
on public.calendar_events
for select
to anon, authenticated
using (status in ('published','pending') or public.is_calendar_admin());

create policy "Public can submit pending calendar events"
on public.calendar_events
for insert
to anon, authenticated
with check (
  status = 'pending'
  and created_by is not null
  and created_by_email is not null
);

create policy "Admins can update calendar events"
on public.calendar_events
for update
to authenticated
using (public.is_calendar_admin())
with check (public.is_calendar_admin());

create policy "Admins can delete calendar events"
on public.calendar_events
for delete
to authenticated
using (public.is_calendar_admin());

drop policy if exists "Public can read active categories" on public.calendar_categories;
drop policy if exists "Admins can insert categories" on public.calendar_categories;
drop policy if exists "Admins can update categories" on public.calendar_categories;
drop policy if exists "Admins can delete categories" on public.calendar_categories;

create policy "Public can read active categories"
on public.calendar_categories
for select
to anon, authenticated
using (active = true or public.is_calendar_admin());

create policy "Admins can insert categories"
on public.calendar_categories
for insert
to authenticated
with check (public.is_calendar_admin());

create policy "Admins can update categories"
on public.calendar_categories
for update
to authenticated
using (public.is_calendar_admin())
with check (public.is_calendar_admin());

create policy "Admins can delete categories"
on public.calendar_categories
for delete
to authenticated
using (public.is_calendar_admin());

drop policy if exists "Admins can read own admin row" on public.calendar_admins;
create policy "Admins can read own admin row"
on public.calendar_admins
for select
to authenticated
using (user_id = auth.uid());

revoke all on table public.calendar_events from anon, authenticated;

grant select (
  id,title,start_date,end_date,start_time,end_time,category,location,
  description,created_by,status,created_at,updated_at
) on public.calendar_events to anon, authenticated;

grant insert (
  title,start_date,end_date,start_time,end_time,category,location,
  description,created_by,created_by_email,status
) on public.calendar_events to anon, authenticated;

grant update, delete on public.calendar_events to authenticated;

grant select on public.calendar_categories to anon, authenticated;
grant insert, update, delete on public.calendar_categories to authenticated;
grant select on public.calendar_admins to authenticated;

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

-- ADMIN EINRICHTEN:
-- 1. Supabase -> Authentication -> Users -> Add user
-- 2. Danach die E-Mail unten ersetzen und ausführen:
--
-- insert into public.calendar_admins(user_id)
-- select id from auth.users
-- where lower(email)=lower('DEINE-ADMIN-EMAIL@gospel-forum.de')
-- on conflict (user_id) do nothing;


-- ===== V18 ADMIN MIGRATION =====
-- Gospel Forum Kalender V18 – Admin-Funktionen
-- Im Supabase SQL Editor vollständig ausführen.
-- Bestehende Termine/Kategorien werden NICHT gelöscht.

create extension if not exists pgcrypto;

create table if not exists public.calendar_admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.calendar_categories (
  slug text primary key,
  name text not null unique,
  color text not null default '#0A84FF',
  allow_proposals boolean not null default true,
  active boolean not null default true,
  sort_order integer not null default 100,
  created_at timestamptz not null default now()
);

alter table public.calendar_categories
  add column if not exists color text not null default '#0A84FF';

alter table public.calendar_categories
  add column if not exists allow_proposals boolean not null default true;

alter table public.calendar_categories
  add column if not exists active boolean not null default true;

alter table public.calendar_categories
  add column if not exists sort_order integer not null default 100;

alter table public.calendar_events
  drop constraint if exists calendar_events_category_check;

create or replace function public.is_calendar_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists(
    select 1
    from public.calendar_admins
    where user_id = auth.uid()
  );
$$;

revoke all on function public.is_calendar_admin() from public;
grant execute on function public.is_calendar_admin() to authenticated;

-- Admin: offene Vorschläge lesen.
create or replace function public.admin_list_pending_events()
returns table(
  id uuid,
  title text,
  start_date date,
  end_date date,
  start_time time,
  end_time time,
  location text,
  category text,
  created_by text,
  description text,
  status text
)
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_calendar_admin() then
    raise exception 'Not authorized';
  end if;

  return query
  select e.id,e.title,e.start_date,e.end_date,e.start_time,e.end_time,
         e.location,e.category,e.created_by,e.description,e.status
  from public.calendar_events e
  where e.status='pending'
  order by e.start_date asc, e.start_time asc nulls last;
end;
$$;

-- Admin: Vorschlag veröffentlichen/ablehnen.
create or replace function public.admin_set_event_status(event_id uuid,new_status text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_calendar_admin() then
    raise exception 'Not authorized';
  end if;
  if new_status not in ('published','rejected','pending') then
    raise exception 'Invalid status';
  end if;

  update public.calendar_events
  set status=new_status, updated_at=now()
  where id=event_id;

  if not found then
    raise exception 'Event not found';
  end if;
end;
$$;

-- Admin: Kategorien inkl. deaktivierter Kategorien lesen.
create or replace function public.admin_list_categories()
returns table(
  slug text,
  name text,
  color text,
  allow_proposals boolean,
  active boolean,
  sort_order integer
)
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_calendar_admin() then
    raise exception 'Not authorized';
  end if;

  return query
  select c.slug,c.name,c.color,c.allow_proposals,c.active,c.sort_order
  from public.calendar_categories c
  order by c.sort_order asc,c.name asc;
end;
$$;

-- Admin: vorhandene Kategorie ändern.
create or replace function public.admin_save_category(
  category_slug text,
  category_name text,
  category_color text,
  proposal_enabled boolean
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_calendar_admin() then
    raise exception 'Not authorized';
  end if;

  update public.calendar_categories
  set name=trim(category_name),
      color=category_color,
      allow_proposals=proposal_enabled
  where slug=category_slug;

  if not found then
    raise exception 'Category not found';
  end if;
end;
$$;

-- Admin: neue Kategorie anlegen.
create or replace function public.admin_create_category(
  category_slug text,
  category_name text,
  category_color text,
  proposal_enabled boolean
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_calendar_admin() then
    raise exception 'Not authorized';
  end if;

  insert into public.calendar_categories(slug,name,color,allow_proposals,active,sort_order)
  values(
    lower(trim(category_slug)),
    trim(category_name),
    category_color,
    proposal_enabled,
    true,
    coalesce((select max(sort_order)+10 from public.calendar_categories),100)
  );
end;
$$;

-- Admin: Kategorie aktivieren/deaktivieren.
create or replace function public.admin_set_category_active(
  category_slug text,
  new_active boolean
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_calendar_admin() then
    raise exception 'Not authorized';
  end if;

  update public.calendar_categories
  set active=new_active
  where slug=category_slug;

  if not found then
    raise exception 'Category not found';
  end if;
end;
$$;

revoke all on function public.admin_list_pending_events() from public;
revoke all on function public.admin_set_event_status(uuid,text) from public;
revoke all on function public.admin_list_categories() from public;
revoke all on function public.admin_save_category(text,text,text,boolean) from public;
revoke all on function public.admin_create_category(text,text,text,boolean) from public;
revoke all on function public.admin_set_category_active(text,boolean) from public;

grant execute on function public.admin_list_pending_events() to authenticated;
grant execute on function public.admin_set_event_status(uuid,text) to authenticated;
grant execute on function public.admin_list_categories() to authenticated;
grant execute on function public.admin_save_category(text,text,text,boolean) to authenticated;
grant execute on function public.admin_create_category(text,text,text,boolean) to authenticated;
grant execute on function public.admin_set_category_active(text,boolean) to authenticated;

-- Admin-Tabelle nur eigene Zeile lesen, damit Login-Check funktioniert.
alter table public.calendar_admins enable row level security;
drop policy if exists "Admins can read own admin row" on public.calendar_admins;
create policy "Admins can read own admin row"
on public.calendar_admins
for select
to authenticated
using (user_id=auth.uid());
grant select on public.calendar_admins to authenticated;

-- Kategorien öffentlich nur aktiv lesen.
alter table public.calendar_categories enable row level security;
drop policy if exists "Public can read active categories" on public.calendar_categories;
create policy "Public can read active categories"
on public.calendar_categories
for select
to anon, authenticated
using (active=true);
grant select on public.calendar_categories to anon,authenticated;

-- WICHTIG:
-- Admin-Benutzer zuerst unter Authentication -> Users anlegen.
-- Danach einmal:
--
-- insert into public.calendar_admins(user_id)
-- select id from auth.users
-- where lower(email)=lower('DEINE-ADMIN-EMAIL@gospel-forum.de')
-- on conflict (user_id) do nothing;


-- ===== V19 SYSTEM-KATEGORIEN =====
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
