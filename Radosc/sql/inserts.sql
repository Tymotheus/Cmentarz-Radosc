-- 3. Seeding the database

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

INSERT into trumniarze(imie) VALUES
('Jan z Kolna');

INSERT into trumny(material, id_kostnicy) VALUES
('olcha', 1);