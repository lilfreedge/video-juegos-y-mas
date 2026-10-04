-- 005: Clubs catalog — pre-seeded clubs with colors + country for autocomplete

create table if not exists clubs_catalog (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  country text not null,
  primary_color text not null,
  text_color text not null default '#ffffff',
  created_at timestamptz default now()
);
alter table clubs_catalog enable row level security;
drop policy if exists clubs_catalog_all on clubs_catalog;
create policy clubs_catalog_all on clubs_catalog for all using (true) with check (true);

insert into clubs_catalog (name, country, primary_color, text_color) values
-- Spain
('Real Madrid', 'Spain', '#FEBE10', '#00529F'),
('FC Barcelona', 'Spain', '#A50044', '#EDBB00'),
('Atletico Madrid', 'Spain', '#CB3524', '#FFFFFF'),
('Sevilla', 'Spain', '#D7141A', '#FFFFFF'),
('Valencia', 'Spain', '#FF7900', '#000000'),
('Real Sociedad', 'Spain', '#003399', '#FFFFFF'),
('Villarreal', 'Spain', '#FFE667', '#005187'),
('Real Betis', 'Spain', '#008B3F', '#FFFFFF'),
('Athletic Bilbao', 'Spain', '#EE2523', '#FFFFFF'),
('Girona', 'Spain', '#CD2534', '#FFFFFF'),
('Osasuna', 'Spain', '#D91A21', '#002856'),
('Celta Vigo', 'Spain', '#8AC3EE', '#FFFFFF'),
('Rayo Vallecano', 'Spain', '#E30613', '#FFFFFF'),
('Mallorca', 'Spain', '#CD1719', '#FBD12A'),
-- England
('Manchester United', 'England', '#DA291C', '#FBE122'),
('Manchester City', 'England', '#6CABDD', '#FFFFFF'),
('Liverpool', 'England', '#C8102E', '#F6EB61'),
('Chelsea', 'England', '#034694', '#FFFFFF'),
('Arsenal', 'England', '#EF0107', '#FFFFFF'),
('Tottenham', 'England', '#132257', '#FFFFFF'),
('Newcastle', 'England', '#241F20', '#FFFFFF'),
('Aston Villa', 'England', '#670E36', '#95BFE5'),
('West Ham', 'England', '#7A263A', '#1BB1E7'),
('Everton', 'England', '#003399', '#FFFFFF'),
('Brighton', 'England', '#0057B8', '#FFFFFF'),
('Nottingham Forest', 'England', '#DD0000', '#FFFFFF'),
('Brentford', 'England', '#E30613', '#FFFFFF'),
('Fulham', 'England', '#FFFFFF', '#000000'),
('Wolves', 'England', '#FDB913', '#231F20'),
('Crystal Palace', 'England', '#1B458F', '#C4122E'),
('Bournemouth', 'England', '#DA291C', '#000000'),
-- Italy
('Juventus', 'Italy', '#000000', '#FFFFFF'),
('Inter Milan', 'Italy', '#0068A8', '#FFFFFF'),
('AC Milan', 'Italy', '#FB090B', '#000000'),
('Napoli', 'Italy', '#087FD5', '#FFFFFF'),
('Roma', 'Italy', '#8E1B1F', '#F3C04C'),
('Lazio', 'Italy', '#87CEEB', '#FFFFFF'),
('Atalanta', 'Italy', '#1664B7', '#000000'),
('Fiorentina', 'Italy', '#482E92', '#FFFFFF'),
('Bologna', 'Italy', '#1B2746', '#D2122E'),
('Torino', 'Italy', '#881F1E', '#FFFFFF'),
('Udinese', 'Italy', '#000000', '#FFFFFF'),
('Genoa', 'Italy', '#C8102E', '#002855'),
-- Germany
('Bayern Munich', 'Germany', '#DC052D', '#FFFFFF'),
('Borussia Dortmund', 'Germany', '#FDE100', '#000000'),
('Bayer Leverkusen', 'Germany', '#E32221', '#000000'),
('RB Leipzig', 'Germany', '#DD0741', '#FFFFFF'),
('Eintracht Frankfurt', 'Germany', '#E1000F', '#000000'),
('VfB Stuttgart', 'Germany', '#E32219', '#FFFFFF'),
('Wolfsburg', 'Germany', '#65B32E', '#FFFFFF'),
('Werder Bremen', 'Germany', '#1D9053', '#FFFFFF'),
('Borussia Monchengladbach', 'Germany', '#000000', '#FFFFFF'),
('Hoffenheim', 'Germany', '#1961B5', '#FFFFFF'),
('Union Berlin', 'Germany', '#E52129', '#FFFFFF'),
('Hamburger SV', 'Germany', '#0F3F8C', '#FFFFFF'),
-- France
('Paris Saint-Germain', 'France', '#004170', '#ED1C24'),
('Marseille', 'France', '#27B2CB', '#FFFFFF'),
('Lyon', 'France', '#DA001A', '#0073CF'),
('Monaco', 'France', '#CE2131', '#FFFFFF'),
('Lille', 'France', '#E01E13', '#FFFFFF'),
('Nice', 'France', '#E60026', '#000000'),
('Rennes', 'France', '#E30613', '#000000'),
('Nantes', 'France', '#FFD700', '#008542'),
('Lens', 'France', '#FFCD00', '#D40028'),
('Strasbourg', 'France', '#0066B3', '#FFFFFF'),
-- Portugal
('Benfica', 'Portugal', '#E30613', '#FFFFFF'),
('Porto', 'Portugal', '#003DA5', '#FFFFFF'),
('Sporting CP', 'Portugal', '#008057', '#FFFFFF'),
('Braga', 'Portugal', '#AC0023', '#FFFFFF'),
-- Netherlands
('Ajax', 'Netherlands', '#D2122E', '#FFFFFF'),
('PSV Eindhoven', 'Netherlands', '#ED1C24', '#FFFFFF'),
('Feyenoord', 'Netherlands', '#CF102D', '#FFFFFF'),
('AZ Alkmaar', 'Netherlands', '#E30613', '#FFFFFF'),
-- Scotland
('Celtic', 'Scotland', '#008751', '#FFFFFF'),
('Rangers', 'Scotland', '#004FA3', '#FFFFFF'),
-- Turkey
('Galatasaray', 'Turkey', '#FFB400', '#A90432'),
('Fenerbahce', 'Turkey', '#FFED00', '#00205B'),
('Besiktas', 'Turkey', '#000000', '#FFFFFF'),
-- Belgium
('Club Brugge', 'Belgium', '#0066B3', '#FFFFFF'),
('Anderlecht', 'Belgium', '#4B2E83', '#FFFFFF'),
-- Americas / Other
('Boca Juniors', 'Argentina', '#0040A0', '#FFC400'),
('River Plate', 'Argentina', '#FFFFFF', '#D62828'),
('Flamengo', 'Brazil', '#C8102E', '#000000'),
('Palmeiras', 'Brazil', '#006437', '#FFFFFF'),
('Sao Paulo', 'Brazil', '#FFFFFF', '#D62828'),
('Corinthians', 'Brazil', '#000000', '#FFFFFF'),
('Al-Nassr', 'Saudi Arabia', '#FFD700', '#004899'),
('Al-Hilal', 'Saudi Arabia', '#004899', '#FFFFFF'),
('Inter Miami', 'USA', '#F7B5CD', '#231F20'),
('LAFC', 'USA', '#000000', '#C39E6D'),
-- Custom
('Haiti United', 'Haiti', '#003F87', '#D21034')
on conflict (name) do nothing;
