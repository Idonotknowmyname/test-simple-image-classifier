from typing import List
from pydantic import BaseModel, Field


class Prediction(BaseModel):
    classname: str = Field(..., description="The name of the class predicted")
    confidence: float = Field(..., description="The confidence of the model in the prediction")


class Response(BaseModel):
    predictiontime: float = Field(..., description="How long in millisecond did the model prediciton take")
    predictions: List[Prediction] = Field(..., description="The list of predicted classes and their confidence")
