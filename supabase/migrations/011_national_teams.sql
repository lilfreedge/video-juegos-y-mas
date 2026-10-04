-- 011: National teams support + career updates
-- Adds is_national flag + seeds national teams + updates Freedge's career

-- Add is_national column to contracts and catalog
alter table contracts add column if not exists is_national boolean default false;
alter table clubs_catalog add column if not exists is_national boolean default false;

-- Mark existing non-national rows (should already be false by default)
update clubs_catalog set is_national = false where is_national is null;
update contracts set is_national = false where is_national is null;

-- Add national teams (FIFA playable countries)
insert into clubs_catalog (name, country, primary_color, text_color, is_national) values
-- Europe (UEFA)
('Portugal', 'Portugal', '#006600', '#DA291C', true),
('Spain', 'Spain', '#AA151B', '#F1BF00', true),
('France', 'France', '#002395', '#FFFFFF', true),
('Germany', 'Germany', '#000000', '#DD0000', true),
('Italy', 'Italy', '#0066CC', '#FFFFFF', true),
('England', 'England', '#FFFFFF', '#CE1126', true),
('Belgium', 'Belgium', '#000000', '#FDDA24', true),
('Netherlands', 'Netherlands', '#F36C21', '#FFFFFF', true),
('Croatia', 'Croatia', '#D21034', '#FFFFFF', true),
('Switzerland', 'Switzerland', '#D21034', '#FFFFFF', true),
('Austria', 'Austria', '#D21034', '#FFFFFF', true),
('Sweden', 'Sweden', '#005CFF', '#FECC00', true),
('Denmark', 'Denmark', '#C8102E', '#FFFFFF', true),
('Norway', 'Norway', '#D21034', '#FFFFFF', true),
('Finland', 'Finland', '#005CFF', '#FFFFFF', true),
('Poland', 'Poland', '#D21034', '#FFFFFF', true),
('Czech Republic', 'Czech Republic', '#11457E', '#FFFFFF', true),
('Hungary', 'Hungary', '#CE2939', '#FFFFFF', true),
('Serbia', 'Serbia', '#D21034', '#FFFFFF', true),
('Ukraine', 'Ukraine', '#005BBB', '#FFCB05', true),
('Scotland', 'Scotland', '#005CA9', '#FFFFFF', true),
('Wales', 'Wales', '#D21034', '#FFFFFF', true),
('Ireland', 'Ireland', '#008057', '#FFFFFF', true),
('Northern Ireland', 'Northern Ireland', '#005CA9', '#FFFFFF', true),
('Turkey', 'Turkey', '#D21034', '#FFFFFF', true),
('Greece', 'Greece', '#0D5EAF', '#FFFFFF', true),
('Romania', 'Romania', '#005CFF', '#FFCB05', true),
('Russia', 'Russia', '#D21034', '#FFFFFF', true),
('Albania', 'Albania', '#D21034', '#000000', true),
('Slovakia', 'Slovakia', '#005CA9', '#FFFFFF', true),
-- South America (CONMEBOL)
('Argentina', 'Argentina', '#75AADB', '#FFFFFF', true),
('Brazil', 'Brazil', '#009C3B', '#FFDF00', true),
('Uruguay', 'Uruguay', '#5CBFEB', '#FFFFFF', true),
('Colombia', 'Colombia', '#FFCB05', '#005CFF', true),
('Chile', 'Chile', '#D21034', '#005CFF', true),
('Peru', 'Peru', '#D21034', '#FFFFFF', true),
('Ecuador', 'Ecuador', '#FFCB05', '#005CFF', true),
('Paraguay', 'Paraguay', '#D21034', '#FFFFFF', true),
('Venezuela', 'Venezuela', '#891C32', '#FFCB05', true),
('Bolivia', 'Bolivia', '#008057', '#FFCB05', true),
-- North America (CONCACAF)
('Mexico', 'Mexico', '#006847', '#CE1126', true),
('United States', 'USA', '#1D3F94', '#D22630', true),
('Canada', 'Canada', '#D21034', '#FFFFFF', true),
('Costa Rica', 'Costa Rica', '#D21034', '#005CFF', true),
('Panama', 'Panama', '#D21034', '#005CFF', true),
('Jamaica', 'Jamaica', '#008057', '#FFCB05', true),
('Honduras', 'Honduras', '#005CFF', '#FFFFFF', true),
('Haiti', 'Haiti', '#003F87', '#D21034', true),
('Dominican Republic', 'Dominican Republic', '#005CA9', '#D21034', true),
('El Salvador', 'El Salvador', '#005CFF', '#FFFFFF', true),
('Guatemala', 'Guatemala', '#005CA9', '#FFFFFF', true),
-- Africa (CAF)
('Senegal', 'Senegal', '#008057', '#FFCB05', true),
('Morocco', 'Morocco', '#D21034', '#008057', true),
('Egypt', 'Egypt', '#D21034', '#000000', true),
('Nigeria', 'Nigeria', '#008057', '#FFFFFF', true),
('Ghana', 'Ghana', '#D21034', '#FFCB05', true),
('Algeria', 'Algeria', '#008057', '#FFFFFF', true),
('Cameroon', 'Cameroon', '#008057', '#D21034', true),
('Tunisia', 'Tunisia', '#D21034', '#FFFFFF', true),
('Ivory Coast', 'Ivory Coast', '#FD7E14', '#008057', true),
('South Africa', 'South Africa', '#008057', '#FFCB05', true),
('Mali', 'Mali', '#008057', '#FFCB05', true),
-- Asia (AFC)
('Japan', 'Japan', '#005CA9', '#FFFFFF', true),
('South Korea', 'South Korea', '#D21034', '#005CA9', true),
('Australia', 'Australia', '#FFCB05', '#008057', true),
('Saudi Arabia', 'Saudi Arabia', '#008057', '#FFFFFF', true),
('Iran', 'Iran', '#008057', '#D21034', true),
('Qatar', 'Qatar', '#891C32', '#FFFFFF', true),
('UAE', 'UAE', '#D21034', '#008057', true),
('Iraq', 'Iraq', '#D21034', '#FFFFFF', true),
('China', 'China', '#D21034', '#FFCB05', true),
('Jordan', 'Jordan', '#D21034', '#FFFFFF', true),
-- Oceania (OFC)
('New Zealand', 'New Zealand', '#000000', '#FFFFFF', true)
on conflict (name) do nothing;

-- CAREER UPDATES

-- Delete Haiti United squad (user has no records/photos)
delete from squad_players where season_id in (
  select s.id from seasons s
  join contracts c on s.contract_id = c.id
  where c.club_name = 'Haiti United' and c.is_national = false
);

-- Update Haiti United contract: ended May 2027
update contracts set end_year = 2027, end_month = 5
where club_name = 'Haiti United' and is_national = false and end_year is null;

-- Add Udinese Calcio contract (May 2027 - present)
insert into contracts (club_name, club_country, club_color, club_text_color, start_year, start_month, end_year, end_month, is_national)
select 'Udinese Calcio', 'Italy', '#000000', '#FFFFFF', 2027, 5, null, null, false
where not exists (
  select 1 from contracts where club_name = 'Udinese Calcio' and is_national = false
);

-- Fix any existing contracts whose name matches a national team in the catalog
-- (e.g., Portugal was manually added before the national toggle existed)
update contracts c
set is_national = true,
    club_color = coalesce(c.club_color, cat.primary_color),
    club_text_color = coalesce(c.club_text_color, cat.text_color),
    club_country = coalesce(c.club_country, cat.country)
from clubs_catalog cat
where cat.name = c.club_name
  and cat.is_national = true
  and (c.is_national is null or c.is_national = false);

-- Add Portugal national team (July 2026 - present, concurrent with clubs)
-- Only inserts if NO Portugal contract exists at all (national or not)
insert into contracts (club_name, club_country, club_color, club_text_color, start_year, start_month, end_year, end_month, is_national)
select 'Portugal', 'Portugal', '#006600', '#DA291C', 2026, 7, null, null, true
where not exists (
  select 1 from contracts where club_name = 'Portugal'
);
