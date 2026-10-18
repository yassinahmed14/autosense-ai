-- Apply once in a Supabase project's SQL editor or with `supabase db push`.
-- No credentials or anonymous access to vehicle/session records.
begin;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text check (length(display_name) <= 100),
  created_at timestamptz not null default now()
);

create table public.vehicles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  make text not null check (length(make) <= 60),
  model text not null check (length(model) <= 60),
  year integer check (year between 1900 and 2100),
  created_at timestamptz not null default now(),
  unique (id, user_id)
);

create table public.diagnostic_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  vehicle_id uuid,
  source text not null check (source in ('manual', 'mock_obd')),
  request jsonb not null check (jsonb_typeof(request) = 'object'),
  created_at timestamptz not null default now(),
  unique (id, user_id),
  foreign key (vehicle_id, user_id) references public.vehicles(id, user_id)
);

create table public.diagnostic_results (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null,
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  engine_version text not null default 'rules-v1',
  result jsonb not null check (jsonb_typeof(result) = 'object'),
  created_at timestamptz not null default now(),
  unique (session_id),
  foreign key (session_id, user_id)
    references public.diagnostic_sessions(id, user_id) on delete cascade
);

create table public.dtc_catalog (
  code text primary key check (code ~ '^[PBCU][0-3][0-9A-F]{3}$'),
  title text not null,
  explanation text not null,
  possible_causes jsonb not null,
  next_checks jsonb not null,
  coverage text not null default 'starter_generic',
  catalog_version text not null default 'demo-v1'
);

create index vehicles_user_idx on public.vehicles(user_id);
create index sessions_user_created_idx on public.diagnostic_sessions(user_id, created_at desc);
create index results_user_idx on public.diagnostic_results(user_id);

alter table public.profiles enable row level security;
alter table public.vehicles enable row level security;
alter table public.diagnostic_sessions enable row level security;
alter table public.diagnostic_results enable row level security;
alter table public.dtc_catalog enable row level security;

create policy profiles_owner on public.profiles for all to authenticated
  using ((select auth.uid()) = id) with check ((select auth.uid()) = id);
create policy vehicles_owner on public.vehicles for all to authenticated
  using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy sessions_owner on public.diagnostic_sessions for all to authenticated
  using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy results_owner on public.diagnostic_results for all to authenticated
  using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy catalog_authenticated_read on public.dtc_catalog for select to authenticated
  using (true);

revoke all on public.profiles, public.vehicles, public.diagnostic_sessions,
  public.diagnostic_results, public.dtc_catalog from anon, authenticated;
grant select, insert, update, delete on public.profiles, public.vehicles,
  public.diagnostic_sessions, public.diagnostic_results to authenticated;
grant select on public.dtc_catalog to authenticated;

comment on table public.diagnostic_results is
  'Owner-managed history; client-writable JSON is not verified clinical or mechanical evidence.';
commit;
