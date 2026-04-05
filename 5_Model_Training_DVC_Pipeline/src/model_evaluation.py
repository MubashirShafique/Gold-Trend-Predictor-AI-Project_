import pandas as pd
import joblib
import json
import logging
import os
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def evaluate():
    """Evaluates the trained model on unseen test data and saves metrics."""
    model_path = 'models/model.pkl'
    test_x_path = 'data/features/X_test.csv'
    test_y_path = 'data/features/y_test.csv'
    metrics_path = 'models/evaluation_metrics.json'

    try:
        # Load Model and Test Data
        if not os.path.exists(model_path):
            logging.error("Model file not found. Please train the model first.")
            return

        model = joblib.load(model_path)
        X_test = pd.read_csv(test_x_path)
        y_test = pd.read_csv(test_y_path)

        # Predictions
        predictions = model.predict(X_test)
        
        # Calculate Metrics
        acc = accuracy_score(y_test, predictions)
        report = classification_report(y_test, predictions, output_dict=True)
        
        logging.info(f"Model Evaluation Complete. Accuracy: {acc:.4f}")

        # Save all details in a JSON file (Better than TXT for tracking)
        metrics = {
            "model_name": "Logistic Regression",
            "accuracy": acc,
            "classification_report": report,
            "hyperparameters": {"C": 10, "penalty": "l2"}
        }

        with open(metrics_path, "w") as f:
            json.dump(metrics, f, indent=4)
        
        logging.info(f"Metrics saved to {metrics_path}")

    except Exception as e:
        logging.error(f"Evaluation failed: {e}")

if __name__ == "__main__":
    evaluate()