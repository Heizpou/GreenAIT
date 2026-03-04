FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY api-recommendations/*.csproj ./api-recommendations/
RUN dotnet restore ./api-recommendations

COPY api-recommendations/. ./api-recommendations/
RUN dotnet publish ./api-recommendations -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app

COPY --from=build /app/publish .

EXPOSE 80
ENTRYPOINT ["dotnet", "ApiRecommendations.dll"]
