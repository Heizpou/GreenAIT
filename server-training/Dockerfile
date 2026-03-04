# server-training/Dockerfile
FROM python:3.12-slim

# Dossier
WORKDIR /app

# Copie des fichiers
COPY server-lib/ /app/server-lib
COPY server-training/requirements.txt ./ 
COPY server-training/docker-entrypoint.sh .
COPY . .

# Installation des dépendances
RUN pip install --no-cache-dir /app/server-lib \
    && pip install --no-cache-dir -r requirements.txt

# Droit sur le fichier et lancement du docker-entrypoint
RUN chmod +x server-training/docker-entrypoint.sh
ENTRYPOINT ["server-training/docker-entrypoint.sh"]
