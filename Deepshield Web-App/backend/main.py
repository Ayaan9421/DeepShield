from fastapi import FastAPI,APIRouter
from routes import predict
from routes import auth
from routes import history
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

#CORS 
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(predict.router)
app.include_router(auth.router)
app.include_router(history.router)

@app.get("/")
async def root():
	return {"message" : "DeepShield Running"}

