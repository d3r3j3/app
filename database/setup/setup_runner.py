import mysql.connector
from mysql.connector import errorcode

# connect to the database
def connect_to_database(username: str = 'root', password: str = 'root', host: str = 'localhost', database: str = None):
    try:

        if database:
            conn = mysql.connector.connect(
                user=username,
                password=password,
                host=host,
                database=database,
                allow_local_infile=True
            )
        else:
            conn = mysql.connector.connect(
                user=username,
                password=password,
                host=host
            )

        return conn
    except mysql.connector.Error as err:
        if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
            print("Something is wrong with your user name or password")
        elif err.errno == errorcode.ER_BAD_DB_ERROR:
            print("Database does not exist")
        else:
            print(err)

def conn_client():
    return connect_to_database(
        username='client',
        password='client',
        host='localhost',
        database='games'
    )

def conn_admin():
    return connect_to_database(
        username='admin',
        password='admin',
        host='localhost',
        database='games'
    )

# create the database
def run_setup():
    conn = connect_to_database()
    with conn.cursor() as cursor:
        with open('setup_python.sql') as f:
            cursor.execute(f.read(), multi=True)
        
    conn.close()

from csv_parser import create_csv_tables

def run_parser():
    csvs = create_csv_tables()

    # add the csv data to the database
    conn = conn_admin()

    with conn.cursor() as cursor:
        for csv_name, table_name in csvs:
            query = f"LOAD DATA LOCAL INFILE '{csv_name}' INTO TABLE {table_name} CHARACTER SET utf8mb4 FIELDS TERMINATED BY ',' ENCLOSED BY '\"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;"
            cursor.execute(query)
            print(f"Added {csv_name} to {table_name}")
            
    conn.commit()
    conn.close()

    # add admin user
    # conn = conn_admin()
    # with conn.cursor() as cursor:
    #     cursor.callproc('sp_add_user', args=('admin', 'admin', 'admin'))

    # conn.commit()
    # conn.close()


def main():
    run_setup()
    run_parser()  

if __name__ == '__main__':
    main()
