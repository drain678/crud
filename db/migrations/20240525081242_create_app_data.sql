-- migrate:up
insert into banks_data.bank (title, founded_in)
select md5(random()::text), '2023-01-01'::DATE + (random() * interval '365 days') AS founded_in
from generate_series(1, 100000);
-- migrate:down

