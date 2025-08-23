import os

class Settings:
    APP_NAME: str = os.getenv("APP_NAME", "ai-webapp")
    HF_MODEL_URL: str = os.getenv(
        "HF_MODEL_URL",
        "https://api-inference.huggingface.co/models/distilbert-base-uncased-finetuned-sst-2-english",
    )
    HF_API_TOKEN: str | None = os.getenv("HF_API_TOKEN")
    ENV: str = os.getenv("ENV", "dev")

settings = Settings()

