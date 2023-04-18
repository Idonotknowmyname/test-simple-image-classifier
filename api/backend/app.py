import os
import time

import uvicorn
from backend.model import init_model, make_predictions
from backend.schema import Response
from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

app = FastAPI()

# Set up CORS
origins = [
    "http://localhost:3000",
    "http://localhost:8080",
    "http://localhost",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
def init():
    init_model()


@app.post("/predict", response_model=Response)
def handle_predict(image: UploadFile = File(...)):
    start = time.time()
    preds = make_predictions(image.file)
    resp = {"predictiontime": time.time() - start, "predictions": preds}
    return resp


if os.path.isdir("static"):
    app.mount("/", StaticFiles(directory="static", html=True), name="static")


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=os.environ.get("PORT", 8080))
