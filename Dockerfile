# Stage 1 – Builder (for building and testing)
FROM python:3.11-slim AS builder

WORKDIR /app

# Install system dependencies required for PyTorch / Hugging Face builds
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

# Install all dependencies, including dev/test packages like pytest
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Copy application code
COPY ./app ./app

# Optional: set PYTHONPATH in builder (for running tests)
ENV PYTHONPATH=/app
ENV HF_HOME=/app/.cache/huggingface
ENV TRANSFORMERS_CACHE=/app/.cache/huggingface

# Stage 2 – Runtime (for production)
FROM python:3.11-slim

WORKDIR /app

# Set environment variables for Python path and Hugging Face cache
ENV PYTHONPATH=/app
ENV HF_HOME=/app/.cache/huggingface
ENV TRANSFORMERS_CACHE=/app/.cache/huggingface

# Copy only installed dependencies from builder (runtime deps only)
COPY --from=builder /install /usr/local

# Copy application code
COPY ./app ./app

# Ensure cache directory exists with correct permissions
RUN mkdir -p /app/.cache/huggingface && chmod -R 777 /app/.cache/huggingface

EXPOSE 8081

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8081"]
