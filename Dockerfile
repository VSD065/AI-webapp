# Stage 1 – Build stage: Install your Python dependencies
FROM python:3.11-slim AS builder
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
 && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Stage 2 – Runtime stage with CPU-only PyTorch
FROM cnstark/pytorch:2.4.1-py3.10.15-ubuntu22.04

WORKDIR /app
COPY --from=builder /install /usr/local
COPY ./app ./app

EXPOSE 8081
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8081"]
