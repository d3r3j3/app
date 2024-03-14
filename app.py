"""
TODO: Student name(s):
TODO: Student email(s):
TODO: High-level program overview

******************************************************************************
This is a template you may start with for your Final Project application.
You may choose to modify it, or you may start with the example function
stubs (most of which are incomplete).

Some sections are provided as recommended program breakdowns, but are optional
to keep, and you will probably want to extend them based on your application's
features.

TODO:
- Make a copy of app-template.py to a more appropriately named file. You can
  either use app.py or separate a client vs. admin interface with app_client.py,
  app_admin.py (you can factor out shared code in a third file, which is
  recommended based on submissions in 22wi).
- For full credit, remove any irrelevant comments, which are included in the
  template to help you get started. Replace this program overview with a
  brief overview of your application as well (including your name/partners name).
  This includes replacing everything in this *** section!
******************************************************************************
"""

from fastapi import Depends, FastAPI, Form, HTTPException, Response
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime, timedelta, timezone
from database.db import get_conn
from database.objects import Game, Games, User
from starlette.requests import Request
from starlette.templating import Jinja2Templates
from fastapi.responses import HTMLResponse, RedirectResponse
from starlette import status
from fastapi.security import OAuth2PasswordRequestForm


import jwt
import uvicorn

HOST = '0.0.0.0'
PORT = 8000
ALGORITHM = "HS256"
SECRET_KEY = "secret"

app = FastAPI()
templates = Jinja2Templates(directory="templates")

class OAuth2PasswordBearerWithCookie():
    def __init__(self):
        self.token_url = "/login"
    
    async def __call__(self, request: Request):
        token = request.cookies.get("Authorization")
        if token is None:
            raise HTTPException(status_code=401, detail="Unautherized")
        
        data = token.split(" ")
        if len(data) != 2 or data[0] != "Bearer":
            raise HTTPException(status_code=401, detail="Unautherized")
        
        token = data[1].strip()
        if token is None:
            raise HTTPException(status_code=401, detail="Unautherized")
        
        return token
    
oauth2scheme = OAuth2PasswordBearerWithCookie()


# override 401 error
@app.exception_handler(HTTPException)
async def http_exception_handler(request, exc):
    print(exc.status_code, exc.detail)
    response = RedirectResponse(url="/login", status_code=307)
    response.set_cookie("Authorization", "")
    return response


# Startup and shutdown events
@app.on_event("startup")
async def startup_event():
    app.db_conn = get_conn()

@app.on_event("shutdown")
async def shutdown_event():
    app.db_conn.close()

# create token
async def create_token(username: str):
    exp_time = datetime.now(timezone.utc) + timedelta(minutes=30)
    payload = {"sub": username, "exp": exp_time}
    token = jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)
    return token

# verify token
async def verify_token(token: str):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise HTTPException(status_code=401, detail="Invalid token")
    except jwt.PyJWTError as e:
        print("jwt error: ", e)
        raise HTTPException(status_code=401, detail="Invalid token")
    return username


# OAuth Setup
async def get_current_user(token: str = Depends(oauth2scheme)):
    username = await verify_token(token)
    return username

# token route
@app.post("/login")
async def login(request: Request, form_data: OAuth2PasswordRequestForm = Depends()):
    username = form_data.username
    password = form_data.password

    # check username and password
    # get admin db connection
    admin_conn = get_conn(user="admin", password="admin")
    user = User(username=username).auth_user(admin_conn, password)
    admin_conn.close()
    if user is None:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    token = await create_token(username)

    # go to home page
    home_url = f"/home/0"
    response = RedirectResponse(url=home_url, status_code=status.HTTP_303_SEE_OTHER)
    response.set_cookie("Authorization", f"Bearer {token}")
    return response

# logout route
@app.get("/logout")
async def logout(request: Request):
    response = RedirectResponse(url="/login", status_code=307)
    response.set_cookie("Authorization", "")
    return response
    
# create account
@app.post("/register")
async def create_account(request: Request, username: str=Form(), password: str=Form()):
    print(username, password)
    admin_conn = get_conn(user="admin", password="admin")
    user = User(username=username).create_user(admin_conn, password)
    admin_conn.close()
    if user is None:
        raise HTTPException(status_code=400, detail="User already exists")
    
    return templates.TemplateResponse("login.html", {"request": request})

# login and register pages
@app.get("/login")
async def login(request: Request):
    return templates.TemplateResponse("login.html", {"request": request})

@app.get("/register")
async def register(request: Request):
    return templates.TemplateResponse("register.html", {"request": request})

# main pages - should be protected
@app.get("/")
async def root(request: Request, response: Response, user: str = Depends(get_current_user)):
    response.status_code = 307
    response.headers["Location"] = "/home/0"
    return response

@app.get("/home/{page}")
async def home(request: Request, page: int = 0, user: str = Depends(get_current_user)):
    games = Games(games=[]).get_games(app.db_conn, limit=10, offset=page*10)
    return templates.TemplateResponse(
        "index.html",
        {"request": request, "games": games.games, "page": page,
         "prev_page": page-1 if page > 0 else 0,
         "next_page": page+1 if len(games.games) == 10 else page
         }
    )

@app.get("/games/{game_id}")
async def game(game_id: int, request: Request, user: str = Depends(get_current_user)):
    game = Game(game_id=game_id).get_game(app.db_conn)
    return templates.TemplateResponse(
        "game.html",
        {"request": request, "game": game}
    )


# run the app
def main():
    uvicorn.run(app, host=HOST, port=PORT)

if __name__ == "__main__":
    main()
