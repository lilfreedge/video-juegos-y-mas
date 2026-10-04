-- Clean start — champions tracker
create table if not exists tournaments (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  country text,
  logo_url text,
  has_top_scorer boolean default false,
  color text,
  text_color text,
  sort_order int default 0,
  created_at timestamptz default now()
);
alter table tournaments enable row level security;
drop policy if exists tournaments_all on tournaments;
create policy tournaments_all on tournaments for all using (true) with check (true);

create table if not exists champions (
  id uuid primary key default gen_random_uuid(),
  tournament_id uuid not null references tournaments(id) on delete cascade,
  year int not null,
  champion_team text not null,
  champion_color text,
  champion_text_color text,
  runner_up_team text,
  from_my_career boolean default false,
  created_at timestamptz default now()
);
alter table champions enable row level security;
drop policy if exists champions_all on champions;
create policy champions_all on champions for all using (true) with check (true);

create table if not exists top_scorers (
  id uuid primary key default gen_random_uuid(),
  tournament_id uuid not null references tournaments(id) on delete cascade,
  year int not null,
  player_name text not null,
  nationality text,
  team text,
  goals int not null,
  from_my_career boolean default false,
  created_at timestamptz default now()
);
alter table top_scorers enable row level security;
drop policy if exists top_scorers_all on top_scorers;
create policy top_scorers_all on top_scorers for all using (true) with check (true);

-- Seeded tournaments
insert into tournaments (name, country, logo_url, has_top_scorer, color, text_color, sort_order) values
  ('UEFA Champions League', null,      'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/en/thumb/b/bf/UEFA_Champions_League_logo_2.svg/1200px-UEFA_Champions_League_logo_2.svg.png', true, '#0b0e4a', '#ffffff', 1),
  ('UEFA Europa League',   null,      'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/en/thumb/d/d8/UEFA_Europa_League_logo_2024.svg/1200px-UEFA_Europa_League_logo_2024.svg.png', true, '#ff6600', '#000000', 2),
  ('UEFA Conference League', null,    'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/en/thumb/8/8f/UEFA_Conference_League.svg/1200px-UEFA_Conference_League.svg.png',             true, '#00a650', '#ffffff', 3),
  ('Ligue 1',             'France',   'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/en/thumb/9/98/Ligue1_2024_Logo.svg/1200px-Ligue1_2024_Logo.svg.png',                       true, '#003a70', '#ffffff', 4),
  ('La Liga',             'Spain',    'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/en/thumb/9/92/LaLiga.svg/1200px-LaLiga.svg.png',                                           true, '#ee8707', '#ffffff', 5),
  ('Premier League',      'England',  'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/en/thumb/f/f2/Premier_League_Logo.svg/1200px-Premier_League_Logo.svg.png',                 true, '#3d195b', '#ffffff', 6),
  ('Serie A',             'Italy',    'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/en/thumb/e/e1/Serie_A_logo_2022.svg/1200px-Serie_A_logo_2022.svg.png',                     true, '#008fd7', '#ffffff', 7),
  ('Bundesliga',          'Germany',  'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/en/thumb/d/df/Bundesliga_logo_%282017%29.svg/1200px-Bundesliga_logo_%282017%29.svg.png',   true, '#d20515', '#ffffff', 8),
  ('FIFA World Cup',      null,       null,                                                                                                                                                   false, '#003a70', '#ffffff', 20),
  ('UEFA Euro',           null,       null,                                                                                                                                                   false, '#005cff', '#ffffff', 21),
  ('UEFA Super Cup',      null,       null,                                                                                                                                                   false, '#1e3a8a', '#ffffff', 22),
  ('Coupe de France',     'France',   null,                                                                                                                                                   false, '#001b4a', '#ffffff', 23)
on conflict (name) do nothing;
