-- 017: UEFA Super Cup — mover al tope de International + 2026 PSG venció Aston Villa + 2027 Crystal Palace venció Barcelona

-- Mover sort_order para que aparezca junto a UCL/UEL/UECL
update tournaments
set sort_order = 4
where name = 'UEFA Super Cup';

-- Insertarlo si no existe
insert into tournaments (name, country, has_top_scorer, color, text_color, sort_order)
select 'UEFA Super Cup', null, false, '#1e3a8a', '#ffffff', 4
where not exists (select 1 from tournaments where name = 'UEFA Super Cup');

-- 2026 Super Cup: PSG venció a Aston Villa (ya estaba en migración 014, por si no se corrió)
insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, 'Paris Saint-Germain', 'France', '#004170', '#ED1C24', 1, 0, '2026', null
from tournaments t where t.name = 'UEFA Super Cup'
on conflict (tournament_id, team_name) do update set
  wins = case when champions.years_won is null or champions.years_won !~ '\m2026\M'
              then champions.wins + 1 else champions.wins end,
  years_won = case when champions.years_won is null then '2026'
                   when champions.years_won !~ '\m2026\M' then champions.years_won || ', 2026'
                   else champions.years_won end;

insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, 'Aston Villa', 'England', '#670E36', '#95BFE5', 0, 1, null, '2026'
from tournaments t where t.name = 'UEFA Super Cup'
on conflict (tournament_id, team_name) do update set
  runners_up = case when champions.years_runner_up is null or champions.years_runner_up !~ '\m2026\M'
                    then champions.runners_up + 1 else champions.runners_up end,
  years_runner_up = case when champions.years_runner_up is null then '2026'
                         when champions.years_runner_up !~ '\m2026\M' then champions.years_runner_up || ', 2026'
                         else champions.years_runner_up end;

-- 2027 Super Cup: Crystal Palace venció a Barcelona (campeones UEL vs UCL del 2026-27)
insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, 'Crystal Palace', 'England', '#1B458F', '#C4122E', 1, 0, '2027', null
from tournaments t where t.name = 'UEFA Super Cup'
on conflict (tournament_id, team_name) do update set
  wins = case when champions.years_won is null or champions.years_won !~ '\m2027\M'
              then champions.wins + 1 else champions.wins end,
  years_won = case when champions.years_won is null then '2027'
                   when champions.years_won !~ '\m2027\M' then champions.years_won || ', 2027'
                   else champions.years_won end;

insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, 'FC Barcelona', 'Spain', '#A50044', '#EDBB00', 0, 1, null, '2027'
from tournaments t where t.name = 'UEFA Super Cup'
on conflict (tournament_id, team_name) do update set
  runners_up = case when champions.years_runner_up is null or champions.years_runner_up !~ '\m2027\M'
                    then champions.runners_up + 1 else champions.runners_up end,
  years_runner_up = case when champions.years_runner_up is null then '2027'
                         when champions.years_runner_up !~ '\m2027\M' then champions.years_runner_up || ', 2027'
                         else champions.years_runner_up end;
