# Stage 1 – Builder
FROM python:3.11-slim AS builder

WORKDIR /app

# Install system dependencies required for PyTorch / Hugging Face builds
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

# Install dependencies into a separate folder
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


# Stage 2 – Runtime
FROM python:3.11-slim

WORKDIR /app

# Set environment variables for Hugging Face caching and Python path
ENV PYTHONPATH=/app
ENV HF_HOME=/app/.cache/huggingface
ENV TRANSFORMERS_CACHE=/app/.cache/huggingface

# Copy installed dependencies from builder
COPY --from=builder /install /usr/local

# Copy application code
COPY ./app ./app

# Ensure cache directory exists with correct permissions
RUN mkdir -p /app/.cache/huggingface && chmod -R 777 /app/.cache/huggingface

EXPOSE 8081

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8081"]
