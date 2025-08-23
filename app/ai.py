from typing import Dict
from transformers import pipeline

# Load pipelines once at startup using CPU (device=-1)
sentiment_pipeline = pipeline("sentiment-analysis", device=-1)
summarization_pipeline = pipeline("summarization", device=-1)

async def analyze_sentiment(text: str) -> Dict:
    result = sentiment_pipeline(text)[0]
    return {"label": result["label"], "score": float(result["score"])}

async def summarize_text(text: str) -> Dict:
    result = summarization_pipeline(text, max_length=150, min_length=40, do_sample=False)[0]
    return {"summary_text": result["summary_text"]}
