-- 1. Initiating the database
-- Enums for materials
DROP TYPE IF EXISTS material_nagrobka CASCADE ;
CREATE TYPE "material_nagrobka" AS ENUM (
  'granit',
  'marmur',
  'piaskowiec'
);

DROP TYPE IF EXISTS material_trumny CASCADE;
CREATE TYPE material_trumny AS ENUM (
  'olcha',
  'sosna',
  'dąb'
);

DROP TYPE IF EXISTS material_urny CASCADE ;
CREATE TYPE "material_urny" AS ENUM (
  'metal',
  'kamień',
  'mosiądz',
  'drewno',
  'szkło'
);

-- Enums for roles
DROP TYPE IF EXISTS role_type CASCADE ;
CREATE TYPE "role_type" AS ENUM(
    'admin',
    'klient'
);

-- Roles
-- DROP ROLE if EXISTS admin;
-- CREATE ROLE admin SUPERUSER ;
REASSIGN OWNED BY klient to admin;
DROP OWNED BY klient;
DROP ROLE if EXISTS klient;
CREATE ROLE klient NOSUPERUSER;

GRANT INSERT (imie, data_urodzenia, data_zgonu) on nieboszczycy  TO klient;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public to klient;
GRANT UPDATE (imie, data_urodzenia, data_zgonu) on nieboszczycy TO klient;

-- Below some user testing:

-- -- Let's set the role to admin
-- SET ROLE admin;

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

-- Tables
DROP TABLE IF EXISTS users CASCADE;
CREATE TABLE "users"(
    "id" SERIAL PRIMARY KEY,
    "role" role_type DEFAULT 'klient', --Dostęp do wszystkich funkcjonalności tylko dla admina
    "username" varchar,
    "email" varchar,
    "password" varchar
);
INSERT INTO users(role, username, email, password) VALUES
('admin', 'admin', 'admin@op.pl', 'admin');

DROP TABLE IF EXISTS nieboszczycy CASCADE;
CREATE TABLE "nieboszczycy" (
  "id" SERIAL PRIMARY KEY,
  "imie" varchar NOT NULL,
  "data_urodzenia" date NOT NULL,
  "data_zgonu" date NOT NULL,
  "id_trumny" int,
  "id_urny" int
);

DROP TABLE IF EXISTS trumny CASCADE ;
CREATE TABLE "trumny" (
  "id" SERIAL PRIMARY KEY,
  "material" material_trumny NOT NULL,
  "id_nagrobka" int,
  "id_krypty" int,
  "id_kostnicy" int NOT NULL
);

DROP TABLE IF EXISTS nagrobki;
CREATE TABLE "nagrobki" (
  "id" SERIAL PRIMARY KEY,
  "material" material_nagrobka NOT NULL,
  "imie" varchar
);

DROP TABLE IF EXISTS kostnice CASCADE ;
CREATE TABLE "kostnice" (
  "id" SERIAL PRIMARY KEY,
  "nazwa" varchar NOT NULL
);

DROP TABLE IF EXISTS urny CASCADE ;
CREATE TABLE "urny" (
  "id" SERIAL PRIMARY KEY,
  "material" material_urny NOT NULL,
  "id_krypty" int,
  "id_krematorium" int NOT NULL
);

DROP TABLE IF EXISTS krematoria CASCADE ;
CREATE TABLE "krematoria" (
  "id" SERIAL PRIMARY KEY,
  "nazwa" varchar NOT NULL
);

DROP TABLE IF EXISTS krypty CASCADE ;
CREATE TABLE "krypty" (
  "id" SERIAL PRIMARY KEY,
  "nazwa" varchar NOT NULL,
  "pojemnosc" int NOT NULL,
  "liczba_trumien" int DEFAULT (0),
  "liczba_urn" int DEFAULT (0),
  "wybudowano" date DEFAULT (now())
);


DROP TABLE IF EXISTS sprzatacze CASCADE;
CREATE TABLE "sprzatacze" (
  "id" SERIAL PRIMARY KEY,
  "imie" VARCHAR NOT NULL
);

DROP TABLE IF EXISTS trumniarze CASCADE ;
CREATE TABLE "trumniarze"(
    "id" SERIAL PRIMARY KEY,
    "imie" VARCHAR NOT NULL
);

DROP TABLE IF EXISTS urniarze CASCADE ;
CREATE TABLE "urniarze"(
    "id" SERIAL PRIMARY KEY,
    "imie" VARCHAR NOT NULL
);

DROP TABLE IF EXISTS sprzatanie_krypt;
CREATE TABLE "sprzatanie_krypt"(
    "id_sprzatacza" INT,
    "id_krypty" INT,
    "data" date DEFAULT (now())
);

DROP TABLE IF EXISTS wykonywanie_trumien;
CREATE TABLE "wykonywanie_trumien"(
    "id_trumniarza" INT,
    "id_trumny" INT,
    "data" date DEFAULT (now())

);

DROP TABLE IF EXISTS wykonywanie_urn;
CREATE TABLE "wykonywanie_urn"(
    "id_urniarza" INT,
    "id_urny" INT,
    "data" date DEFAULT (now())

);


-- Relationships
ALTER TABLE "nieboszczycy" ADD FOREIGN KEY ("id_trumny") REFERENCES "trumny" ("id");

ALTER TABLE "nieboszczycy" ADD FOREIGN KEY ("id_urny") REFERENCES "urny" ("id");

ALTER TABLE "trumny" ADD FOREIGN KEY ("id_nagrobka") REFERENCES "nagrobki" ("id");

ALTER TABLE "trumny" ADD FOREIGN KEY ("id_krypty") REFERENCES "krypty" ("id");

ALTER TABLE "urny" ADD FOREIGN KEY ("id_krypty") REFERENCES "krypty" ("id");

ALTER TABLE "urny" ADD FOREIGN KEY ("id_krematorium") REFERENCES "krematoria" ("id");

ALTER TABLE "trumny" ADD FOREIGN KEY ("id_kostnicy") REFERENCES "kostnice" ("id");

-- Relacje many to many dla tablic asocjacyjnych
ALTER TABLE "sprzatanie_krypt" ADD FOREIGN KEY  ("id_krypty") REFERENCES "krypty" ("id");
ALTER TABLE "sprzatanie_krypt" ADD FOREIGN KEY  ("id_sprzatacza") REFERENCES "sprzatacze" ("id");

ALTER TABLE "wykonywanie_trumien" ADD FOREIGN KEY ("id_trumny") REFERENCES "trumny" ("id");
ALTER TABLE "wykonywanie_trumien" ADD FOREIGN KEY ("id_trumniarza") REFERENCES "trumniarze" ("id");

ALTER TABLE "wykonywanie_urn" ADD FOREIGN KEY ("id_urny") REFERENCES "urny" ("id");
ALTER TABLE "wykonywanie_urn" ADD FOREIGN KEY ("id_urniarza") REFERENCES "urniarze" ("id");




-- Dodawanie userów
INSERT INTO users (role, username)
VALUES
    ('klient', 'Nowy Klient'),
    ('admin', 'Admin');



SELECT * FROM nieboszczycy left join trumny on nieboszczycy.id_trumny = trumny.id
    left join nagrobki on nagrobki.id = trumny.id_nagrobka;

SELECT * from nieboszczycy;

-- Ok próbujemy zrobić ładny select do wyszukiwania nieboszczyków:
SELECT * from nieboszczycy
WHERE imie='Stefan Banach';


-- Union - można połączyć tylko kolumny tego samego typu :/
SELECT id, id_krypty from trumny
UNION
SELECT id, id_krypty from urny;

-- Views

-- Urodzeni po dacie - wyzwoleniu Krakowa spod okupacji
CREATE VIEW Urodzeni_po_Wyzwoleniu AS
SELECT imie, data_urodzenia, data_zgonu
FROM nieboszczycy
WHERE CAST(nieboszczycy.data_urodzenia AS Date) > '1945-01-18';

-- Klienci z konkretnej krypty
CREATE VIEW Mieszkancy_Odrodzenia AS
SELECT krypty.nazwa, nieboszczycy.imie, nieboszczycy.data_urodzenia, nieboszczycy.data_zgonu, trumny.material as Trumna
FROM nieboszczycy inner join trumny on nieboszczycy.id_trumny = trumny.id
    inner join krypty on trumny.id_krypty=krypty.id
WHERE krypty.nazwa = 'Krypta Odrodzenia';

SELECT imie, trumna FROM Mieszkancy_Odrodzenia;

-- Srednia wieku naszych klientow - ile sobie żyli
CREATE VIEW srednia_wieku AS
    SELECT AVG( EXTRACT( YEAR FROM nieboszczycy.data_zgonu) - EXTRACT( YEAR FROM data_urodzenia))
    FROM nieboszczycy;

-- Pogrupowane trumien materiałami - i policzone
CREATE VIEW materialy_trumien AS
    SELECT trumny.material, count(*) AS Ilosc FROM nieboszczycy
        inner join trumny on nieboszczycy.id_trumny = trumny.id
        GROUP BY trumny.material;


-- Wszystkie trumny nieprzypisane nigdzie z trupkiem w środku
CREATE OR REPLACE VIEW nieprzypisane_trumny AS
    SELECT trumny.id, trumny.material, n.imie FROM trumny
        inner join nieboszczycy n on trumny.id = n.id_trumny
        WHERE trumny.id_krypty is null and trumny.id_nagrobka is null
    Group By trumny.id, n.imie;

-- Wszystkie urny nieprzypisane nigdzie z trupkiem w środku
CREATE OR REPLACE VIEW nieprzypisane_urny AS
    SELECT urny.id, urny.material, n.imie FROM urny
        inner join nieboszczycy n on urny.id = n.id_urny
        WHERE urny.id_krypty is null
    Group By urny.id, n.imie;

SELECT * from nieprzypisane_urny;

SELECT * from nieboszczycy order by id;
