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
    """Ensure sentiment works in local mode (no HF_API_TOKEN)."""
    if "HF_API_TOKEN" in os.environ:
        del os.environ["HF_API_TOKEN"]

    async with AsyncClient(app=app, base_url="http://test") as ac:
        pos = await ac.post("/api/sentiment", json={"text": "This is great and awesome"})
        neg = await ac.post("/api/sentiment", json={"text": "This is terrible and bad"})
        assert pos.status_code == 200
        assert pos.json()["label"] == "POSITIVE"
        assert neg.status_code == 200
        assert neg.json()["label"] == "NEGATIVE"


@pytest.mark.asyncio
async def test_sentiment_with_hf_api(monkeypatch):
    """Ensure sentiment works in remote mode (with HF_API_TOKEN)."""
    monkeypatch.setenv("HF_API_TOKEN", "fake-test-token")

    async with AsyncClient(app=app, base_url="http://test") as ac:
        res = await ac.post("/api/sentiment", json={"text": "I love this product!"})
        assert res.status_code == 200
        data = res.json()
        # Check response has the expected keys, actual label may vary depending on HuggingFace API
        assert "label" in data
        assert "score" in data
