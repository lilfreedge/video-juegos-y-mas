-- 010: Dedupe champion rows where same team appears under multiple name variants
-- Strategy: when both canonical name and alternate exist in same tournament,
--   keep the one with more wins (or more total titles), delete the other.
-- When only an alternate exists, rename it to canonical.

-- Build alias map: alternates -> canonical
create temporary table _aliases (alt text, canonical text) on commit drop;
insert into _aliases (alt, canonical) values
  -- PSG
  ('PSG', 'Paris Saint-Germain'),
  ('Paris SG', 'Paris Saint-Germain'),
  ('Paris Saint Germain', 'Paris Saint-Germain'),
  ('Paris St-Germain', 'Paris Saint-Germain'),
  ('Paris St Germain', 'Paris Saint-Germain'),
  -- Marseille
  ('Olympique Marseille', 'Marseille'),
  ('Olympique de Marseille', 'Marseille'),
  ('OM', 'Marseille'),
  ('Olympique Marsella', 'Marseille'),
  -- Monaco
  ('AS Monaco', 'Monaco'),
  ('A.S. Monaco', 'Monaco'),
  -- Saint-Etienne
  ('AS Saint-Etienne', 'Saint-Etienne'),
  ('AS Saint Etienne', 'Saint-Etienne'),
  ('St-Etienne', 'Saint-Etienne'),
  ('St Etienne', 'Saint-Etienne'),
  ('ASSE', 'Saint-Etienne'),
  -- Nantes
  ('FC Nantes', 'Nantes'),
  -- Lyon
  ('Olympique Lyonnais', 'Lyon'),
  ('OL', 'Lyon'),
  -- Lille
  ('LOSC Lille', 'Lille'),
  ('Lille OSC', 'Lille'),
  -- Nice
  ('OGC Nice', 'Nice'),
  -- Bordeaux
  ('Girondins Bordeaux', 'Bordeaux'),
  ('Girondins de Bordeaux', 'Bordeaux'),
  -- Rennes
  ('Stade Rennais', 'Rennes'),
  -- Reims
  ('Stade de Reims', 'Reims'),
  -- Barcelona
  ('Barcelona', 'FC Barcelona'),
  ('Barca', 'FC Barcelona'),
  ('Barça', 'FC Barcelona'),
  -- Real Madrid
  ('R. Madrid', 'Real Madrid'),
  ('Madrid', 'Real Madrid'),
  -- Atletico
  ('Atlético Madrid', 'Atletico Madrid'),
  ('Atletico de Madrid', 'Atletico Madrid'),
  ('Club Atletico de Madrid', 'Atletico Madrid'),
  -- Athletic Bilbao
  ('Athletic Club', 'Athletic Bilbao'),
  ('Athletic de Bilbao', 'Athletic Bilbao'),
  -- Real Sociedad
  ('Real Sociedad de Futbol', 'Real Sociedad'),
  -- Real Betis
  ('Betis', 'Real Betis'),
  -- Deportivo
  ('Deportivo', 'Deportivo La Coruna'),
  ('Depor', 'Deportivo La Coruna'),
  -- Sevilla
  ('Sevilla FC', 'Sevilla'),
  -- Valencia
  ('Valencia CF', 'Valencia'),
  -- Villarreal
  ('Villarreal CF', 'Villarreal'),
  -- English teams
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
  ('WBA', 'West Brom'),
  ('Queens Park Rangers', 'QPR'),
  -- Italian teams
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
  -- German teams
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
  ('M''gladbach', 'Borussia Monchengladbach'),
  ('Stuttgart', 'VfB Stuttgart'),
  ('Bremen', 'Werder Bremen'),
  ('Hamburger', 'Hamburger SV'),
  ('Hamburg SV', 'Hamburger SV'),
  ('Hamburg', 'Hamburger SV'),
  ('HSV', 'Hamburger SV'),
  ('Koln', 'FC Koln'),
  ('Cologne', 'FC Koln'),
  ('1. FC Koln', 'FC Koln'),
  -- Portuguese
  ('SL Benfica', 'Benfica'),
  ('FC Porto', 'Porto'),
  ('Sporting Lisbon', 'Sporting CP'),
  ('Sporting', 'Sporting CP'),
  ('SC Braga', 'Braga'),
  -- Dutch
  ('AFC Ajax', 'Ajax'),
  ('PSV', 'PSV Eindhoven'),
  -- Other
  ('Celtic FC', 'Celtic'),
  ('Rangers FC', 'Rangers'),
  ('Galatasaray SK', 'Galatasaray'),
  ('Fenerbahçe', 'Fenerbahce'),
  ('Beşiktaş', 'Besiktas'),
  -- Russia/Ukraine
  ('Shakhtar', 'Shakhtar Donetsk'),
  ('CSKA', 'CSKA Moscow'),
  ('Zenit', 'Zenit St. Petersburg')
;

-- Also handle whitespace/case variants automatically by normalizing:
-- Delete rows where a canonical with more wins already exists (merge losers)
delete from champions c
using _aliases a, champions canon
where lower(trim(c.team_name)) = lower(trim(a.alt))
  and canon.tournament_id = c.tournament_id
  and lower(trim(canon.team_name)) = lower(trim(a.canonical))
  and (canon.wins + canon.runners_up) >= (c.wins + c.runners_up);

-- When the alternate has MORE data than canonical, delete canonical instead and rename alternate
with winners as (
  select c.id as alt_id, canon.id as canon_id
  from champions c
  join _aliases a on lower(trim(c.team_name)) = lower(trim(a.alt))
  join champions canon on canon.tournament_id = c.tournament_id and lower(trim(canon.team_name)) = lower(trim(a.canonical))
  where (c.wins + c.runners_up) > (canon.wins + canon.runners_up)
)
delete from champions where id in (select canon_id from winners);

-- Rename remaining alternates to canonical (no conflict since canonicals were deleted or never existed)
update champions c
set team_name = a.canonical
from _aliases a
where lower(trim(c.team_name)) = lower(trim(a.alt))
  and not exists (
    select 1 from champions c2
    where c2.tournament_id = c.tournament_id
      and lower(trim(c2.team_name)) = lower(trim(a.canonical))
      and c2.id <> c.id
  );

-- Final pass: dedupe EXACT normalized matches (whitespace/case only)
-- Keep the row with the most data (wins + runners_up), delete siblings
delete from champions c
using champions keep
where c.tournament_id = keep.tournament_id
  and c.id <> keep.id
  and lower(regexp_replace(c.team_name, '\s+', ' ', 'g')) = lower(regexp_replace(keep.team_name, '\s+', ' ', 'g'))
  and (
    (keep.wins + keep.runners_up) > (c.wins + c.runners_up)
    or ((keep.wins + keep.runners_up) = (c.wins + c.runners_up) and keep.id < c.id)
  );
