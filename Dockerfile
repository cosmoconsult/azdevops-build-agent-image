# escape=`
ARG BASE
FROM mcr.microsoft.com/windows/servercore:$BASE

WORKDIR /azp
COPY start.ps1 .
RUN powershell -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'));" `
    "choco install -y docker-cli;" `
    "Install-PackageProvider -Name \"Nuget\" -Force" `
    "Install-Module AzureDevOpsAPIUtils -Force -ErrorAction SilentlyContinue"
CMD powershell .\start.ps1
