-- 002: switch champions to per-team totals (matches Google Sheet format)
drop table if exists champions cascade;

create table if not exists champions (
  id uuid primary key default gen_random_uuid(),
  tournament_id uuid not null references tournaments(id) on delete cascade,
  team_name text not null,
  team_country text,
  team_color text,
  team_text_color text,
  wins int default 0,
  runners_up int default 0,
  years_won text,
  years_runner_up text,
  from_my_career boolean default false,
  created_at timestamptz default now(),
  unique(tournament_id, team_name)
);
alter table champions enable row level security;
drop policy if exists champions_all on champions;
create policy champions_all on champions for all using (true) with check (true);
