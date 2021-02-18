-- Pierwsza dębowa trumna, która nie ma przypisanej krypty i nagrobka - wybiera tylko jedną, pierwszą
-- UWAGA!!! może wziąć trumnę z nieboszczykiem w środku :///
select * from trumny where material = 'dąb' and id_krypty is null and id_nagrobka is null limit 1;


-- Pierwsza dębowa trumna wolna bez nikogo w środku
SELECT * from trumny left join nieboszczycy n on trumny.id = n.id_trumny
WHERE material = 'dąb' and n.id is null
group by trumny.id, n.id
limit 1;


-- Wszystkie nagrobki które mają pod sobą trumnę z nieboszczykiem
SELECT nagrobki.id, nagrobki.material, nagrobki.imie
FROM nagrobki
    inner join trumny on nagrobki.id = trumny.id_nagrobka
    inner join nieboszczycy on nieboszczycy.id_trumny = trumny.id;

-- Nieboszczycy i trumny dla nieboszczyków pochowanych w jakiejś trumnie bądź w krypcie
Select * from nieboszczycy left join trumny on nieboszczycy.id_trumny=trumny.id where nieboszczycy.id_trumny is not null or nieboszczycy.id_urny is not null;

-- Nagrobek trzymający Sierpińskiego
select nagrobki.* from nagrobki
    inner join trumny on nagrobki.id=trumny.id_nagrobka
    inner join nieboszczycy on nieboszczycy.id_trumny = trumny.id
where nieboszczycy.imie='Wacław Sierpiński';

-- Wolne nagrobki
SELECT * from nagrobki
WHERE imie is null ;

-- Wszystkie wolne trumny
SELECT trumny.* from trumny left join nieboszczycy n on trumny.id = n.id_trumny
    WHERE n.id is null
    group by trumny.id, n.id;

-- Nieboszczycy bez trumien (i urn!) :/
SELECT * from nieboszczycy
WHERE id_trumny is null and id_urny is null;
