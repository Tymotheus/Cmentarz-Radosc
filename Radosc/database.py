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
            connection = psycopg2.connect(user="postgres",
                                          password="postgres",
                                          host="localhost",
                                          port="5432",
                                          database="postgres")
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
            connection = psycopg2.connect(user="postgres",
                                          password="postgres",
                                          host="localhost",
                                          port="5432",
                                          database="postgres")
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

@postgres_send
def set_client_role():
    print('Set role to client')
    return f"SET ROLE klient"

@postgres_send
def set_admin_role():
    print('Set role to admin')
    return f"SET ROLE admin"

# pobieranie danych z bazki
@postgres_get
def pobierz_krypty():
    return f"SELECT * FROM krypty ORDER BY ID"

@postgres_get
def pobierz_nieboszczykow():
    return f"""SELECT * FROM nieboszczycy
                WHERE id_urny is not null OR id_trumny is not null
                ORDER BY ID"""

@postgres_get
def pobierz_nieprzypisanych_nieboszczykow():
    return f"SELECT * from nieboszczycy WHERE id_trumny is null and id_urny is null"

@postgres_get
def pobierz_kostnice():
    return f"SELECT * FROM kostnice"

@postgres_get
def pobierz_krematoria():
    return f"SELECT * FROM krematoria"

@postgres_get
def pobierz_sredni_wiek():
    return f"SELECT * FROM srednia_wieku"

@postgres_get
def pobierz_zajete_nagrobki():
    return f"""SELECT nagrobki.id, nagrobki.material, nagrobki.imie \
                FROM nagrobki  \
                inner join trumny on nagrobki.id = trumny.id_nagrobka \
                inner join nieboszczycy on nieboszczycy.id_trumny = trumny.id"""

@postgres_get
def pobierz_nieprzypisane_trumny():
    return f"SELECT * FROM nieprzypisane_trumny"

@postgres_get
def pobierz_nieprzypisane_urny():
    return f"SELECT * FROM nieprzypisane_urny"

@postgres_get
def pobierz_nieprzypisane_nagrobki():
    return f"SELECT * FROM nagrobki WHERE imie is null"

@postgres_get
def pobierz_puste_trumny():
    return "SELECT * FROM puste_trumny"

@postgres_get
def pobierz_puste_urny():
    return "SELECT * FROM puste_urny"

#wyszukuje konretnego nieboszczyka
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
    return f"SELECT nieboszczycy.imie, nieboszczycy.data_urodzenia, nieboszczycy.data_zgonu, trumny.material as Trumna \
        FROM nieboszczycy inner join trumny on nieboszczycy.id_trumny = trumny.id \
        inner join krypty on trumny.id_krypty=krypty.id \
        WHERE krypty.nazwa = ('{nazwa}') "

#zwraca wszystkich mieszkancow danej krypty mieszkajacych w urnach
@postgres_get
def mieszkancy_krypty_urny(nazwa):
    return f"SELECT nieboszczycy.imie, nieboszczycy.data_urodzenia, nieboszczycy.data_zgonu, urny.material as Urna \
FROM nieboszczycy inner join urny on nieboszczycy.id_urny = urny.id \
    inner join krypty on urny.id_krypty=krypty.id \
WHERE krypty.nazwa = ('{nazwa}') "

# wstawianie danych do bazki
@postgres_send
def wstaw_krypte(nazwa, pojemnosc):
    return f"INSERT INTO krypty (nazwa, pojemnosc) VALUES ('{nazwa}', {pojemnosc})"

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
    return f"INSERT INTO nieboszczycy (imie, data_urodzenia, data_zgonu) VALUES ('{imie}', '{data_urodzenia}', '{data_zgonu}')"

@postgres_send
def wstaw_kostnice(nazwa):
    return f"INSERT INTO kostnice (nazwa) VALUES ('{nazwa}')"

@postgres_send
def wstaw_krematorium(nazwa):
    return f"INSERT INTO krematoria (nazwa) VALUES ('{nazwa}')"

@postgres_send
def przypisz_trumnie_krypte(id_trumny, id_krypty):
    return f"UPDATE trumny SET id_krypty=('{id_krypty}') WHERE id=('{id_trumny }')"

@postgres_send
def przypisz_trumnie_nagrobek(id_trumny, id_nagrobka):
    return f"UPDATE trumny SET id_nagrobka=('{id_nagrobka}') WHERE id=('{id_trumny }')"

@postgres_send
def przypisz_urnie_krypte(id_urny, id_krypty):
    return f"UPDATE urny SET id_krypty=('{id_krypty}') WHERE id=('{id_urny }')"


@postgres_send
def przypisz_nieboszczyka_do_trumny(id_nieboszczyka, id_trumny):
    return f"""UPDATE nieboszczycy
                SET id_trumny = {id_trumny}
                WHERE nieboszczycy.id = ({id_nieboszczyka})
                """

@postgres_send
def przypisz_nieboszczyka_do_urny(id_nieboszczyka, id_urny):
    return f"""UPDATE nieboszczycy
                SET id_urny = {id_urny}
                WHERE nieboszczycy.id = ({id_nieboszczyka})
                """
