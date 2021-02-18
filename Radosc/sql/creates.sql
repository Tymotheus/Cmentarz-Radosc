-- 1. Creating the database structure

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


-- Tables

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

-- Tablica asocjacyjna
DROP TABLE IF EXISTS sprzatanie_krypt;
CREATE TABLE "sprzatanie_krypt"(
    "id_sprzatacza" INT,
    "id_krypty" INT,
    "data" date DEFAULT (now())
);

-- Tablica asocjacyjna
DROP TABLE IF EXISTS wykonywanie_trumien;
CREATE TABLE "wykonywanie_trumien"(
    "id_trumniarza" INT,
    "id_trumny" INT,
    "data" date DEFAULT (now())
);

-- Tablica asocjacyjna
DROP TABLE IF EXISTS wykonywanie_urn;
CREATE TABLE "wykonywanie_urn"(
    "id_urniarza" INT,
    "id_urny" INT,
    "data" date DEFAULT (now())
);

-- Relacje
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
