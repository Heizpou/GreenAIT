FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY api-collect-metrics/*.csproj ./api-collect-metrics/
RUN dotnet restore ./api-collect-metrics

COPY api-collect-metrics/. ./api-collect-metrics/
RUN dotnet publish ./api-collect-metrics -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app

COPY --from=build /app/publish .

EXPOSE 80
ENTRYPOINT ["dotnet", "ApiCollectMetrics.dll"]
