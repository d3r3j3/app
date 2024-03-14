import mysql.connector
from mysql.connector import errorcode
import sys

HOST = 'localhost'
USER = 'client'
PORT = '3306'
PASSWORD = 'client'
DATABASE = 'games'
CHARSET = 'utf8mb4'
DEBUG = True

def get_conn(user: str=USER, password: str=PASSWORD) -> mysql.connector.MySQLConnection:
    """"
    Returns a connected MySQL connector instance, if connection is successful.
    If unsuccessful, exits.
    """
    try:
        conn = mysql.connector.connect(
          host=HOST,
          user=user,
          port=PORT,
          password=password,
          database=DATABASE
        )
        print('Successfully connected.')
        return conn
    except mysql.connector.Error as err:
        if err.errno == errorcode.ER_ACCESS_DENIED_ERROR and DEBUG:
            sys.stderr('Incorrect username or password when connecting to DB.')
        elif err.errno == errorcode.ER_BAD_DB_ERROR and DEBUG:
            sys.stderr('Database does not exist.')
        elif DEBUG:
            sys.stderr(err)
        else:
            sys.stderr('An error occurred, please contact the administrator.')
        sys.exit(1)