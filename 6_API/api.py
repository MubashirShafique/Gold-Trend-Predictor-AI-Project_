import joblib
import pandas as pd
import uvicorn
from fastapi import FastAPI, HTTPException

app = FastAPI(title="Gold Price Prediction API")

# File paths
MODEL_FILE = "Models/model.pkl"
SCALER_FILE = "Models/scaler.pkl"
FEATURES_FILE = "data_for_prediction_&_graph/today_gold_features.csv"
HISTORY_FILE = "data_for_prediction_&_graph/gold_history_90d.csv"

def get_model_assets():
    try:
        with open(MODEL_FILE, 'rb') as f:
            model = joblib.load(f)
        with open(SCALER_FILE, 'rb') as f:
            scaler = joblib.load(f)
        return model, scaler
    except FileNotFoundError:
        raise HTTPException(status_code=500, detail="Model or Scaler files missing")

@app.get("/predict")
async def get_prediction():
    # Load assets and data
    model, scaler = get_model_assets()
    
    try:
        today_features = pd.read_csv(FEATURES_FILE)
        history_df = pd.read_csv(HISTORY_FILE)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error reading CSV: {str(e)}")

    # Preprocessing and Prediction
    scaled_input = scaler.transform(today_features)
    prediction = int(model.predict(scaled_input)[0])
    
    # Calculate confidence for Logistic Regression
    probabilities = model.predict_proba(scaled_input)
    confidence_score = float(probabilities.max())

    return {
        "status": "success",
        "prediction": prediction,
        "confidence_score": round(confidence_score, 4),
        "history_data": history_df.to_dict(orient="records")
    }

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)