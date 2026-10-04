-- 010: Dedupe champion rows where same team appears under multiple name variants
-- Strategy: For each (tournament, canonical identity), rank rows by score,
-- delete all but the top-ranked, then rename survivors to canonical.

create temporary table _aliases (alt text, canonical text) on commit drop;
insert into _aliases (alt, canonical) values
  -- France
  ('PSG', 'Paris Saint-Germain'),
  ('Paris SG', 'Paris Saint-Germain'),
  ('Paris Saint Germain', 'Paris Saint-Germain'),
  ('Paris St-Germain', 'Paris Saint-Germain'),
  ('Paris St Germain', 'Paris Saint-Germain'),
  ('Olympique Marseille', 'Marseille'),
  ('Olympique de Marseille', 'Marseille'),
  ('OM', 'Marseille'),
  ('Olympique Marsella', 'Marseille'),
  ('AS Monaco', 'Monaco'),
  ('A.S. Monaco', 'Monaco'),
  ('AS Saint-Etienne', 'Saint-Etienne'),
  ('AS Saint Etienne', 'Saint-Etienne'),
  ('St-Etienne', 'Saint-Etienne'),
  ('St Etienne', 'Saint-Etienne'),
  ('ASSE', 'Saint-Etienne'),
  ('FC Nantes', 'Nantes'),
  ('Olympique Lyonnais', 'Lyon'),
  ('OL', 'Lyon'),
  ('LOSC Lille', 'Lille'),
  ('Lille OSC', 'Lille'),
  ('OGC Nice', 'Nice'),
  ('Girondins Bordeaux', 'Bordeaux'),
  ('Girondins de Bordeaux', 'Bordeaux'),
  ('Stade Rennais', 'Rennes'),
  ('Stade de Reims', 'Reims'),
  -- Spain
  ('Barcelona', 'FC Barcelona'),
  ('Barca', 'FC Barcelona'),
  ('R. Madrid', 'Real Madrid'),
  ('Madrid', 'Real Madrid'),
  ('Atletico de Madrid', 'Atletico Madrid'),
  ('Club Atletico de Madrid', 'Atletico Madrid'),
  ('Athletic Club', 'Athletic Bilbao'),
  ('Athletic de Bilbao', 'Athletic Bilbao'),
  ('Real Sociedad de Futbol', 'Real Sociedad'),
  ('Betis', 'Real Betis'),
  ('Deportivo', 'Deportivo La Coruna'),
  ('Depor', 'Deportivo La Coruna'),
  ('Sevilla FC', 'Sevilla'),
  ('Valencia CF', 'Valencia'),
  ('Villarreal CF', 'Villarreal'),
  -- England
  ('Man United', 'Manchester United'),
  ('Man Utd', 'Manchester United'),
  ('Man U', 'Manchester United'),
  ('Manchester Utd', 'Manchester United'),
  ('Man City', 'Manchester City'),
  ('Manchester C', 'Manchester City'),
  ('Spurs', 'Tottenham'),
  ('Tottenham Hotspur', 'Tottenham'),
  ('Newcastle United', 'Newcastle'),
  ('Newcastle Utd', 'Newcastle'),
  ('Wolverhampton', 'Wolves'),
  ('Wolverhampton Wanderers', 'Wolves'),
  ('West Ham United', 'West Ham'),
  ('West Ham Utd', 'West Ham'),
  ('Nottingham', 'Nottingham Forest'),
  ('Forest', 'Nottingham Forest'),
  ('Brighton & Hove Albion', 'Brighton'),
  ('Brighton and Hove Albion', 'Brighton'),
  ('Leeds', 'Leeds United'),
  ('West Bromwich', 'West Brom'),
  ('West Bromwich Albion', 'West Brom'),
  ('WBA', 'West Brom'),
  ('Queens Park Rangers', 'QPR'),
  -- Italy
  ('Inter', 'Inter Milan'),
  ('Internazionale', 'Inter Milan'),
  ('Milan', 'AC Milan'),
  ('Associazione Calcio Milan', 'AC Milan'),
  ('SSC Napoli', 'Napoli'),
  ('AS Roma', 'Roma'),
  ('SS Lazio', 'Lazio'),
  ('ACF Fiorentina', 'Fiorentina'),
  ('Bologna FC', 'Bologna'),
  ('Udinese', 'Udinese Calcio'),
  ('Hellas', 'Hellas Verona'),
  ('Verona', 'Hellas Verona'),
  -- Germany
  ('Bayern', 'Bayern Munich'),
  ('FC Bayern', 'Bayern Munich'),
  ('FC Bayern Munchen', 'Bayern Munich'),
  ('Bayern Munchen', 'Bayern Munich'),
  ('Dortmund', 'Borussia Dortmund'),
  ('BVB', 'Borussia Dortmund'),
  ('Leverkusen', 'Bayer Leverkusen'),
  ('Bayer 04 Leverkusen', 'Bayer Leverkusen'),
  ('Leipzig', 'RB Leipzig'),
  ('Frankfurt', 'Eintracht Frankfurt'),
  ('Mgladbach', 'Borussia Monchengladbach'),
  ('Monchengladbach', 'Borussia Monchengladbach'),
  ('Gladbach', 'Borussia Monchengladbach'),
  ('Stuttgart', 'VfB Stuttgart'),
  ('Bremen', 'Werder Bremen'),
  ('Hamburger', 'Hamburger SV'),
  ('Hamburg SV', 'Hamburger SV'),
  ('Hamburg', 'Hamburger SV'),
  ('HSV', 'Hamburger SV'),
  ('Koln', 'FC Koln'),
  ('Cologne', 'FC Koln'),
  ('1. FC Koln', 'FC Koln'),
  -- Portugal / Netherlands / Scotland / Turkey / Russia / Ukraine
  ('SL Benfica', 'Benfica'),
  ('FC Porto', 'Porto'),
  ('Sporting Lisbon', 'Sporting CP'),
  ('Sporting', 'Sporting CP'),
  ('SC Braga', 'Braga'),
  ('AFC Ajax', 'Ajax'),
  ('PSV', 'PSV Eindhoven'),
  ('Celtic FC', 'Celtic'),
  ('Rangers FC', 'Rangers'),
  ('Galatasaray SK', 'Galatasaray'),
  ('Shakhtar', 'Shakhtar Donetsk'),
  ('CSKA', 'CSKA Moscow'),
  ('Zenit', 'Zenit St. Petersburg')
;

-- Step 1: Rank all champion rows by (tournament, canonical identity), delete losers
-- "canonical identity" = alias.canonical if row is an alt, else row's own name
with family as (
  select
    c.id,
    c.tournament_id,
    lower(trim(coalesce(a.canonical, c.team_name))) as canon_key,
    coalesce(c.wins, 0) + coalesce(c.runners_up, 0) as score
  from champions c
  left join _aliases a on lower(trim(c.team_name)) = lower(trim(a.alt))
),
ranked as (
  select id, row_number() over (
    partition by tournament_id, canon_key
    order by score desc, id asc
  ) as rn
  from family
)
delete from champions where id in (select id from ranked where rn > 1);

-- Step 2: Rename remaining alt rows to their canonical name
-- Safe now because step 1 removed all duplicate (tournament, canonical) collisions
update champions c
set team_name = a.canonical
from _aliases a
where lower(trim(c.team_name)) = lower(trim(a.alt));

-- Step 3: Final pass — dedupe any exact normalized duplicates (whitespace/case only)
with ranked2 as (
  select id, row_number() over (
    partition by tournament_id, lower(regexp_replace(team_name, '\s+', ' ', 'g'))
    order by coalesce(wins, 0) + coalesce(runners_up, 0) desc, id asc
  ) as rn
  from champions
)
delete from champions where id in (select id from ranked2 where rn > 1);
