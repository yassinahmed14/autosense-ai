-- For databases that already applied the initial migration.
begin;
alter table public.diagnostic_sessions drop constraint diagnostic_sessions_source_check;
alter table public.diagnostic_sessions add constraint diagnostic_sessions_source_check
  check (source in ('manual', 'mock_obd', 'ble_obd', 'wifi_obd'));
commit;
