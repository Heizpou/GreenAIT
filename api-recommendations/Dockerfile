FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copier seulement le .csproj
COPY api-recommendations/*.csproj ./
RUN dotnet restore

# Copier le reste du code
COPY api-recommendations/. ./
RUN dotnet publish -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=build /app/publish .

EXPOSE 80
ENTRYPOINT ["dotnet", "ApiRecommendations.dll"]