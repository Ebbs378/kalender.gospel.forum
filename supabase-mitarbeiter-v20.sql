-- V20 Mitarbeiterzugang
alter table public.calendar_events enable row level security;
alter table public.calendar_categories enable row level security;

drop policy if exists "Public can read calendar requests" on public.calendar_events;
drop policy if exists "Public can submit pending calendar events" on public.calendar_events;
drop policy if exists "Public can read active categories" on public.calendar_categories;
drop policy if exists "Employees can read calendar events" on public.calendar_events;
drop policy if exists "Employees can submit pending calendar events" on public.calendar_events;
drop policy if exists "Employees can read active categories" on public.calendar_categories;

create policy "Employees can read calendar events"
on public.calendar_events for select to authenticated
using(status in ('published','pending') or public.is_calendar_admin());

create policy "Employees can submit pending calendar events"
on public.calendar_events for insert to authenticated
with check(status='pending' and created_by is not null and created_by_email is not null);

create policy "Employees can read active categories"
on public.calendar_categories for select to authenticated
using(active=true or public.is_calendar_admin());

revoke all on table public.calendar_events from anon;
revoke all on table public.calendar_categories from anon;

grant select(id,title,start_date,end_date,start_time,end_time,category,location,description,created_by,status,created_at,updated_at)
on public.calendar_events to authenticated;
grant insert(title,start_date,end_date,start_time,end_time,category,location,description,created_by,created_by_email,status)
on public.calendar_events to authenticated;
grant select on public.calendar_categories to authenticated;
NOTIFY pgrst,'reload schema';
