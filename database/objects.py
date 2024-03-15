from pydantic import BaseModel
from typing import List, Optional
import datetime
import mysql.connector

# Procedures
FUNC_AUTHENTICATE = 'authenticate'
FUNC_HAS_PURCHASED = 'has_purchased'
PROC_CHANGE_PASSWORD = 'sp_change_password'
PROC_ADD_USER = 'sp_add_user'
PROC_GET_GAME_INFO = 'sp_get_game_info'
PROC_MAKE_PURCHASE = 'sp_make_purchase'
DEFAULT_ROLE = 'user'

def get_supported_platforms(bin_str: str) -> List[str]:
    platforms = []
    if bin_str[0] == '1':
        platforms.append('Windows')
    if bin_str[1] == '1':
        platforms.append('Mac')
    if bin_str[2] == '1':
        platforms.append('Linux')
    return platforms

class Game(BaseModel):
    game_id: Optional[int] = None
    game_name: Optional[str] = None
    release_date: Optional[datetime.date] = None
    estimated_owners: Optional[str] = None
    price_usd: Optional[float] = None
    about_game: Optional[str] = None
    metacritic_score: Optional[int] = None
    platform_support: Optional[List[str]] = None
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
                    platform_support=get_supported_platforms(row[7]) if row[7] else None,
                    header_image=row[8]
                )

                return game
            else:
                return None
            
class GameInfo(BaseModel):
    game_id: Optional[int] = None
    game_name: Optional[str] = None
    release_date: Optional[datetime.date] = None
    estimated_owners: Optional[str] = None
    price_usd: Optional[float] = None
    about_game: Optional[str] = None
    metacritic_score: Optional[int] = None
    platform_support: Optional[List[str]] = None
    header_image: Optional[str] = None
    video_urls: Optional[List[str]] = None
    categories: Optional[List[str]] = None
    genres: Optional[List[str]] = None
    tags: Optional[List[str]] = None
    supported_langs: Optional[List[str]] = None
    supported_audio_langas: Optional[List[str]] = None
    developers: Optional[List[str]] = None
    publishers: Optional[List[str]] = None
    is_purchased: Optional[bool] = None

    def get_game_info(self, conn: mysql.connector.MySQLConnection, user_id: str=None) -> 'GameInfo':
        if not self.game_id or not user_id:
            return None
        
        has_purchased_params = (user_id, self.game_id)
        has_purchased_query = f"SELECT {FUNC_HAS_PURCHASED}(%s, %s);"
        query = f"CALL {PROC_GET_GAME_INFO}(%s);"
        
        with conn.cursor() as cursor:
            cursor.execute(has_purchased_query, has_purchased_params)
            row = cursor.fetchone()
            purchased = False

            if row[0] > 0:
                purchased = True
            
            cursor.execute(query, (self.game_id,))
            row = cursor.fetchone()
            if row:
                game_info = GameInfo(
                    game_id=row[0],
                    game_name=row[1],
                    release_date=row[2],
                    estimated_owners=row[3],
                    price_usd=row[4],
                    about_game=row[5],
                    metacritic_score=row[6],
                    platform_support=get_supported_platforms(row[7]) if row[7] else None,
                    header_image=row[8],
                    video_urls=row[9].split(',') if row[9] else None,
                    categories=row[10].split(',') if row[10] else None,
                    genres=row[11].split(',') if row[11] else None,
                    tags=row[12].split(',') if row[12] else None,
                    supported_langs=row[13].split(',') if row[13] else None,
                    supported_audio_langas=row[14].split(',') if row[14] else None,
                    developers=row[15].split(',') if row[15] else None,
                    publishers=row[16].split(',') if row[16] else None,
                    is_purchased=purchased
                )

                return game_info
            else:
                return None
            
    def purchase_game(self, conn: mysql.connector.MySQLConnection, user_id: int) -> 'GameInfo':
        if not self.game_id or not user_id:
            return None

        try:
            with conn.cursor() as cursor:
                cursor.callproc(PROC_MAKE_PURCHASE, (user_id, self.game_id))
                conn.commit()
        except mysql.connector.Error as err:
            print("Purchase Game Err: ", err)
            return None
        
        return self
            
            
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
                    platform_support=get_supported_platforms(row[7]) if row[7] else None,
                    header_image=row[8]
                )
                games.append(game)
        
        return Games(games=games)

class User(BaseModel):
    user_id: Optional[int] = None
    username: Optional[str] = None
    balance: Optional[float] = None
    password_hash: Optional[str] = None
    salt: Optional[str] = None
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
                    balance=row[2],
                    password_hash=row[3],
                    salt=row[4],
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
            
    def change_password(self, conn: mysql.connector.MySQLConnection, password: str) -> 'User':
        if not self.user_id or not self.username or not password:
            return None
        
        try:
            with conn.cursor() as cursor:
                cursor.callproc(PROC_CHANGE_PASSWORD, (self.username, password))
                conn.commit()
        except mysql.connector.Error as err:
            print(err)
            return None
        
        return self
            
            
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
                    balance=row[2],
                    password_hash=row[3],
                    salt=row[4],
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
    
class UserPurchases(BaseModel):
    purchase_id: Optional[int] = None
    user_id: Optional[int] = None
    game_id: Optional[int] = None
    purchase_date: Optional[datetime.date] = None
    purchase_price: Optional[float] = None
    game_name: Optional[str] = None
    release_date: Optional[datetime.date] = None
    price_usd: Optional[float] = None
    platform_support: Optional[List[str]] = None
    metacritic_score: Optional[int] = None
    header_image: Optional[str] = None

    def get_user_purchases(self, conn: mysql.connector.MySQLConnection,
                    user_id: int, limit: int = 10, offset: int = 0) -> List['UserPurchases']:
            
            query = f"""
                    SELECT 
                        p.purchase_id, 
                        p.user_id, 
                        p.game_id, 
                        p.purchase_date,  
                        g.game_name, 
                        g.release_date, 
                        g.price_usd, 
                        g.platform_support, 
                        g.metacritic_score, 
                        g.header_image
                    FROM purchases p
                    JOIN game g
                    ON p.game_id = g.game_id
                    WHERE p.user_id = %s
                    LIMIT %s OFFSET %s;
                    """ % (user_id, limit, offset)
            
            try:
                purchases = []
                with conn.cursor() as cursor:
                    cursor.execute(query)
                    rows = cursor.fetchall()
                    for row in rows:
                        purchase = UserPurchases(
                            purchase_id=row[0],
                            user_id=row[1],
                            game_id=row[2],
                            purchase_date=row[3],
                            game_name=row[4],
                            release_date=row[5],
                            price_usd=row[6],
                            platform_support=get_supported_platforms(row[7]) if row[7] else None,
                            metacritic_score=row[8],
                            header_image=row[9]
                        )
                        purchases.append(purchase)

                return purchases
            except mysql.connector.Error as err:
                print(err)
                return None
        

