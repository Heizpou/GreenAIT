# Stage 1: build frontend
FROM node:20-alpine AS build
WORKDIR /app

# Copier package.json et lockfile depuis le dossier frontend
COPY frontend/package*.json ./

# Installer les dépendances
RUN npm install

# Copier tout le code frontend
COPY frontend/. .

# Build production
RUN npm run build

# Stage 2: Nginx
FROM nginx:stable-alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
