# server-simulator/Dockerfile
FROM python:3.12-slim

# Définir le répertoire de travail
WORKDIR /app

# Copie des fichiers
COPY server-lib/ /app/server-lib
COPY server-simulator/requirements.txt ./ 
COPY server-simulator/docker-entrypoint.sh .
COPY . .

# Installation des dépendances
RUN pip install --no-cache-dir /app/server-lib \
    && pip install --no-cache-dir -r requirements.txt

# Droit sur le fichier et lancement du docker-entrypoint
RUN chmod +x server-simulator/docker-entrypoint.sh
ENTRYPOINT ["server-simulator/docker-entrypoint.sh"]