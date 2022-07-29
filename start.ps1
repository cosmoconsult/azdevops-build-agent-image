if (-not (Test-Path Env:AZP_URL)) {
  Write-Error "error: missing AZP_URL environment variable"
  exit 1
}

if (-not (Test-Path Env:AZP_TOKEN_FILE)) {
  if (-not (Test-Path Env:AZP_TOKEN)) {
    Write-Error "error: missing AZP_TOKEN environment variable"
    exit 1
  }

  $Env:AZP_TOKEN_FILE = "\azp\.token"
  $Env:AZP_TOKEN | Out-File -FilePath $Env:AZP_TOKEN_FILE
}

Remove-Item Env:AZP_TOKEN

if ($Env:AZP_WORK -and -not (Test-Path Env:AZP_WORK)) {
  New-Item $Env:AZP_WORK -ItemType directory | Out-Null
}

# Let the agent ignore the token env variables
$Env:VSO_AGENT_IGNORE = "AZP_TOKEN,AZP_TOKEN_FILE"

if ([intptr]::Size -eq 4) {
  Write-Host "running in x86"
} else {
  Write-Host "running in x64"
}

Set-Location agent
try
{

  if (Test-Path Env:AZP_ENVIRONMENTNAME) {
    Write-Host "Configuring Azure Environment agent..." -ForegroundColor Cyan

    .\config.cmd --environment `
      --environmentname "$(${$env:AZP_ENVIRONMENTNAME})" `
      --unattended `
      --replace `
      --agent "$(if (Test-Path Env:AZP_AGENT_NAME) { ${Env:AZP_AGENT_NAME} } else { ${Env:computername} })" `
      --work "$(if (Test-Path Env:AZP_WORK) { ${Env:AZP_WORK} } else { '_work' })" `
      --url "$(${Env:AZP_URL})" `
      --projectname  "$(${$env:AZP_PROJECTNAME})" `
      --auth PAT `
      --token "$(Get-Content ${Env:AZP_TOKEN_FILE})" `
      --addvirtualmachineresourcetags `
      --virtualmachineresourcetags "$(${$env:AZP_DEPLOYMENTTAGS})"
  } else {
    Write-Host "Configuring Azure Pipelines agent..." -ForegroundColor Cyan

    .\config.cmd --unattended `
      --agent "$(if (Test-Path Env:AZP_AGENT_NAME) { ${Env:AZP_AGENT_NAME} } else { ${Env:computername} })" `
      --url "$(${Env:AZP_URL})" `
      --auth PAT `
      --token "$(Get-Content ${Env:AZP_TOKEN_FILE})" `
      --pool "$(if (Test-Path Env:AZP_POOL) { ${Env:AZP_POOL} } else { 'Default' })" `
      --work "$(if (Test-Path Env:AZP_WORK) { ${Env:AZP_WORK} } else { '_work' })" `
      --replace
  }

  # remove the administrative token before accepting work
  Remove-Item $Env:AZP_TOKEN_FILE

  Write-Host "Running Azure Pipelines agent..." -ForegroundColor Cyan

  # optionally copy in NST files for BC release pipelines with ALOps
  if (Test-Path Env:BC_RELEASE_PIPELINE) {
    Write-Host "Trying to find NST files"
    $types = Get-Item C:\bcartifacts.cache\* | Where-Object { $_.Name -eq "onprem" -or $_.Name -eq "sandbox" } | Sort-Object Name
    if ($types.Count -lt 1) {
      Write-Host "Couldn't identify BC artifact type"
    } else {
      $versions = Get-Item "C:\bcartifacts.cache\$($types[0].Name)\*" | Sort-Object Name -Descending
      if ($versions.Count -lt 1) {
        Write-Host "Couldn't identify BC artifact version"
      } else {
        $versionWithZero = "$($versions[0].Name.Substring(0, $versions[0].Name.IndexOf(".")))0"
        New-Item -Path $env:ProgramFiles -Name "Microsoft Dynamics NAV" -Type Directory
        New-Item -Path (Join-Path $env:ProgramFiles "Microsoft Dynamics NAV") -Name $versionWithZero -Type Directory
        Copy-Item -Path "C:\bcartifacts.cache\$($types[0].Name)\$($versions[0].Name)\platform\ServiceTier\program files\Microsoft Dynamics NAV\*\Service" -Destination (Join-Path $env:ProgramFiles "Microsoft Dynamics NAV\$versionWithZero") -Recurse
      }
    }
  }

  .\run.cmd
}
catch 
{
   Write-Host $_
   $LogFile = Get-Item -Path "C:\azp\agent\_diag\Agent_*.log" -ErrorAction SilentlyContinue
   if ($null -ne $LogFile) {
    Write-Host | Get-Content $LogFile
   }
}
finally
{
  Write-Host "Cleanup. Removing Azure Pipelines agent..." -ForegroundColor Cyan

  .\config.cmd remove --unattended `
    --auth PAT `
    --token "$(Get-Content ${Env:AZP_TOKEN_FILE})"
}
