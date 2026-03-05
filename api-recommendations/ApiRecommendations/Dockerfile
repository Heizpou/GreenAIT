FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copier le .csproj pour restaurer les dépendances
COPY *.csproj ./
RUN dotnet restore

# Copier tout le code
COPY . ./
RUN dotnet publish -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app

# Copier le build publié
COPY --from=build /app/publish .

# Installer curl
RUN apt-get update && apt-get install -y curl

EXPOSE 80
ENTRYPOINT ["dotnet", "ApiRecommendations.dll"]
