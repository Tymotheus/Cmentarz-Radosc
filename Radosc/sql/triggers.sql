
-- 2. Creating array triggers

-- Trigger dbający o odpowiednie aktualizowanie liczby trumien w każdej krypcie
-- Kiedy trumna jest dodawana do krypty - inkrementuje zmienną lczba_trumien
-- Kiedy jest odejmowana - dekrementuje zmienną liczba_trumien

-- Note - I should also make sure that noone inserts too many trumnas
-- into one krypta (we can not exceed its capacity)

-- Funkcja dbająca o zlicznie trumn
CREATE OR REPLACE FUNCTION krypta1() RETURNS TRIGGER AS $example_table_1$
    DECLARE
        _liczba_trumien INTEGER = (Select liczba_trumien from krypty where id=NEW.id_krypty);
        _liczba_urn INTEGER = (Select liczba_urn from krypty where id=NEW.id_krypty);
        _pojemnosc INTEGER = (SELECT pojemnosc from krypty where id=NEW.id_krypty);
    BEGIN
        IF ( (_liczba_trumien+_liczba_urn) >= _pojemnosc) THEN
            RAISE exception 'Ta krypta jest już pełna';
        ELSE
            UPDATE krypty
            SET liczba_trumien = liczba_trumien + 1
            WHERE id = NEW.id_krypty;
            UPDATE krypty
            SET liczba_trumien = liczba_trumien - 1
            WHERE id = OLD.id_krypty;
            RETURN NEW;
        END IF;
    END
    $example_table_1$ LANGUAGE plpgsql;


DROP TRIGGER IF EXISTS  zaktualizuj_liczbe_trumien on trumny;
CREATE TRIGGER zaktualizuj_liczbe_trumien
    BEFORE UPDATE of id_krypty ON trumny
    FOR EACH ROW
    WHEN (OLD.id_krypty IS DISTINCT FROM NEW.id_krypty)
    EXECUTE PROCEDURE krypta1();


-- Funkcja dbajaca o zliczanie urn
CREATE OR REPLACE FUNCTION krypta2() RETURNS TRIGGER AS $example_table_2$
    DECLARE
        _liczba_urn INTEGER = (Select liczba_urn from krypty where id=NEW.id_krypty);
        _liczba_trumien INTEGER = (Select liczba_trumien from krypty where id=NEW.id_krypty);
        _pojemnosc INTEGER = (SELECT pojemnosc from krypty where id=NEW.id_krypty);
    BEGIN
        IF ( (_liczba_urn +_liczba_trumien)  >= _pojemnosc) THEN
            RAISE exception 'Ta krypta jest już pełna';
        ELSE
            UPDATE krypty
            SET liczba_urn = liczba_urn + 1
            WHERE id = NEW.id_krypty;
            UPDATE krypty
            SET liczba_urn = liczba_urn - 1
            WHERE id = OLD.id_krypty;
            RETURN NEW;
        END IF;
    END
    $example_table_2$ LANGUAGE plpgsql;

DROP TRIGGER if exists  zaktualizuj_liczbe_urn ON urny;
CREATE TRIGGER zaktualizuj_liczbe_urn
    BEFORE UPDATE of id_krypty ON urny
    FOR EACH ROW
    WHEN (OLD.id_krypty IS DISTINCT FROM NEW.id_krypty)
    EXECUTE PROCEDURE krypta2();


-- Funkcja dbająca o odpowiednie przypisywanie nagrobkom imion ich rezydentów
CREATE OR REPLACE FUNCTION nagrobek1() RETURNS TRIGGER AS $example_table_3$
    DECLARE
        _imie varchar = (SELECT imie from nieboszczycy where id_trumny=NEW.id);
    BEGIN
            UPDATE nagrobki
            SET imie = _imie
            WHERE id = NEW.id_nagrobka;
            RETURN NEW;
    END
    $example_table_3$ LANGUAGE plpgsql;


DROP TRIGGER IF EXISTS  zaktualizuj_imiona_nagrobka on trumny;
CREATE TRIGGER zaktualizuj_imiona_nagrobka
    BEFORE UPDATE of id_nagrobka ON trumny
    FOR EACH ROW
    WHEN (OLD.id_nagrobka IS DISTINCT FROM NEW.id_nagrobka)
    EXECUTE PROCEDURE nagrobek1();


-- Funkcja walidująca wprowadzane daty urodzenia i zgonu nieboszczyków
CREATE OR REPLACE FUNCTION nieboszczyk1() RETURNS TRIGGER AS $nieboszczykowy1$
    BEGIN
        RAISE exception 'Przepraszamy, nie akceptujemy nieumarłych!';
    END;
    $nieboszczykowy1$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS sprawdz_nieboszczyka_na_insert ON nieboszczycy;
CREATE TRIGGER sprawdz_nieboszczyka_na_insert
    BEFORE INSERT ON nieboszczycy
    FOR EACH ROW
    WHEN (NEW.data_urodzenia > NEW.data_zgonu)
    EXECUTE PROCEDURE nieboszczyk1();

-- Funkcja dbająca o to, aby trumna nie była dodana jednocześnie do krypty i nagrobka
CREATE OR REPLACE FUNCTION trumna1() RETURNS TRIGGER AS $trumniasty1$
    BEGIN
        RAISE exception 'Trumna może być dodana tylko do jednej krypty lub urny!';
    END;
    $trumniasty1$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS sprawdz_trumne_na_update ON trumny;
CREATE TRIGGER sprawdz_trumne_na_update
    BEFORE UPDATE ON trumny
    FOR EACH ROW
    WHEN (
        (NEW.id_nagrobka is not null and OLD.id_krypty is not null)
        OR (NEW.id_krypty is not null and OLD.id_nagrobka is not null)
        )
    EXECUTE PROCEDURE trumna1();
