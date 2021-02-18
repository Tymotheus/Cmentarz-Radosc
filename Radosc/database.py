import psycopg2
from psycopg2 import Error
import datetime

# Decorator for connection with the database
# The connection is opened for each query and then immediately closed
def postgres_get(func):
    def wrapped_function(*args, **kwargs):
        # print("Inside a decorator")
        # print("I will establish the connection now")
        try:
            #change those values to your database's
            connection = psycopg2.connect(user="oxshwzrq",
                                          password="9ZKvgKkiRx4DeHNoawPToBdgpXl-DXtn",
                                          host="balarama.db.elephantsql.com",
                                          port="5432",
                                          database="oxshwzrq")
            # print("Connection:")
            # print(connection)
            cursor = connection.cursor()
            cursor.execute(func(*args, **kwargs))
            connection.commit()
            result = cursor.fetchall()
        except (Exception, Error) as error:
            print("Error while connecting to PostgresQL", error)
        finally:
            if (connection):
                cursor.close()
                connection.close()
                # print("PostgreSQL connection is closed")
            return result
    return wrapped_function


def postgres_send(func):
    def wrapped_function(*args, **kwargs):
        # print("Inside a decorator")
        # print("I will establish the connection now")
        try:
            #change those values to your database's
            connection = psycopg2.connect(user="oxshwzrq",
                                          password="9ZKvgKkiRx4DeHNoawPToBdgpXl-DXtn",
                                          host="balarama.db.elephantsql.com",
                                          port="5432",
                                          database="oxshwzrq")
            print("Connection:")
            print(connection)
            cursor = connection.cursor()
            cursor.execute(func(*args, **kwargs))
            connection.commit()
        except (Exception, Error) as error:
            print("Error while connecting to PostgresQL", error)
        finally:
            if (connection):
                cursor.close()
                connection.close()
                # print("PostgreSQL connection is closed")
    return wrapped_function

#TO DO: Check whether this should be invoked for every other query
# Maybe also as a decorator???
@postgres_send
def set_client_role():
    print('Set role to client')
    return f"SET ROLE klient"

#TO DO: The same as with set_client_role
@postgres_send
def set_admin_role():
    print('Set role to admin')
    return f"SET ROLE admin"

# pobieranie wszystkie krypty z bazy
@postgres_get
def pobierz_krypty():
    return f"SELECT * FROM krypty ORDER BY ID"

# pobiera nieboszczyków którzy są w trumnie albo w urnie
# = wstępnie (lub w pełni) obsłużeni klienci
@postgres_get
def pobierz_nieboszczykow():
    return f"""SELECT * FROM nieboszczycy
                WHERE id_urny is not null OR id_trumny is not null
                ORDER BY ID"""

#pobiera nieboszczyków którzy nie znajdują się w żadnej urnie ani trumnie
# = zostali jedynie zarejestrowani przez klientów
@postgres_get
def pobierz_nieprzypisanych_nieboszczykow():
    return f"SELECT * from nieboszczycy WHERE id_trumny is null and id_urny is null"

#pobiera wszystkie kostnice z bazy
@postgres_get
def pobierz_kostnice():
    return f"SELECT * FROM kostnice"

#pobiera wszystkie krematoria z bazy
@postgres_get
def pobierz_krematoria():
    return f"SELECT * FROM krematoria"

#pobiera średnią wieku wszystkich nieboszczyków z bazy
#korzysta z odpowiedniego widoku
@postgres_get
def pobierz_sredni_wiek():
    return f"SELECT * FROM srednia_wieku"

#pobiera wszystkie nagrobki z bazy, pod którymi znajduje się trumna
@postgres_get
def pobierz_zajete_nagrobki():
    return f"""SELECT nagrobki.id, nagrobki.material, nagrobki.imie \
                FROM nagrobki  \
                inner join trumny on nagrobki.id = trumny.id_nagrobka \
                inner join nieboszczycy on nieboszczycy.id_trumny = trumny.id"""

# pobiera wszystkie trumny z bazy, które mają nieboszczyka w środku,
# ale nie są jeszcze przypisane do krypty albo nagrobka
@postgres_get
def pobierz_nieprzypisane_trumny():
    return f"SELECT * FROM nieprzypisane_trumny"

# pobiera wszystkie urny z bazy, które mają nieboszczyka w środku,
# ale nie są jeszcze przypisane do krypty
@postgres_get
def pobierz_nieprzypisane_urny():
    return f"SELECT * FROM nieprzypisane_urny"

# pobiera wszystkie nagrobki z bazy, które nie mają przypisanego żadnego nieboszczyka
@postgres_get
def pobierz_nieprzypisane_nagrobki():
    return f"SELECT * FROM nagrobki WHERE imie is null"

# pobiera wszystkie puste trumny bez nieboszczyków
# korzysta z widoku puste_trumny
@postgres_get
def pobierz_puste_trumny():
    return "SELECT * FROM puste_trumny"

# pobiera wszystkie puste urny bez nieboszczyków
# korzysta z widoku puste_urny
@postgres_get
def pobierz_puste_urny():
    return "SELECT * FROM puste_urny"

#pobiera wszystkich zarejestrowanych w bazie trumniarzy
@postgres_get
def pobierz_trumniarzy():
    return "SELECT * FROM trumniarze"

#pobiera wszystkich zarejestrowanych w bazie urniarzy
@postgres_get
def pobierz_urniarzy():
    return "SELECT * FROM urniarze"

#pobiera wszystkich zarejestrowanych w bazie sprzataczy
@postgres_get
def pobierz_sprzataczy():
    return "SELECT * FROM sprzatacze"

#wyszukuje konretnego nieboszczyka w bazie
@postgres_get
def wyszukaj_nieboszczyka(imie):
    return f"SELECT * FROM nieboszczycy where imie=('{imie}')"

#wyszukuje mieszkancow konkretnej krypty
#korzystajac ze stworzonego wczesniej widoku
@postgres_get
def mieszkancy_odrodzenia():
    return f"SELECT imie, trumna FROM Mieszkancy_Odrodzenia"

#zwraca wszystkich mieszkancow danej krypty mieszkajacych w trumnach
#ich: imie, daty urodzenia i smierci i material trumny
#struktura wyniku: [(imie1, urodzenie1, zgon1, material1), (imie2, urodzenie2...)...]
@postgres_get
def mieszkancy_krypty_trumny(nazwa):
    return f"""SELECT nieboszczycy.imie, nieboszczycy.data_urodzenia,
            nieboszczycy.data_zgonu, trumny.material as Trumna
        FROM nieboszczycy inner join trumny on nieboszczycy.id_trumny = trumny.id
        inner join krypty on trumny.id_krypty=krypty.id
        WHERE krypty.nazwa = ('{nazwa}') """

#zwraca wszystkich mieszkancow danej krypty mieszkajacych w urnach
#analogicznie do powyższego
@postgres_get
def mieszkancy_krypty_urny(nazwa):
    return f"""SELECT nieboszczycy.imie, nieboszczycy.data_urodzenia,
            nieboszczycy.data_zgonu, urny.material as Urna
            FROM nieboszczycy inner join urny on nieboszczycy.id_urny = urny.id
            inner join krypty on urny.id_krypty=krypty.id
            WHERE krypty.nazwa = ('{nazwa}') """

# wstawia kryptę do bazy
@postgres_send
def wstaw_krypte(nazwa, pojemnosc):
    return f"INSERT INTO krypty (nazwa, pojemnosc) VALUES ('{nazwa}', {pojemnosc})"

# wstawia nieboszczyka do bazy
@postgres_send
def wstaw_nieboszczyka(imie, data_urodzenia, data_zgonu):
    id_trumny = None
    id_urny = None
    if id_trumny is not None:
        print("Opcja z trumną")
        pass
    elif id_urny is not None:
        print("Opcja z urną")
        pass
    return f"""INSERT INTO nieboszczycy (imie, data_urodzenia, data_zgonu)
            VALUES ('{imie}', '{data_urodzenia}', '{data_zgonu}')"""

# wstawia kostnicę do bazy
@postgres_send
def wstaw_kostnice(nazwa):
    return f"INSERT INTO kostnice (nazwa) VALUES ('{nazwa}')"

# wstawia krematorium do bazy
@postgres_send
def wstaw_krematorium(nazwa):
    return f"INSERT INTO krematoria (nazwa) VALUES ('{nazwa}')"

# przypisuje danej trumnie daną kryptę
@postgres_send
def przypisz_trumnie_krypte(id_trumny, id_krypty):
    return f"UPDATE trumny SET id_krypty=('{id_krypty}') WHERE id=('{id_trumny }')"

# przypisuje danej trumnie dany nagrobek
@postgres_send
def przypisz_trumnie_nagrobek(id_trumny, id_nagrobka):
    return f"UPDATE trumny SET id_nagrobka=('{id_nagrobka}') WHERE id=('{id_trumny }')"

# przypisuje danej urnie daną kryptę
@postgres_send
def przypisz_urnie_krypte(id_urny, id_krypty):
    return f"UPDATE urny SET id_krypty=('{id_krypty}') WHERE id=('{id_urny }')"

# przypisuje danemu nieboszczykowi daną trumnę
@postgres_send
def przypisz_nieboszczyka_do_trumny(id_nieboszczyka, id_trumny):
    return f"""UPDATE nieboszczycy
                SET id_trumny = {id_trumny}
                WHERE nieboszczycy.id = ({id_nieboszczyka})
                """

# przypisuje danemu nieboszczykowi daną urnę
@postgres_send
def przypisz_nieboszczyka_do_urny(id_nieboszczyka, id_urny):
    return f"""UPDATE nieboszczycy
                SET id_urny = {id_urny}
                WHERE nieboszczycy.id = ({id_nieboszczyka})
                """

#dodaje do bazy trumniarza o podanym imieniu
@postgres_send
def dodaj_trumniarza(imie):
    return f"INSERT INTO trumniarze(imie) VALUES ('{imie}')"

#dodaje do bazy urniarza o podanym imieniu
@postgres_send
def dodaj_urniarza(imie):
    return f"INSERT INTO urniarze(imie) VALUES ('{imie}')"

#dodaje do bazy sprzątacza o podanym imieniu
@postgres_send
def dodaj_sprzatacza(imie):
    return f"INSERT INTO sprzatacze(imie) VALUES ('{imie}')"

#dodaje do bazy trumnę z danego materiału, wyprodukowana w danej kostnicy
@postgres_send
def dodaj_trumne(material, id_kostnicy):
    return f"""INSERT INTO trumny(material, id_kostnicy)
            VALUES ('{material}', {id_kostnicy})"""

#dodaje do bazy urnę z danego materiału, wyprodukowaną w danym krematorium
@postgres_send
def dodaj_urne(material, id_krematorium):
    return f"""INSERT INTO urny(material, id_krematorium)
            VALUES ('{material}', {id_krematorium})"""

#dodaje do bazy nagrobek z danego materiału
@postgres_send
def dodaj_nagrobek(material):
    return f"INSERT INTO nagrobki(material) VALUES ('{material}')"
