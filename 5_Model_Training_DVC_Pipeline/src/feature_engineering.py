import pandas as pd
import numpy as np
from sklearn.preprocessing import RobustScaler
import joblib
import os
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def calculate_indicators(df):
    """Calculates indicators and applies shifting logic from original source."""
    # 1. Base Indicators (Current t)
    df['SMA5'] = df['final_price'].rolling(5).mean()
    df['SMA20'] = df['final_price'].rolling(20).mean()
    df['7d_avg'] = df['final_price'].rolling(7).mean()
    df['30d_avg'] = df['final_price'].rolling(30).mean()

    # RSI
    delta = df['final_price'].diff()
    gain = (delta.where(delta > 0, 0)).rolling(window=14).mean()
    loss = (-delta.where(delta < 0, 0)).rolling(window=14).mean()
    df['rsi'] = 100 - (100 / (1 + (gain / loss)))

    # Other Features
    df['daily_pct_change'] = df['final_price'].pct_change()
    df['volatility_7d'] = df['daily_pct_change'].rolling(7).std()
    df['momentum_14d'] = df['final_price'] - df['final_price'].shift(14)
    df['price_zscore'] = (df['final_price'] - df['30d_avg']) / df['final_price'].rolling(30).std()

    # 2. Target Feature (SMA Crossover - Tomorrow's Signal)
    df['trend_signal'] = (df['SMA5'].shift(-1) > df['SMA20'].shift(-1)).astype(int)

    # 3. Feature Shifting (To Avoid Data Leakage)
    # final_price ko indicators calculate karne ke liye use kiya gaya hai
    all_cols = [
        'final_price', 'rsi', '7d_avg', '30d_avg', 
        'SMA5', 'SMA20', 'daily_pct_change', 'volatility_7d', 
        'momentum_14d', 'price_zscore'
    ]
    df[all_cols] = df[all_cols].shift(1)
    
    # final_price ko features list se nikaal diya gaya hai
    feature_cols = [
        'rsi', '7d_avg', '30d_avg', 
        'SMA5', 'SMA20', 'daily_pct_change', 'volatility_7d', 
        'momentum_14d', 'price_zscore'
    ]
    
    return df, feature_cols

def engineer_features():
    """Generates features using SMA Crossover logic and scales data."""
    processed_path = 'data/processed/cleaned_data.csv'
    feature_dir = 'data/features'
    model_dir = 'models'
    
    os.makedirs(feature_dir, exist_ok=True)
    os.makedirs(model_dir, exist_ok=True)

    try:
        df = pd.read_csv(processed_path)
        df['Date'] = pd.to_datetime(df['Date'])
        df = df.sort_values('Date')

        logging.info("Calculating technical indicators with shifting logic...")
        df, feature_cols = calculate_indicators(df)

        # Drop NaNs created by rolling and shifting
        df = df.dropna().reset_index(drop=True)

        X = df[feature_cols]
        y = df['trend_signal']

        logging.info("Scaling features...")
        scaler = RobustScaler()
        X_scaled = scaler.fit_transform(X)
        
        # Save results
        pd.DataFrame(X_scaled, columns=feature_cols).to_csv(f'{feature_dir}/X_scaled.csv', index=False)
        y.to_csv(f'{feature_dir}/y.csv', index=False)
        joblib.dump(scaler, f'{model_dir}/scaler.pkl')
        
        logging.info(f"Feature engineering complete. Samples: {len(df)}")

    except Exception as e:
        logging.error(f"Feature engineering failed: {e}")

if __name__ == "__main__":
    engineer_features()