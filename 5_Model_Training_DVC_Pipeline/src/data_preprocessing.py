import pandas as pd
import os
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def preprocess_data():
    """Cleans raw gold data and handles missing essential values."""
    raw_path = 'data/raw/raw_data.csv'
    processed_path = 'data/processed/cleaned_data.csv'
    os.makedirs('data/processed', exist_ok=True)

    try:
        df = pd.read_csv(raw_path)
        df['Date'] = pd.to_datetime(df['Date'])
        
        # Sort and remove duplicates based on Date
        df = df.sort_values(by='Date').drop_duplicates(subset=['Date']).reset_index(drop=True)

        # Drop only if essential columns are missing to preserve new data rows
        initial_count = len(df)
        df = df.dropna(subset=['Date', 'final_price'])

        logging.info(f"Rows processed: {initial_count} -> {len(df)}")
        
        df.to_csv(processed_path, index=False)
        logging.info(f"Cleaned data saved to {processed_path}")

    except Exception as e:
        logging.error(f"Preprocessing failed: {e}")

if __name__ == "__main__":
    preprocess_data()