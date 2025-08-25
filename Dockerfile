# ===========================
# Stage 1 – Builder
# ===========================
FROM python:3.11-slim AS builder

WORKDIR /app

# Install system dependencies required for PyTorch / Hugging Face builds
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip + wheel
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Copy requirements first (for caching)
COPY requirements.txt .

# Install dependencies twice:
# 1. Into system path (so pytest etc. are on PATH during tests)
# 2. Into /install (for runtime slim image)
RUN pip install --no-cache-dir -r requirements.txt \
 && pip install --no-cache-dir --prefix=/install -r requirements.txt

# Copy application code (optional for tests in builder stage)
COPY ./app ./app

# Environment (builder only)
ENV PYTHONPATH=/app
ENV HF_HOME=/app/.cache/huggingface
ENV TRANSFORMERS_CACHE=/app/.cache/huggingface


# ===========================
# Stage 2 – Runtime
# ===========================
FROM python:3.11-slim

WORKDIR /app

# Create a non-root user for security
RUN useradd -m appuser

# Environment variables
ENV PYTHONPATH=/app
ENV HF_HOME=/app/.cache/huggingface
ENV TRANSFORMERS_CACHE=/app/.cache/huggingface

# Copy installed dependencies from builder
COPY --from=builder /install /usr/local

# Copy app code
COPY ./app ./app

# Ensure Hugging Face cache directory exists with correct permissions
RUN mkdir -p /app/.cache/huggingface && chown -R appuser:appuser /app/.cache

# Switch to non-root user
USER appuser

EXPOSE 8081

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8081"]
