# Multi-platform support: amd64, arm64, arm/v7
# Optimized for ARM64 architecture deployment
# Use Alpine 3.18 with explicit Python for verified ARM64 support
FROM public.ecr.aws/docker/library/python:3-alpine3.18

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8080

WORKDIR /app

RUN apk add --no-cache build-base

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt && \
    apk del build-base

COPY app.py ./
COPY images ./images

EXPOSE 8080

CMD ["gunicorn", "-b", "0.0.0.0:8080", "app:app"]
