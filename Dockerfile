# escape=`
ARG BASE
FROM mcr.microsoft.com/windows/servercore:$BASE
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';"]
ARG AZP_TOKEN
ARG AZP_URL

WORKDIR /azp

RUN New-Item \"\azp\agent\" -ItemType directory | Out-Null; `
    Set-Location agent; `
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(\":$env:AZP_TOKEN\")); `
    $url = \"$ENV:AZP_URL/_apis/distributedtask/packages/agent?platform=win-x64&`$top=1\"; `
    $package = Invoke-RestMethod -Headers @{Authorization=(\"Basic $base64AuthInfo\")} $url; `
    $packageUrl = $package[0].Value.downloadUrl; `
    Write-Host \"Downloading $packageUrl\"; `
    $wc = New-Object System.Net.WebClient; `
    $wc.DownloadFile($packageUrl, \"$(Get-Location)\agent.zip\"); `
    Expand-Archive -Path 'agent.zip' -DestinationPath '\azp\agent'


RUN iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')); `
    choco install -y docker-cli; `
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
    Install-PackageProvider -Name 'Nuget' -Force; `
    Install-Module AzureDevOpsAPIUtils -Force -ErrorAction SilentlyContinue

COPY start.ps1 .
CMD .\start.ps1
