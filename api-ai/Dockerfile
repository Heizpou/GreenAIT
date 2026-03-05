FROM python:3.12-slim

WORKDIR /app

# Copier les fichiers depuis le contexte du projet (./api-ai)
COPY . .

# Installer les dépendances
RUN pip install --no-cache-dir -r requirements.txt

# Rendre le script exécutable
RUN chmod +x docker-entrypoint.sh

# Installer curl
RUN apt-get update && apt-get install -y curl

# Entrypoint
ENTRYPOINT ["./docker-entrypoint.sh"]
