-- 007: Seed Freedge's own career history
-- Haiti United was his first club. Only inserts if no contract with that club exists yet.

insert into contracts (club_name, club_country, club_color, club_text_color, start_year, start_month, end_year, end_month)
select 'Haiti United', 'Haiti', '#003F87', '#D21034', 2026, 7, null, null
where not exists (select 1 from contracts where club_name = 'Haiti United');

-- If the contract already exists with wrong start year (e.g., 2014 from earlier seed), fix it
update contracts set start_year = 2026, start_month = 7 where club_name = 'Haiti United' and start_year = 2014;

-- Fix seasons with corrupt years from an earlier UI bug (start_year=0, end_year=1)
-- Parse the "Season YYYY-YY" or "YYYY-YYYY" from the label and update
update seasons
set start_year = cast(substring(label from '(\d{4})') as int),
    end_year   = cast(substring(label from '(\d{4})') as int) + 1
where start_year < 1900 and label ~ '\d{4}';
