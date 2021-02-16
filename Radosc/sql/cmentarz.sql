-- 1. Initiating the database
-- Enums
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

-- Tables
DROP TABLE IF EXISTS nieboszczycy CASCADE;
CREATE TABLE "nieboszczycy" (
  "id" SERIAL PRIMARY KEY,
  "imie" varchar,
  "data_urodzenia" date,
  "data_zgonu" date,
  "id_trumny" int,
  "id_urny" int
);

DROP TABLE IF EXISTS trumny CASCADE ;
CREATE TABLE "trumny" (
  "id" SERIAL PRIMARY KEY,
  "material" material_trumny,
  "id_nagrobka" int,
  "id_krypty" int,
  "id_kostnicy" int
);

DROP TABLE IF EXISTS nagrobki;
CREATE TABLE "nagrobki" (
  "id" SERIAL PRIMARY KEY,
  "material" material_nagrobka,
  "imie" varchar
);

DROP TABLE IF EXISTS kostnice;
CREATE TABLE "kostnice" (
  "id" SERIAL PRIMARY KEY,
  "nazwa" varchar
);

DROP TABLE IF EXISTS urny;
CREATE TABLE "urny" (
  "id" SERIAL PRIMARY KEY,
  "material" material_urny,
  "id_krypty" int,
  "id_krematorium" int
);

DROP TABLE IF EXISTS krematoria;
CREATE TABLE "krematoria" (
  "id" SERIAL PRIMARY KEY,
  "nazwa" varchar
);

DROP TABLE IF EXISTS krypty;
CREATE TABLE "krypty" (
  "id" SERIAL PRIMARY KEY,
  "nazwa" varchar,
  "pojemnosc" int,
  "liczba_trumien" int,
  "wybudowano" date DEFAULT (now())
);

DROP TABLE IF EXISTS pracownicy;
CREATE TABLE "pracownicy" (
  "id" SERIAL PRIMARY KEY
);

DROP TABLE IF EXISTS grabarze;
CREATE TABLE "grabarze" (
  "id" SERIAL PRIMARY KEY
);

DROP TABLE IF EXISTS sprzatacze;
CREATE TABLE "sprzatacze" (
  "id" SERIAL PRIMARY KEY
);

DROP TABLE IF EXISTS prac_administracyjni;
CREATE TABLE "prac_administracyjni" (
  "id" SERIAL PRIMARY KEY
);

DROP TABLE IF EXISTS biura;
CREATE TABLE "biura" (
  "id" SERIAL PRIMARY KEY
);

-- Relationships
ALTER TABLE "nieboszczycy" ADD FOREIGN KEY ("id_trumny") REFERENCES "trumny" ("id");

ALTER TABLE "nieboszczycy" ADD FOREIGN KEY ("id_urny") REFERENCES "urny" ("id");

ALTER TABLE "trumny" ADD FOREIGN KEY ("id_nagrobka") REFERENCES "nagrobki" ("id");

ALTER TABLE "trumny" ADD FOREIGN KEY ("id_krypty") REFERENCES "krypty" ("id");

ALTER TABLE "urny" ADD FOREIGN KEY ("id_krematorium") REFERENCES "krematoria" ("id");

ALTER TABLE "trumny" ADD FOREIGN KEY ("id_kostnicy") REFERENCES "kostnice" ("id");

insert into krypty (nazwa, pojemnosc, wybudowano) VALUES
('Krypta Odrodzenia', 4, '15.04.1452'),
('Krypta św. Leonarda', 10, '25.12.1117');


-- Dodawanie kostnic
INSERT INTO kostnice (nazwa) VALUES
('Casablanca');

-- Dodawanie krematoriów
INSERT INTO krematoria (nazwa) VALUES
('Jordan');
-- Dodawanie trumien
INSERT INTO trumny (material, id_kostnicy) VALUES
('olcha', 1),
('sosna', 1),
('dąb', 1),
('dąb', 1),
('sosna', 1),
('olcha', 1)                                                 ;

-- Dodawanie urn
insert into urny (material, id_krematorium) VALUES
('mosiądz', 1),
('drewno', 1),
('kamień', 1);


-- Dodawanie nagrobków
INSERT INTO nagrobki (material) VALUES
('granit'),
('marmur'),
('piaskowiec');


-- Dodawanie nieboszczyków
INSERT INTO nieboszczycy (imie, data_urodzenia, data_zgonu) VALUES
( 'Stefan Banach', '30.04.1892', '31.08.1945'),
( 'Hugo Steinhaus', '14.01.1887', '25.02.1972'),
( 'Stanisław Ulam', '3.04.1909', '13.05.1984'),
( 'Kazimierz Kuratowski', '2.02.1896', '18.06.1980'),
( 'Wacław Sierpiński', '14.03.1882', '21.10.1969') ,
( 'Marian Smoluchowski', '28.05.1872', '5.09.1917'),
( 'Leopold Infeld', '20.08.1898', '15.01.1968'),
( 'Aleksander Wolszczan', '29.04.1946', '10.11.2036')                                                                   ;

-- Nadanie Banachowi odpowiedniej trumny
-- Ustaw Banachowi pierwszą dębową trumnę
update nieboszczycy
set id_trumny = (
    with id_trumny as (
    select * from trumny where material = 'dąb' and id_krypty is null and id_nagrobka is null limit 1
) select id from id_trumny
) where imie='Stefan Banach';

-- Nadanie jego trumnie odpowiedniej krypty 1 (takiej trumnie która trzyma Banacha)
update trumny
set id_krypty = 1
where id=(
    SELECT id_trumny
    from nieboszczycy
    where imie = 'Stefan Banach'
);

-- -- Nadanie Ulamowi odpowiedniej urny
UPDATE nieboszczycy
SET id_urny=1
WHERE imie = 'Stanisław Ulam';


--Dodanie Sierpińskiemu odpowiedniej trumny - pierwszej olszanej
UPDATE nieboszczycy
SET id_trumny = (
    with id_trumny as (
        select * from trumny where material = 'olcha' and id_krypty is null and id_nagrobka is null limit 1
    )
    select id
    from id_trumny
)WHERE imie='Wacław Sierpiński';

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

-- Nagrobek trzymający Sierpińskiego
select nagrobki.* from nagrobki
    inner join trumny on nagrobki.id=trumny.id_nagrobka
    inner join nieboszczycy on nieboszczycy.id_trumny = trumny.id
where nieboszczycy.imie='Wacław Sierpiński';

-- Dodanie Smoluchowskiemu dębowej trumny
update nieboszczycy
set id_trumny = (
    with id_trumny as (
    select * from trumny where material = 'dąb' and id_krypty is null and id_nagrobka is null limit 1
) select id from id_trumny
) where imie='Marian Smoluchowski';

-- Dodanie Smoluchowskiego do odpowiedniej krypty
update trumny
set id_krypty = 1
where id=(
    SELECT id_trumny
    from nieboszczycy
    where imie = 'Wacław Sierpiński'
);

-- Dodanie Infeldowi sosnowej trumny
update nieboszczycy
set id_trumny = (
    with id_trumny as (
    select * from trumny where material = 'sosna' and id_krypty is null and id_nagrobka is null limit 1
) select id from id_trumny
) where imie='Leopold Infeld';

-- Dodanie Infelda do odpowiedniej krypty
update trumny
set id_krypty = 2
where id=(
    SELECT id_trumny
    from nieboszczycy
    where imie = 'Leopold Infeld'
);

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