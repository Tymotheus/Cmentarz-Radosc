-- Views

-- Urodzeni po dacie - wyzwoleniu Krakowa spod okupacji
CREATE OR REPLACE VIEW Urodzeni_po_Wyzwoleniu AS
SELECT imie, data_urodzenia, data_zgonu
FROM nieboszczycy
WHERE CAST(nieboszczycy.data_urodzenia AS Date) > '1945-01-18';

-- Klienci z konkretnej krypty
CREATE OR REPLACE VIEW Mieszkancy_Odrodzenia AS
SELECT krypty.nazwa, nieboszczycy.imie, nieboszczycy.data_urodzenia, nieboszczycy.data_zgonu, trumny.material as Trumna
FROM nieboszczycy inner join trumny on nieboszczycy.id_trumny = trumny.id
    inner join krypty on trumny.id_krypty=krypty.id
WHERE krypty.nazwa = 'Krypta Odrodzenia';

SELECT imie, trumna FROM Mieszkancy_Odrodzenia;

-- Srednia wieku naszych klientow - ile sobie żyli
CREATE OR REPLACE VIEW srednia_wieku AS
    SELECT AVG( EXTRACT( YEAR FROM nieboszczycy.data_zgonu) - EXTRACT( YEAR FROM data_urodzenia))
    FROM nieboszczycy;

-- Pogrupowane trumien materiałami - i policzone
CREATE OR REPLACE VIEW materialy_trumien AS
    SELECT trumny.material, count(*) AS Ilosc FROM nieboszczycy
        inner join trumny on nieboszczycy.id_trumny = trumny.id
        GROUP BY trumny.material;


-- Wszystkie trumny nieprzypisane nigdzie z trupkiem w środku
CREATE OR REPLACE VIEW nieprzypisane_trumny AS
    SELECT trumny.id, trumny.material, n.imie FROM trumny
        inner join nieboszczycy n on trumny.id = n.id_trumny
        WHERE trumny.id_krypty is null and trumny.id_nagrobka is null
    Group By trumny.id, n.imie;

-- Wszystkie urny nieprzypisane nigdzie z nieboszczykiem w środku
CREATE OR REPLACE VIEW nieprzypisane_urny AS
    SELECT urny.id, urny.material, n.imie FROM urny
        inner join nieboszczycy n on urny.id = n.id_urny
        WHERE urny.id_krypty is null
    Group By urny.id, n.imie;

-- Wszystkie puste trumny
CREATE OR REPLACE VIEW puste_trumny AS
    SELECT trumny.* from trumny left join nieboszczycy n on trumny.id = n.id_trumny
        WHERE n.id is null
        group by trumny.id, n.id;

-- Wszystkie puste urny
CREATE OR REPLACE VIEW puste_urny AS
    SELECT urny.* from urny left join nieboszczycy n on urny.id = n.id_urny
        WHERE n.id is null
        group by urny.id, n.id;


SELECT * from nieprzypisane_urny;
SELECT * from materialy_trumien;