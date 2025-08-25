# ===========================
# Stage 1 – Builder
# ===========================
FROM python:3.11-slim AS builder

WORKDIR /app

# Install build deps (removed later)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gcc \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip tooling
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Copy requirements
COPY requirements.txt .

# Install runtime deps into /install (✅ only runtime, no pytest)
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Copy app code
COPY ./app ./app

# ===========================
# Stage 2 – Runtime
# ===========================
FROM python:3.11-slim

WORKDIR /app

# Create non-root user
RUN useradd -m appuser

# Copy only runtime deps
COPY --from=builder /install /usr/local

# Copy application code
COPY ./app ./app

# Set Hugging Face cache env
ENV HF_HOME=/app/.cache/huggingface
ENV TRANSFORMERS_CACHE=/app/.cache/huggingface
ENV PYTHONPATH=/app

# Create cache dir with correct permissions
RUN mkdir -p /app/.cache/huggingface && chown -R appuser:appuser /app/.cache

# Switch user
USER appuser

EXPOSE 8081

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8081"]
