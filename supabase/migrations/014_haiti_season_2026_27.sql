-- 014: Haiti United season 2026-27 + UCL/UEL/UECL/Super Cup 2026-27 results

-- Add is_my_team flag to standings
alter table standings add column if not exists is_my_team boolean default false;

-- LIGUE 1 2026-27 STANDINGS (top 6 only — user has no data for bottom)
insert into standings (tournament_id, year_end, team_name, position, points, is_my_team)
select t.id, 2027, v.team_name, v.position, v.points, v.is_my_team
from tournaments t, (values
  ('Stade Rennais', 1, 72, false),
  ('Paris Saint-Germain', 2, 67, false),
  ('Monaco', 3, 65, false),
  ('Haiti United', 4, 63, true),
  ('Strasbourg', 5, 59, false),
  ('Lyon', 6, 58, false)
) as v(team_name, position, points, is_my_team)
where t.name = 'Ligue 1'
on conflict (tournament_id, year_end, team_name) do update set
  position = excluded.position, points = excluded.points, is_my_team = excluded.is_my_team;

-- LIGUE 2 2026-27 STANDINGS (user says these teams were in his Ligue 2)
insert into standings (tournament_id, year_end, team_name, position, points, is_my_team)
select t.id, 2027, v.team_name, v.position, v.points, false
from tournaments t, (values
  ('Al-Hilal', 1, 84),
  ('Al-Ittihad', 2, 73),
  ('Al-Nassr', 3, 73),
  ('Al-Qadsiah', 4, 63),
  ('FC Juarez', 5, 57),
  ('Toronto FC', 6, 46)
) as v(team_name, position, points)
where t.name = 'Ligue 2'
on conflict (tournament_id, year_end, team_name) do update set
  position = excluded.position, points = excluded.points;

-- LIONEL MESSI (Haiti United) 19 goals Ligue 1 2026-27 — from my career
insert into top_scorers (tournament_id, year, player_name, nationality, team, goals, from_my_career)
select t.id, 2027, 'Lionel Messi', 'Argentina', 'Haiti United', 19, true
from tournaments t
where t.name = 'Ligue 1'
on conflict (tournament_id, year, player_name) do update set
  goals = excluded.goals, team = excluded.team, from_my_career = excluded.from_my_career;

-- Haiti United qualified to UCL Qualifying (4to lugar)
insert into trophies_won (season_id, tournament_id, tournament_name_snapshot, result, notes)
select s.id, t.id, 'Ligue 1', 'other', '4to - Clasificó a UCL Qualifying'
from seasons s
join contracts c on s.contract_id = c.id
cross join tournaments t
where c.club_name = 'Haiti United' and c.is_national = false
  and s.end_year = 2027
  and t.name = 'Ligue 1'
  and not exists (
    select 1 from trophies_won tw
    where tw.season_id = s.id and tw.tournament_id = t.id and tw.notes like '%4to%'
  );

-- UEFA CHAMPIONS LEAGUE 2026-27: Barcelona won vs Borussia Dortmund (year_end = 2027)
insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, 'FC Barcelona', 'Spain', '#A50044', '#EDBB00', 1, 0, '2027', null
from tournaments t where t.name = 'UEFA Champions League'
on conflict (tournament_id, team_name) do update set
  wins = case when champions.years_won is null or champions.years_won !~ '\m2027\M'
              then champions.wins + 1 else champions.wins end,
  years_won = case when champions.years_won is null then '2027'
                   when champions.years_won !~ '\m2027\M' then champions.years_won || ', 2027'
                   else champions.years_won end;

insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, 'Borussia Dortmund', 'Germany', '#FDE100', '#000000', 0, 1, null, '2027'
from tournaments t where t.name = 'UEFA Champions League'
on conflict (tournament_id, team_name) do update set
  runners_up = case when champions.years_runner_up is null or champions.years_runner_up !~ '\m2027\M'
                   then champions.runners_up + 1 else champions.runners_up end,
  years_runner_up = case when champions.years_runner_up is null then '2027'
                         when champions.years_runner_up !~ '\m2027\M' then champions.years_runner_up || ', 2027'
                         else champions.years_runner_up end;

-- UEFA EUROPA LEAGUE 2026-27: Crystal Palace won vs Athletic Bilbao
insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, 'Crystal Palace', 'England', '#1B458F', '#C4122E', 1, 0, '2027', null
from tournaments t where t.name = 'UEFA Europa League'
on conflict (tournament_id, team_name) do update set
  wins = case when champions.years_won is null or champions.years_won !~ '\m2027\M'
              then champions.wins + 1 else champions.wins end,
  years_won = case when champions.years_won is null then '2027'
                   when champions.years_won !~ '\m2027\M' then champions.years_won || ', 2027'
                   else champions.years_won end;

insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, 'Athletic Bilbao', 'Spain', '#EE2523', '#FFFFFF', 0, 1, null, '2027'
from tournaments t where t.name = 'UEFA Europa League'
on conflict (tournament_id, team_name) do update set
  runners_up = case when champions.years_runner_up is null or champions.years_runner_up !~ '\m2027\M'
                   then champions.runners_up + 1 else champions.runners_up end,
  years_runner_up = case when champions.years_runner_up is null then '2027'
                         when champions.years_runner_up !~ '\m2027\M' then champions.years_runner_up || ', 2027'
                         else champions.years_runner_up end;

-- UEFA CONFERENCE LEAGUE 2026-27: Brighton won vs Ajax
insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, 'Brighton', 'England', '#0057B8', '#FFFFFF', 1, 0, '2027', null
from tournaments t where t.name = 'UEFA Conference League'
on conflict (tournament_id, team_name) do update set
  wins = case when champions.years_won is null or champions.years_won !~ '\m2027\M'
              then champions.wins + 1 else champions.wins end,
  years_won = case when champions.years_won is null then '2027'
                   when champions.years_won !~ '\m2027\M' then champions.years_won || ', 2027'
                   else champions.years_won end;

insert into champions (tournament_id, team_name, team_country, team_color, team_text_color, wins, runners_up, years_won, years_runner_up)
select t.id, 'Ajax', 'Netherlands', '#D2122E', '#FFFFFF', 0, 1, null, '2027'
from tournaments t where t.name = 'UEFA Conference League'
on conflict (tournament_id, team_name) do update set
  runners_up = case when champions.years_runner_up is null or champions.years_runner_up !~ '\m2027\M'
                   then champions.runners_up + 1 else champions.runners_up end,
  years_runner_up = case when champions.years_runner_up is null then '2027'
                         when champions.years_runner_up !~ '\m2027\M' then champions.years_runner_up || ', 2027'
                         else champions.years_runner_up end;

-- UEFA SUPER CUP Aug 2026 (year 2026): PSG beat Aston Villa
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
