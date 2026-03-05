FROM python:3.12-slim

WORKDIR /app

# Copier la lib partagée
COPY ../server-lib/ /app/server-lib

# Copier tout le code du service
COPY . .

# Installer dépendances
RUN pip install --no-cache-dir /app/server-lib \
    && pip install --no-cache-dir -r requirements.txt

# Rendre l’entrypoint exécutable
RUN chmod +x docker-entrypoint.sh

ENTRYPOINT ["./docker-entrypoint.sh"]
