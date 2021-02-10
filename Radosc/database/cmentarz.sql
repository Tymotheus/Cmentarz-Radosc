-- 1. Initiating the database
DROP TYPE IF EXISTS material_nagrobka CASCADE ;
CREATE TYPE "material_nagrobka" AS ENUM (
  'granit',
  'marmur',
  'piaskowiec'
);

DROP TYPE IF EXISTS material_trumny CASCADE;
CREATE TYPE "material_trumny" AS ENUM (
  'olcha',
  'sosna',
  'dab'
);

DROP TYPE IF EXISTS material_urny CASCADE ;
CREATE TYPE "material_urny" AS ENUM (
  'metal',
  'kamien',
  'mosiadz',
  'drewno',
  'szklo'
);

DROP TABLE IF EXISTS nieboszczycy;
CREATE TABLE "nieboszczycy" (
  "id" SERIAL PRIMARY KEY,
  "trumna" int,
  "urna" int,
  "data_urodzenia" date,
  "data_zgonu" date
);


DROP TABLE IF EXISTS trumny;
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
  "material" material_nagrobka
);

DROP TABLE IF EXISTS kostnice;
CREATE TABLE "kostnice" (
  "id" SERIAL PRIMARY KEY
);

DROP TABLE IF EXISTS urny;
CREATE TABLE "urny" (
  "id" int PRIMARY KEY,
  "material" material_urny,
  "id_krematorium" int
);

DROP TABLE IF EXISTS krematoria;
CREATE TABLE "krematoria" (
  "id" int PRIMARY KEY
);

DROP TABLE IF EXISTS krypty;
CREATE TABLE "krypty" (
  "id" int PRIMARY KEY,
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
  "id" int PRIMARY KEY
);

DROP TABLE IF EXISTS prac_administracyjni;
CREATE TABLE "prac_administracyjni" (
  "id" int PRIMARY KEY
);

DROP TABLE IF EXISTS biura;
CREATE TABLE "biura" (
  "id" int PRIMARY KEY
);

ALTER TABLE "nieboszczycy" ADD FOREIGN KEY ("trumna") REFERENCES "trumny" ("id");

ALTER TABLE "nieboszczycy" ADD FOREIGN KEY ("urna") REFERENCES "urny" ("id");

ALTER TABLE "trumny" ADD FOREIGN KEY ("id_nagrobka") REFERENCES "nagrobki" ("id");

ALTER TABLE "trumny" ADD FOREIGN KEY ("id_krypty") REFERENCES "krypty" ("id");

ALTER TABLE "urny" ADD FOREIGN KEY ("id_krematorium") REFERENCES "krematoria" ("id");

ALTER TABLE "trumny" ADD FOREIGN KEY ("id_kostnicy") REFERENCES "kostnice" ("id");


