-- 003: add division + more leagues per country, remove UEFA Super Cup

alter table tournaments add column if not exists division int;

-- Mark existing top-flight divisions
update tournaments set division = 1 where name in ('La Liga','Premier League','Serie A','Bundesliga','Ligue 1');

-- Remove UEFA Super Cup
delete from tournaments where name = 'UEFA Super Cup';

-- Insert additional divisions
insert into tournaments (name, country, logo_url, has_top_scorer, color, text_color, sort_order, division) values
  -- Spain
  ('La Liga 2',          'Spain',   'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/en/thumb/0/09/LaLiga_Hypermotion_Logo.svg/1200px-LaLiga_Hypermotion_Logo.svg.png', false, '#004a99', '#ffffff', 50, 2),
  -- England
  ('Championship',       'England', 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/en/thumb/e/e2/EFL_Championship.svg/1200px-EFL_Championship.svg.png',             false, '#00264d', '#ffffff', 51, 2),
  ('League One',         'England', 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/en/thumb/a/a7/EFL_League_One.svg/1200px-EFL_League_One.svg.png',                  false, '#f7941e', '#ffffff', 52, 3),
  ('League Two',         'England', 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/en/thumb/5/5e/EFL_League_Two.svg/1200px-EFL_League_Two.svg.png',                  false, '#009640', '#ffffff', 53, 4),
  -- Italy
  ('Serie B',            'Italy',   'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/en/thumb/f/f0/Serie_B_logo_%282022%29.svg/1200px-Serie_B_logo_%282022%29.svg.png', false, '#8f5e00', '#ffffff', 54, 2),
  -- Germany
  ('2. Bundesliga',      'Germany', 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/en/thumb/8/8e/2._Bundesliga_logo.svg/1200px-2._Bundesliga_logo.svg.png',          false, '#d20515', '#ffffff', 55, 2),
  ('3. Liga',            'Germany', 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/en/thumb/6/68/3._Liga_logo.svg/1200px-3._Liga_logo.svg.png',                      false, '#000000', '#ffffff', 56, 3),
  -- France
  ('Ligue 2',            'France',  'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/en/thumb/9/91/Ligue2_2024_Logo.svg/1200px-Ligue2_2024_Logo.svg.png',              false, '#003a70', '#ffffff', 57, 2)
on conflict (name) do nothing;

-- ==========================================
-- Domestic cups + super cups per country
-- ==========================================
insert into tournaments (name, country, logo_url, has_top_scorer, color, text_color, sort_order, division) values
  -- Spain
  ('Copa del Rey',          'Spain',   'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/en/thumb/c/cd/Copa_del_Rey.svg/1200px-Copa_del_Rey.svg.png',                     false, '#001b4a', '#fcc200', 100, null),
  ('Supercopa de España',   'Spain',   'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/en/thumb/3/36/Supercopa_de_España_logo.svg/1200px-Supercopa_de_España_logo.svg.png', false, '#8c0e2e', '#ffffff', 101, null),
  -- England
  ('FA Cup',                'England', 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/en/thumb/0/02/FA_Cup_logo.svg/1200px-FA_Cup_logo.svg.png',                         false, '#00234b', '#e30613', 102, null),
  ('EFL Cup',               'England', 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/en/thumb/8/8e/EFL_Cup.svg/1200px-EFL_Cup.svg.png',                                 false, '#1b1464', '#ffffff', 103, null),
  ('Community Shield',      'England', 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/en/thumb/b/bc/FA_Community_Shield_logo.svg/1200px-FA_Community_Shield_logo.svg.png', false, '#00234b', '#e30613', 104, null),
  -- Italy
  ('Coppa Italia',          'Italy',   'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/en/thumb/2/29/Coppa_Italia_logo_2019.svg/1200px-Coppa_Italia_logo_2019.svg.png',   false, '#009246', '#ce2b37', 105, null),
  ('Supercoppa Italiana',   'Italy',   'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/en/thumb/a/a3/Supercoppa_italiana_logo.svg/1200px-Supercoppa_italiana_logo.svg.png', false, '#003a70', '#ffffff', 106, null),
  -- Germany
  ('DFB-Pokal',             'Germany', 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/en/thumb/a/ad/DFB-Pokal_logo_2017.svg/1200px-DFB-Pokal_logo_2017.svg.png',         false, '#000000', '#dd0000', 107, null),
  ('DFL-Supercup',          'Germany', 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/en/thumb/d/d6/DFL-Supercup_logo.svg/1200px-DFL-Supercup_logo.svg.png',             false, '#d20515', '#ffffff', 108, null),
  -- France
  ('Coupe de France',       'France',  'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/en/thumb/1/1a/Coupe_de_France_logo.svg/1200px-Coupe_de_France_logo.svg.png',       false, '#001b4a', '#ffffff', 109, null),
  ('Trophée des Champions', 'France',  'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/en/thumb/9/94/Trophée_des_Champions_%282019%29.svg/1200px-Trophée_des_Champions_%282019%29.svg.png', false, '#001b4a', '#ffffff', 110, null)
on conflict (name) do nothing;

-- ==========================================
-- UEFA Super Cup moves to International with proper flag (removed above and re-added)
-- Already removed in the delete at the top. Not re-adding per user request.
-- ==========================================
