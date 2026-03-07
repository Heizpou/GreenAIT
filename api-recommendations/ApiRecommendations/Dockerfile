FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Lib partagée (layer cacheable)
COPY shared/GreenAIT.Data/ ./shared/GreenAIT.Data/

# .csproj pour restore (layer cacheable)
COPY api-recommendations/ApiRecommendations/ApiRecommendations.csproj ./api-recommendations/ApiRecommendations/
RUN dotnet restore ./api-recommendations/ApiRecommendations/ApiRecommendations.csproj

# Code source
COPY api-recommendations/ApiRecommendations/ ./api-recommendations/ApiRecommendations/
RUN dotnet publish ./api-recommendations/ApiRecommendations/ApiRecommendations.csproj -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app

COPY --from=build /app/publish .

RUN apt-get update \
 && apt-get install -y --no-install-recommends curl \
 && rm -rf /var/lib/apt/lists/*

EXPOSE 80
ENTRYPOINT ["dotnet", "ApiRecommendations.dll"]
