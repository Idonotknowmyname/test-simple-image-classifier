import io

from PIL import Image
from transformers import AutoImageProcessor, AutoModelForImageClassification

MODEL_NAME = "google/mobilenet_v1_0.75_192"
RETURN_TOP = 4

MODEL = None
PREPROCESSOR = None


def init_model():
    global MODEL, PREPROCESSOR
    if MODEL is None:
        PREPROCESSOR = AutoImageProcessor.from_pretrained("google/mobilenet_v1_0.75_192")
        MODEL = AutoModelForImageClassification.from_pretrained("google/mobilenet_v1_0.75_192")


def make_predictions(file):
    image = Image.open(io.BytesIO(file.read()))

    # Convert image if png (remove extra channel)
    if image.format == "PNG":
        image = image.convert("RGB")

    inputs = PREPROCESSOR(images=image, return_tensors="pt")

    outputs = MODEL(**inputs)
    logits = outputs.logits

    # model predicts one of the 1000 ImageNet classes
    # predicted_class_idx = logits.argmax(-1).item()
    vs, ids = logits.topk(RETURN_TOP)
    preds = [
        {"classname": MODEL.config.id2label[idx], "confidence": val}
        for idx, val in zip(ids[0].tolist(), vs[0].tolist())
    ]

    return preds
