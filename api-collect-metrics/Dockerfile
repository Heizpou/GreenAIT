FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copier seulement le .csproj
COPY api-collect-metrics/*.csproj ./
RUN dotnet restore

# Copier le reste du code
COPY api-collect-metrics/. ./
RUN dotnet publish -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=build /app/publish .

EXPOSE 80
ENTRYPOINT ["dotnet", "ApiCollectMetrics.dll"]
