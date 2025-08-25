# ===========================
# Stage 1 – Builder
# ===========================
FROM python:3.11-slim AS builder

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gcc \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip tooling
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Copy requirements first
COPY requirements.txt .

# Install runtime dependencies into /install
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Install test dependencies only in builder
RUN pip install --no-cache-dir pytest pytest-asyncio

# Copy application code
COPY ./app ./app

# Hugging Face cache env vars
# ✅ Add /install site-packages so pytest can import deps like httpx, fastapi, etc.
ENV PYTHONPATH=/app:/install/lib/python3.11/site-packages
ENV HF_HOME=/app/.cache/huggingface
ENV TRANSFORMERS_CACHE=/app/.cache/huggingface

# Ensure cache dir exists and is writable (important for Jenkins & model downloads)
RUN mkdir -p /app/.cache/huggingface && chmod -R 777 /app/.cache


# ===========================
# Stage 2 – Runtime
# ===========================
FROM python:3.11-slim

WORKDIR /app

# Create non-root user
RUN useradd -m appuser

# Environment vars
ENV PYTHONPATH=/app
ENV HF_HOME=/app/.cache/huggingface
ENV TRANSFORMERS_CACHE=/app/.cache/huggingface

# Copy installed dependencies from builder
COPY --from=builder /install /usr/local

# Copy application code
COPY ./app ./app

# Ensure Hugging Face cache exists with correct permissions
RUN mkdir -p /app/.cache/huggingface && chown -R appuser:appuser /app/.cache

# Switch to non-root user
USER appuser

EXPOSE 8081

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8081"]