-- 013: Dedupe top scorers where same player appears under multiple name variants
-- Strategy: rank by (tournament, year, canonical identity) by goals desc, delete losers,
-- then rename remaining alias names to canonical.

create temporary table _player_aliases (alt text, canonical text) on commit drop;
insert into _player_aliases (alt, canonical) values
  -- Messi
  ('Messi', 'Lionel Messi'),
  ('L. Messi', 'Lionel Messi'),
  ('Leo Messi', 'Lionel Messi'),
  ('Lionel Andres Messi', 'Lionel Messi'),
  -- Cristiano Ronaldo
  ('CR7', 'Cristiano Ronaldo'),
  ('C. Ronaldo', 'Cristiano Ronaldo'),
  ('Cristiano', 'Cristiano Ronaldo'),
  ('Ronaldo CR7', 'Cristiano Ronaldo'),
  ('Cristiano Ronaldo Jr', 'Cristiano Ronaldo'),
  -- Zlatan
  ('Zlatan', 'Zlatan Ibrahimovic'),
  ('Ibra', 'Zlatan Ibrahimovic'),
  ('Ibrahimovic', 'Zlatan Ibrahimovic'),
  ('Z. Ibrahimovic', 'Zlatan Ibrahimovic'),
  -- Salah
  ('Salah', 'Mohamed Salah'),
  ('Mo Salah', 'Mohamed Salah'),
  ('M. Salah', 'Mohamed Salah'),
  -- Lewandowski
  ('Lewandowski', 'Robert Lewandowski'),
  ('Lewa', 'Robert Lewandowski'),
  ('R. Lewandowski', 'Robert Lewandowski'),
  -- Haaland
  ('Haaland', 'Erling Haaland'),
  ('E. Haaland', 'Erling Haaland'),
  ('Erling Haland', 'Erling Haaland'),
  ('Erling Braut Haaland', 'Erling Haaland'),
  -- Kylian Mbappe
  ('Mbappe', 'Kylian Mbappe'),
  ('K. Mbappe', 'Kylian Mbappe'),
  ('Kylian Mbappé', 'Kylian Mbappe'),
  ('Mbappé', 'Kylian Mbappe'),
  -- Harry Kane
  ('Kane', 'Harry Kane'),
  ('H. Kane', 'Harry Kane'),
  -- Benzema
  ('Benzema', 'Karim Benzema'),
  ('K. Benzema', 'Karim Benzema'),
  -- Neymar
  ('Neymar Jr', 'Neymar'),
  ('Neymar Jr.', 'Neymar'),
  ('Ney', 'Neymar'),
  -- Historical greats
  ('Henry', 'Thierry Henry'),
  ('T. Henry', 'Thierry Henry'),
  ('Van Nistelrooy', 'Ruud van Nistelrooy'),
  ('R. van Nistelrooy', 'Ruud van Nistelrooy'),
  ('Van Nistelrooij', 'Ruud van Nistelrooy'),
  ('Drogba', 'Didier Drogba'),
  ('D. Drogba', 'Didier Drogba'),
  ('Aubameyang', 'Pierre-Emerick Aubameyang'),
  ('PEA', 'Pierre-Emerick Aubameyang'),
  ('P-E. Aubameyang', 'Pierre-Emerick Aubameyang'),
  ('Cavani', 'Edinson Cavani'),
  ('E. Cavani', 'Edinson Cavani'),
  ('El Matador', 'Edinson Cavani'),
  ('Shevchenko', 'Andriy Shevchenko'),
  ('A. Shevchenko', 'Andriy Shevchenko'),
  ('Sheva', 'Andriy Shevchenko'),
  ('Luis Suarez', 'Luis Suarez'),
  ('L. Suarez', 'Luis Suarez'),
  ('Luis Suárez', 'Luis Suarez'),
  ('Suarez', 'Luis Suarez'),
  ('Son', 'Son Heung-min'),
  ('Heung-Min Son', 'Son Heung-min'),
  ('Son Heung Min', 'Son Heung-min'),
  -- Italian league
  ('Immobile', 'Ciro Immobile'),
  ('C. Immobile', 'Ciro Immobile'),
  ('Icardi', 'Mauro Icardi'),
  ('M. Icardi', 'Mauro Icardi'),
  ('Higuain', 'Gonzalo Higuain'),
  ('G. Higuain', 'Gonzalo Higuain'),
  ('Higuaín', 'Gonzalo Higuain'),
  ('Gonzalo Higuaín', 'Gonzalo Higuain'),
  ('El Pipita', 'Gonzalo Higuain'),
  ('Di Natale', 'Antonio Di Natale'),
  ('A. Di Natale', 'Antonio Di Natale'),
  ('Totti', 'Francesco Totti'),
  ('F. Totti', 'Francesco Totti'),
  ('Il Capitano', 'Francesco Totti'),
  ('Toni', 'Luca Toni'),
  ('L. Toni', 'Luca Toni'),
  ('Del Piero', 'Alessandro Del Piero'),
  ('A. Del Piero', 'Alessandro Del Piero'),
  ('Pinturicchio', 'Alessandro Del Piero'),
  ('Trezeguet', 'David Trezeguet'),
  ('D. Trezeguet', 'David Trezeguet'),
  ('Vieri', 'Christian Vieri'),
  ('C. Vieri', 'Christian Vieri'),
  ('Bobo Vieri', 'Christian Vieri'),
  ('Crespo', 'Hernan Crespo'),
  ('H. Crespo', 'Hernan Crespo'),
  ('Hernán Crespo', 'Hernan Crespo'),
  ('Dzeko', 'Edin Dzeko'),
  ('E. Dzeko', 'Edin Dzeko'),
  ('Edin Džeko', 'Edin Dzeko'),
  ('Osimhen', 'Victor Osimhen'),
  ('V. Osimhen', 'Victor Osimhen'),
  ('Quagliarella', 'Fabio Quagliarella'),
  ('F. Quagliarella', 'Fabio Quagliarella'),
  ('Lautaro', 'Lautaro Martinez'),
  ('L. Martinez', 'Lautaro Martinez'),
  ('Lautaro Martínez', 'Lautaro Martinez'),
  -- Spanish league
  ('Diego Forlán', 'Diego Forlan'),
  ('Forlan', 'Diego Forlan'),
  ('Forlán', 'Diego Forlan'),
  ('D. Forlan', 'Diego Forlan'),
  ('Raúl', 'Raul'),
  ('Raul Gonzalez', 'Raul'),
  ('Raúl González', 'Raul'),
  ('Diego Tristán', 'Diego Tristan'),
  ('D. Tristan', 'Diego Tristan'),
  ('Guiza', 'Daniel Guiza'),
  ('D. Guiza', 'Daniel Guiza'),
  ('Güiza', 'Daniel Guiza'),
  ('Daniel Güiza', 'Daniel Guiza'),
  ('Makaay', 'Roy Makaay'),
  ('R. Makaay', 'Roy Makaay'),
  ('Hasselbaink', 'Jimmy Floyd Hasselbaink'),
  ('J. Hasselbaink', 'Jimmy Floyd Hasselbaink'),
  ('Jimmy Hasselbaink', 'Jimmy Floyd Hasselbaink'),
  ('Van Persie', 'Robin van Persie'),
  ('R. van Persie', 'Robin van Persie'),
  ('RvP', 'Robin van Persie'),
  ('Berbatov', 'Dimitar Berbatov'),
  ('D. Berbatov', 'Dimitar Berbatov'),
  ('Anelka', 'Nicolas Anelka'),
  ('N. Anelka', 'Nicolas Anelka'),
  ('Nico Anelka', 'Nicolas Anelka'),
  ('Vardy', 'Jamie Vardy'),
  ('J. Vardy', 'Jamie Vardy'),
  ('Aguero', 'Sergio Aguero'),
  ('Agüero', 'Sergio Aguero'),
  ('Kun Aguero', 'Sergio Aguero'),
  ('S. Aguero', 'Sergio Aguero'),
  ('Sergio Agüero', 'Sergio Aguero'),
  -- French league
  ('Cisse', 'Djibril Cisse'),
  ('D. Cisse', 'Djibril Cisse'),
  ('Djibril Cissé', 'Djibril Cisse'),
  ('Pedro Pauleta', 'Pauleta'),
  ('P. Pauleta', 'Pauleta'),
  ('Lacazette', 'Alexandre Lacazette'),
  ('A. Lacazette', 'Alexandre Lacazette'),
  ('Giroud', 'Olivier Giroud'),
  ('O. Giroud', 'Olivier Giroud'),
  ('Niang', 'Mamadou Niang'),
  ('M. Niang', 'Mamadou Niang'),
  ('Sow', 'Moussa Sow'),
  ('M. Sow', 'Moussa Sow'),
  ('Gignac', 'Andre-Pierre Gignac'),
  ('A-P. Gignac', 'Andre-Pierre Gignac'),
  ('André-Pierre Gignac', 'Andre-Pierre Gignac'),
  ('Nonda', 'Shabani Nonda'),
  ('S. Nonda', 'Shabani Nonda'),
  ('Frei', 'Alexander Frei'),
  ('A. Frei', 'Alexander Frei'),
  ('Sonny Anderson', 'Sonny Anderson'),
  ('Anderson Sonny', 'Sonny Anderson'),
  ('Dembele', 'Ousmane Dembele'),
  ('O. Dembele', 'Ousmane Dembele'),
  ('Dembélé', 'Ousmane Dembele'),
  ('Ousmane Dembélé', 'Ousmane Dembele'),
  ('Ben Yedder', 'Wissam Ben Yedder'),
  ('W. Ben Yedder', 'Wissam Ben Yedder'),
  -- German league
  ('Toni Luca', 'Luca Toni'),
  ('Klose', 'Miroslav Klose'),
  ('M. Klose', 'Miroslav Klose'),
  ('Gomez', 'Mario Gomez'),
  ('M. Gomez', 'Mario Gomez'),
  ('Mario Gómez', 'Mario Gomez'),
  ('Huntelaar', 'Klaas-Jan Huntelaar'),
  ('K-J Huntelaar', 'Klaas-Jan Huntelaar'),
  ('Klaas Jan Huntelaar', 'Klaas-Jan Huntelaar'),
  ('Kiessling', 'Stefan Kiessling'),
  ('S. Kiessling', 'Stefan Kiessling'),
  ('Kießling', 'Stefan Kiessling'),
  ('Stefan Kießling', 'Stefan Kiessling'),
  ('Meier', 'Alexander Meier'),
  ('A. Meier', 'Alexander Meier'),
  ('Amoroso', 'Marcio Amoroso'),
  ('M. Amoroso', 'Marcio Amoroso'),
  ('Márcio Amoroso', 'Marcio Amoroso'),
  ('Mintal', 'Marek Mintal'),
  ('M. Mintal', 'Marek Mintal'),
  ('Marek Mintál', 'Marek Mintal'),
  ('Gekas', 'Theofanis Gekas'),
  ('T. Gekas', 'Theofanis Gekas'),
  ('Ailton', 'Ailton'),
  ('Fullkrug', 'Niklas Fullkrug'),
  ('Niklas Füllkrug', 'Niklas Fullkrug'),
  -- UCL
  ('Kaká', 'Kaka'),
  ('R. Kaka', 'Kaka'),
  ('Ricardo Kaka', 'Kaka'),
  ('Raphinha', 'Raphinha'),
  ('Raphael Dias Belloli', 'Raphinha'),
  -- UEL/UECL
  ('Falcao', 'Falcao'),
  ('Radamel Falcao', 'Falcao'),
  ('R. Falcao', 'Falcao'),
  ('Boniface', 'Victor Boniface'),
  ('V. Boniface', 'Victor Boniface'),
  ('El Kaabi', 'Ayoub El Kaabi'),
  ('A. El Kaabi', 'Ayoub El Kaabi'),
  ('Pizzi', 'Pizzi'),
  ('Luis Pizzi', 'Pizzi'),
  ('Abraham', 'Tammy Abraham'),
  ('T. Abraham', 'Tammy Abraham'),
  ('Cardozo', 'Oscar Cardozo'),
  ('O. Cardozo', 'Oscar Cardozo'),
  ('Óscar Cardozo', 'Oscar Cardozo'),
  ('Rashford', 'Marcus Rashford'),
  ('M. Rashford', 'Marcus Rashford'),
  ('Fernandes', 'Bruno Fernandes'),
  ('B. Fernandes', 'Bruno Fernandes'),
  ('Gimenez', 'Santiago Gimenez'),
  ('S. Gimenez', 'Santiago Gimenez'),
  ('Santi Gimenez', 'Santiago Gimenez'),
  ('Santiago Giménez', 'Santiago Gimenez'),
  ('Lukaku', 'Romelu Lukaku'),
  ('R. Lukaku', 'Romelu Lukaku'),
  ('Big Rom', 'Romelu Lukaku'),
  ('Aduriz', 'Aritz Aduriz'),
  ('A. Aduriz', 'Aritz Aduriz'),
  ('Dovbyk', 'Artem Dovbyk'),
  ('A. Dovbyk', 'Artem Dovbyk'),
  ('Retegui', 'Mateo Retegui'),
  ('M. Retegui', 'Mateo Retegui'),
  ('Mateo Retegui', 'Mateo Retegui')
;

-- Step 1: Within each (tournament, year, canonical identity), keep only the row with max goals
with family as (
  select
    s.id,
    s.tournament_id,
    s.year,
    lower(trim(coalesce(a.canonical, s.player_name))) as canon_key,
    coalesce(s.goals, 0) as score
  from top_scorers s
  left join _player_aliases a on lower(trim(s.player_name)) = lower(trim(a.alt))
),
ranked as (
  select id, row_number() over (
    partition by tournament_id, year, canon_key
    order by score desc, id asc
  ) as rn
  from family
)
delete from top_scorers where id in (select id from ranked where rn > 1);

-- Step 2: Rename remaining alias rows to canonical names
update top_scorers s
set player_name = a.canonical
from _player_aliases a
where lower(trim(s.player_name)) = lower(trim(a.alt));

-- Step 3: Final whitespace/case dedupe pass
with ranked2 as (
  select id, row_number() over (
    partition by tournament_id, year, lower(regexp_replace(player_name, '\s+', ' ', 'g'))
    order by coalesce(goals, 0) desc, id asc
  ) as rn
  from top_scorers
)
delete from top_scorers where id in (select id from ranked2 where rn > 1);
