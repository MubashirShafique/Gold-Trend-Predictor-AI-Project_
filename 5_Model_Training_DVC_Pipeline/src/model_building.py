import pandas as pd
import os
import joblib
import logging
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def train_model():
    """Splits data, trains Logistic Regression, and saves test sets for evaluation."""
    feature_path = 'data/features/X_scaled.csv'
    target_path = 'data/features/y.csv'
    feature_dir = 'data/features'
    model_dir = 'models'

    try:
        logging.info("Loading features and target...")
        X = pd.read_csv(feature_path)
        y = pd.read_csv(target_path).values.ravel()

        # Step 1: Split data (80% Train, 20% Test)
        # shuffle=False is CRITICAL for time-series to prevent data leakage
        X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, shuffle=False)

        # Step 2: Save Test sets for model_evaluation.py
        pd.DataFrame(X_test, columns=X.columns).to_csv(f'{feature_dir}/X_test.csv', index=False)
        pd.Series(y_test).to_csv(f'{feature_dir}/y_test.csv', index=False)
        logging.info("Test sets saved for evaluation.")

        # Step 3: Train the model
        logging.info(f"Training on {len(X_train)} samples...")
        model = LogisticRegression(C=10, penalty='l2', max_iter=2000, random_state=42)
        model.fit(X_train, y_train)

        # Step 4: Save the model
        os.makedirs(model_dir, exist_ok=True)
        joblib.dump(model, f'{model_dir}/model.pkl')
        
        logging.info(f"Model Training Complete! Saved at: models/model.pkl")

    except FileNotFoundError:
        logging.error("Feature files missing. Run feature_engineering.py first.")
    except Exception as e:
        logging.error(f"Model training failed: {e}")

if __name__ == "__main__":
    train_model()