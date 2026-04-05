import pandas as pd
import os
import yfinance as yf
import logging
from datetime import datetime, timedelta

# Professional logging setup
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def load_and_update_data():
    """
    Loads existing gold data and appends new records from yfinance up to yesterday.
    """
    file_path = 'data/gold_ml_dataset_2000_2026.csv'
    raw_path = 'data/raw/raw_data.csv'
    os.makedirs('data/raw', exist_ok=True)

    try:
        df = pd.read_csv(file_path)
        df['Date'] = pd.to_datetime(df['Date'])
    except FileNotFoundError:
        logging.error(f"Source file missing at {file_path}")
        return

    # Calculate date range: from day after last entry until yesterday
    last_date = df['Date'].max()
    start_date = (last_date + timedelta(days=1)).strftime('%Y-%m-%d')
    end_date = (datetime.now() - timedelta(days=1)).strftime('%Y-%m-%d')

    if start_date < end_date:
        logging.info(f"Fetching data: {start_date} to {end_date}")
        gold_data = yf.download("GC=F", start=start_date, end=end_date)
        
        if not gold_data.empty:
            # Syncing columns with original dataset structure
            new_data = gold_data[['Close']].reset_index()
            new_data.columns = ['Date', 'final_price']
            new_data['Date'] = pd.to_datetime(new_data['Date'])
            
            updated_df = pd.concat([df, new_data], ignore_index=True)
            updated_df.to_csv(raw_path, index=False)
            logging.info("Dataset updated and merged successfully.")
        else:
            logging.warning("No new data available from API.")
            df.to_csv(raw_path, index=False)
    else:
        logging.info("Local data is already current.")
        df.to_csv(raw_path, index=False)

if __name__ == "__main__":
    load_and_update_data()