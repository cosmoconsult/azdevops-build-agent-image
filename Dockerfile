# escape=`
ARG BASE
FROM mcr.microsoft.com/windows/servercore:ltsc$BASE

WORKDIR /azp
COPY start.ps1 .
CMD powershell .\start.ps1
