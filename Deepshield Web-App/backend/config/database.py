from pymongo.mongo_client import MongoClient
from pymongo.server_api import ServerApi
from dotenv import load_dotenv
import os

load_dotenv()

MONGO_URI = os.getenv("MONGO_URI")
if not MONGO_URI:
	raise Exception("Mongo URI not found in .env")

client = MongoClient(MONGO_URI, server_api = ServerApi('1'))

try:
	client.admin.command('ping')
	print("Successfully connect to MongoDB")
except Exception as e:
	print("Unsuccessful conn , error = " , str(e))


db = client["DeepFake-db"]
user_collections = db["users"]
video_collections = db["videos"]
