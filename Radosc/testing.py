import psycopg2
from psycopg2 import Error

try:
    #connect to an existing database
    connection = psycopg2.connect(user="postgres",
                                  password="postgres",
                                  host="localhost",
                                  port="5432",
                                  database="postgres")
    # Create a cursor to perform database operations
    print("Connection:")
    print(connection)
    cursor = connection.cursor()
    # Print Postgres details
    print("PostgreSQL server information")
    print(connection.get_dsn_parameters(), "\n")
    # Executing SQL queries
    cursor.execute("SELECT version();")
     # Fetch result
    record = cursor.fetchone()
    print("You are connected to - ", record, "\n")
    cursor.execute("SELECT * from nieboszczycy;")
    record = cursor.fetchall()
    print("Wynik - ", record, "\n")
except (Exception, Error) as error:
    print("Error while connecting to PostgreSQL", error)
finally:
    if (connection):
        cursor.close()
        connection.close()
        print("PostgreSQL connection is closed")
