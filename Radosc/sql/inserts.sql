-- 4. Seeding the database

-- Dodawanie krypt
insert into krypty (nazwa, pojemnosc, wybudowano) VALUES
('Krypta Odrodzenia', 4, '1452-04-15'),
('Krypta św. Leonarda', 10, '1117-12-25'),
('Krypta 101', 13, '2011-09-14'),
('Krypta Norymberska', 2, '1928-08-02');

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
( 'Stefan Banach', '1892-04-30', '1945.08.31'),
( 'Hugo Steinhaus', '1887-01-14', '1972-02-25'),
( 'Stanisław Ulam', '3-04-1909', '1984-05-13'),
( 'Kazimierz Kuratowski', '1896.2.02', '1980.06.18'),
( 'Wacław Sierpiński', '1882.03.14', '1969.10.21') ,
( 'Marian Smoluchowski', '1872.05.28', '1917.09.5'),
( 'Leopold Infeld', '1898.08.20', '1968.01.15'),
( 'Aleksander Wolszczan', '1946.04.29', '2036.11.10'),
( 'Karol Borsuk', '1905.05.08', '1982.01.24'),
( 'Stanisław Mazur', '1905.01.01', '1981.11.5'),
( 'Marian Rejewski', '1905.08.16', '1980.02.13');

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

-- Nadanie jego trumnie odpowiedniej krypty o id 2 (takiej trumnie która trzyma Banacha)
update trumny
set id_krypty = 2
where id=(
    SELECT id_trumny
    from nieboszczycy
    where imie = 'Stefan Banach'
);

-- -- Nadanie Ulamowi odpowiedniej urny o id=1
UPDATE nieboszczycy
SET id_urny=1
WHERE imie = 'Stanisław Ulam';

UPDATE urny
SET id_krypty=4
where id=(
    SELECT id_urny
    from nieboszczycy
    where imie = 'Stanisław Ulam'
);
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
set id_krypty = 1
where id=(
    SELECT id_trumny
    from nieboszczycy
    where imie = 'Kazimierz Kuratowski'
);

-- -- Nadanie Wolszczanowi odpowiedniej urny
UPDATE nieboszczycy
SET id_urny=2
WHERE imie = 'Aleksander Wolszczan';