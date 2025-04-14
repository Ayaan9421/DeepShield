from fastapi import APIRouter, HTTPException
from config.database import user_collections, video_collections
from models.user_model import User
import bcrypt
import jwt
import os
from dotenv import load_dotenv

load_dotenv()

SECRET_KEY = os.getenv("SECRET_KEY", "supersecret")

router = APIRouter()

@router.get("/test-db")
def test_db():
	count = user_collections.count_documents({})
	return {"message" : f"users in database = {count}"}

@router.post("/register")
async def register(user: User):
	if user_collections.find_one({"username": user.username}):
		raise HTTPException(status_code=400, detail="Username Already Exists")

	hashed_pw = bcrypt.hashpw(user.password.encode(), bcrypt.gensalt())
	user_collections.insert_one({
		"username" : user.username,
		"password" : hashed_pw
	})
	
	return {"message" : "Registered Successfully"}

@router.post("/login")
async def login(user: User):
	found_user = user_collections.find_one({"username" : user.username})
	if not found_user:
		raise HTTPException(status_code=404 , detail="User not found")

	if not bcrypt.checkpw(user.password.encode(), found_user["password"]):
		raise HTTPException(status_code=401, detail="Incorrect Password")
	
	token = jwt.encode({"username": user.username}, SECRET_KEY, algorithm="HS256")
	return {"token" : token}
 















