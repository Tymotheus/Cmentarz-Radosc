-- Dodawanie krypt
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