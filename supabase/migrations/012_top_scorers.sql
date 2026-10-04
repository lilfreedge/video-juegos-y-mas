-- 012: Top scorers for major leagues + UEFA competitions
-- Safe to re-run — unique index on (tournament_id, year, player_name) prevents dupes

create unique index if not exists top_scorers_tournament_year_player
  on top_scorers (tournament_id, year, player_name);

-- LA LIGA (Pichichi, year = season end)
insert into top_scorers (tournament_id, year, player_name, nationality, team, goals)
select t.id, v.year, v.player_name, v.nationality, v.team, v.goals
from tournaments t, (values
  (2001, 'Raul', 'Spain', 'Real Madrid', 24),
  (2002, 'Diego Tristan', 'Spain', 'Deportivo La Coruna', 21),
  (2003, 'Roy Makaay', 'Netherlands', 'Deportivo La Coruna', 29),
  (2004, 'Ronaldo', 'Brazil', 'Real Madrid', 24),
  (2005, 'Diego Forlan', 'Uruguay', 'Villarreal', 25),
  (2006, 'Samuel Etoo', 'Cameroon', 'FC Barcelona', 26),
  (2007, 'Ruud van Nistelrooy', 'Netherlands', 'Real Madrid', 25),
  (2008, 'Daniel Guiza', 'Spain', 'Mallorca', 27),
  (2009, 'Diego Forlan', 'Uruguay', 'Atletico Madrid', 32),
  (2010, 'Lionel Messi', 'Argentina', 'FC Barcelona', 34),
  (2011, 'Cristiano Ronaldo', 'Portugal', 'Real Madrid', 40),
  (2012, 'Lionel Messi', 'Argentina', 'FC Barcelona', 50),
  (2013, 'Lionel Messi', 'Argentina', 'FC Barcelona', 46),
  (2014, 'Cristiano Ronaldo', 'Portugal', 'Real Madrid', 31),
  (2015, 'Cristiano Ronaldo', 'Portugal', 'Real Madrid', 48),
  (2016, 'Luis Suarez', 'Uruguay', 'FC Barcelona', 40),
  (2017, 'Lionel Messi', 'Argentina', 'FC Barcelona', 37),
  (2018, 'Lionel Messi', 'Argentina', 'FC Barcelona', 34),
  (2019, 'Lionel Messi', 'Argentina', 'FC Barcelona', 36),
  (2020, 'Lionel Messi', 'Argentina', 'FC Barcelona', 25),
  (2021, 'Lionel Messi', 'Argentina', 'FC Barcelona', 30),
  (2022, 'Karim Benzema', 'France', 'Real Madrid', 27),
  (2023, 'Robert Lewandowski', 'Poland', 'FC Barcelona', 23),
  (2024, 'Artem Dovbyk', 'Ukraine', 'Girona', 24),
  (2025, 'Kylian Mbappe', 'France', 'Real Madrid', 31)
) as v(year, player_name, nationality, team, goals)
where t.name = 'La Liga'
on conflict (tournament_id, year, player_name) do update set
  goals = excluded.goals, team = excluded.team, nationality = excluded.nationality;

-- PREMIER LEAGUE (Golden Boot)
insert into top_scorers (tournament_id, year, player_name, nationality, team, goals)
select t.id, v.year, v.player_name, v.nationality, v.team, v.goals
from tournaments t, (values
  (2001, 'Jimmy Floyd Hasselbaink', 'Netherlands', 'Chelsea', 23),
  (2002, 'Thierry Henry', 'France', 'Arsenal', 24),
  (2003, 'Ruud van Nistelrooy', 'Netherlands', 'Manchester United', 25),
  (2004, 'Thierry Henry', 'France', 'Arsenal', 30),
  (2005, 'Thierry Henry', 'France', 'Arsenal', 25),
  (2006, 'Thierry Henry', 'France', 'Arsenal', 27),
  (2007, 'Didier Drogba', 'Ivory Coast', 'Chelsea', 20),
  (2008, 'Cristiano Ronaldo', 'Portugal', 'Manchester United', 31),
  (2009, 'Nicolas Anelka', 'France', 'Chelsea', 19),
  (2010, 'Didier Drogba', 'Ivory Coast', 'Chelsea', 29),
  (2011, 'Dimitar Berbatov', 'Bulgaria', 'Manchester United', 20),
  (2012, 'Robin van Persie', 'Netherlands', 'Arsenal', 30),
  (2013, 'Robin van Persie', 'Netherlands', 'Manchester United', 26),
  (2014, 'Luis Suarez', 'Uruguay', 'Liverpool', 31),
  (2015, 'Sergio Aguero', 'Argentina', 'Manchester City', 26),
  (2016, 'Harry Kane', 'England', 'Tottenham', 25),
  (2017, 'Harry Kane', 'England', 'Tottenham', 29),
  (2018, 'Mohamed Salah', 'Egypt', 'Liverpool', 32),
  (2019, 'Pierre-Emerick Aubameyang / Mane / Salah', 'Multi', 'Arsenal/Liverpool', 22),
  (2020, 'Jamie Vardy', 'England', 'Leicester City', 23),
  (2021, 'Harry Kane', 'England', 'Tottenham', 23),
  (2022, 'Son Heung-min / Mohamed Salah', 'Multi', 'Tottenham/Liverpool', 23),
  (2023, 'Erling Haaland', 'Norway', 'Manchester City', 36),
  (2024, 'Erling Haaland', 'Norway', 'Manchester City', 27),
  (2025, 'Mohamed Salah', 'Egypt', 'Liverpool', 29)
) as v(year, player_name, nationality, team, goals)
where t.name = 'Premier League'
on conflict (tournament_id, year, player_name) do update set
  goals = excluded.goals, team = excluded.team, nationality = excluded.nationality;

-- SERIE A (Capocannoniere)
insert into top_scorers (tournament_id, year, player_name, nationality, team, goals)
select t.id, v.year, v.player_name, v.nationality, v.team, v.goals
from tournaments t, (values
  (2001, 'Hernan Crespo', 'Argentina', 'Lazio', 26),
  (2002, 'David Trezeguet', 'France', 'Juventus', 24),
  (2003, 'Christian Vieri', 'Italy', 'Inter Milan', 24),
  (2004, 'Andriy Shevchenko', 'Ukraine', 'AC Milan', 24),
  (2005, 'Cristiano Lucarelli', 'Italy', 'Livorno', 24),
  (2006, 'Luca Toni', 'Italy', 'Fiorentina', 31),
  (2007, 'Francesco Totti', 'Italy', 'Roma', 26),
  (2008, 'Alessandro Del Piero', 'Italy', 'Juventus', 21),
  (2009, 'Zlatan Ibrahimovic', 'Sweden', 'Inter Milan', 25),
  (2010, 'Antonio Di Natale', 'Italy', 'Udinese Calcio', 29),
  (2011, 'Antonio Di Natale', 'Italy', 'Udinese Calcio', 28),
  (2012, 'Zlatan Ibrahimovic', 'Sweden', 'AC Milan', 28),
  (2013, 'Edinson Cavani', 'Uruguay', 'Napoli', 29),
  (2014, 'Ciro Immobile', 'Italy', 'Torino', 22),
  (2015, 'Mauro Icardi', 'Argentina', 'Inter Milan', 22),
  (2016, 'Gonzalo Higuain', 'Argentina', 'Napoli', 36),
  (2017, 'Edin Dzeko', 'Bosnia', 'Roma', 29),
  (2018, 'Mauro Icardi / Ciro Immobile', 'Multi', 'Inter/Lazio', 29),
  (2019, 'Fabio Quagliarella', 'Italy', 'Sampdoria', 26),
  (2020, 'Ciro Immobile', 'Italy', 'Lazio', 36),
  (2021, 'Cristiano Ronaldo', 'Portugal', 'Juventus', 29),
  (2022, 'Ciro Immobile', 'Italy', 'Lazio', 27),
  (2023, 'Victor Osimhen', 'Nigeria', 'Napoli', 26),
  (2024, 'Lautaro Martinez', 'Argentina', 'Inter Milan', 24),
  (2025, 'Mateo Retegui', 'Italy', 'Atalanta', 25)
) as v(year, player_name, nationality, team, goals)
where t.name = 'Serie A'
on conflict (tournament_id, year, player_name) do update set
  goals = excluded.goals, team = excluded.team, nationality = excluded.nationality;

-- BUNDESLIGA (Torschutzenkonig)
insert into top_scorers (tournament_id, year, player_name, nationality, team, goals)
select t.id, v.year, v.player_name, v.nationality, v.team, v.goals
from tournaments t, (values
  (2001, 'Sergej Barbarez / Ebbe Sand', 'Multi', 'HSV/Schalke', 22),
  (2002, 'Marcio Amoroso', 'Brazil', 'Borussia Dortmund', 18),
  (2003, 'Thomas Christiansen / Giovane Elber', 'Multi', 'Bochum/Bayern', 21),
  (2004, 'Ailton', 'Brazil', 'Werder Bremen', 28),
  (2005, 'Marek Mintal', 'Slovakia', 'Nurnberg', 24),
  (2006, 'Miroslav Klose', 'Germany', 'Werder Bremen', 25),
  (2007, 'Theofanis Gekas', 'Greece', 'Bochum', 20),
  (2008, 'Luca Toni', 'Italy', 'Bayern Munich', 24),
  (2009, 'Grafite', 'Brazil', 'Wolfsburg', 28),
  (2010, 'Edin Dzeko', 'Bosnia', 'Wolfsburg', 22),
  (2011, 'Mario Gomez', 'Germany', 'Bayern Munich', 28),
  (2012, 'Klaas-Jan Huntelaar', 'Netherlands', 'Schalke 04', 29),
  (2013, 'Stefan Kiessling', 'Germany', 'Bayer Leverkusen', 25),
  (2014, 'Robert Lewandowski', 'Poland', 'Borussia Dortmund', 20),
  (2015, 'Alexander Meier', 'Germany', 'Eintracht Frankfurt', 19),
  (2016, 'Robert Lewandowski', 'Poland', 'Bayern Munich', 30),
  (2017, 'Pierre-Emerick Aubameyang', 'Gabon', 'Borussia Dortmund', 31),
  (2018, 'Robert Lewandowski', 'Poland', 'Bayern Munich', 29),
  (2019, 'Robert Lewandowski', 'Poland', 'Bayern Munich', 22),
  (2020, 'Robert Lewandowski', 'Poland', 'Bayern Munich', 34),
  (2021, 'Robert Lewandowski', 'Poland', 'Bayern Munich', 41),
  (2022, 'Robert Lewandowski', 'Poland', 'Bayern Munich', 35),
  (2023, 'Niklas Fullkrug / Christopher Nkunku', 'Multi', 'Bremen/Leipzig', 16),
  (2024, 'Harry Kane', 'England', 'Bayern Munich', 36),
  (2025, 'Harry Kane', 'England', 'Bayern Munich', 26)
) as v(year, player_name, nationality, team, goals)
where t.name = 'Bundesliga'
on conflict (tournament_id, year, player_name) do update set
  goals = excluded.goals, team = excluded.team, nationality = excluded.nationality;

-- LIGUE 1
insert into top_scorers (tournament_id, year, player_name, nationality, team, goals)
select t.id, v.year, v.player_name, v.nationality, v.team, v.goals
from tournaments t, (values
  (2001, 'Sonny Anderson', 'Brazil', 'Lyon', 22),
  (2002, 'Djibril Cisse', 'France', 'AJ Auxerre', 22),
  (2003, 'Shabani Nonda', 'DR Congo', 'Monaco', 26),
  (2004, 'Djibril Cisse', 'France', 'AJ Auxerre', 26),
  (2005, 'Alexander Frei', 'Switzerland', 'Rennes', 20),
  (2006, 'Pauleta', 'Portugal', 'Paris Saint-Germain', 21),
  (2007, 'Pauleta', 'Portugal', 'Paris Saint-Germain', 15),
  (2008, 'Karim Benzema', 'France', 'Lyon', 20),
  (2009, 'Andre-Pierre Gignac', 'France', 'Toulouse', 24),
  (2010, 'Mamadou Niang', 'Senegal', 'Marseille', 18),
  (2011, 'Moussa Sow', 'Senegal', 'Lille', 25),
  (2012, 'Olivier Giroud', 'France', 'Montpellier', 21),
  (2013, 'Zlatan Ibrahimovic', 'Sweden', 'Paris Saint-Germain', 30),
  (2014, 'Zlatan Ibrahimovic', 'Sweden', 'Paris Saint-Germain', 26),
  (2015, 'Alexandre Lacazette', 'France', 'Lyon', 27),
  (2016, 'Zlatan Ibrahimovic', 'Sweden', 'Paris Saint-Germain', 38),
  (2017, 'Edinson Cavani', 'Uruguay', 'Paris Saint-Germain', 35),
  (2018, 'Edinson Cavani', 'Uruguay', 'Paris Saint-Germain', 28),
  (2019, 'Kylian Mbappe', 'France', 'Paris Saint-Germain', 33),
  (2020, 'Wissam Ben Yedder / Kylian Mbappe', 'Multi', 'Monaco/PSG', 18),
  (2021, 'Kylian Mbappe', 'France', 'Paris Saint-Germain', 27),
  (2022, 'Kylian Mbappe', 'France', 'Paris Saint-Germain', 28),
  (2023, 'Kylian Mbappe', 'France', 'Paris Saint-Germain', 29),
  (2024, 'Kylian Mbappe', 'France', 'Paris Saint-Germain', 27),
  (2025, 'Ousmane Dembele', 'France', 'Paris Saint-Germain', 21)
) as v(year, player_name, nationality, team, goals)
where t.name = 'Ligue 1'
on conflict (tournament_id, year, player_name) do update set
  goals = excluded.goals, team = excluded.team, nationality = excluded.nationality;

-- UEFA CHAMPIONS LEAGUE
insert into top_scorers (tournament_id, year, player_name, nationality, team, goals)
select t.id, v.year, v.player_name, v.nationality, v.team, v.goals
from tournaments t, (values
  (2001, 'Raul', 'Spain', 'Real Madrid', 7),
  (2002, 'Ruud van Nistelrooy', 'Netherlands', 'Manchester United', 10),
  (2003, 'Ruud van Nistelrooy', 'Netherlands', 'Manchester United', 12),
  (2004, 'Fernando Morientes', 'Spain', 'Monaco', 9),
  (2005, 'Ruud van Nistelrooy', 'Netherlands', 'Manchester United', 8),
  (2006, 'Andriy Shevchenko', 'Ukraine', 'AC Milan', 9),
  (2007, 'Kaka', 'Brazil', 'AC Milan', 10),
  (2008, 'Cristiano Ronaldo', 'Portugal', 'Manchester United', 8),
  (2009, 'Lionel Messi', 'Argentina', 'FC Barcelona', 9),
  (2010, 'Lionel Messi', 'Argentina', 'FC Barcelona', 8),
  (2011, 'Lionel Messi', 'Argentina', 'FC Barcelona', 12),
  (2012, 'Lionel Messi', 'Argentina', 'FC Barcelona', 14),
  (2013, 'Cristiano Ronaldo', 'Portugal', 'Real Madrid', 12),
  (2014, 'Cristiano Ronaldo', 'Portugal', 'Real Madrid', 17),
  (2015, 'Lionel Messi / Neymar / Cristiano Ronaldo', 'Multi', 'Barcelona/Madrid', 10),
  (2016, 'Cristiano Ronaldo', 'Portugal', 'Real Madrid', 16),
  (2017, 'Cristiano Ronaldo', 'Portugal', 'Real Madrid', 12),
  (2018, 'Cristiano Ronaldo', 'Portugal', 'Real Madrid', 15),
  (2019, 'Lionel Messi', 'Argentina', 'FC Barcelona', 12),
  (2020, 'Robert Lewandowski', 'Poland', 'Bayern Munich', 15),
  (2021, 'Erling Haaland', 'Norway', 'Borussia Dortmund', 10),
  (2022, 'Karim Benzema', 'France', 'Real Madrid', 15),
  (2023, 'Erling Haaland', 'Norway', 'Manchester City', 12),
  (2024, 'Harry Kane', 'England', 'Bayern Munich', 8),
  (2025, 'Raphinha', 'Brazil', 'FC Barcelona', 13)
) as v(year, player_name, nationality, team, goals)
where t.name = 'UEFA Champions League'
on conflict (tournament_id, year, player_name) do update set
  goals = excluded.goals, team = excluded.team, nationality = excluded.nationality;

-- UEFA EUROPA LEAGUE (since 2010 rebrand)
insert into top_scorers (tournament_id, year, player_name, nationality, team, goals)
select t.id, v.year, v.player_name, v.nationality, v.team, v.goals
from tournaments t, (values
  (2010, 'Oscar Cardozo', 'Paraguay', 'Benfica', 9),
  (2011, 'Falcao', 'Colombia', 'Porto', 17),
  (2012, 'Falcao / Klaas-Jan Huntelaar', 'Multi', 'Atletico/Schalke', 12),
  (2013, 'Libor Kozak', 'Czech Republic', 'Lazio', 8),
  (2014, 'Romelu Lukaku', 'Belgium', 'Everton', 7),
  (2015, 'Alan', 'Brazil', 'Red Bull Salzburg', 8),
  (2016, 'Aritz Aduriz', 'Spain', 'Athletic Bilbao', 10),
  (2017, 'Edin Dzeko', 'Bosnia', 'Roma', 8),
  (2018, 'Ciro Immobile / Aritz Aduriz', 'Multi', 'Lazio/Athletic', 8),
  (2019, 'Olivier Giroud', 'France', 'Chelsea', 11),
  (2020, 'Bruno Fernandes / Lukaku / Pizzi', 'Multi', 'Multi', 8),
  (2021, 'Pizzi', 'Portugal', 'Benfica', 8),
  (2022, 'Paulinho', 'Portugal', 'Braga', 9),
  (2023, 'Marcus Rashford', 'England', 'Manchester United', 7),
  (2024, 'Santiago Gimenez', 'Mexico', 'Feyenoord', 7),
  (2025, 'Victor Boniface', 'Nigeria', 'Bayer Leverkusen', 8)
) as v(year, player_name, nationality, team, goals)
where t.name = 'UEFA Europa League'
on conflict (tournament_id, year, player_name) do update set
  goals = excluded.goals, team = excluded.team, nationality = excluded.nationality;

-- UEFA CONFERENCE LEAGUE (since 2022)
insert into top_scorers (tournament_id, year, player_name, nationality, team, goals)
select t.id, v.year, v.player_name, v.nationality, v.team, v.goals
from tournaments t, (values
  (2022, 'Tammy Abraham', 'England', 'Roma', 9),
  (2023, 'Arthur Cabral', 'Brazil', 'Fiorentina', 7),
  (2024, 'Ayoub El Kaabi', 'Morocco', 'Olympiacos', 11),
  (2025, 'Pedro', 'Spain', 'Real Betis', 7)
) as v(year, player_name, nationality, team, goals)
where t.name = 'UEFA Conference League'
on conflict (tournament_id, year, player_name) do update set
  goals = excluded.goals, team = excluded.team, nationality = excluded.nationality;
