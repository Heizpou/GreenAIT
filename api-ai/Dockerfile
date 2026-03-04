# api-ai/Dockerfile
FROM python:3.12-slim

# Définir le répertoire de travail
WORKDIR /app

# Copie des fichiers
COPY api-ai/requirements.txt ./ 
COPY api-ai/docker-entrypoint.sh .
COPY . .

# Installation des dépendances
RUN pip install --no-cache-dir -r requirements.txt

# Droit sur le fichier et lancement du docker-entrypoint
RUN chmod +x api-ai/docker-entrypoint.sh
ENTRYPOINT ["api-ai/docker-entrypoint.sh"]