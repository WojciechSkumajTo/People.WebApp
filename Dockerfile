# Specjalistyczny obraz, zoptymalizowany do uruchamiania ASP.NET
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base

# Ustawia katalog roboczy na /app wewnątrz kontenera
WORKDIR /app

# Otwiera port 5000
EXPOSE 5000

# Konfiguracja środowiska ASP.NET
ENV ASPNETCORE_URLS=http://+:5000

# Ustawienie użytkownika na "app" (stworzony w obrazie bazowym)
USER app

# Etap budowy
FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG configuration=Release
WORKDIR /src
COPY ["People.WebApp.csproj", "./"]
RUN dotnet restore "People.WebApp.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "People.WebApp.csproj" -c $configuration \
    -o /app/build

# Etap publikacji
FROM build AS publish
ARG configuration=Release
RUN dotnet publish "People.WebApp.csproj" -c $configuration \
    -o /app/publish /p:UseAppHost=false

# Etap końcowy (finalny)
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "People.WebApp.dll"]
