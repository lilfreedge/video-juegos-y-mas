-- 016: Limpia rows con team_name vacío/whitespace en champions, standings y top_scorers
-- Y agrega CHECK constraint para prevenir que pase de nuevo

-- Clean up existing bad data
delete from champions where team_name is null or trim(team_name) = '';
delete from standings where team_name is null or trim(team_name) = '';
delete from top_scorers where player_name is null or trim(player_name) = '';

-- Add CHECK constraints (drop first if they exist to be idempotent)
alter table champions drop constraint if exists champions_team_name_not_empty;
alter table champions add constraint champions_team_name_not_empty check (length(trim(team_name)) > 0);

alter table standings drop constraint if exists standings_team_name_not_empty;
alter table standings add constraint standings_team_name_not_empty check (length(trim(team_name)) > 0);

alter table top_scorers drop constraint if exists top_scorers_player_name_not_empty;
alter table top_scorers add constraint top_scorers_player_name_not_empty check (length(trim(player_name)) > 0);

-- Re-sync standings to champions in case any Al-Hilal/Al-Ittihad etc. were lost
do $$
declare
  s record;
  year_str text;
  canonical text;
begin
  for s in
    select tournament_id, year_end, team_name, position
    from standings
    where position in (1, 2) and team_name is not null and trim(team_name) <> ''
  loop
    year_str := s.year_end::text;
    canonical := trim(s.team_name);

    if s.position = 1 then
      insert into champions (tournament_id, team_name, wins, runners_up, years_won, years_runner_up)
      values (s.tournament_id, canonical, 1, 0, year_str, null)
      on conflict (tournament_id, team_name) do update set
        wins = case when champions.years_won is null or champions.years_won !~ ('\m' || year_str || '\M')
                    then champions.wins + 1 else champions.wins end,
        years_won = case when champions.years_won is null then year_str
                         when champions.years_won !~ ('\m' || year_str || '\M') then champions.years_won || ', ' || year_str
                         else champions.years_won end;
    else
      insert into champions (tournament_id, team_name, wins, runners_up, years_won, years_runner_up)
      values (s.tournament_id, canonical, 0, 1, null, year_str)
      on conflict (tournament_id, team_name) do update set
        runners_up = case when champions.years_runner_up is null or champions.years_runner_up !~ ('\m' || year_str || '\M')
                          then champions.runners_up + 1 else champions.runners_up end,
        years_runner_up = case when champions.years_runner_up is null then year_str
                               when champions.years_runner_up !~ ('\m' || year_str || '\M') then champions.years_runner_up || ', ' || year_str
                               else champions.years_runner_up end;
    end if;
  end loop;
end $$;
