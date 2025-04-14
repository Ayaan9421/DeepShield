from fastapi import FastAPI,APIRouter
from routes import predict
from routes import auth
app = FastAPI()

app.include_router(predict.router)
app.include_router(auth.router)

@app.get("/")
async def root():
	return {"message" : "DeepShield Running"}

