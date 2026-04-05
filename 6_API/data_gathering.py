import yfinance as yf
import pandas as pd
import numpy as np
from datetime import datetime, timedelta

def process_gold_data():
    symbol = "GC=F"
    
    # Download data for calculations
    end_date = datetime.now()
    start_date = end_date - timedelta(days=200)
    
    df = yf.download(symbol, start=start_date, end=end_date, auto_adjust=True)

    if df.empty:
        print("No data found!")
        return

    if isinstance(df.columns, pd.MultiIndex):
        df.columns = df.columns.get_level_values(0)

    # Calculate Technical Indicators
    df['SMA5'] = df['Close'].rolling(window=5).mean()
    df['SMA20'] = df['Close'].rolling(window=20).mean()
    df['7d_avg'] = df['Close'].rolling(window=7).mean()
    df['30d_avg'] = df['Close'].rolling(window=30).mean()

    # RSI Calculation
    delta = df['Close'].diff()
    gain = (delta.where(delta > 0, 0)).rolling(window=14).mean()
    loss = (-delta.where(delta < 0, 0)).rolling(window=14).mean()
    rs = gain / loss
    df['rsi'] = 100 - (100 / (1 + rs))

    # Statistical Features
    df['daily_pct_change'] = df['Close'].pct_change()
    df['volatility_7d'] = df['daily_pct_change'].rolling(7).std()
    df['momentum_14d'] = df['Close'] - df['Close'].shift(14)
    df['price_zscore'] = (df['Close'] - df['30d_avg']) / df['Close'].rolling(30).std()
    df['final_price'] = df['Close']

    # Filter last 90 rows
    df.dropna(inplace=True)
    df = df.tail(90)

    # Save today's features only
    feature_order = [
        'rsi', '7d_avg', '30d_avg', 'SMA5', 'SMA20', 
        'daily_pct_change', 'volatility_7d', 'momentum_14d', 'price_zscore'
    ]
    today_data = df.tail(1)[feature_order]
    today_data.to_csv("data_for_prediction_&_graph/today_gold_features.csv", index=False)
    
    # Save historical price data (excluding today)
    history_data = df.iloc[:-1][['final_price']] 
    history_data.to_csv("data_for_prediction_&_graph/gold_history_90d.csv", index=True)

    print("Success: Files saved.")

if __name__ == "__main__":
    process_gold_data()