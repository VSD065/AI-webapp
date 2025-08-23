import time
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Dict
from .ai import analyze_sentiment, summarize_text
from .config import settings

# Prometheus imports
from prometheus_client import Counter, Histogram, make_asgi_app
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import Response

REQUESTS = Counter("http_requests_total", "Total HTTP requests", ["path", "method", "status"])
LATENCY = Histogram("http_request_duration_seconds", "Latency", ["path", "method", "status"])

class MetricsMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        start = time.time()
        response: Response | None = None
        try:
            response = await call_next(request)
            return response
        finally:
            status = str(response.status_code if response else 500)
            path = request.url.path
            method = request.method
            REQUESTS.labels(path, method, status).inc()
            LATENCY.labels(path, method, status).observe(time.time() - start)

app = FastAPI(title=settings.APP_NAME)
app.add_middleware(MetricsMiddleware)

class TextIn(BaseModel):
    text: str

@app.get("/health")
async def health() -> Dict:
    return {"status": "ok", "app": settings.APP_NAME, "env": settings.ENV}

@app.post("/api/sentiment")
async def sentiment(payload: TextIn) -> Dict:
    text = payload.text.strip()
    if not text:
        raise HTTPException(status_code=400, detail="text cannot be empty")
    result = await analyze_sentiment(text)
    return {"input": text, **result}

@app.post("/api/summarize")
async def summarize(payload: TextIn) -> Dict:
    text = payload.text.strip()
    if not text:
        raise HTTPException(status_code=400, detail="text cannot be empty")
    result = await summarize_text(text)
    return {"input": text, **result}

# Expose metrics endpoint for Prometheus
metrics_app = make_asgi_app()
app.mount("/metrics", metrics_app)
