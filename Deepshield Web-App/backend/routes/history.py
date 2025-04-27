from fastapi import APIRouter, Depends
from config.database import video_collections
from utils.jwt_auth import get_current_user  # import the function

router = APIRouter()

@router.get("/videos/me")
def get_my_predictions(username: str = Depends(get_current_user)):
    user_videos = list(video_collections.find({"username": username}, {"_id": 0}))
    return {
        "username": username,
        "videos": user_videos
    }
