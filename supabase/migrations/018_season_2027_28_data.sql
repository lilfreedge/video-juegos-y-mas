-- 018: Season 2027-28 data (user's current season, incremental)

-- UEFA Champions League 2027-28: Barcelona venció a Bayer Leverkusen
insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, 'FC Barcelona', 'Spain', '#A50044', '#EDBB00', 1, 0, '2028', null
from tournaments t where t.name = 'UEFA Champions League'
on conflict (tournament_id, team_name) do update set
  wins = case when champions.years_won is null or champions.years_won !~ '\m2028\M'
              then champions.wins + 1 else champions.wins end,
  years_won = case when champions.years_won is null then '2028'
                   when champions.years_won !~ '\m2028\M' then champions.years_won || ', 2028'
                   else champions.years_won end;

insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, 'Bayer Leverkusen', 'Germany', '#E32221', '#000000', 0, 1, null, '2028'
from tournaments t where t.name = 'UEFA Champions League'
on conflict (tournament_id, team_name) do update set
  runners_up = case when champions.years_runner_up is null or champions.years_runner_up !~ '\m2028\M'
                    then champions.runners_up + 1 else champions.runners_up end,
  years_runner_up = case when champions.years_runner_up is null then '2028'
                         when champions.years_runner_up !~ '\m2028\M' then champions.years_runner_up || ', 2028'
                         else champions.years_runner_up end;
