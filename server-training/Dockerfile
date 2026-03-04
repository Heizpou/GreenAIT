FROM python:3.12-slim

WORKDIR /app

COPY server-lib/ /app/server-lib
COPY server-training/requirements.txt .
COPY server-training/ .
COPY server-training/docker-entrypoint.sh .

RUN pip install --no-cache-dir /app/server-lib \
    && pip install --no-cache-dir -r requirements.txt

RUN chmod +x docker-entrypoint.sh

ENTRYPOINT ["./docker-entrypoint.sh"]
