# Stage 1 – Builder
FROM python:3.11-slim AS builder

WORKDIR /app

# Install system dependencies required for PyTorch / Hugging Face builds
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

# Install dependencies (including pytest) into /install
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Stage 2 – Runtime
FROM python:3.11-slim

WORKDIR /app

# Environment variables
ENV PYTHONPATH=/app
ENV HF_HOME=/app/.cache/huggingface
ENV TRANSFORMERS_CACHE=/app/.cache/huggingface

# Copy Python packages from builder
COPY --from=builder /install /usr/local

# Copy application code
COPY ./app ./app

# Ensure Hugging Face cache directory exists with proper permissions
RUN mkdir -p /app/.cache/huggingface && chmod -R 777 /app/.cache/huggingface

# Install pytest for runtime tests (optional, but ensures Jenkins can run tests)
RUN pip install --no-cache-dir pytest pytest-asyncio

EXPOSE 8081

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8081"]
