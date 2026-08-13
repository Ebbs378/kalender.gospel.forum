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
