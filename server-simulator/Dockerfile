# server-simulator/Dockerfile
FROM python:3.12-slim

WORKDIR /app

# Copier la lib partagée
COPY server-lib/ /app/server-lib

# Copier le service
COPY server-simulator/requirements.txt .
COPY server-simulator/ .
COPY server-simulator/docker-entrypoint.sh .

# Installer dépendances
RUN pip install --no-cache-dir /app/server-lib \
    && pip install --no-cache-dir -r requirements.txt

# Rendre exécutable
RUN chmod +x docker-entrypoint.sh

ENTRYPOINT ["./docker-entrypoint.sh"]
