-- 004: Career module — contracts, seasons, squad, transfers, trophies

create table if not exists contracts (
  id uuid primary key default gen_random_uuid(),
  club_name text not null,
  club_country text,
  club_color text,
  club_text_color text,
  club_logo_url text,
  start_year int not null,
  start_month int,
  end_year int,
  end_month int,
  notes text,
  created_at timestamptz default now()
);
alter table contracts enable row level security;
drop policy if exists contracts_all on contracts;
create policy contracts_all on contracts for all using (true) with check (true);

create table if not exists seasons (
  id uuid primary key default gen_random_uuid(),
  contract_id uuid not null references contracts(id) on delete cascade,
  label text not null,
  start_year int not null,
  end_year int not null,
  notes text,
  created_at timestamptz default now()
);
alter table seasons enable row level security;
drop policy if exists seasons_all on seasons;
create policy seasons_all on seasons for all using (true) with check (true);

create table if not exists squad_players (
  id uuid primary key default gen_random_uuid(),
  season_id uuid not null references seasons(id) on delete cascade,
  jersey int,
  position text,
  name text not null,
  age int,
  overall int,
  nationality text,
  status text default 'squad' check (status in ('squad','new_signing','loan_in','loan_out','sold')),
  created_at timestamptz default now()
);
create index if not exists squad_players_season on squad_players(season_id);
alter table squad_players enable row level security;
drop policy if exists squad_players_all on squad_players;
create policy squad_players_all on squad_players for all using (true) with check (true);

create table if not exists transfers (
  id uuid primary key default gen_random_uuid(),
  season_id uuid not null references seasons(id) on delete cascade,
  type text not null check (type in ('in','out','loan_in','loan_out')),
  player_name text not null,
  from_club text,
  to_club text,
  amount text,
  month int,
  notes text,
  squad_player_id uuid references squad_players(id) on delete set null,
  created_at timestamptz default now()
);
create index if not exists transfers_season on transfers(season_id);
alter table transfers enable row level security;
drop policy if exists transfers_all on transfers;
create policy transfers_all on transfers for all using (true) with check (true);

create table if not exists trophies_won (
  id uuid primary key default gen_random_uuid(),
  season_id uuid not null references seasons(id) on delete cascade,
  tournament_id uuid references tournaments(id) on delete set null,
  tournament_name_snapshot text not null,
  result text default 'winner' check (result in ('winner','runner_up','semifinal','quarterfinal','r16','group','other')),
  notes text,
  created_at timestamptz default now()
);
create index if not exists trophies_won_season on trophies_won(season_id);
alter table trophies_won enable row level security;
drop policy if exists trophies_won_all on trophies_won;
create policy trophies_won_all on trophies_won for all using (true) with check (true);
