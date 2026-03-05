# Build
FROM node:20-alpine AS build
WORKDIR /app

# Copier package.json et package-lock.json pour installer les deps
COPY package*.json .
RUN npm install

# Copier tout le code depuis le contexte (./frontend)
COPY . .
RUN npm run build

# Nginx
FROM nginx:stable-alpine

COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
