-- Pierwsza dębowa trumna, która jest pusta (nie ma przypsanej krypty i nagrobka) - wybiera tylko jedną, pierwszą
select * from trumny where material = 'dąb' and id_krypty is null and id_nagrobka is null limit 1;

-- Wszystkie nagrobki które mają pod sobą trumnę z nieboszczykiem
SELECT * from nagrobki inner  join trumny on nagrobki.id = trumny.id_nagrobka inner join nieboszczycy on nieboszczycy.id = trumny.id;

-- Nieboszczycy i trumny dla nieboszczyków pochowanych w jakiejś trumnie bądź w krypcie
Select * from nieboszczycy left join trumny on nieboszczycy.trumna=trumny.id where nieboszczycy.trumna is not null or nieboszczycy.urna is not null;