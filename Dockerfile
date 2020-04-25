# escape=`
ARG BASE
ARG AZP_TOKEN
ARG AZP_URL
FROM mcr.microsoft.com/windows/servercore:$BASE

WORKDIR /azp
COPY start.ps1 .
RUN powershell -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'));" `
    "choco install -y docker-cli;" `
    "Install-PackageProvider -Name \"Nuget\" -Force;" `
    "Install-Module AzureDevOpsAPIUtils -Force -ErrorAction SilentlyContinue"

RUN powershell -Command "New-Item \"\\azp\\agent\" -ItemType directory | Out-Null;" `
    "Set-Location agent;" `
    "$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(\":$AZP_TOKEN\"));" `
    "$package = Invoke-RestMethod -Headers @{Authorization=(\"Basic $base64AuthInfo\")} \"$AZP_URL/_apis/distributedtask/packages/agent?platform=win-x64&``$top=1\";" `
    "$packageUrl = $package[0].Value.downloadUrl;" `
    "Write-Host $packageUrl;" `
    "$wc = New-Object System.Net.WebClient;" `
    "$wc.DownloadFile($packageUrl, \"$(Get-Location)\\agent.zip\");" `
    "Expand-Archive -Path \"agent.zip\" -DestinationPath \"\\azp\\agent\""

CMD powershell .\start.ps1
