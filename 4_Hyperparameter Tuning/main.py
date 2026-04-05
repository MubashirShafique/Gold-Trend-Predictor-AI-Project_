

import streamlit as st
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split, GridSearchCV, TimeSeriesSplit
from sklearn.preprocessing import RobustScaler
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score
from sklearn.ensemble import RandomForestClassifier
from sklearn.svm import SVC
from sklearn.linear_model import LogisticRegression
from xgboost import XGBClassifier
from lightgbm import LGBMClassifier

# Page configuration
st.set_page_config(page_title="Gold Trend Predictor Pro", layout="wide")
st.title("📊 Gold Market Trend Prediction (All 5 Models Optimized)")

# --- LOAD DATA FUNCTION ---
@st.cache_data
def load_data():
    # File name aapke dataset ke mutabiq
    df = pd.read_csv('gold_ml_dataset_2000_2026.csv')
    df = df.dropna() 
    return df

# Load data with error handling
try:
    df = load_data()
except FileNotFoundError:
    st.error("Dataset file nahi mili. Please check karein ke file name 'gold_ml_dataset_2000_2026.csv' hi hai.")
    st.stop()

# --- PREPROCESSING ---
# Features selection
X = df[['7d_avg', '30d_avg', 'daily_pct_change', 'volatility_7d', 'momentum_14d', 'price_zscore','volume', 'rsi','SMA5', 'SMA20']]
y = df['trend_signal']

# Train-Test Split (Time-series order maintained)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42, shuffle=False)

# Robust Scaling: Ye financial data ke sudden spikes ko behtar handle karta hai
scaler = RobustScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# --- MODELS DICTIONARY (Pancho Models With Better Params) ---
models = {
   "Logistic Regression": (LogisticRegression(max_iter=2000), {

        'C': [0.01, 0.1, 1, 10],

        'penalty': ['l2']

    }),
    
    "Random Forest": (RandomForestClassifier(random_state=42, class_weight='balanced'), {
        'n_estimators': [200, 500],
        'max_depth': [10, 20],
        'min_samples_split': [5, 10]
    }),
    
    "SVM": (SVC(probability=True, class_weight='balanced'), {
        'C': [1, 10],
        'gamma': ['scale', 'auto'], 
        'kernel': ['rbf']
    }),
    
    "XGBoost": (XGBClassifier(use_label_encoder=False, eval_metric='logloss', random_state=42), {
        'n_estimators': [200, 400],
        'learning_rate': [0.01, 0.05],
        'max_depth': [3, 6,],
        'subsample': [0.8]
    }),
    
    "LightGBM": (LGBMClassifier(verbosity=-1, random_state=42, class_weight='balanced'), {
        'n_estimators': [200, 400],
        'learning_rate': [0.01, 0.05],
        'num_leaves': [31, 50],
        'reg_alpha': [0.1, 0.5]
    })
}

# --- TRAINING SECTION ---
if st.button('🚀 Start Full Model Training'):
    results = []
    best_overall_acc = 0
    
    progress_bar = st.progress(0)
    status_text = st.empty()
    
    # TimeSeriesSplit: Trading data ke liye standard cross-validation
    tscv = TimeSeriesSplit(n_splits=3)

    for idx, (name, (model, params)) in enumerate(models.items()):
        status_text.text(f"Training {name} with Time-Series CV...")
        
        # Grid Search using f1 score (balanced classes ke liye behtar hai)
        grid = GridSearchCV(model, params, cv=tscv, scoring='accuracy', n_jobs=-1)
        grid.fit(X_train_scaled, y_train)
        
        best_model_found = grid.best_estimator_
        y_pred = best_model_found.predict(X_test_scaled)
        
        # Metrics calculation
        acc = accuracy_score(y_test, y_pred)
        prec = precision_score(y_test, y_pred, zero_division=0)
        rec = recall_score(y_test, y_pred, zero_division=0)
        f1 = f1_score(y_test, y_pred, zero_division=0)
        
        results.append({
            "Model": name,
            "Accuracy": round(acc, 4),
            "Precision": round(prec, 4),
            "Recall": round(rec, 4),
            "F1-Score": round(f1, 4),
            "Best Params": str(grid.best_params_)
        })
        
        progress_bar.progress((idx + 1) / len(models))

    # Results Display
    status_text.text("Training Mukammal!")
    results_df = pd.DataFrame(results).sort_values(by="Accuracy", ascending=False)
    
    st.subheader("📈 Models Comparison Table")
    st.dataframe(results_df, use_container_width=True)
    
    winner = results_df.iloc[0]
    st.success(f"Sabse behtar model **{winner['Model']}** raha jiski accuracy **{winner['Accuracy']*100:.2f}%** hai.")



    # --- TXT FILE SAVING LOGIC ---
    file_content = (
        f"Best Model: {winner['Model']}\n"
        f"Accuracy: {winner['Accuracy']}\n"
        f"Hyperparameters: {winner['Best Params']}"
    )

    
    with open("best_model_info.txt", "w") as f:
        f.write(file_content)

    
    