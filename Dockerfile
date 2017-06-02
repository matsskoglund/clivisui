FROM microsoft/dotnet:1.1-sdk

WORKDIR /app

EXPOSE 80/tcp

COPY bin/Debug/netcoreapp1.1/publish /app

ENTRYPOINT ["dotnet", "Clivisui.dll","--server.urls","http://*:80"]

