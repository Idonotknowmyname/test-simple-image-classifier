import os
import time

from fastapi import FastAPI, UploadFile, File
import uvicorn

from backend.schema import Response
from backend.model import init_model, make_predictions

app = FastAPI()

@app.on_event('startup')
def init():
    init_model()


@app.post("/predict", response_model=Response)
def handle_predict(image: UploadFile = File(...)):
    start = time.time()
    preds = make_predictions(image.file)
    resp = {
        "predictiontime": time.time() - start,
        "predictions": preds
    }
    return resp


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=os.environ.get("PORT", 8080))
