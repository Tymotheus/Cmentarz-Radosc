import psycopg2
from psycopg2 import Error
import datetime

# Decorator for connection with the database
# The connection is opened for each query and then immediately closed
def postgres_connection(func):
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

# chce to wywolywać tak - wstaw_krypte(nazwa_z_formularza, pojemnosc_z_formularza)
@postgres_connection
def wstaw_krypte(nazwa, pojemnosc):
    return f"INSERT INTO krypty (nazwa, pojemnosc) VALUES ('{nazwa}', {pojemnosc})"

@postgres_connection
def wstaw_nieboszczyka(imie, data_urodzenia, data_zgonu):
    return f"INSERT INTO nieboszczycy (imie, data_urodzenia, data_zgonu) VALUES ('{imie}', '{data_urodzenia}', '{data_zgonu}')"

@postgres_connection
def wstaw_kostnice(nazwa):
    return f"INSERT INTO kostnice (nazwa) VALUES ('{nazwa}')"

@postgres_connection
def wstaw_krematorium(nazwa):
    return f"INSERT INTO krematoria (nazwa) VALUES ('{nazwa}')"
