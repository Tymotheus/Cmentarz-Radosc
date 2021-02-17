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
