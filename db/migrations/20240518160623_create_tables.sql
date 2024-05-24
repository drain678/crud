-- migrate:up

create schema banks_data;

create extension if not exists "uuid-ossp";

create table banks_data.bank
(
	id uuid primary key default uuid_generate_v4(),
	title text,
    founded_in date
);


CREATE TABLE banks_data.client
(
    id uuid primary key default uuid_generate_v4(),
	first_name text,
    last_name text,
	phone text check(length(phone) < 20)
);


create table banks_data.bank_to_client
(
	bank_id uuid references banks_data.bank,
	client_id uuid references banks_data.client,
	primary key(bank_id, client_id)
);



create table banks_data.transaction
(
	id uuid primary key default uuid_generate_v4(),
    amount float not null,
    date_of_transaction date not null,
    description_of_transaction text,
	sender_id uuid references banks_data.client not null,
    receiver_id uuid references banks_data.client not null
);


INSERT INTO banks_data.bank (title, founded_in) VALUES 
('Simga', '1990-12-09'),
('Russia', '1970-09-08'),
('Sber', '1960-11-23'),
('Tinkoff', '2000-05-07'),
('VTB', '1995-10-17');

INSERT INTO banks_data.client (first_name, last_name, phone) VALUES 
('Lyosha', 'Zaitsev', '+79195639966'),
('Sam', 'Komarov', '+79195138803'),
('Nastya', 'Prohochyova', '+79194704532'),
('Polina', 'Tokareva', '+79197806512');

INSERT INTO banks_data.transaction (amount, date_of_transaction, description_of_transaction, sender_id, receiver_id) VALUES 
(
    123.0,
    '2022-05-09',
    'transaction1',
    (SELECT id FROM banks_data.client WHERE first_name = 'Polina' and last_name = 'Tokareva'),
    (SELECT id FROM banks_data.client WHERE first_name = 'Nastya' and last_name = 'Prohochyova')
),
(
    500.0,
    '2022-05-10',
    'transaction2',
    (SELECT id FROM banks_data.client WHERE first_name = 'Lyosha' and last_name = 'Zaitsev'),
    (SELECT id FROM banks_data.client WHERE first_name = 'Sam' and last_name = 'Komarov')
)



INSERT INTO banks_data.bank_to_client (bank_id, client_id) VALUES 
((SELECT id FROM banks_data.bank WHERE title = 'Simga'), (SELECT id FROM banks_data.client WHERE first_name = 'Lyosha' and last_name = 'Zaitsev')),
((SELECT id FROM banks_data.bank WHERE title = 'Russia'), (SELECT id FROM banks_data.client WHERE first_name = 'Sam' and last_name = 'Komarov')),
((SELECT id FROM banks_data.bank WHERE title = 'Sber'), (SELECT id FROM banks_data.client WHERE first_name = 'Nastya' and last_name = 'Prohochyova')),
((SELECT id FROM banks_data.bank WHERE title = 'Tinkoff'), (SELECT id FROM banks_data.client WHERE first_name = 'Polina' and last_name = 'Tokareva')),
((SELECT id FROM banks_data.bank WHERE title = 'VTB'), (SELECT id FROM banks_data.client WHERE first_name = 'Lyosha' and last_name = 'Zaitsev'));

INSERT INTO banks_data.transaction (amount, date_of_transaction, description_of_transaction, sender_id, receiver_id) VALUES 
(   100.0,
    '2024-12-12',
    'ale',
    (SELECT id FROM banks_data.client WHERE first_name = 'Lyosha' and last_name = 'Zaitsev'),
    (SELECT id FROM banks_data.client WHERE first_name = 'Sam' and last_name = 'Komarov')
),
(   200.0,
    '2024-08-25',
    'hello',
    (SELECT id FROM banks_data.client WHERE first_name = 'Nastya' and last_name = 'Prohochyova'),
    (SELECT id FROM banks_data.client WHERE first_name = 'Polina' and last_name = 'Tokareva')
),
(   300.0,
    '2023-10-11',
    'privet',
    (SELECT id FROM banks_data.client WHERE first_name = 'Nastya' and last_name = 'Prohochyova'),
    (SELECT id FROM banks_data.client WHERE  first_name = 'Sam' and last_name = 'Komarov')
),
(   400.0,
    '2022-05-13',
    'taxi',
    (SELECT id FROM banks_data.client WHERE first_name = 'Polina' and last_name = 'Tokareva'),
    (SELECT id FROM banks_data.client WHERE  first_name = 'Lyosha' and last_name = 'Zaitsev')
),
(   500.0,
    '2022-07-24',
    'obed',
    (SELECT id FROM banks_data.client WHERE first_name = 'Sam' and last_name = 'Komarov'),
    (SELECT id FROM banks_data.client WHERE  first_name = 'Polina' and last_name = 'Tokareva')
),
(   500.0,
    '2020-01-30',
    'obed',
    (SELECT id FROM banks_data.client WHERE first_name = 'Sam' and last_name = 'Komarov'),
    (SELECT id FROM banks_data.client WHERE  first_name = 'Lyosha' and last_name = 'Zaitsev')
);


-- migrate:down