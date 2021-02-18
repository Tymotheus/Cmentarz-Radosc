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



-- 2. Creating array triggers

-- Trigger dbający o odpowiednie aktualizowanie liczby trumien w każdej krypcie
-- Kiedy trumna jest dodawana do krypty - inkrementuje zmienną lczba_trumien
-- Kiedy jest odejmowana - dekrementuje zmienną liczba_trumien

-- Note - I should also make sure that noone inserts too many trumnas
-- into one krypta (we can not exceed its capacity)

-- Funkcja dbająca o zlicznie trumn
CREATE OR REPLACE FUNCTION krypta1() RETURNS TRIGGER AS $example_table_1$
    DECLARE
        _liczba_trumien INTEGER = (Select liczba_trumien from krypty where id=NEW.id_krypty);
        _liczba_urn INTEGER = (Select liczba_urn from krypty where id=NEW.id_krypty);
        _pojemnosc INTEGER = (SELECT pojemnosc from krypty where id=NEW.id_krypty);
    BEGIN
        IF ( (_liczba_trumien+_liczba_urn) >= _pojemnosc) THEN
            RAISE exception 'Ta krypta jest już pełna';
        ELSE
            UPDATE krypty
            SET liczba_trumien = liczba_trumien + 1
            WHERE id = NEW.id_krypty;
            UPDATE krypty
            SET liczba_trumien = liczba_trumien - 1
            WHERE id = OLD.id_krypty;
            RETURN NEW;
        END IF;
    END
    $example_table_1$ LANGUAGE plpgsql;


DROP TRIGGER IF EXISTS  zaktualizuj_liczbe_trumien on trumny;
CREATE TRIGGER zaktualizuj_liczbe_trumien
    BEFORE UPDATE of id_krypty ON trumny
    FOR EACH ROW
    WHEN (OLD.id_krypty IS DISTINCT FROM NEW.id_krypty)
    EXECUTE PROCEDURE krypta1();


-- Funkcja dbajaca o zliczanie urn
CREATE OR REPLACE FUNCTION krypta2() RETURNS TRIGGER AS $example_table_2$
    DECLARE
        _liczba_urn INTEGER = (Select liczba_urn from krypty where id=NEW.id_krypty);
        _liczba_trumien INTEGER = (Select liczba_trumien from krypty where id=NEW.id_krypty);
        _pojemnosc INTEGER = (SELECT pojemnosc from krypty where id=NEW.id_krypty);
    BEGIN
        IF ( (_liczba_urn +_liczba_trumien)  >= _pojemnosc) THEN
            RAISE exception 'Ta krypta jest już pełna';
        ELSE
            UPDATE krypty
            SET liczba_urn = liczba_urn + 1
            WHERE id = NEW.id_krypty;
            UPDATE krypty
            SET liczba_urn = liczba_urn - 1
            WHERE id = OLD.id_krypty;
            RETURN NEW;
        END IF;
    END
    $example_table_2$ LANGUAGE plpgsql;



CREATE TRIGGER zaktualizuj_liczbe_urn
    BEFORE UPDATE of id_krypty ON urny
    FOR EACH ROW
    WHEN (OLD.id_krypty IS DISTINCT FROM NEW.id_krypty)
    EXECUTE PROCEDURE krypta2();

CREATE OR REPLACE FUNCTION nagrobek1() RETURNS TRIGGER AS $example_table_3$
    DECLARE
        _imie varchar = (SELECT imie from nieboszczycy where id_trumny=NEW.id);
    BEGIN
            UPDATE nagrobki
            SET imie = _imie
            WHERE id = NEW.id_nagrobka;
            RETURN NEW;
    END
    $example_table_3$ LANGUAGE plpgsql;


DROP TRIGGER IF EXISTS  zaktualizuj_imiona_nagrobka on trumny;
CREATE TRIGGER zaktualizuj_imiona_nagrobka
    BEFORE UPDATE of id_nagrobka ON trumny
    FOR EACH ROW
    WHEN (OLD.id_nagrobka IS DISTINCT FROM NEW.id_nagrobka)
    EXECUTE PROCEDURE nagrobek1();



CREATE OR REPLACE FUNCTION nieboszczyk1() RETURNS TRIGGER AS $nieboszczykowy1$
    BEGIN
        RAISE exception 'Przepraszamy, nie akceptujemy nieumarłych!';
    END;
    $nieboszczykowy1$ LANGUAGE plpgsql;

CREATE TRIGGER sprawdz_nieboszczyka_na_insert
    BEFORE INSERT ON nieboszczycy
    FOR EACH ROW
    WHEN (NEW.data_urodzenia > NEW.data_zgonu)
    EXECUTE PROCEDURE nieboszczyk1();

-- 3. Seeding the database

-- Dodawanie userów
INSERT INTO users (role, username)
VALUES
    ('klient', 'Nowy Klient'),
    ('admin', 'Admin');

-- Dodawanie krypt
insert into krypty (nazwa, pojemnosc, wybudowano) VALUES
('Krypta Odrodzenia', 4, '15.04.1452'),
('Krypta św. Leonarda', 10, '25.12.1117'),
('Krypta 101', 13, '14.09.2011'),
('Krypta Norymberska', 2, '2.08.1928');

-- Dodawanie kostnic
INSERT INTO kostnice (nazwa) VALUES
('Casablanca'),
('Trypolis');

-- Dodawanie krematoriów
INSERT INTO krematoria (nazwa) VALUES
('Jordan'),
('Ganges');

-- Dodawanie trumien
INSERT INTO trumny (material, id_kostnicy) VALUES
('olcha', 1),
('sosna', 1),
('dąb', 1),
('dąb', 1),
('sosna', 1),
('olcha', 1),
('olcha', 1),
('sosna', 1),
('olcha', 1),
('olcha', 1),
('dąb', 1),
('dąb', 1),
('sosna', 1),
('sosna', 1),
('sosna', 1);


-- Dodawanie urn
insert into urny (material, id_krematorium) VALUES
('mosiądz', 1),
('drewno', 1),
('kamień', 1),
('metal', 1),
('szkło', 1),
('mosiądz', 1);

-- Dodawanie nagrobków
INSERT INTO nagrobki (material) VALUES
('granit'),
('marmur'),
('piaskowiec'),
('marmur'),
('piaskowiec'),
('granit');

-- Dodawanie nieboszczyków
INSERT INTO nieboszczycy (imie, data_urodzenia, data_zgonu) VALUES
( 'Stefan Banach', '30.04.1892', '31.08.1945'),
( 'Hugo Steinhaus', '14.01.1887', '25.02.1972'),
( 'Stanisław Ulam', '3.04.1909', '13.05.1984'),
( 'Kazimierz Kuratowski', '2.02.1896', '18.06.1980'),
( 'Wacław Sierpiński', '14.03.1882', '21.10.1969') ,
( 'Marian Smoluchowski', '28.05.1872', '5.09.1917'),
( 'Leopold Infeld', '20.08.1898', '15.01.1968'),
( 'Aleksander Wolszczan', '29.04.1946', '10.11.2036'),
( 'Karol Borsuk', '8.05.1905', '24.01.1982'),
( 'Stanisław Mazur', '1.01.1905', '5.11.1981'),
( 'Marian Rejewski', '16.08.1905', '13.02.1980');

-- Dodawanie trumniarzy
INSERT INTO trumniarze (imie) VALUES
('Maciej Podbioł'),
('Gabriel Podbioł');

-- Dodawanie urniarzy
INSERT INTO urniarze (imie) VALUES
('Piotr Kubica'),
('Ksenia Kwiatkowska');

-- Dodawanie sprzątaczy
INSERT INTO sprzatacze (imie) VALUES
('Franiszek Wietrzykostki'),
('Rita Wietrzykostka');

-- Dodawanie informacji o sprzątaniu krypt
INSERT INTO sprzatanie_krypt (id_sprzatacza, id_krypty) VALUES
(1,1),
(1,2),
(1,3),
(2,2),
(2,3),
(2,4);

-- Dodawanie informacji o wykonywaniu trumien
INSERT INTO wykonywanie_trumien (id_trumniarza, id_trumny) VALUES
(1,1),
(1,2),
(1,3),
(1,4),
(2,3),
(2,4),
(2,5),
(2,6),
(2,7),
(2,8);

-- Dodawanie informacji o wykonywaninu urn
INSERT INTO wykonywanie_urn (id_urniarza, id_urny) VALUES
(1,1),
(1,2),
(1,3),
(1,4),
(2,3),
(2,4),
(2,5),
(2,6);

-- Nadanie Banachowi odpowiedniej trumny
-- Ustaw Banachowi pierwszą dębową trumnę
update nieboszczycy
set id_trumny = (
    with pierwsza as (
        SELECT trumny.* from trumny left join nieboszczycy n on trumny.id = n.id_trumny
        WHERE material = 'dąb' and n.id is null
        group by trumny.id, n.id
        limit 1)
    select id from pierwsza
) where imie='Stefan Banach';

-- Nadanie jego trumnie odpowiedniej krypty 1 (takiej trumnie która trzyma Banacha)
update trumny
set id_krypty = 2
where id=(
    SELECT id_trumny
    from nieboszczycy
    where imie = 'Stefan Banach'
);

-- -- Nadanie Ulamowi odpowiedniej urny
UPDATE nieboszczycy
SET id_urny=1
WHERE imie = 'Stanisław Ulam';

--Dodanie Borsukowi odpowiedniej trumny - pierwszej olszanej
UPDATE nieboszczycy
SET id_trumny = (
    with pierwsza as (
        SELECT trumny.* from trumny left join nieboszczycy n on trumny.id = n.id_trumny
        WHERE material = 'olcha' and n.id is null
        group by trumny.id, n.id
        limit 1)
    select id from pierwsza
    )
WHERE imie='Karol Borsuk';


--Dodanie Sierpińskiemu odpowiedniej trumny - pierwszej olszanej
UPDATE nieboszczycy
SET id_trumny = (
    with pierwsza as (
        SELECT trumny.* from trumny left join nieboszczycy n on trumny.id = n.id_trumny
        WHERE material = 'olcha' and n.id is null
        group by trumny.id, n.id
        limit 1)
    select id from pierwsza
)WHERE imie='Wacław Sierpiński';

select * from trumny where (material = 'olcha' and id_krypty is null and id_nagrobka is null) limit 1;

-- Nadanie jego trumnie odpowiedniego nagrobka (takiej trumnie która trzyma Sierpińskiego)
update trumny
set id_nagrobka = (
    with grobek as (
        select * from nagrobki where material = 'marmur' and imie is null limit 1
    )
    select id
    from grobek
)where id=(
select trumny.id from trumny left join nieboszczycy on trumny.id = nieboszczycy.id_trumny where nieboszczycy.imie = 'Wacław Sierpiński'
);

--Dodanie Mazurowi odpowiedniej trumny - pierwszej sosnowej
UPDATE nieboszczycy
SET id_trumny = (
    with pierwsza as (
        SELECT trumny.* from trumny left join nieboszczycy n on trumny.id = n.id_trumny
        WHERE material = 'sosna' and n.id is null
        group by trumny.id, n.id
        limit 1)
    select id from pierwsza
)WHERE imie='Stanisław Mazur';



-- Dodanie Smoluchowskiemu dębowej trumny
update nieboszczycy
set id_trumny = (
    with pierwsza as (
        SELECT trumny.* from trumny left join nieboszczycy n on trumny.id = n.id_trumny
        WHERE material = 'dąb' and n.id is null
        group by trumny.id, n.id
        limit 1)
    select id from pierwsza
) where imie='Marian Smoluchowski';


-- Dodanie Infeldowi sosnowej trumny
update nieboszczycy
set id_trumny = (
    with pierwsza as (
        SELECT trumny.* from trumny left join nieboszczycy n on trumny.id = n.id_trumny
        WHERE material = 'sosna' and n.id is null
        group by trumny.id, n.id
        limit 1)
    select id from pierwsza
) where imie='Leopold Infeld';

-- Dodanie Infelda do odpowiedniej krypty
update trumny
set id_krypty = 2
where id=(
    SELECT id_trumny
    from nieboszczycy
    where imie = 'Leopold Infeld'
);

-- Dodanie Steinhausowi sosnowej trumny
update nieboszczycy
set id_trumny = (
    with pierwsza as (
        SELECT trumny.* from trumny left join nieboszczycy n on trumny.id = n.id_trumny
        WHERE material = 'sosna' and n.id is null
        group by trumny.id, n.id
        limit 1)
    select id from pierwsza
) where imie='Hugo Steinhaus';

-- Dodanie Steinhausa do odpowiedniej krypty
update trumny
set id_krypty = 3
where id=(
    SELECT id_trumny
    from nieboszczycy
    where imie = 'Hugo Steinhaus'
);

-- Dodanie Kuratowskiemu sosnowej trumny
update nieboszczycy
set id_trumny = (
    with pierwsza as (
        SELECT trumny.* from trumny left join nieboszczycy n on trumny.id = n.id_trumny
        WHERE material = 'sosna' and n.id is null
        group by trumny.id, n.id
        limit 1)
    select id from pierwsza
) where imie='Kazimierz Kuratowski';

-- Dodanie Kuratowskiego do odpowiedniej krypty
update trumny
set id_krypty = 4
where id=(
    SELECT id_trumny
    from nieboszczycy
    where imie = 'Kazimierz Kuratowski'
);

-- -- Nadanie Wolszczanowi odpowiedniej urny
UPDATE nieboszczycy
SET id_urny=2
WHERE imie = 'Aleksander Wolszczan';




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
