-- 006: Seed champions for all catalog tournaments
-- Safe to re-run — ON CONFLICT updates. Skips any tournament not present.
-- Format: years_won / years_runner_up are free-text; leagues use "YYYY-YY", cups use "YYYY".

-- ====================================================================
-- ENGLAND
-- ====================================================================

-- Premier League (since 1992-93)
insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, v.team_name, v.team_country, v.team_color, v.team_text_color, v.wins, v.runners_up, v.years_won, v.years_runner_up
from tournaments t, (values
  ('Manchester United','England','#DA291C','#FBE122',13,7,'1992-93, 1993-94, 1995-96, 1996-97, 1998-99, 1999-00, 2000-01, 2002-03, 2006-07, 2007-08, 2008-09, 2010-11, 2012-13','1994-95, 1997-98, 2005-06, 2009-10, 2011-12, 2017-18, 2020-21'),
  ('Manchester City','England','#6CABDD','#FFFFFF',8,6,'2011-12, 2013-14, 2017-18, 2018-19, 2020-21, 2021-22, 2022-23, 2023-24','2012-13, 2014-15, 2019-20, 2024-25'),
  ('Chelsea','England','#034694','#FFFFFF',5,5,'2004-05, 2005-06, 2009-10, 2014-15, 2016-17','2003-04, 2007-08, 2010-11, 2015-16, 2021-22'),
  ('Arsenal','England','#EF0107','#FFFFFF',3,8,'1997-98, 2001-02, 2003-04','1998-99, 1999-00, 2000-01, 2002-03, 2004-05, 2015-16, 2022-23, 2023-24'),
  ('Liverpool','England','#C8102E','#F6EB61',2,6,'2019-20, 2024-25','2001-02, 2008-09, 2013-14, 2017-18, 2018-19, 2021-22'),
  ('Blackburn Rovers','England','#009EE0','#FFFFFF',1,0,'1994-95',null),
  ('Leicester City','England','#003090','#FDBE11',1,0,'2015-16',null),
  ('Newcastle','England','#241F20','#FFFFFF',0,2,null,'1995-96, 1996-97'),
  ('Tottenham','England','#132257','#FFFFFF',0,1,null,'2016-17'),
  ('Aston Villa','England','#670E36','#95BFE5',0,1,null,'1992-93')
) as v(team_name,team_country,team_color,team_text_color,wins,runners_up,years_won,years_runner_up)
where t.name = 'Premier League'
on conflict (tournament_id, team_name) do update set
  team_country=excluded.team_country, team_color=excluded.team_color, team_text_color=excluded.team_text_color,
  wins=excluded.wins, runners_up=excluded.runners_up, years_won=excluded.years_won, years_runner_up=excluded.years_runner_up;

-- Championship (second tier, modern names since 2004-05)
insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, v.team_name, v.team_country, v.team_color, v.team_text_color, v.wins, v.runners_up, v.years_won, v.years_runner_up
from tournaments t, (values
  ('Leicester City','England','#003090','#FDBE11',2,0,'2013-14, 2023-24',null),
  ('Newcastle','England','#241F20','#FFFFFF',2,0,'2009-10, 2016-17',null),
  ('Reading','England','#004494','#FFFFFF',2,0,'2005-06, 2011-12',null),
  ('Burnley','England','#6C1D45','#99D6EA',2,0,'2015-16, 2022-23',null),
  ('Sunderland','England','#EB172B','#FFFFFF',1,0,'2004-05',null),
  ('West Brom','England','#122F67','#FFFFFF',1,0,'2007-08',null),
  ('Wolves','England','#FDB913','#231F20',2,0,'2008-09, 2017-18',null),
  ('QPR','England','#1D5BA4','#FFFFFF',1,0,'2010-11',null),
  ('Cardiff City','Wales','#0070B5','#FFFFFF',1,0,'2012-13',null),
  ('Bournemouth','England','#DA291C','#000000',1,0,'2014-15',null),
  ('Norwich City','England','#00A650','#FFF200',1,1,'2018-19, 2020-21',null),
  ('Fulham','England','#FFFFFF','#000000',1,0,'2021-22',null),
  ('Leeds United','England','#FFCD00','#1D4189',1,0,'2019-20',null)
) as v(team_name,team_country,team_color,team_text_color,wins,runners_up,years_won,years_runner_up)
where t.name = 'Championship'
on conflict (tournament_id, team_name) do update set
  wins=excluded.wins, runners_up=excluded.runners_up, years_won=excluded.years_won, years_runner_up=excluded.years_runner_up;

-- League One (third tier)
insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, v.team_name, v.team_country, v.team_color, v.team_text_color, v.wins, v.runners_up, v.years_won, v.years_runner_up
from tournaments t, (values
  ('Luton Town','England','#F78F1E','#FFFFFF',1,0,'2018-19',null),
  ('Norwich City','England','#00A650','#FFF200',1,0,'2009-10',null),
  ('Charlton Athletic','England','#D4021D','#FFFFFF',1,0,'2011-12',null),
  ('Doncaster Rovers','England','#D52B1E','#FFFFFF',1,0,'2012-13',null),
  ('Wolves','England','#FDB913','#231F20',1,0,'2013-14',null),
  ('Bristol City','England','#D21034','#FFFFFF',1,0,'2014-15',null),
  ('Wigan Athletic','England','#1D59AF','#FFFFFF',2,0,'2015-16, 2017-18',null),
  ('Sheffield United','England','#EE2737','#FFFFFF',1,0,'2016-17',null),
  ('Hull City','England','#F8A81B','#000000',1,0,'2020-21',null),
  ('Plymouth Argyle','England','#004B30','#FFFFFF',1,0,'2022-23',null),
  ('Portsmouth','England','#001489','#FFFFFF',1,0,'2023-24',null),
  ('Birmingham City','England','#1D5BA4','#FFFFFF',1,0,'2024-25',null)
) as v(team_name,team_country,team_color,team_text_color,wins,runners_up,years_won,years_runner_up)
where t.name = 'League One'
on conflict (tournament_id, team_name) do update set
  wins=excluded.wins, runners_up=excluded.runners_up, years_won=excluded.years_won, years_runner_up=excluded.years_runner_up;

-- League Two (fourth tier)
insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, v.team_name, v.team_country, v.team_color, v.team_text_color, v.wins, v.runners_up, v.years_won, v.years_runner_up
from tournaments t, (values
  ('Portsmouth','England','#001489','#FFFFFF',1,0,'2016-17',null),
  ('Accrington Stanley','England','#D20022','#FFFFFF',1,0,'2017-18',null),
  ('Lincoln City','England','#D20022','#FFFFFF',1,0,'2018-19',null),
  ('Swindon Town','England','#CF1920','#FFFFFF',1,0,'2019-20',null),
  ('Cheltenham Town','England','#CC0000','#FFFFFF',1,0,'2020-21',null),
  ('Forest Green Rovers','England','#008000','#000000',1,0,'2021-22',null),
  ('Leyton Orient','England','#DA291C','#FFFFFF',1,0,'2022-23',null),
  ('Stockport County','England','#003399','#FFFFFF',1,0,'2023-24',null),
  ('Doncaster Rovers','England','#D52B1E','#FFFFFF',1,0,'2024-25',null)
) as v(team_name,team_country,team_color,team_text_color,wins,runners_up,years_won,years_runner_up)
where t.name = 'League Two'
on conflict (tournament_id, team_name) do update set
  wins=excluded.wins, runners_up=excluded.runners_up, years_won=excluded.years_won, years_runner_up=excluded.years_runner_up;

-- FA Cup
insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, v.team_name, v.team_country, v.team_color, v.team_text_color, v.wins, v.runners_up, v.years_won, v.years_runner_up
from tournaments t, (values
  ('Arsenal','England','#EF0107','#FFFFFF',14,8,'1930, 1936, 1950, 1971, 1979, 1993, 1998, 2002, 2003, 2005, 2014, 2015, 2017, 2020','1927, 1932, 1952, 1972, 1978, 1980, 2001'),
  ('Manchester United','England','#DA291C','#FBE122',12,8,'1909, 1948, 1963, 1977, 1983, 1985, 1990, 1994, 1996, 1999, 2004, 2016','1957, 1958, 1976, 1979, 1995, 2005, 2007, 2018'),
  ('Chelsea','England','#034694','#FFFFFF',8,8,'1970, 1997, 2000, 2007, 2009, 2010, 2012, 2018','1915, 1967, 1994, 2002, 2017, 2020, 2021, 2022'),
  ('Tottenham','England','#132257','#FFFFFF',8,1,'1901, 1921, 1961, 1962, 1967, 1981, 1982, 1991','1987'),
  ('Liverpool','England','#C8102E','#F6EB61',8,5,'1965, 1974, 1986, 1989, 1992, 2001, 2006, 2022','1950, 1971, 1977, 1988, 1996'),
  ('Aston Villa','England','#670E36','#95BFE5',7,3,'1887, 1895, 1897, 1905, 1913, 1920, 1957','1892, 1924, 2000'),
  ('Manchester City','England','#6CABDD','#FFFFFF',7,2,'1904, 1934, 1956, 1969, 2011, 2019, 2023','1933, 1955, 1981, 2013'),
  ('Newcastle','England','#241F20','#FFFFFF',6,7,'1910, 1924, 1932, 1951, 1952, 1955','1908, 1911, 1974, 1998, 1999'),
  ('Everton','England','#003399','#FFFFFF',5,8,'1906, 1933, 1966, 1984, 1995','1893, 1897, 1907, 1968, 1985, 1986, 1989, 2009'),
  ('Wanderers','England','#000000','#FFFFFF',5,0,'1872, 1873, 1876, 1877, 1878',null),
  ('West Bromwich Albion','England','#122F67','#FFFFFF',5,5,'1888, 1892, 1931, 1954, 1968','1886, 1887, 1895, 1912, 1935'),
  ('Blackburn Rovers','England','#009EE0','#FFFFFF',6,2,'1884, 1885, 1886, 1890, 1891, 1928','1882, 1960'),
  ('Portsmouth','England','#001489','#FFFFFF',2,2,'1939, 2008','1929, 1934'),
  ('Wigan Athletic','England','#1D59AF','#FFFFFF',1,0,'2013',null),
  ('Leicester City','England','#003090','#FDBE11',1,4,'2021','1949, 1961, 1963, 1969')
) as v(team_name,team_country,team_color,team_text_color,wins,runners_up,years_won,years_runner_up)
where t.name = 'FA Cup'
on conflict (tournament_id, team_name) do update set
  wins=excluded.wins, runners_up=excluded.runners_up, years_won=excluded.years_won, years_runner_up=excluded.years_runner_up;

-- EFL Cup (League Cup)
insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, v.team_name, v.team_country, v.team_color, v.team_text_color, v.wins, v.runners_up, v.years_won, v.years_runner_up
from tournaments t, (values
  ('Liverpool','England','#C8102E','#F6EB61',10,4,'1981, 1982, 1983, 1984, 1995, 2001, 2003, 2012, 2022, 2024','1978, 1987, 2005, 2016'),
  ('Manchester City','England','#6CABDD','#FFFFFF',8,2,'1970, 1976, 2014, 2016, 2018, 2019, 2020, 2021','1974, 2025'),
  ('Chelsea','England','#034694','#FFFFFF',5,4,'1965, 1998, 2005, 2007, 2015','1972, 2008, 2019, 2024'),
  ('Manchester United','England','#DA291C','#FBE122',6,4,'1992, 2006, 2009, 2010, 2017, 2023','1983, 1991, 1994, 2003'),
  ('Aston Villa','England','#670E36','#95BFE5',5,4,'1961, 1975, 1977, 1994, 1996','1963, 1971, 2010, 2020'),
  ('Tottenham','England','#132257','#FFFFFF',4,4,'1971, 1973, 1999, 2008','1982, 2002, 2009, 2015'),
  ('Nottingham Forest','England','#DD0000','#FFFFFF',4,2,'1978, 1979, 1989, 1990','1980, 1992'),
  ('Arsenal','England','#EF0107','#FFFFFF',2,6,'1987, 1993','1968, 1969, 1988, 2007, 2011, 2018'),
  ('Birmingham City','England','#1D5BA4','#FFFFFF',2,2,'1963, 2011','2001, 2024'),
  ('Leicester City','England','#003090','#FDBE11',3,2,'1964, 1997, 2000','1965, 1999'),
  ('Wolves','England','#FDB913','#231F20',2,2,'1974, 1980','1981, 1983'),
  ('Swansea City','Wales','#FFFFFF','#000000',1,0,'2013',null),
  ('Newcastle','England','#241F20','#FFFFFF',0,3,null,'1976, 2023, 2025')
) as v(team_name,team_country,team_color,team_text_color,wins,runners_up,years_won,years_runner_up)
where t.name = 'EFL Cup'
on conflict (tournament_id, team_name) do update set
  wins=excluded.wins, runners_up=excluded.runners_up, years_won=excluded.years_won, years_runner_up=excluded.years_runner_up;

-- Community Shield
insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, v.team_name, v.team_country, v.team_color, v.team_text_color, v.wins, v.runners_up, v.years_won, v.years_runner_up
from tournaments t, (values
  ('Manchester United','England','#DA291C','#FBE122',21,8,'1908, 1911, 1952, 1956, 1957, 1965, 1967, 1977, 1983, 1990, 1993, 1994, 1996, 1997, 2003, 2007, 2008, 2010, 2011, 2013, 2016','1948, 1958, 1963, 1985, 1998, 1999, 2000, 2004'),
  ('Arsenal','England','#EF0107','#FFFFFF',17,8,'1930, 1931, 1933, 1934, 1938, 1948, 1953, 1991, 1998, 1999, 2002, 2004, 2014, 2015, 2017, 2020, 2023','1935, 1936, 1979, 1989, 1993, 2003, 2005, 2024'),
  ('Liverpool','England','#C8102E','#F6EB61',16,8,'1964, 1965, 1966, 1974, 1976, 1977, 1979, 1980, 1982, 1986, 1988, 1989, 1990, 2001, 2006, 2022','1971, 1983, 1984, 1992, 2002, 2003, 2020, 2024'),
  ('Chelsea','England','#034694','#FFFFFF',4,10,'1955, 2000, 2005, 2009','1970, 1997, 2006, 2007, 2010, 2012, 2015, 2017, 2018, 2021'),
  ('Manchester City','England','#6CABDD','#FFFFFF',7,4,'1937, 1968, 1972, 2012, 2018, 2019, 2024','1934, 1956, 1969, 2023'),
  ('Everton','England','#003399','#FFFFFF',9,8,'1928, 1932, 1963, 1970, 1984, 1985, 1986, 1987, 1995','1933, 1966, 1969, 1984, 1986, 1987, 1988'),
  ('Tottenham','England','#132257','#FFFFFF',7,4,'1921, 1951, 1961, 1962, 1967, 1981, 1991','1920, 1961, 1971, 1982')
) as v(team_name,team_country,team_color,team_text_color,wins,runners_up,years_won,years_runner_up)
where t.name = 'Community Shield'
on conflict (tournament_id, team_name) do update set
  wins=excluded.wins, runners_up=excluded.runners_up, years_won=excluded.years_won, years_runner_up=excluded.years_runner_up;

-- ====================================================================
-- FRANCE
-- ====================================================================

-- Ligue 1
insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, v.team_name, v.team_country, v.team_color, v.team_text_color, v.wins, v.runners_up, v.years_won, v.years_runner_up
from tournaments t, (values
  ('Paris Saint-Germain','France','#004170','#ED1C24',13,10,'1986, 1994, 2013, 2014, 2015, 2016, 2018, 2019, 2020, 2022, 2023, 2024, 2025','1989, 1993, 1996, 1997, 2000, 2004, 2008, 2012, 2017, 2021'),
  ('Marseille','France','#27B2CB','#FFFFFF',9,13,'1937, 1948, 1971, 1972, 1989, 1990, 1991, 1992, 2010','1970, 1975, 1987, 1994, 1999, 2007, 2009, 2011, 2013, 2020, 2022, 2023, 2024'),
  ('Lyon','France','#DA001A','#0073CF',7,4,'2002, 2003, 2004, 2005, 2006, 2007, 2008','2001, 2015, 2016'),
  ('Monaco','France','#CE2131','#FFFFFF',8,6,'1961, 1963, 1978, 1982, 1988, 1997, 2000, 2017','1964, 1991, 1992, 2003, 2014, 2018'),
  ('Nantes','France','#FFD700','#008542',8,7,'1965, 1966, 1973, 1977, 1980, 1983, 1995, 2001','1967, 1974, 1978, 1979, 1981, 1985, 1986'),
  ('Saint-Etienne','France','#009639','#FFFFFF',10,3,'1957, 1964, 1967, 1968, 1969, 1970, 1974, 1975, 1976, 1981','1946, 1956, 1982'),
  ('Bordeaux','France','#000080','#FFFFFF',6,8,'1950, 1984, 1985, 1987, 1999, 2009','1952, 1965, 1983, 1988, 1990, 1995, 2006, 2008'),
  ('Lille','France','#E01E13','#FFFFFF',4,4,'1946, 1954, 2011, 2021','1948, 1949, 1950, 2005'),
  ('Nice','France','#E60026','#000000',4,2,'1951, 1952, 1956, 1959','1973, 1976'),
  ('Reims','France','#D81A1A','#FFFFFF',6,2,'1949, 1953, 1955, 1958, 1960, 1962','1947, 1954'),
  ('Montpellier','France','#F58220','#003F80',1,0,'2012',null)
) as v(team_name,team_country,team_color,team_text_color,wins,runners_up,years_won,years_runner_up)
where t.name = 'Ligue 1'
on conflict (tournament_id, team_name) do update set
  wins=excluded.wins, runners_up=excluded.runners_up, years_won=excluded.years_won, years_runner_up=excluded.years_runner_up;

-- Ligue 2
insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, v.team_name, v.team_country, v.team_color, v.team_text_color, v.wins, v.runners_up, v.years_won, v.years_runner_up
from tournaments t, (values
  ('Nantes','France','#FFD700','#008542',1,1,'2008','2013'),
  ('Montpellier','France','#F58220','#003F80',1,0,'2009',null),
  ('Caen','France','#D7141A','#003399',1,0,'2010',null),
  ('Evian','France','#0066B3','#FFFFFF',1,0,'2011',null),
  ('Monaco','France','#CE2131','#FFFFFF',1,0,'2013',null),
  ('Metz','France','#881F1E','#FFFFFF',2,0,'2014, 2019',null),
  ('Troyes','France','#1E90FF','#FFFFFF',2,0,'2015, 2021',null),
  ('Nancy','France','#D81A1A','#FFFFFF',1,0,'2016',null),
  ('Strasbourg','France','#0066B3','#FFFFFF',1,0,'2017',null),
  ('Reims','France','#D81A1A','#FFFFFF',1,0,'2018',null),
  ('Lorient','France','#F58220','#000000',2,0,'2020, 2025',null),
  ('Toulouse','France','#5A28A0','#FFFFFF',1,0,'2022',null),
  ('Le Havre','France','#003F87','#FFFFFF',1,0,'2023',null),
  ('AJ Auxerre','France','#001E62','#FFFFFF',1,0,'2024',null)
) as v(team_name,team_country,team_color,team_text_color,wins,runners_up,years_won,years_runner_up)
where t.name = 'Ligue 2'
on conflict (tournament_id, team_name) do update set
  wins=excluded.wins, runners_up=excluded.runners_up, years_won=excluded.years_won, years_runner_up=excluded.years_runner_up;

-- Coupe de France
insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, v.team_name, v.team_country, v.team_color, v.team_text_color, v.wins, v.runners_up, v.years_won, v.years_runner_up
from tournaments t, (values
  ('Paris Saint-Germain','France','#004170','#ED1C24',16,2,'1982, 1983, 1993, 1995, 1998, 2004, 2006, 2010, 2015, 2016, 2017, 2018, 2020, 2021, 2024, 2025','2003, 2011'),
  ('Marseille','France','#27B2CB','#FFFFFF',10,6,'1924, 1926, 1927, 1935, 1938, 1943, 1969, 1972, 1976, 1989','1934, 1940, 1954, 1986, 1991, 2007'),
  ('Monaco','France','#CE2131','#FFFFFF',5,5,'1960, 1963, 1980, 1985, 1991','1974, 1984, 1989, 2010, 2021'),
  ('Lyon','France','#DA001A','#0073CF',5,4,'1964, 1967, 1973, 2008, 2012','1963, 1971, 1976, 2024'),
  ('Saint-Etienne','France','#009639','#FFFFFF',6,3,'1962, 1968, 1970, 1974, 1975, 1977','1960, 1961, 1981, 1982'),
  ('Lille','France','#E01E13','#FFFFFF',6,3,'1946, 1947, 1948, 1953, 1955, 2011','1945, 1949, 1994'),
  ('Bordeaux','France','#000080','#FFFFFF',4,2,'1941, 1986, 1987, 2013','1943, 1952'),
  ('Nantes','France','#FFD700','#008542',4,3,'1979, 1999, 2000, 2022','1966, 1970, 1993'),
  ('Rennes','France','#E30613','#000000',3,5,'1965, 1971, 2019','1922, 1935, 1968, 1983, 2009'),
  ('Guingamp','France','#D81A1A','#000000',2,0,'2009, 2014',null),
  ('Montpellier','France','#F58220','#003F80',2,1,'1929, 1990','1931'),
  ('Toulouse','France','#5A28A0','#FFFFFF',1,2,'2023','1945, 1946')
) as v(team_name,team_country,team_color,team_text_color,wins,runners_up,years_won,years_runner_up)
where t.name = 'Coupe de France'
on conflict (tournament_id, team_name) do update set
  wins=excluded.wins, runners_up=excluded.runners_up, years_won=excluded.years_won, years_runner_up=excluded.years_runner_up;

-- Trophee des Champions
insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, v.team_name, v.team_country, v.team_color, v.team_text_color, v.wins, v.runners_up, v.years_won, v.years_runner_up
from tournaments t, (values
  ('Paris Saint-Germain','France','#004170','#ED1C24',12,2,'1995, 1998, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2022, 2023','1996, 2008'),
  ('Lyon','France','#DA001A','#0073CF',8,2,'1973, 2002, 2003, 2004, 2005, 2006, 2007, 2012','2008, 2011'),
  ('Marseille','France','#27B2CB','#FFFFFF',3,3,'1971, 2010, 2011','1972, 1998, 2015'),
  ('Monaco','France','#CE2131','#FFFFFF',4,3,'1961, 1985, 1997, 2000','1963, 1978, 2017'),
  ('Bordeaux','France','#000080','#FFFFFF',3,3,'1986, 2008, 2009','1987, 2000, 2013'),
  ('Lille','France','#E01E13','#FFFFFF',1,2,'2021','2001, 2011'),
  ('Nantes','France','#FFD700','#008542',2,2,'1965, 1999','1979, 2001'),
  ('Toulouse','France','#5A28A0','#FFFFFF',1,0,'2024',null)
) as v(team_name,team_country,team_color,team_text_color,wins,runners_up,years_won,years_runner_up)
where t.name = 'Trophee des Champions'
on conflict (tournament_id, team_name) do update set
  wins=excluded.wins, runners_up=excluded.runners_up, years_won=excluded.years_won, years_runner_up=excluded.years_runner_up;

-- ====================================================================
-- GERMANY
-- ====================================================================

-- Bundesliga
insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, v.team_name, v.team_country, v.team_color, v.team_text_color, v.wins, v.runners_up, v.years_won, v.years_runner_up
from tournaments t, (values
  ('Bayern Munich','Germany','#DC052D','#FFFFFF',33,11,'1932, 1969, 1972, 1973, 1974, 1980, 1981, 1985, 1986, 1987, 1989, 1990, 1994, 1997, 1999, 2000, 2001, 2003, 2005, 2006, 2008, 2010, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2025','1970, 1971, 1988, 1993, 1996, 1998, 2002, 2004, 2009, 2012, 2024'),
  ('Borussia Dortmund','Germany','#FDE100','#000000',8,8,'1956, 1957, 1963, 1995, 1996, 2002, 2011, 2012','1949, 1961, 1966, 1992, 2013, 2014, 2016, 2019, 2023'),
  ('Borussia Monchengladbach','Germany','#000000','#FFFFFF',5,2,'1970, 1971, 1975, 1976, 1977','1974, 1978'),
  ('Werder Bremen','Germany','#1D9053','#FFFFFF',4,7,'1965, 1988, 1993, 2004','1968, 1983, 1985, 1986, 1995, 2006, 2008'),
  ('Hamburger SV','Germany','#0F3F8C','#FFFFFF',6,5,'1923, 1928, 1960, 1979, 1982, 1983','1976, 1980, 1981, 1984, 1987'),
  ('Stuttgart','Germany','#E32219','#FFFFFF',5,4,'1950, 1952, 1984, 1992, 2007','1935, 1953, 1979, 2003'),
  ('Bayer Leverkusen','Germany','#E32221','#000000',1,5,'2024','1997, 1999, 2000, 2002, 2011'),
  ('Kaiserslautern','Germany','#D11919','#FFFFFF',4,2,'1951, 1953, 1991, 1998','1954, 1994'),
  ('Koln','Germany','#D11919','#FFFFFF',3,2,'1962, 1964, 1978','1963, 1965'),
  ('Wolfsburg','Germany','#65B32E','#FFFFFF',1,0,'2009',null)
) as v(team_name,team_country,team_color,team_text_color,wins,runners_up,years_won,years_runner_up)
where t.name = 'Bundesliga'
on conflict (tournament_id, team_name) do update set
  wins=excluded.wins, runners_up=excluded.runners_up, years_won=excluded.years_won, years_runner_up=excluded.years_runner_up;

-- 2. Bundesliga
insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, v.team_name, v.team_country, v.team_color, v.team_text_color, v.wins, v.runners_up, v.years_won, v.years_runner_up
from tournaments t, (values
  ('Hamburger SV','Germany','#0F3F8C','#FFFFFF',1,2,'2025','2023, 2024'),
  ('FC Koln','Germany','#D11919','#FFFFFF',6,3,'2000, 2005, 2008, 2014, 2019, 2025','2003, 2017, 2018'),
  ('Bochum','Germany','#005CA9','#FFFFFF',4,2,'1993, 1996, 2000, 2021','2002, 2006'),
  ('Hannover 96','Germany','#009639','#000000',3,1,'1987, 1989, 2002','2008'),
  ('Union Berlin','Germany','#E52129','#FFFFFF',1,1,'2019','2001'),
  ('Fortuna Dusseldorf','Germany','#E52129','#FFFFFF',2,2,'2012, 2018','1989, 1995'),
  ('St. Pauli','Germany','#4F2A24','#FFFFFF',1,2,'2024','2010, 2011'),
  ('Darmstadt','Germany','#005CA9','#FFFFFF',1,1,'2023','2015'),
  ('Werder Bremen','Germany','#1D9053','#FFFFFF',0,1,null,'2022'),
  ('Schalke 04','Germany','#004D9D','#FFFFFF',1,0,'2022',null),
  ('Jahn Regensburg','Germany','#F58220','#FFFFFF',1,0,'2003',null)
) as v(team_name,team_country,team_color,team_text_color,wins,runners_up,years_won,years_runner_up)
where t.name = '2. Bundesliga'
on conflict (tournament_id, team_name) do update set
  wins=excluded.wins, runners_up=excluded.runners_up, years_won=excluded.years_won, years_runner_up=excluded.years_runner_up;

-- 3. Liga
insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, v.team_name, v.team_country, v.team_color, v.team_text_color, v.wins, v.runners_up, v.years_won, v.years_runner_up
from tournaments t, (values
  ('Union Berlin','Germany','#E52129','#FFFFFF',1,0,'2009',null),
  ('Augsburg','Germany','#C32938','#FFFFFF',1,0,'2010',null),
  ('Eintracht Braunschweig','Germany','#F8D217','#004893',1,0,'2011',null),
  ('Sandhausen','Germany','#000000','#FFFFFF',1,0,'2012',null),
  ('Karlsruher SC','Germany','#003399','#FFFFFF',1,0,'2013',null),
  ('Heidenheim','Germany','#D52B1E','#FFFFFF',2,0,'2014, 2023',null),
  ('Arminia Bielefeld','Germany','#004A9E','#FFFFFF',1,0,'2015',null),
  ('Dynamo Dresden','Germany','#F8D217','#000000',3,0,'2016, 2021, 2025',null),
  ('MSV Duisburg','Germany','#004A9E','#FFFFFF',1,0,'2017',null),
  ('Magdeburg','Germany','#004A9E','#FFFFFF',1,1,'2018','2022'),
  ('Osnabruck','Germany','#5F2878','#FFFFFF',1,0,'2019',null),
  ('Bayern Munich II','Germany','#DC052D','#FFFFFF',1,0,'2020',null),
  ('Elversberg','Germany','#000000','#FFCC00',1,0,'2024',null)
) as v(team_name,team_country,team_color,team_text_color,wins,runners_up,years_won,years_runner_up)
where t.name = '3. Liga'
on conflict (tournament_id, team_name) do update set
  wins=excluded.wins, runners_up=excluded.runners_up, years_won=excluded.years_won, years_runner_up=excluded.years_runner_up;

-- DFB-Pokal
insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, v.team_name, v.team_country, v.team_color, v.team_text_color, v.wins, v.runners_up, v.years_won, v.years_runner_up
from tournaments t, (values
  ('Bayern Munich','Germany','#DC052D','#FFFFFF',20,4,'1957, 1966, 1967, 1969, 1971, 1982, 1984, 1986, 1998, 2000, 2003, 2005, 2006, 2008, 2010, 2013, 2014, 2016, 2019, 2020','1985, 1999, 2018, 2024'),
  ('Werder Bremen','Germany','#1D9053','#FFFFFF',6,3,'1961, 1991, 1994, 1999, 2004, 2009','1989, 1990, 2000'),
  ('Borussia Dortmund','Germany','#FDE100','#000000',5,5,'1965, 1989, 2012, 2017, 2021','1963, 1973, 1999, 2008, 2016'),
  ('Schalke 04','Germany','#004D9D','#FFFFFF',5,5,'1937, 1972, 2001, 2002, 2011','1935, 1942, 1955, 1969, 2005'),
  ('Eintracht Frankfurt','Germany','#E1000F','#000000',5,5,'1974, 1975, 1981, 1988, 2018','1964, 1994, 2006, 2017, 2023'),
  ('Hamburger SV','Germany','#0F3F8C','#FFFFFF',3,3,'1963, 1976, 1987','1956, 1967, 1974'),
  ('Bayer Leverkusen','Germany','#E32221','#000000',2,4,'1993, 2024','2002, 2009, 2020, 2023'),
  ('Stuttgart','Germany','#E32219','#FFFFFF',3,4,'1954, 1958, 1997','1986, 2007, 2013, 2025'),
  ('Koln','Germany','#D11919','#FFFFFF',4,2,'1968, 1977, 1978, 1983','1970, 1971'),
  ('RB Leipzig','Germany','#DD0741','#FFFFFF',3,1,'2022, 2023, 2025','2019')
) as v(team_name,team_country,team_color,team_text_color,wins,runners_up,years_won,years_runner_up)
where t.name = 'DFB-Pokal'
on conflict (tournament_id, team_name) do update set
  wins=excluded.wins, runners_up=excluded.runners_up, years_won=excluded.years_won, years_runner_up=excluded.years_runner_up;

-- DFL-Supercup
insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, v.team_name, v.team_country, v.team_color, v.team_text_color, v.wins, v.runners_up, v.years_won, v.years_runner_up
from tournaments t, (values
  ('Bayern Munich','Germany','#DC052D','#FFFFFF',11,7,'1987, 1990, 2010, 2012, 2016, 2017, 2018, 2020, 2021, 2022, 2025','1989, 1994, 2011, 2013, 2014, 2015, 2019'),
  ('Borussia Dortmund','Germany','#FDE100','#000000',6,5,'1989, 1995, 1996, 2008, 2013, 2014, 2019','1988, 1990, 2016, 2017, 2021'),
  ('Werder Bremen','Germany','#1D9053','#FFFFFF',3,2,'1988, 1993, 1994','1991, 2004'),
  ('Bayer Leverkusen','Germany','#E32221','#000000',1,2,'2024','1993, 2018'),
  ('Stuttgart','Germany','#E32219','#FFFFFF',2,2,'1992, 2007','1997, 2008'),
  ('Eintracht Frankfurt','Germany','#E1000F','#000000',1,2,'2018','1974, 2022'),
  ('Kaiserslautern','Germany','#D11919','#FFFFFF',1,0,'1991',null)
) as v(team_name,team_country,team_color,team_text_color,wins,runners_up,years_won,years_runner_up)
where t.name = 'DFL-Supercup'
on conflict (tournament_id, team_name) do update set
  wins=excluded.wins, runners_up=excluded.runners_up, years_won=excluded.years_won, years_runner_up=excluded.years_runner_up;

-- ====================================================================
-- ITALY
-- ====================================================================

-- Serie A
insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, v.team_name, v.team_country, v.team_color, v.team_text_color, v.wins, v.runners_up, v.years_won, v.years_runner_up
from tournaments t, (values
  ('Juventus','Italy','#000000','#FFFFFF',36,21,'1905, 1926, 1931, 1932, 1933, 1934, 1935, 1950, 1952, 1958, 1960, 1961, 1967, 1972, 1973, 1975, 1977, 1978, 1981, 1982, 1984, 1986, 1995, 1997, 1998, 2002, 2003, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020','1946, 1947, 1953, 1954, 1963, 1976, 1980, 1983, 1987, 1992, 1994, 1996, 2000, 2001, 2009, 2022'),
  ('Inter Milan','Italy','#0068A8','#FFFFFF',20,16,'1910, 1920, 1930, 1938, 1940, 1953, 1954, 1963, 1965, 1966, 1971, 1980, 1989, 2006, 2007, 2008, 2009, 2010, 2021, 2024','1933, 1935, 1941, 1950, 1951, 1961, 1964, 1967, 1970, 1993, 1998, 2003, 2011, 2020, 2023, 2025'),
  ('AC Milan','Italy','#FB090B','#000000',19,16,'1901, 1906, 1907, 1951, 1955, 1957, 1959, 1962, 1968, 1979, 1988, 1992, 1993, 1994, 1996, 1999, 2004, 2011, 2022','1902, 1960, 1961, 1965, 1969, 1971, 1972, 1973, 1990, 1991, 2005, 2012, 2013, 2021, 2023'),
  ('Genoa','Italy','#C8102E','#002855',9,8,'1898, 1899, 1900, 1902, 1903, 1904, 1915, 1923, 1924','1897, 1919, 1922, 1925, 1928, 1930, 1937, 1946'),
  ('Torino','Italy','#881F1E','#FFFFFF',7,8,'1928, 1943, 1946, 1947, 1948, 1949, 1976','1927, 1942, 1962, 1965, 1972, 1975, 1977, 1985'),
  ('Bologna','Italy','#1B2746','#D2122E',7,5,'1925, 1929, 1936, 1937, 1939, 1941, 1964','1921, 1924, 1932, 1984, 2002'),
  ('Napoli','Italy','#087FD5','#FFFFFF',3,8,'1987, 1990, 2023','1968, 1975, 1988, 1989, 2013, 2016, 2018, 2024'),
  ('Roma','Italy','#8E1B1F','#F3C04C',3,15,'1942, 1983, 2001','1931, 1936, 1981, 1984, 1986, 2002, 2004, 2008, 2010, 2014, 2015, 2017'),
  ('Lazio','Italy','#87CEEB','#FFFFFF',2,7,'1974, 2000','1913, 1914, 1923, 1995, 1999, 2000, 2023'),
  ('Fiorentina','Italy','#482E92','#FFFFFF',2,5,'1956, 1969','1957, 1958, 1959, 1960, 1999'),
  ('Hellas Verona','Italy','#004896','#FDBE11',1,0,'1985',null),
  ('Cagliari','Italy','#D21034','#003F87',1,0,'1970',null)
) as v(team_name,team_country,team_color,team_text_color,wins,runners_up,years_won,years_runner_up)
where t.name = 'Serie A'
on conflict (tournament_id, team_name) do update set
  wins=excluded.wins, runners_up=excluded.runners_up, years_won=excluded.years_won, years_runner_up=excluded.years_runner_up;

-- Serie B
insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, v.team_name, v.team_country, v.team_color, v.team_text_color, v.wins, v.runners_up, v.years_won, v.years_runner_up
from tournaments t, (values
  ('Juventus','Italy','#000000','#FFFFFF',1,0,'2007',null),
  ('Bologna','Italy','#1B2746','#D2122E',2,0,'2008, 2015',null),
  ('Bari','Italy','#DC0A0A','#FFFFFF',2,0,'2009, 2014',null),
  ('Lecce','Italy','#F8D217','#D22630',4,0,'2010, 2022, 2024, 2025',null),
  ('Atalanta','Italy','#1664B7','#000000',1,0,'2011',null),
  ('Pescara','Italy','#004B87','#FFFFFF',1,0,'2012',null),
  ('Sassuolo','Italy','#008057','#000000',2,0,'2013, 2025',null),
  ('Carpi','Italy','#8B0000','#FFFFFF',1,0,'2015',null),
  ('Cagliari','Italy','#D21034','#003F87',2,0,'2016, 2023',null),
  ('SPAL','Italy','#005BBB','#FFFFFF',1,0,'2017',null),
  ('Empoli','Italy','#0066B3','#FFFFFF',2,0,'2018, 2021',null),
  ('Brescia','Italy','#1D59AF','#FFFFFF',1,0,'2019',null),
  ('Benevento','Italy','#F9DC00','#D21034',1,0,'2020',null),
  ('Frosinone','Italy','#F7D800','#003A6B',1,0,'2023',null),
  ('Parma','Italy','#F7D800','#003A6B',1,0,'2024',null)
) as v(team_name,team_country,team_color,team_text_color,wins,runners_up,years_won,years_runner_up)
where t.name = 'Serie B'
on conflict (tournament_id, team_name) do update set
  wins=excluded.wins, runners_up=excluded.runners_up, years_won=excluded.years_won, years_runner_up=excluded.years_runner_up;

-- Coppa Italia
insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, v.team_name, v.team_country, v.team_color, v.team_text_color, v.wins, v.runners_up, v.years_won, v.years_runner_up
from tournaments t, (values
  ('Juventus','Italy','#000000','#FFFFFF',15,7,'1938, 1942, 1959, 1960, 1965, 1979, 1983, 1990, 1995, 2015, 2016, 2017, 2018, 2021, 2024','1972, 1973, 1992, 2002, 2004, 2012, 2020'),
  ('Roma','Italy','#8E1B1F','#F3C04C',9,8,'1964, 1969, 1980, 1981, 1984, 1986, 1991, 2007, 2008','1937, 1941, 1993, 2003, 2005, 2006, 2010, 2013'),
  ('Inter Milan','Italy','#0068A8','#FFFFFF',9,5,'1939, 1978, 1982, 2005, 2006, 2010, 2011, 2022, 2023','1959, 1965, 1977, 2007, 2008'),
  ('Lazio','Italy','#87CEEB','#FFFFFF',7,4,'1958, 1998, 2000, 2004, 2009, 2013, 2019','1961, 2015, 2017, 2024'),
  ('Napoli','Italy','#087FD5','#FFFFFF',6,6,'1962, 1976, 1987, 2012, 2014, 2020','1972, 1978, 1989, 1997, 2020, 2022'),
  ('AC Milan','Italy','#FB090B','#000000',5,8,'1967, 1972, 1973, 1977, 2003','1942, 1971, 1975, 1985, 1990, 1998, 2016, 2018'),
  ('Fiorentina','Italy','#482E92','#FFFFFF',6,6,'1940, 1961, 1966, 1975, 1996, 2001','1958, 1960, 2014, 2023, 2024, 2025'),
  ('Bologna','Italy','#1B2746','#D2122E',2,4,'1970, 1974','1998, 2000, 2003, 2025'),
  ('Torino','Italy','#881F1E','#FFFFFF',5,8,'1936, 1943, 1968, 1971, 1993','1938, 1964, 1980, 1981, 1988, 1998, 2000, 2011'),
  ('Parma','Italy','#F7D800','#003A6B',3,2,'1992, 1999, 2002','1995, 2001'),
  ('Atalanta','Italy','#1664B7','#000000',1,4,'1963','1987, 1996, 2019, 2021'),
  ('Vicenza','Italy','#D21034','#FFFFFF',1,0,'1997',null)
) as v(team_name,team_country,team_color,team_text_color,wins,runners_up,years_won,years_runner_up)
where t.name = 'Coppa Italia'
on conflict (tournament_id, team_name) do update set
  wins=excluded.wins, runners_up=excluded.runners_up, years_won=excluded.years_won, years_runner_up=excluded.years_runner_up;

-- Supercoppa Italiana
insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, v.team_name, v.team_country, v.team_color, v.team_text_color, v.wins, v.runners_up, v.years_won, v.years_runner_up
from tournaments t, (values
  ('Juventus','Italy','#000000','#FFFFFF',9,7,'1995, 1997, 2002, 2003, 2012, 2013, 2015, 2018, 2020','1990, 1998, 2005, 2014, 2016, 2017, 2021'),
  ('Inter Milan','Italy','#0068A8','#FFFFFF',8,3,'1989, 2005, 2006, 2008, 2010, 2021, 2022, 2024','2000, 2007, 2011'),
  ('AC Milan','Italy','#FB090B','#000000',7,4,'1988, 1992, 1993, 1994, 2004, 2011, 2016','1996, 1999, 2003, 2024'),
  ('Lazio','Italy','#87CEEB','#FFFFFF',5,2,'1998, 2000, 2009, 2017, 2019','2004, 2013'),
  ('Napoli','Italy','#087FD5','#FFFFFF',2,4,'1990, 2014','1987, 2012, 2020, 2023'),
  ('Roma','Italy','#8E1B1F','#F3C04C',2,5,'2001, 2007','1991, 2006, 2008, 2010, 2015'),
  ('Parma','Italy','#F7D800','#003A6B',1,3,'1999','1992, 1995, 2002'),
  ('Fiorentina','Italy','#482E92','#FFFFFF',1,0,'1996',null),
  ('Vicenza','Italy','#D21034','#FFFFFF',0,1,null,'1997')
) as v(team_name,team_country,team_color,team_text_color,wins,runners_up,years_won,years_runner_up)
where t.name = 'Supercoppa Italiana'
on conflict (tournament_id, team_name) do update set
  wins=excluded.wins, runners_up=excluded.runners_up, years_won=excluded.years_won, years_runner_up=excluded.years_runner_up;

-- ====================================================================
-- SPAIN
-- ====================================================================

-- La Liga
insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, v.team_name, v.team_country, v.team_color, v.team_text_color, v.wins, v.runners_up, v.years_won, v.years_runner_up
from tournaments t, (values
  ('Real Madrid','Spain','#FEBE10','#00529F',36,25,'1932, 1933, 1954, 1955, 1957, 1958, 1961, 1962, 1963, 1964, 1965, 1967, 1968, 1969, 1972, 1975, 1976, 1978, 1979, 1980, 1986, 1987, 1988, 1989, 1990, 1995, 1997, 2001, 2003, 2007, 2008, 2012, 2017, 2020, 2022, 2024','1935, 1942, 1945, 1959, 1960, 1966, 1973, 1974, 1977, 1981, 1983, 1985, 1992, 1993, 2000, 2004, 2005, 2006, 2009, 2010, 2013, 2015, 2016, 2019, 2023'),
  ('FC Barcelona','Spain','#A50044','#EDBB00',28,28,'1929, 1945, 1948, 1949, 1952, 1953, 1959, 1960, 1974, 1985, 1991, 1992, 1993, 1994, 1998, 1999, 2005, 2006, 2009, 2010, 2011, 2013, 2015, 2016, 2018, 2019, 2023, 2025','1930, 1954, 1955, 1956, 1962, 1964, 1967, 1968, 1971, 1973, 1976, 1977, 1978, 1982, 1984, 1986, 1987, 1988, 1989, 1997, 2000, 2003, 2004, 2007, 2008, 2012, 2014, 2017'),
  ('Atletico Madrid','Spain','#CB3524','#FFFFFF',11,10,'1940, 1941, 1950, 1951, 1966, 1970, 1973, 1977, 1996, 2014, 2021','1944, 1958, 1961, 1963, 1965, 1991, 1997, 2015, 2016, 2018'),
  ('Athletic Bilbao','Spain','#EE2523','#FFFFFF',8,7,'1930, 1931, 1934, 1936, 1943, 1956, 1983, 1984','1932, 1933, 1941, 1947, 1952, 1955, 1970'),
  ('Valencia','Spain','#FF7900','#000000',6,6,'1942, 1944, 1947, 1971, 2002, 2004','1948, 1949, 1953, 1972, 1990, 1996'),
  ('Real Sociedad','Spain','#003399','#FFFFFF',2,3,'1981, 1982','1980, 1988, 2003'),
  ('Deportivo La Coruna','Spain','#005CFF','#FFFFFF',1,5,'2000','1950, 1994, 1995, 2001, 2002'),
  ('Sevilla','Spain','#D7141A','#FFFFFF',1,4,'1946','1940, 1942, 1943, 1956'),
  ('Real Betis','Spain','#008B3F','#FFFFFF',1,0,'1935',null)
) as v(team_name,team_country,team_color,team_text_color,wins,runners_up,years_won,years_runner_up)
where t.name = 'La Liga'
on conflict (tournament_id, team_name) do update set
  wins=excluded.wins, runners_up=excluded.runners_up, years_won=excluded.years_won, years_runner_up=excluded.years_runner_up;

-- La Liga 2 (Segunda División)
insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, v.team_name, v.team_country, v.team_color, v.team_text_color, v.wins, v.runners_up, v.years_won, v.years_runner_up
from tournaments t, (values
  ('Real Madrid Castilla','Spain','#FEBE10','#00529F',1,0,'1984',null),
  ('Real Betis','Spain','#008B3F','#FFFFFF',4,2,'1932, 1942, 1958, 2015','1952, 1974'),
  ('Osasuna','Spain','#D91A21','#002856',2,2,'1953, 2019','1968, 2014'),
  ('Levante','Spain','#A51C30','#002856',2,2,'2004, 2017','2011, 2023'),
  ('Sporting Gijon','Spain','#D20022','#FFFFFF',1,2,'1977','2008, 2015'),
  ('Real Zaragoza','Spain','#004899','#FFFFFF',1,2,'1978','1951, 1990'),
  ('Rayo Vallecano','Spain','#E30613','#FFFFFF',1,0,'2018',null),
  ('Granada','Spain','#D21034','#FFFFFF',1,2,'2016','2019, 2023'),
  ('Mallorca','Spain','#CD1719','#FBD12A',1,1,'2019','2015'),
  ('Cadiz','Spain','#FFCB05','#003F7F',1,0,'2020',null),
  ('Espanyol','Spain','#005BBB','#FFCB05',1,0,'2021',null),
  ('Girona','Spain','#CD2534','#FFFFFF',0,1,null,'2022'),
  ('Almeria','Spain','#D30007','#FFFFFF',1,0,'2022',null),
  ('Leganes','Spain','#002E62','#FFFFFF',1,0,'2024',null),
  ('Elche','Spain','#008857','#FFFFFF',1,0,'2025',null)
) as v(team_name,team_country,team_color,team_text_color,wins,runners_up,years_won,years_runner_up)
where t.name = 'La Liga 2'
on conflict (tournament_id, team_name) do update set
  wins=excluded.wins, runners_up=excluded.runners_up, years_won=excluded.years_won, years_runner_up=excluded.years_runner_up;

-- Copa del Rey
insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, v.team_name, v.team_country, v.team_color, v.team_text_color, v.wins, v.runners_up, v.years_won, v.years_runner_up
from tournaments t, (values
  ('FC Barcelona','Spain','#A50044','#EDBB00',32,11,'1910, 1912, 1913, 1920, 1922, 1925, 1926, 1928, 1942, 1951, 1952, 1953, 1957, 1959, 1963, 1968, 1971, 1978, 1981, 1983, 1988, 1990, 1997, 1998, 2009, 2012, 2015, 2016, 2017, 2018, 2021, 2025','1902, 1919, 1932, 1936, 1954, 1974, 1984, 1986, 1996, 2011, 2014'),
  ('Athletic Bilbao','Spain','#EE2523','#FFFFFF',24,15,'1903, 1904, 1910, 1911, 1914, 1915, 1916, 1921, 1923, 1930, 1931, 1932, 1933, 1943, 1944, 1945, 1950, 1955, 1956, 1958, 1969, 1973, 1984, 2024','1913, 1942, 1949, 1953, 1966, 1967, 1977, 1985, 2009, 2012, 2015, 2020, 2021'),
  ('Real Madrid','Spain','#FEBE10','#00529F',20,20,'1905, 1906, 1907, 1908, 1917, 1934, 1936, 1946, 1947, 1962, 1970, 1974, 1975, 1980, 1982, 1989, 1993, 2011, 2014, 2023','1903, 1916, 1918, 1930, 1940, 1943, 1958, 1960, 1961, 1968, 1979, 1983, 1990, 1992, 2002, 2004, 2013'),
  ('Atletico Madrid','Spain','#CB3524','#FFFFFF',10,10,'1960, 1961, 1965, 1972, 1976, 1985, 1991, 1992, 1996, 2013','1921, 1926, 1964, 1975, 1987, 1999, 2000, 2010'),
  ('Valencia','Spain','#FF7900','#000000',8,10,'1941, 1949, 1954, 1967, 1979, 1999, 2008, 2019','1934, 1944, 1945, 1946, 1952, 1970, 1971, 1972, 1990, 1995'),
  ('Real Zaragoza','Spain','#004899','#FFFFFF',6,5,'1964, 1966, 1986, 1994, 2001, 2004','1963, 1965, 1976, 1993, 2006'),
  ('Sevilla','Spain','#D7141A','#FFFFFF',5,3,'1935, 1939, 1948, 2007, 2010','1955, 1962, 2008'),
  ('Real Union','Spain','#D21034','#FFFFFF',4,0,'1913, 1918, 1924, 1927',null),
  ('Real Betis','Spain','#008B3F','#FFFFFF',3,3,'1977, 2005, 2022','1931, 1997, 2019'),
  ('Deportivo La Coruna','Spain','#005CFF','#FFFFFF',2,4,'1995, 2002','1932, 1994, 2000, 2008'),
  ('Mallorca','Spain','#CD1719','#FBD12A',1,3,'2003','1991, 1998, 2024')
) as v(team_name,team_country,team_color,team_text_color,wins,runners_up,years_won,years_runner_up)
where t.name = 'Copa del Rey'
on conflict (tournament_id, team_name) do update set
  wins=excluded.wins, runners_up=excluded.runners_up, years_won=excluded.years_won, years_runner_up=excluded.years_runner_up;

-- Supercopa de Espana
insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, v.team_name, v.team_country, v.team_color, v.team_text_color, v.wins, v.runners_up, v.years_won, v.years_runner_up
from tournaments t, (values
  ('FC Barcelona','Spain','#A50044','#EDBB00',14,10,'1983, 1991, 1992, 1994, 1996, 2005, 2006, 2009, 2010, 2011, 2013, 2016, 2018, 2023','1985, 1988, 1990, 1993, 1997, 1998, 1999, 2012, 2015, 2017'),
  ('Real Madrid','Spain','#FEBE10','#00529F',13,8,'1988, 1989, 1990, 1993, 1997, 2001, 2003, 2008, 2012, 2017, 2020, 2022, 2024','1982, 1987, 1992, 1994, 1996, 2007, 2011, 2014'),
  ('Deportivo La Coruna','Spain','#005CFF','#FFFFFF',3,2,'1995, 2000, 2002','1994, 2001'),
  ('Athletic Bilbao','Spain','#EE2523','#FFFFFF',3,2,'1984, 2015, 2021','2009, 2024'),
  ('Atletico Madrid','Spain','#CB3524','#FFFFFF',2,2,'1985, 2014','2013, 2019'),
  ('Valencia','Spain','#FF7900','#000000',1,1,'1999','2008'),
  ('Mallorca','Spain','#CD1719','#FBD12A',1,0,'1998',null),
  ('Real Zaragoza','Spain','#004899','#FFFFFF',1,2,'2004','1986, 2001'),
  ('Sevilla','Spain','#D7141A','#FFFFFF',1,1,'2007','2010'),
  ('Real Sociedad','Spain','#003399','#FFFFFF',0,1,null,'1982')
) as v(team_name,team_country,team_color,team_text_color,wins,runners_up,years_won,years_runner_up)
where t.name = 'Supercopa de Espana'
on conflict (tournament_id, team_name) do update set
  wins=excluded.wins, runners_up=excluded.runners_up, years_won=excluded.years_won, years_runner_up=excluded.years_runner_up;

-- ====================================================================
-- INTERNATIONAL / CLUB
-- ====================================================================

-- UEFA Champions League (includes European Cup era)
insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, v.team_name, v.team_country, v.team_color, v.team_text_color, v.wins, v.runners_up, v.years_won, v.years_runner_up
from tournaments t, (values
  ('Real Madrid','Spain','#FEBE10','#00529F',15,3,'1956, 1957, 1958, 1959, 1960, 1966, 1998, 2000, 2002, 2014, 2016, 2017, 2018, 2022, 2024','1962, 1964, 1981'),
  ('AC Milan','Italy','#FB090B','#000000',7,4,'1963, 1969, 1989, 1990, 1994, 2003, 2007','1958, 1993, 1995, 2005'),
  ('Liverpool','England','#C8102E','#F6EB61',6,4,'1977, 1978, 1981, 1984, 2005, 2019','1985, 2007, 2018, 2022'),
  ('Bayern Munich','Germany','#DC052D','#FFFFFF',6,5,'1974, 1975, 1976, 2001, 2013, 2020','1982, 1987, 1999, 2010, 2012'),
  ('FC Barcelona','Spain','#A50044','#EDBB00',5,3,'1992, 2006, 2009, 2011, 2015','1961, 1986, 1994'),
  ('Ajax','Netherlands','#D2122E','#FFFFFF',4,2,'1971, 1972, 1973, 1995','1969, 1996'),
  ('Manchester United','England','#DA291C','#FBE122',3,2,'1968, 1999, 2008','2009, 2011'),
  ('Inter Milan','Italy','#0068A8','#FFFFFF',3,3,'1964, 1965, 2010','1967, 1972, 2023'),
  ('Benfica','Portugal','#E30613','#FFFFFF',2,5,'1961, 1962','1963, 1965, 1968, 1988, 1990'),
  ('Chelsea','England','#034694','#FFFFFF',2,1,'2012, 2021','2008'),
  ('Juventus','Italy','#000000','#FFFFFF',2,7,'1985, 1996','1973, 1983, 1997, 1998, 2003, 2015, 2017'),
  ('Nottingham Forest','England','#DD0000','#FFFFFF',2,0,'1979, 1980',null),
  ('Porto','Portugal','#003DA5','#FFFFFF',2,0,'1987, 2004',null),
  ('Borussia Dortmund','Germany','#FDE100','#000000',1,2,'1997','2013, 2024'),
  ('Celtic','Scotland','#008751','#FFFFFF',1,1,'1967','1970'),
  ('Hamburger SV','Germany','#0F3F8C','#FFFFFF',1,1,'1983','1980'),
  ('Steaua Bucuresti','Romania','#003F87','#FFCB05',1,1,'1986','1989'),
  ('Red Star Belgrade','Serbia','#D81A1A','#FFFFFF',1,0,'1991',null),
  ('Marseille','France','#27B2CB','#FFFFFF',1,1,'1993','1991'),
  ('Feyenoord','Netherlands','#CF102D','#FFFFFF',1,0,'1970',null),
  ('Aston Villa','England','#670E36','#95BFE5',1,0,'1982',null),
  ('PSV Eindhoven','Netherlands','#ED1C24','#FFFFFF',1,0,'1988',null),
  ('Paris Saint-Germain','France','#004170','#ED1C24',1,1,'2025','2020'),
  ('Atletico Madrid','Spain','#CB3524','#FFFFFF',0,3,null,'1974, 2014, 2016'),
  ('Manchester City','England','#6CABDD','#FFFFFF',1,1,'2023','2021'),
  ('Tottenham','England','#132257','#FFFFFF',0,1,null,'2019')
) as v(team_name,team_country,team_color,team_text_color,wins,runners_up,years_won,years_runner_up)
where t.name = 'UEFA Champions League'
on conflict (tournament_id, team_name) do update set
  wins=excluded.wins, runners_up=excluded.runners_up, years_won=excluded.years_won, years_runner_up=excluded.years_runner_up;

-- UEFA Europa League (post-2009 rebrand, plus some UEFA Cup legacy)
insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, v.team_name, v.team_country, v.team_color, v.team_text_color, v.wins, v.runners_up, v.years_won, v.years_runner_up
from tournaments t, (values
  ('Sevilla','Spain','#D7141A','#FFFFFF',7,0,'2006, 2007, 2014, 2015, 2016, 2020, 2023',null),
  ('Inter Milan','Italy','#0068A8','#FFFFFF',3,0,'1991, 1994, 1998',null),
  ('Juventus','Italy','#000000','#FFFFFF',3,1,'1977, 1990, 1993','1995'),
  ('Liverpool','England','#C8102E','#F6EB61',3,1,'1973, 1976, 2001','2016'),
  ('Atletico Madrid','Spain','#CB3524','#FFFFFF',3,0,'2010, 2012, 2018',null),
  ('Chelsea','England','#034694','#FFFFFF',2,0,'2013, 2019',null),
  ('Porto','Portugal','#003DA5','#FFFFFF',2,0,'2003, 2011',null),
  ('Tottenham','England','#132257','#FFFFFF',3,0,'1972, 1984, 2025',null),
  ('Feyenoord','Netherlands','#CF102D','#FFFFFF',2,0,'1974, 2002',null),
  ('Borussia Monchengladbach','Germany','#000000','#FFFFFF',2,2,'1975, 1979','1973, 1980'),
  ('Ajax','Netherlands','#D2122E','#FFFFFF',1,2,'1992','1991, 2017'),
  ('Bayern Munich','Germany','#DC052D','#FFFFFF',1,0,'1996',null),
  ('Schalke 04','Germany','#004D9D','#FFFFFF',1,0,'1997',null),
  ('Parma','Italy','#F7D800','#003A6B',2,0,'1995, 1999',null),
  ('Galatasaray','Turkey','#FFB400','#A90432',1,0,'2000',null),
  ('CSKA Moscow','Russia','#D81A1A','#FFFFFF',1,0,'2005',null),
  ('Zenit St. Petersburg','Russia','#1B5CA0','#FFFFFF',1,0,'2008',null),
  ('Shakhtar Donetsk','Ukraine','#F58220','#000000',1,0,'2009',null),
  ('Eintracht Frankfurt','Germany','#E1000F','#000000',1,0,'2022',null),
  ('Villarreal','Spain','#FFE667','#005187',1,0,'2021',null),
  ('Manchester United','England','#DA291C','#FBE122',1,1,'2017','2021'),
  ('Atalanta','Italy','#1664B7','#000000',1,0,'2024',null),
  ('Borussia Dortmund','Germany','#FDE100','#000000',0,1,null,'2002'),
  ('Marseille','France','#27B2CB','#FFFFFF',0,3,null,'1999, 2004, 2018'),
  ('Werder Bremen','Germany','#1D9053','#FFFFFF',0,1,null,'2009'),
  ('Fulham','England','#FFFFFF','#000000',0,1,null,'2010'),
  ('Benfica','Portugal','#E30613','#FFFFFF',0,2,null,'2013, 2014'),
  ('Dnipro','Ukraine','#005BBB','#FFCB05',0,1,null,'2015'),
  ('Arsenal','England','#EF0107','#FFFFFF',0,1,null,'2019'),
  ('Roma','Italy','#8E1B1F','#F3C04C',0,1,null,'2023'),
  ('Bayer Leverkusen','Germany','#E32221','#000000',0,1,null,'2024')
) as v(team_name,team_country,team_color,team_text_color,wins,runners_up,years_won,years_runner_up)
where t.name = 'UEFA Europa League'
on conflict (tournament_id, team_name) do update set
  wins=excluded.wins, runners_up=excluded.runners_up, years_won=excluded.years_won, years_runner_up=excluded.years_runner_up;

-- UEFA Conference League (since 2021-22)
insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, v.team_name, v.team_country, v.team_color, v.team_text_color, v.wins, v.runners_up, v.years_won, v.years_runner_up
from tournaments t, (values
  ('Roma','Italy','#8E1B1F','#F3C04C',1,0,'2022',null),
  ('West Ham','England','#7A263A','#1BB1E7',1,0,'2023',null),
  ('Olympiacos','Greece','#D7141A','#FFFFFF',1,0,'2024',null),
  ('Chelsea','England','#034694','#FFFFFF',1,0,'2025',null),
  ('Feyenoord','Netherlands','#CF102D','#FFFFFF',0,1,null,'2022'),
  ('Fiorentina','Italy','#482E92','#FFFFFF',0,2,null,'2023, 2024'),
  ('Real Betis','Spain','#008B3F','#FFFFFF',0,1,null,'2025')
) as v(team_name,team_country,team_color,team_text_color,wins,runners_up,years_won,years_runner_up)
where t.name = 'UEFA Conference League'
on conflict (tournament_id, team_name) do update set
  wins=excluded.wins, runners_up=excluded.runners_up, years_won=excluded.years_won, years_runner_up=excluded.years_runner_up;

-- UEFA Super Cup
insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, v.team_name, v.team_country, v.team_color, v.team_text_color, v.wins, v.runners_up, v.years_won, v.years_runner_up
from tournaments t, (values
  ('Real Madrid','Spain','#FEBE10','#00529F',6,1,'2002, 2014, 2016, 2017, 2022, 2024','1998'),
  ('AC Milan','Italy','#FB090B','#000000',5,2,'1989, 1990, 1994, 2003, 2007','1973, 1993'),
  ('FC Barcelona','Spain','#A50044','#EDBB00',5,4,'1992, 1997, 2009, 2011, 2015','1979, 1982, 1989, 2006'),
  ('Atletico Madrid','Spain','#CB3524','#FFFFFF',3,0,'2010, 2012, 2018',null),
  ('Liverpool','England','#C8102E','#F6EB61',4,2,'1977, 2001, 2005, 2019','1978, 1984'),
  ('Ajax','Netherlands','#D2122E','#FFFFFF',3,1,'1972, 1973, 1995','1987'),
  ('Bayern Munich','Germany','#DC052D','#FFFFFF',2,4,'2013, 2020','1975, 1976, 1996, 2001'),
  ('Chelsea','England','#034694','#FFFFFF',1,3,'2021','1998, 2012, 2013'),
  ('Porto','Portugal','#003DA5','#FFFFFF',1,2,'1987','2003, 2011'),
  ('Juventus','Italy','#000000','#FFFFFF',2,3,'1984, 1996','1973, 1985, 2015'),
  ('Manchester City','England','#6CABDD','#FFFFFF',1,1,'2023','2021'),
  ('Paris Saint-Germain','France','#004170','#ED1C24',1,0,'2025',null),
  ('Tottenham','England','#132257','#FFFFFF',0,1,null,'2025')
) as v(team_name,team_country,team_color,team_text_color,wins,runners_up,years_won,years_runner_up)
where t.name = 'UEFA Super Cup'
on conflict (tournament_id, team_name) do update set
  wins=excluded.wins, runners_up=excluded.runners_up, years_won=excluded.years_won, years_runner_up=excluded.years_runner_up;

-- ====================================================================
-- NATIONAL TEAMS
-- ====================================================================

-- FIFA World Cup
insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, v.team_name, v.team_country, v.team_color, v.team_text_color, v.wins, v.runners_up, v.years_won, v.years_runner_up
from tournaments t, (values
  ('Brazil','Brazil','#009C3B','#FFDF00',5,2,'1958, 1962, 1970, 1994, 2002','1950, 1998'),
  ('Germany','Germany','#000000','#DD0000',4,4,'1954, 1974, 1990, 2014','1966, 1982, 1986, 2002'),
  ('Italy','Italy','#0066CC','#FFFFFF',4,2,'1934, 1938, 1982, 2006','1970, 1994'),
  ('Argentina','Argentina','#75AADB','#FFFFFF',3,3,'1978, 1986, 2022','1930, 1990, 2014'),
  ('France','France','#002395','#FFFFFF',2,2,'1998, 2018','2006, 2022'),
  ('Uruguay','Uruguay','#5CBFEB','#FFFFFF',2,0,'1930, 1950',null),
  ('England','England','#FFFFFF','#CE1126',1,0,'1966',null),
  ('Spain','Spain','#AA151B','#F1BF00',1,0,'2010',null),
  ('Netherlands','Netherlands','#F36C21','#FFFFFF',0,3,null,'1974, 1978, 2010'),
  ('Hungary','Hungary','#CE2939','#FFFFFF',0,2,null,'1938, 1954'),
  ('Czechoslovakia','Czechoslovakia','#11457E','#FFFFFF',0,2,null,'1934, 1962'),
  ('Sweden','Sweden','#005CFF','#FECC00',0,1,null,'1958'),
  ('Croatia','Croatia','#D21034','#FFFFFF',0,1,null,'2018')
) as v(team_name,team_country,team_color,team_text_color,wins,runners_up,years_won,years_runner_up)
where t.name = 'FIFA World Cup'
on conflict (tournament_id, team_name) do update set
  wins=excluded.wins, runners_up=excluded.runners_up, years_won=excluded.years_won, years_runner_up=excluded.years_runner_up;

-- UEFA Euro
insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, v.team_name, v.team_country, v.team_color, v.team_text_color, v.wins, v.runners_up, v.years_won, v.years_runner_up
from tournaments t, (values
  ('Spain','Spain','#AA151B','#F1BF00',4,0,'1964, 2008, 2012, 2024',null),
  ('Germany','Germany','#000000','#DD0000',3,3,'1972, 1980, 1996','1976, 1992, 2008'),
  ('Italy','Italy','#0066CC','#FFFFFF',2,2,'1968, 2020','2000, 2012'),
  ('France','France','#002395','#FFFFFF',2,1,'1984, 2000','2016'),
  ('Portugal','Portugal','#006600','#DA291C',1,1,'2016','2004'),
  ('Greece','Greece','#0D5EAF','#FFFFFF',1,0,'2004',null),
  ('Denmark','Denmark','#C8102E','#FFFFFF',1,0,'1992',null),
  ('Netherlands','Netherlands','#F36C21','#FFFFFF',1,0,'1988',null),
  ('Czechoslovakia','Czechoslovakia','#11457E','#FFFFFF',1,1,'1976','1996'),
  ('Soviet Union','USSR','#CC0000','#FFCC00',1,3,'1960','1964, 1972, 1988'),
  ('England','England','#FFFFFF','#CE1126',0,2,null,'2020, 2024'),
  ('Yugoslavia','Yugoslavia','#005CFF','#FFFFFF',0,2,null,'1960, 1968'),
  ('Belgium','Belgium','#000000','#FDDA24',0,1,null,'1980')
) as v(team_name,team_country,team_color,team_text_color,wins,runners_up,years_won,years_runner_up)
where t.name = 'UEFA Euro'
on conflict (tournament_id, team_name) do update set
  wins=excluded.wins, runners_up=excluded.runners_up, years_won=excluded.years_won, years_runner_up=excluded.years_runner_up;
