-- Run AFTER the migration on a disposable Supabase DB with an admin connection:
-- psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/tests/ownership.sql
-- Rolls back all test records. Does not require pgTAP.
begin;
insert into auth.users(id) values
  ('10000000-0000-0000-0000-000000000001'),
  ('20000000-0000-0000-0000-000000000002');

set local role authenticated;
select set_config('request.jwt.claim.sub', '10000000-0000-0000-0000-000000000001', true);
select set_config('request.jwt.claims', '{"sub":"10000000-0000-0000-0000-000000000001","role":"authenticated"}', true);
insert into public.vehicles(id, make, model) values
  ('30000000-0000-0000-0000-000000000003', 'Demo', 'A');
insert into public.diagnostic_sessions(id, vehicle_id, source, request) values
  ('40000000-0000-0000-0000-000000000004',
   '30000000-0000-0000-0000-000000000003', 'manual', '{"codes":["P0300"]}');
insert into public.diagnostic_results(session_id, result) values
  ('40000000-0000-0000-0000-000000000004', '{"simulated":false}');
insert into public.diagnostic_sessions(id, source, request) values
  ('50000000-0000-0000-0000-000000000005', 'manual', '{}');

do $$ begin
  if (select count(*) from public.vehicles) <> 1 then
    raise exception 'Owner cannot see own vehicle';
  end if;
end $$;

select set_config('request.jwt.claim.sub', '20000000-0000-0000-0000-000000000002', true);
select set_config('request.jwt.claims', '{"sub":"20000000-0000-0000-0000-000000000002","role":"authenticated"}', true);
do $$ begin
  if exists(select 1 from public.vehicles) or exists(select 1 from public.diagnostic_sessions)
    or exists(select 1 from public.diagnostic_results) then
    raise exception 'Cross-user read leaked records';
  end if;
  begin
    insert into public.vehicles(user_id, make, model) values
      ('10000000-0000-0000-0000-000000000001', 'Wrong', 'Owner');
    raise exception 'Cross-owner write unexpectedly succeeded';
  exception when insufficient_privilege then null;
  end;
  begin
    insert into public.diagnostic_sessions(vehicle_id, source, request) values
      ('30000000-0000-0000-0000-000000000003', 'manual', '{}');
    raise exception 'Cross-owner vehicle link unexpectedly succeeded';
  exception when foreign_key_violation then null;
  end;
  begin
    insert into public.diagnostic_results(session_id, result) values
      ('50000000-0000-0000-0000-000000000005', '{}');
    raise exception 'Cross-owner session link unexpectedly succeeded';
  exception when foreign_key_violation then null;
  end;
  update public.vehicles set make='Hijacked';
  if found then raise exception 'Cross-owner update succeeded'; end if;
  delete from public.diagnostic_sessions;
  if found then raise exception 'Cross-owner delete succeeded'; end if;
end $$;
reset role;
set local role anon;
do $$ begin
  begin
    perform 1 from public.vehicles;
    raise exception 'Anonymous vehicle read unexpectedly allowed';
  exception when insufficient_privilege then null;
  end;
end $$;
reset role;
set local role authenticated;
select set_config('request.jwt.claim.sub', '10000000-0000-0000-0000-000000000001', true);
select set_config('request.jwt.claims', '{"sub":"10000000-0000-0000-0000-000000000001","role":"authenticated"}', true);
delete from public.diagnostic_sessions;
do $$ begin
  if exists(select 1 from public.diagnostic_results) then
    raise exception 'Deleting sessions did not cascade to their results';
  end if;
end $$;
delete from public.vehicles;
reset role;
rollback;
