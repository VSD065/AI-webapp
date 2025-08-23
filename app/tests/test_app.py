import os
import pytest
from httpx import AsyncClient
from fastapi import status
from app.main import app

@pytest.mark.asyncio
async def test_health():
    async with AsyncClient(app=app, base_url="http://test") as ac:
        r = await ac.get("/health")
        assert r.status_code == status.HTTP_200_OK
        assert r.json()["status"] == "ok"

@pytest.mark.asyncio
async def test_sentiment_positive_negative_local():
    # ensure local mode (no token)
    if "HF_API_TOKEN" in os.environ:
        del os.environ["HF_API_TOKEN"]

    async with AsyncClient(app=app, base_url="http://test") as ac:
        pos = await ac.post("/api/sentiment", json={"text": "This is great and awesome"})
        neg = await ac.post("/api/sentiment", json={"text": "This is terrible and bad"})
        assert pos.status_code == 200 and pos.json()["label"] == "POSITIVE"
        assert neg.status_code == 200 and neg.json()["label"] == "NEGATIVE"

