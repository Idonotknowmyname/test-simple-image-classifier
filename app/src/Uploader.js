import React, { useState } from "react";
import "./Uploader.css";

function ImageUploader() {
  const [image, setImage] = useState("");
  const [prediction, setPrediction] = useState("");

  const handleFileUpload = (event) => {
    const file = event.target.files[0];
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
    // add your prediction code here
    setPrediction("This is a prediction");
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

      {prediction && <p className="prediction-text">{prediction}</p>}
    </div>
  );
}

export default ImageUploader;