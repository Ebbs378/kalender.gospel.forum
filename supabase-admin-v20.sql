-- V20 Admin RPC
create table if not exists public.calendar_admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create or replace function public.is_calendar_admin()
returns boolean language sql stable security definer set search_path=public
as $$ select exists(select 1 from public.calendar_admins where user_id=auth.uid()) $$;

create or replace function public.admin_list_pending_events()
returns table(id uuid,title text,start_date date,end_date date,start_time time,end_time time,location text,category text,created_by text,description text,status text)
language plpgsql security definer set search_path=public
as $$ begin
 if not public.is_calendar_admin() then raise exception 'Not authorized'; end if;
 return query select e.id,e.title,e.start_date,e.end_date,e.start_time,e.end_time,e.location,e.category,e.created_by,e.description,e.status
 from public.calendar_events e where e.status='pending' order by e.start_date,e.start_time nulls last;
end $$;

create or replace function public.admin_set_event_status(event_id uuid,new_status text)
returns void language plpgsql security definer set search_path=public
as $$ begin
 if not public.is_calendar_admin() then raise exception 'Not authorized'; end if;
 if new_status not in ('published','rejected','pending') then raise exception 'Invalid status'; end if;
 update public.calendar_events set status=new_status,updated_at=now() where id=event_id;
 if not found then raise exception 'Event not found'; end if;
end $$;

revoke all on function public.admin_list_pending_events() from public;
revoke all on function public.admin_set_event_status(uuid,text) from public;
grant execute on function public.admin_list_pending_events() to authenticated;
grant execute on function public.admin_set_event_status(uuid,text) to authenticated;

alter table public.calendar_admins enable row level security;
drop policy if exists "Admins can read own admin row" on public.calendar_admins;
create policy "Admins can read own admin row" on public.calendar_admins for select to authenticated using(user_id=auth.uid());
grant select on public.calendar_admins to authenticated;
NOTIFY pgrst,'reload schema';
