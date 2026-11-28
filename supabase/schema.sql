-- Hermaeus Mora: per-account private snapshots, optimistic revision checks.
begin;
create table if not exists public.codex_archives (
  user_id uuid primary key references auth.users(id) on delete cascade,
  archive jsonb not null check (jsonb_typeof(archive) = 'object' and octet_length(archive::text) <= 5000000),
  revision bigint not null default 1 check (revision > 0),
  updated_at timestamptz not null default now()
);
alter table public.codex_archives enable row level security;
revoke all on public.codex_archives from public, anon, authenticated;
grant select, insert, update on public.codex_archives to authenticated;
drop policy if exists codex_read_own on public.codex_archives;
create policy codex_read_own on public.codex_archives for select to authenticated using ((select auth.uid()) = user_id);
drop policy if exists codex_insert_own on public.codex_archives;
create policy codex_insert_own on public.codex_archives for insert to authenticated with check ((select auth.uid()) = user_id);
drop policy if exists codex_update_own on public.codex_archives;
create policy codex_update_own on public.codex_archives for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
commit;
