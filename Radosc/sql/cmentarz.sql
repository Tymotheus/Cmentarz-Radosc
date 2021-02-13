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
DROP TABLE IF EXISTS nieboszczycy;
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

-- Dodawanie krypt
insert into krypty (nazwa, pojemnosc) VALUES
('Krypta Odrodzenia', 4);

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
('dąb', 1);

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
( 'Leopold Infeld', '20.08.1898', '15.01.1968');

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

-- -- Nadanie jego trumnie odpowiedniego nagrobka (takiej trumnie która trzyma Sierpińskiego)
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

SELECT * from nieboszczycy;
