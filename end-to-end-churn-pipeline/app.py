from fastapi import FastAPI
from pydantic import BaseModel, Field
import joblib
import pandas as pd
from contextlib import asynccontextmanager


cat_dict = joblib.load('models/categories_dict.pkl')
model = None

@asynccontextmanager
async def lifespan(app: FastAPI):
    global model
    # Загружаем саму модель из папки models
    model = joblib.load('models/churn_model.pkl')
    print("🚀 Модель LightGBM успешно загружена из папки models!")
    yield
    model = None

app = FastAPI(title="E-commerce Churn API", lifespan=lifespan)


class CustomerFeatures(BaseModel):
    recency_days: float
    tenure_days: float
    total_orders: int
    total_spent: float
    max_installments: float
    avg_review_score: float = Field(..., ge=1.0, le=5.0)
    min_review_score: float = Field(..., ge=1.0, le=5.0)
    avg_delivery_delay: float
    max_delivery_delay: float
    cancellation_rate: float = Field(..., ge=0.0, le=1.0)
    customer_state: str 
    customer_city: str 
    avg_spent: float
    purchase_intensity: float
    lag_90d_orders: float
    lag_90d_spent: float
    recent_spend_ratio: float
    installment_burden: float

@app.post("/predict")
async def predict_churn(customer: CustomerFeatures):
    df = pd.DataFrame([customer.model_dump()])
    df['customer_state'] = pd.Categorical(df['customer_state'], categories=cat_dict['customer_state'])
    df['customer_city'] = pd.Categorical(df['customer_city'], categories=cat_dict['customer_city'])
    
    proba = model.predict_proba(df)[0, 1]
    

    BEST_THRESHOLD = 0.01 
    
    return {
        "churn_probability": round(float(proba), 4),
        "send_promo": bool(proba >= BEST_THRESHOLD)
    }