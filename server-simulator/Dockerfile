FROM python:3.12-slim

WORKDIR /app

# Copier la lib partagée depuis le contexte racine
COPY shared/server-lib/ ./server-lib

# Copier le code du service
COPY server-simulator/ .

# Copier le script d'entrée
RUN chmod +x docker-entrypoint.sh

# Installer curl pour le healthcheck
RUN apt-get update \
 && apt-get install -y --no-install-recommends curl \
 && rm -rf /var/lib/apt/lists/*

# Installer dépendances
RUN pip install --no-cache-dir ./server-lib \
    && pip install --no-cache-dir -r requirements.txt

ENTRYPOINT ["./docker-entrypoint.sh"]
