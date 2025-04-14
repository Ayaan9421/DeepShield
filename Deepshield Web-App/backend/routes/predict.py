from fastapi import FastAPI,APIRouter,UploadFile, File, Header, HTTPException, Depends
from fastapi.responses import JSONResponse
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import os, shutil, jwt	
from config.database import video_collections
from detector.detect_deepfake import detect_video
from dotenv import load_dotenv

load_dotenv()

SECRET_KEY = os.getenv("SECRET_KEY", "supersecret")

router = APIRouter()
security = HTTPBearer()

@router.get("/predict")
async def predict_info():
	return {"message" : "Use POST /predict to upload and analyse a video."}

@router.post("/predict")
async def predict_video(file: UploadFile = File(...), credentials: HTTPAuthorizationCredentials = Depends(security)):
	try:
		token = credentials.credentials
		decoded = jwt.decode(token , SECRET_KEY, algorithms=["HS256"])
		username = decoded['username']
		
		#save video locally
		temp_video_path = f"temp_{file.filename}"
		with open(temp_video_path, "wb") as buffer:
			shutil.copyfileobj(file.file , buffer)
			
		#saveing the results
		result = detect_video(temp_video_path)
		os.remove(temp_video_path)
		
		video_collections.insert_one({
			"username" : username,
			"filename" : file.filename,
			"result" : result,
		})

		return JSONResponse(content = result)

	except jwt.ExpiredSignatureError:
		raise HTTPException(status_code=401 , detail="Token Expired")

	except  jwt.DecodeError:
		raise HTTPException(status_code=401, detail="Invalid Token")
			
	except Exception as e:
		return HTTPException(status_code=500, detail=str(e))



#	register / login route works fine
#	stores in db ==> cool
#	now, check how can i store the video and cropped faces into the db or somewhere else on the cloud
#	then the only thing left will the data read operations on the db
#	then integrate it with the frontend


