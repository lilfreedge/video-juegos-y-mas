-- 007: Seed Freedge's own career history
-- Haiti United was his first club. Only inserts if no contract with that club exists yet.

insert into contracts (club_name, club_country, club_color, club_text_color, start_year, start_month, end_year, end_month)
select 'Haiti United', 'Haiti', '#003F87', '#D21034', 2026, 7, null, null
where not exists (select 1 from contracts where club_name = 'Haiti United');

-- If the contract already exists with wrong start year (e.g., 2014 from earlier seed), fix it
update contracts set start_year = 2026, start_month = 7 where club_name = 'Haiti United' and start_year = 2014;
