#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
USER app
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["Fragomen.Messaging/Fragomen.Messaging.csproj", "Fragomen.Messaging/"]
COPY ["Fragomen.Messaging.Application/Fragomen.Messaging.Application.csproj", "Fragomen.Messaging.Application/"]
COPY ["Frogomen.Messaging.Domain/Frogomen.Messaging.Domain.csproj", "Frogomen.Messaging.Domain/"]
COPY ["Fragomen.Messaging.Infrastructure/Fragomen.Messaging.Infrastructure.csproj", "Fragomen.Messaging.Infrastructure/"]
RUN dotnet restore "./Fragomen.Messaging/Fragomen.Messaging.csproj"
COPY . .
WORKDIR "/src/Fragomen.Messaging"
RUN dotnet build "./Fragomen.Messaging.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./Fragomen.Messaging.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Fragomen.Messaging.dll"]