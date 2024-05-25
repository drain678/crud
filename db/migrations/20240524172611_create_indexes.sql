-- migrate:up
create index banks_founded_in_ind on banks_data.bank using btree(founded_in, title);

create extension pg_trgm;
create index banks_title_ind on banks_data.bank using gist(title gist_trgm_ops);

-- migrate:down