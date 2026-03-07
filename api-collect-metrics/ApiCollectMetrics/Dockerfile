FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Lib partagée (layer cacheable)
COPY shared/GreenAIT.Data/ ./shared/GreenAIT.Data/

# .csproj pour restore (layer cacheable)
COPY api-collect-metrics/ApiCollectMetrics/ApiCollectMetrics.csproj ./api-collect-metrics/ApiCollectMetrics/
RUN dotnet restore ./api-collect-metrics/ApiCollectMetrics/ApiCollectMetrics.csproj

# Code source
COPY api-collect-metrics/ApiCollectMetrics/ ./api-collect-metrics/ApiCollectMetrics/
RUN dotnet publish ./api-collect-metrics/ApiCollectMetrics/ApiCollectMetrics.csproj -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app

COPY --from=build /app/publish .

RUN apt-get update \
 && apt-get install -y --no-install-recommends curl \
 && rm -rf /var/lib/apt/lists/*

EXPOSE 80
ENTRYPOINT ["dotnet", "ApiCollectMetrics.dll"]
