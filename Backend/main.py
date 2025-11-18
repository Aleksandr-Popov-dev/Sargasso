import os
import uuid
from sqlite3 import OperationalError

from fastapi import FastAPI, File, UploadFile, HTTPException, Depends
from fastapi.staticfiles import StaticFiles
from multipart import file_path
from sqlalchemy.orm import Session
from pydantic import BaseModel
import asyncio
import asyncpg
from datetime import datetime

from sqlalchemy.testing.pickleable import User

app = FastAPI()


app.mount("/static", StaticFiles(directory="static"), name="static")


@app.on_event("startup")
async def startup():
    try:
        app.state.pool = await asyncpg.create_pool(
            "postgresql://postgres:Awsdzx12@localhost/postgres"
        )
    except Exception as e:
        # print("error in connection")
        app.state.pool = None


@app.on_event("shutdown")
async def shutdown():
    if hasattr(app.state, "pool") and app.state.pool:
        await app.state.pool.close()



class UserCreate(BaseModel):
    email: str
    password: str
    username: str
    fullname: str
    avatar: str


@app.post("/register")
async def register(user: UserCreate):
    try:
        async with app.state.pool.acquire() as connection:

            user_id = str(uuid.uuid4())
            created_at = datetime.utcnow()

            exist = await connection.fetch(
                "SELECT * FROM users WHERE email = $1 OR username = $2",
                user.email, user.username
            )

            if exist:
                return {"status": "error", "message": "User already exists"}

            await connection.execute(
                "INSERT INTO users (id, email, password, username, fullname, avatar, created_at) VALUES ($1, $2, $3, $4, $5, $6, $7)",
                user_id, user.email, user.password, user.username,user.fullname, user.avatar, created_at
            )

            return {"status": "success", "user_id": user_id}
    except Exception as e:
        print(f"error with registration: {e}")
        return {"status": "error", "message": str(e)}


class Userlogin(BaseModel):
    email: str
    password: str

@app.post("/login")
async def login(user: Userlogin):
    try:
        async with app.state.pool.acquire() as connection:
            row = await connection.fetchrow(
                "SELECT * FROM users WHERE email = $1 AND password = $2",
                user.email, user.password
            )

            if row:
                return {"status": "success", "user_id": str(row["id"]), "username": row["username"], "fullname": row["fullname"],
                        "avatar": row["avatar"]}
            else:
                return {"status": "error", "message": "User does not exist"}
    except Exception as e:
        return {"status": "error", "message": str(e)}



@app.post("/users/{user_id}/avatar")
async def upload_avatar(user_id: str, file: UploadFile = File(...)):
    try:
        async with app.state.pool.acquire() as connection:

            if not file.content_type.startswith("image/"):
                raise HTTPException(status_code=400, detail="File must be an image")

            contents = await file.read()
            if len(contents) > 5 * 1024 * 1024:
                raise HTTPException(status_code=400, detail="File too large")

            # await file.seek(0)

            file_extension = file.filename.split(".").pop()
            unique_filename = f"user_{user_id}_avatar_{uuid.uuid4()}.{file_extension}"

            file_path = os.path.join("static", "images", unique_filename)

            os.makedirs(os.path.dirname(file_path), exist_ok=True)

            with open(file_path, "wb") as f:
                f.write(contents)

            result = await connection.execute(
                "UPDATE users SET avatar = $1 WHERE id = $2",
                unique_filename, user_id
            )

            if result == "UPDATE 0":
                raise HTTPException(status_code=400, detail="User not found")

            return {"status": "success", "avatar": unique_filename}
    except HTTPException :
        raise
    except Exception as e:
        return {"status": "error", "message": str(e)}


@app.get("/users/{user_id}/get")
async def get_users(user_id: str):
    try:
        async with app.state.pool.acquire() as connection:

            data = await connection.fetch(
                "SELECT * FROM users WHERE id != $1 ORDER BY RANDOM()",
                user_id
            )

            users = []
            for user in data:
                users.append({
                    "id": str(user["id"]),
                    "email": user["email"],
                    "username": user["username"],
                    "fullname": user["fullname"],
                    "avatar": user["avatar"],
                    "created_at": user["created_at"].isoformat() if user["created_at"] else None
                })

            if users:
                return {"status": "success", "users": users}
            else:
                return {"status": "error", "message": "cant find users"}
    except Exception as e:
        return {"status": "error", "message": str(e)}


class CreateChat(BaseModel):
    user1_id: str
    user2_id: str
    message_content: str


@app.post("/chat/create")
async def create_chat(chat: CreateChat):
    try:
        async with app.state.pool.acquire() as connection:

            user1_id = min(chat.user1_id, chat.user2_id)
            user2_id = max(chat.user2_id, chat.user1_id)

            existing_chat = await connection.fetchrow(
                "SELECT * FROM chats WHERE (user1_id = $1 AND user2_id = $2) or (user1_id = $2 AND user2_id = $1)",
                user1_id, user2_id
            )

            if existing_chat:
                return {"status": "error", "message": "Chat already exists"}

            chat_id = str(uuid.uuid4())
            chat_created_at = datetime.utcnow()

            message_id = str(uuid.uuid4())
            message_created_at = datetime.utcnow()

            await connection.execute(
                "INSERT INTO chats(id, user1_id, user2_id, created_at, last_message_at) VALUES ($1, $2, $3, $4, $5)",
                chat_id, user1_id, user2_id, chat_created_at, message_created_at
            )

            await connection.execute(
                "INSERT INTO chat_messages(id, chat_id, sender_id, content, created_at) VALUES ($1, $2, $3, $4, $5)",
                message_id, chat_id, user1_id, chat.message_content, message_created_at
            )

            return {"status": "success", "chat_id": chat_id}
    except Exception as e:
        return {"status": "error", "message": str(e)}


@app.get("/chat/find/{user1_id}/{user2_id}")
async def find_chat(user1_id: str, user2_id: str):
    try:
        async with app.state.pool.acquire() as connection:

            u1 = min(user1_id, user2_id)
            u2 = max(user1_id, user2_id)

            chat = await connection.fetchrow(
                "SELECT id FROM chats WHERE user1_id = $1 AND user2_id = $2",
                u1, u2
            )

            if chat:
                return {"status": "success", "chat_id": str(chat["id"])}
            else:
                return {"status": "error", "message": "Chat does not exist"}
    except Exception as e:
        return {"status": "error", "message": str(e)}





@app.get("/contacts/fetch/{user_id}")
async def fetch_contacts(user_id: str):
    try:
        async with app.state.pool.acquire() as connection:

            chats = await connection.fetch(
                "SELECT * FROM chats WHERE user1_id = $1 OR user2_id = $1",
                user_id
            )

            contacts_ids = set()
            for chat in chats:
                if str(chat["user1_id"]) == user_id:
                    contacts_ids.add(str(chat["user2_id"]))
                else:
                    contacts_ids.add(str(chat["user1_id"]))

            if contacts_ids:
                placeholders = ','.join([f"${i + 1}" for i in range(len(contacts_ids))])

                partners = await connection.fetch(
                    f"SELECT * FROM users WHERE id IN ({placeholders}) ORDER BY created_at ASC", *list(contacts_ids)
                )
            else:
                partners = []

            contacts = []
            for partner in partners:
                contacts.append({
                    "id": str(partner["id"]),
                    "email": partner["email"],
                    "password": partner["password"],
                    "username": partner["username"],
                    "fullname": partner["fullname"],
                    "avatar": partner["avatar"],
                    "created_at": partner["created_at"].isoformat() if partner["created_at"] else None
                })

            return {"status": "success", "contacts": contacts}

    except Exception as e:
        return {"status": "error", "message": str(e)}


@app.get("/chats/{chat_id}/messages")
async def get_messages(chat_id: str):
    try:
        async with app.state.pool.acquire() as connection:

            rows = await connection.fetch(
                "SELECT * FROM chat_messages WHERE chat_id = $1 ORDER BY created_at ASC",
                chat_id
            )

            messages = []
            for row in rows:
                messages.append({
                    "id": str(row["id"]),
                    "chat_id": str(row["chat_id"]),
                    "sender_id": str(row["sender_id"]),
                    "content": row["content"],
                    "created_at": row["created_at"].isoformat() if row["created_at"] else None
                })

            return {"status": "success", "messages": messages}
    except Exception as e:
        return {"status": "error", "message": str(e)}


class Message(BaseModel):
    chat_id: str
    sender_id: str
    content: str

@app.post("/chat/{chat_id}/sendMessage")
async def send_message(message: Message):
    try:
        async with app.state.pool.acquire() as connection:


            chat_exist = await connection.fetchrow(
                "SELECT 1 FROM chats WHERE id = $1",
                message.chat_id
            )


            if not chat_exist:
                return {"status": "error", "message": "Chat does not exist"}

            message_id = str(uuid.uuid4())
            message_created_at = datetime.utcnow()

            await connection.execute(
                "INSERT INTO chat_messages(id, chat_id, sender_id, content, created_at) VALUES ($1, $2, $3, $4, $5)",
                message_id, message.chat_id, message.sender_id, message.content, message_created_at
            )

            await connection.execute(
                "UPDATE chat_messages SET created_at = $1 WHERE id = $2",
                message_created_at, message.chat_id
            )

            return {"status": "success", "message_id": message_id}
    except Exception as e:
        return {"status": "error", "message": str(e)}
