-- 015: Sync — para todos los standings existentes:
--   position = 1 → asegura que el equipo es campeón con ese año en years_won
--   position = 2 → asegura que el equipo es runner-up con ese año en years_runner_up
-- Idempotente: si el año ya está en years_won/years_runner_up, no toca nada.

do $$
declare
  s record;
  year_str text;
  canonical text;
begin
  -- Mapa de alias club → canonical para que los nombres matcheen champions existentes
  -- (ej: standings dice "Al-Hilal" pero champions podría tener "Al Hilal")
  for s in
    select tournament_id, year_end, team_name, position
    from standings
    where position in (1, 2)
  loop
    year_str := s.year_end::text;
    canonical := trim(s.team_name);

    if s.position = 1 then
      insert into champions (tournament_id, team_name, wins, runners_up, years_won, years_runner_up)
      values (s.tournament_id, canonical, 1, 0, year_str, null)
      on conflict (tournament_id, team_name) do update set
        wins = case
          when champions.years_won is null or champions.years_won !~ ('\m' || year_str || '\M')
          then champions.wins + 1
          else champions.wins
        end,
        years_won = case
          when champions.years_won is null then year_str
          when champions.years_won !~ ('\m' || year_str || '\M') then champions.years_won || ', ' || year_str
          else champions.years_won
        end;
    else
      insert into champions (tournament_id, team_name, wins, runners_up, years_won, years_runner_up)
      values (s.tournament_id, canonical, 0, 1, null, year_str)
      on conflict (tournament_id, team_name) do update set
        runners_up = case
          when champions.years_runner_up is null or champions.years_runner_up !~ ('\m' || year_str || '\M')
          then champions.runners_up + 1
          else champions.runners_up
        end,
        years_runner_up = case
          when champions.years_runner_up is null then year_str
          when champions.years_runner_up !~ ('\m' || year_str || '\M') then champions.years_runner_up || ', ' || year_str
          else champions.years_runner_up
        end;
    end if;
  end loop;
end $$;
