-- 008: Standings — league tables per tournament/season
create table if not exists standings (
  id uuid primary key default gen_random_uuid(),
  tournament_id uuid not null references tournaments(id) on delete cascade,
  year_end int not null,
  team_name text not null,
  position int,
  played int,
  wins int,
  draws int,
  losses int,
  goals_for int,
  goals_against int,
  points int,
  created_at timestamptz default now(),
  unique(tournament_id, year_end, team_name)
);
create index if not exists standings_tournament_year on standings(tournament_id, year_end);
alter table standings enable row level security;
drop policy if exists standings_all on standings;
create policy standings_all on standings for all using (true) with check (true);
