FROM python:3.12-slim

WORKDIR /app

# Copier la lib partagée depuis le contexte racine
COPY server-lib/ ./server-lib

# Copier le code du service
COPY server-simulator/ .

# Copier le script d'entrée
COPY server-simulator/docker-entrypoint.sh .
RUN chmod +x docker-entrypoint.sh

# Installer dépendances
RUN pip install --no-cache-dir ./server-lib \
    && pip install --no-cache-dir -r requirements.txt

ENTRYPOINT ["./docker-entrypoint.sh"]
