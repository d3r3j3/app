# Game Store Project - CS121
## How to run the project
1. Clone the repository
2. Retrieve data csv files from the following link:
    - https://drive.google.com/drive/folders/1lVA9u-XAnb7lFG_pBJCIzIWN7MlLSQLw?usp=drive_link
3. Place the csv files into the database/setup folder
4. Now make sure you have the dependencies installed by running the following command:
    - `pip install -r requirements.txt`
    - Best to do this in a virtual environment
    - Also make sure you are in the root directory of the project
5. Now change directory to the database/setup folder and
    - Run the following commands (connect to mysql as root):
        - `source setup.sql`
        - `source load-data.sql`
        - `source setup-passwords.sql`
        - `source setup-routines.sql`
        - `source grant-permissions.sql`
        - `source setup-users.sql`
        - `source queries.sql`
    - Hopefully you should have a database setup with the data loaded
6. Now you can run the project by switching to the root directory and
    - Running the following command:
        - `python app.py`
7. Now you can open your browser and go to the following link:
    - `http://localhost:8080/`
8. You should now be able to use the application
9. admin login:
    - username: admin
    - password: admin
10. customers range from 1 to 1000
    - username: user1
    - password: password