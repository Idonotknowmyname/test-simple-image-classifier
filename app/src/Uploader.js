import React, { useState } from "react";
import axios from "axios";
import PredictionTable from "./PredictionTable";
import "./Uploader.css";

function ImageUploader() {
  const [image, setImage] = useState("");
  const [imageFile, setImageFile] = useState("");
  const [prediction, setPrediction] = useState("");

  const handleFileUpload = (event) => {
    const file = event.target.files[0];
    setImageFile(file);

    const reader = new FileReader();
  
    if (!file.type.startsWith("image/")) {
      alert("Please upload an image file.");
      return;
    }

    setPrediction(""); // reset prediction state to an empty string
  
    reader.readAsDataURL(file);
  
    reader.onloadend = () => {
      setImage(reader.result);
    };
  };

  const handlePrediction = () => {
    if (!image) {
      return;
    }

    let data = new FormData();
    data.append('image', imageFile);

    const config = {
      headers: {
        "Content-Type": "multipart/form-data"
      }
    }

    axios
      .post("http://localhost:8080/predict", data, config)
      .then((response) => {
        setPrediction(response.data);
      })
      .catch((error) => {
        console.error(error);
      });
  };

  return (
    <div className="container">
      <div className="file-upload">
        <label htmlFor="file-upload-input">Choose File</label>
        <input
          id="file-upload-input"
          type="file"
          accept="image/*"
          onChange={handleFileUpload}
        />
      </div>

      {image && <img className="image-preview" src={image} alt="Preview" />}

      {image && (
        <button className="predict-button" onClick={handlePrediction}>
          Predict
        </button>
      )}

      {prediction && (<PredictionTable prediction={prediction}/>)}
    </div>
  );
}

export default ImageUploader;