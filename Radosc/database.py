import psycopg2
from psycopg2 import Error
import datetime

# Decorator for connection with the database
# The connection is opened for each query and then immediately closed
def postgres_get(func):
    def wrapped_function(*args, **kwargs):
        print("Inside a decorator")
        print("I will establish the connection now")
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
            result = cursor.fetchall()
        except (Exception, Error) as error:
            print("Error while connecting to PostgresQL", error)
        finally:
            if (connection):
                cursor.close()
                connection.close()
                print("PostgreSQL connection is closed")
            return result
    return wrapped_function


def postgres_send(func):
    def wrapped_function(*args, **kwargs):
        print("Inside a decorator")
        print("I will establish the connection now")
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
                print("PostgreSQL connection is closed")
    return wrapped_function

# pobieranie danych z bazki
@postgres_get
def pobierz_krypty():
    return f"SELECT * FROM krypty"

@postgres_get
def pobierz_nieboszczykow():
    return f"SELECT * FROM nieboszczycy"

@postgres_get
def pobierz_kostnice():
    return f"SELECT * FROM kostnice"

@postgres_get
def pobierz_krematoria():
    return f"SELECT * FROM krematoria"

@postgres_get
def pobierz_sredni_wiek():
    return f"SELECT * FROM srednia_wieku"

#wyszukuje konretnego nieboszczyka
@postgres_get
def wyszukaj_nieboszczyka(imie):
    return f"SELECT * FROM nieboszczycy where imie=('{imie}')"

# wstawianie danych do bazki
@postgres_send
def wstaw_krypte(nazwa, pojemnosc):
    return f"INSERT INTO krypty (nazwa, pojemnosc) VALUES ('{nazwa}', {pojemnosc})"

@postgres_send
def wstaw_nieboszczyka(imie, data_urodzenia, data_zgonu):
    return f"INSERT INTO nieboszczycy (imie, data_urodzenia, data_zgonu) VALUES ('{imie}', '{data_urodzenia}', '{data_zgonu}')"

@postgres_send
def wstaw_kostnice(nazwa):
    return f"INSERT INTO kostnice (nazwa) VALUES ('{nazwa}')"

@postgres_send
def wstaw_krematorium(nazwa):
    return f"INSERT INTO krematoria (nazwa) VALUES ('{nazwa}')"
