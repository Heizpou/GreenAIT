# api-ai/Dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY api-ai/requirements.txt .
COPY api-ai/ .
COPY api-ai/docker-entrypoint.sh .

RUN pip install --no-cache-dir -r requirements.txt

RUN chmod +x docker-entrypoint.sh
ENTRYPOINT ["./docker-entrypoint.sh"]
