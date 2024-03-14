from pydantic import BaseModel
from typing import List, Optional
import datetime
import mysql.connector

# Procedures
FUNC_AUTHENTICATE = 'authenticate'
PROC_ADD_USER = 'sp_add_user'
DEFAULT_ROLE = 'user'

class Game(BaseModel):
    game_id: Optional[int] = None
    game_name: Optional[str] = None
    release_date: Optional[datetime.date] = None
    estimated_owners: Optional[str] = None
    price_usd: Optional[float] = None
    about_game: Optional[str] = None
    metacritic_score: Optional[int] = None
    platform_support: Optional[str] = None
    header_image: Optional[str] = None

    def get_game(self, conn: mysql.connector.MySQLConnection) -> 'Game':
        params = (self.game_id,)

        query = """
                SELECT * FROM game WHERE game_id = %s;
                """ % (params)
        
        with conn.cursor() as cursor:
            cursor.execute(query)
            row = cursor.fetchone()
            if row:
                game = Game(
                    game_id=row[0],
                    game_name=row[1],
                    release_date=row[2],
                    estimated_owners=row[3],
                    price_usd=row[4],
                    about_game=row[5],
                    metacritic_score=row[6],
                    platform_support=row[7],
                    header_image=row[8]
                )

                return game
            else:
                return None
            
class Games(BaseModel):
    games: List[Game]

    def get_games(self, conn: mysql.connector.MySQLConnection,
                  limit: int = 10, offset: int = 0) -> 'Games':
        
        query = """
                SELECT * FROM game LIMIT %s OFFSET %s;
                """ % (limit, offset)
        
        with conn.cursor() as cursor:
            cursor.execute(query)
            rows = cursor.fetchall()
            games = []
            for row in rows:
                game = Game(
                    game_id=row[0],
                    game_name=row[1],
                    release_date=row[2],
                    estimated_owners=row[3],
                    price_usd=row[4],
                    about_game=row[5],
                    metacritic_score=row[6],
                    platform_support=row[7],
                    header_image=row[8]
                )
                games.append(game)
        
        return Games(games=games)

class User(BaseModel):
    user_id: Optional[int] = None
    username: Optional[str] = None
    password_hash: Optional[str] = None
    salt: Optional[str] = None
    age: Optional[int] = None
    user_role: Optional[str] = None
    date_joined: Optional[datetime.date] = None

    def get_user(self, conn: mysql.connector.MySQLConnection) -> 'User':
        params = (self.user_id,)

        query = """
                SELECT * FROM user WHERE user_id = %s;
                """ % (params)
        
        with conn.cursor() as cursor:
            cursor.execute(query)
            row = cursor.fetchone()
            if row:
                user = User(
                    user_id=row[0],
                    username=row[1],
                    password_hash=row[2],
                    salt=row[3],
                    age=row[4],
                    user_role=row[5],
                    date_joined=row[6]
                )

                return user
            else:
                return None
            
    def auth_user(self, conn: mysql.connector.MySQLConnection, password: str) -> 'User':
        if not self.username or not password:
            return None

        with conn.cursor() as cursor:
            cursor.execute(f"SELECT {FUNC_AUTHENTICATE}(%s, %s);", (self.username, password))
            row = cursor.fetchone()
            if not row:
                return None
            
            print(row)

            cursor.execute(f"SELECT * FROM user WHERE username = %s;", (self.username,))
            row = cursor.fetchone()

            if not row:
                return None
            
            user = User(
                user_id=row[0],
                username=row[1],
                user_role=row[5],
            )

            return user
            
    def create_user(self, conn: mysql.connector.MySQLConnection, password: str) -> 'User':
        if not self.username or not password:
            return None

        with conn.cursor() as cursor:
            cursor.execute(f"SELECT * FROM user WHERE username = %s;", (self.username,))
            row = cursor.fetchone()
            if row:
                return None
            else:
                cursor.callproc(PROC_ADD_USER, (self.username, password, DEFAULT_ROLE))

                cursor.execute(f"SELECT * FROM user WHERE username = %s;", (self.username,))
                row = cursor.fetchone()
                conn.commit()

                if not row:
                    return None

                user = User(
                    user_id=row[0],
                    username=row[1],
                    user_role=row[5],
                )

                return user
            
            
class Users(BaseModel):
    users: List[User]

    def get_users(self, conn: mysql.connector.MySQLConnection,
                  limit: int = 10, offset: int = 0) -> 'Users':
        
        query = """
                SELECT * FROM user LIMIT %s OFFSET %s;
                """ % (limit, offset)
        
        with conn.cursor() as cursor:
            cursor.execute(query)
            rows = cursor.fetchall()
            users = []
            for row in rows:
                user = User(
                    user_id=row[0],
                    username=row[1],
                    password_hash=row[2],
                    salt=row[3],
                    age=row[4],
                    user_role=row[5],
                    date_joined=row[6]
                )
                users.append(user)
        
        return Users(users=users)
    
class Purchase(BaseModel):
    purchase_id: Optional[int] = None
    user_id: Optional[int] = None
    game_id: Optional[int] = None
    purchase_date: Optional[datetime.date] = None
    purchase_price: Optional[float] = None

    def get_purchase(self, conn: mysql.connector.MySQLConnection) -> 'Purchase':
        params = (self.purchase_id,)

        query = """
                SELECT * FROM purchases WHERE purchase_id = %s;
                """ % (params)
        
        with conn.cursor() as cursor:
            cursor.execute(query)
            row = cursor.fetchone()
            if row:
                purchase = Purchase(
                    purchase_id=row[0],
                    user_id=row[1],
                    game_id=row[2],
                    purchase_date=row[3],
                    purchase_price=row[4]
                )

                return purchase
            else:
                return None
            
class Purchases(BaseModel):
    purchases: List[Purchase]

    def get_purchases(self, conn: mysql.connector.MySQLConnection,
                  limit: int = 10, offset: int = 0) -> 'Purchases':
        
        query = """
                SELECT * FROM purchases LIMIT %s OFFSET %s;
                """ % (limit, offset)
        
        with conn.cursor() as cursor:
            cursor.execute(query)
            rows = cursor.fetchall()
            purchases = []
            for row in rows:
                purchase = Purchase(
                    purchase_id=row[0],
                    user_id=row[1],
                    game_id=row[2],
                    purchase_date=row[3],
                    purchase_price=row[4]
                )
                purchases.append(purchase)
        
        return Purchases(purchases=purchases)
    
    def get_user_purchases(self, conn: mysql.connector.MySQLConnection,
                  user_id: int, limit: int = 10, offset: int = 0) -> 'Purchases':
        
        query = """
                SELECT * FROM purchases WHERE user_id = %s LIMIT %s OFFSET %s;
                """ % (user_id, limit, offset)
        
        with conn.cursor() as cursor:
            cursor.execute(query)
            rows = cursor.fetchall()
            purchases = []
            for row in rows:
                purchase = Purchase(
                    purchase_id=row[0],
                    user_id=row[1],
                    game_id=row[2],
                    purchase_date=row[3],
                    purchase_price=row[4]
                )
                purchases.append(purchase)
        
        return Purchases(purchases=purchases)
    
    def get_game_purchases(self, conn: mysql.connector.MySQLConnection,
                    game_id: int, limit: int = 10, offset: int = 0) -> 'Purchases':
            
            query = """
                    SELECT * FROM purchases WHERE game_id = %s LIMIT %s OFFSET %s;
                    """ % (game_id, limit, offset)
            
            with conn.cursor() as cursor:
                cursor.execute(query)
                rows = cursor.fetchall()
                purchases = []
                for row in rows:
                    purchase = Purchase(
                        purchase_id=row[0],
                        user_id=row[1],
                        game_id=row[2],
                        purchase_date=row[3],
                        purchase_price=row[4]
                    )
                    purchases.append(purchase)
            
            return Purchases(purchases=purchases)
