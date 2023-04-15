import React from "react";
import "./PredictionTable.css";

function PredictionTable({ prediction }) {
  const { predictiontime, predictions } = prediction;
  return (
    <div>
      <table>
        <thead>
          <tr>
            <th>Class Name</th>
            <th>Confidence</th>
          </tr>
        </thead>
        <tbody>
          {predictions.map((prediction, index) => (
            <tr key={index}>
              <td>{prediction.classname}</td>
              <td>{prediction.confidence.toFixed(2)}</td>
            </tr>
          ))}
        </tbody>
      </table>
      <p className="prediction-time">Prediction Time: {predictiontime.toFixed(2)} seconds</p>
    </div>
  );
};

export default PredictionTable;