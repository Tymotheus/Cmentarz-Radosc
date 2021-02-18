-- 5. Roles

-- Enums for roles
DROP TYPE IF EXISTS role_type CASCADE ;
CREATE TYPE "role_type" AS ENUM(
    'admin_bazy',
    'klient'
);

CREATE ROLE admin_bazy SUPERUSER ;
REASSIGN OWNED BY klient to admin_bazy;
DROP OWNED BY klient;
DROP ROLE if EXISTS klient;
CREATE ROLE klient NOSUPERUSER;

GRANT INSERT (imie, data_urodzenia, data_zgonu) on nieboszczycy  TO klient;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public to klient;
GRANT UPDATE (imie, data_urodzenia, data_zgonu) on nieboszczycy TO klient;

DROP TABLE IF EXISTS users CASCADE;
CREATE TABLE "users"(
    "id" SERIAL PRIMARY KEY,
    "role" role_type DEFAULT 'klient', --Dostęp do wszystkich funkcjonalności tylko dla admina
    "username" varchar,
    "email" varchar,
    "password" varchar
);

-- Dodawanie userów
INSERT INTO users(role, username, email, password) VALUES
('admin_bazy', 'admin', 'admin@op.pl', 'admin'),
('klient', 'klient1', 'klient@op.pl', 'klient');

-- Below some user testing:

-- -- Let's set the role to admin
-- SET ROLE admin_bazy;

-- INSERT INTO krypty (nazwa, pojemnosc) VALUES
-- ('Krypta adminowa', 10);

-- -- Everything works perfectly (or should)

-- -- Ok let's set the role to client
-- SET ROLE klient;

--  -- This one should be ok - klient has some granted privileges
-- INSERT INTO nieboszczycy(imie, data_urodzenia, data_zgonu) VALUES
-- ('Misiu Pysiu', '30.04.1892', '31.08.1952')

-- But this one is causing the warning (or should)!
-- Klient should not have privileges to insert data into Krypty!
-- INSERT INTO krypty (nazwa, pojemnosc) VALUES
-- ('Krypta kliencka', 2);