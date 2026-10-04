-- 007: Seed Freedge's own career history
-- Haiti United was his first club. Only inserts if no contract with that club exists yet.

insert into contracts (club_name, club_country, club_color, club_text_color, start_year, start_month, end_year, end_month)
select 'Haiti United', 'Haiti', '#003F87', '#D21034', 2014, 7, null, null
where not exists (select 1 from contracts where club_name = 'Haiti United');
