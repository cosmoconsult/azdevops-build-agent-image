# Examples

## Dockerfile.bcagent

- docker build -t cosmoconsult/azdevops-build-agent:dev-bcagent-2004 -f Dockerfile.bcagent --build-arg BASE=2004 --build-arg AZP_URL=https://dev.azure.com/cc-ppi --build-arg AZP_TOKEN=... .
- docker push cosmoconsult/azdevops-build-agent:dev-bcagent-2004

## Dockerfile.coreagent

- docker build -t cosmoconsult/azdevops-build-agent:dev-coreagent-2004 -f Dockerfile.coreagent --build-arg BASE=2004 --build-arg AZP_URL=https://dev.azure.com/cc-ppi --build-arg AZP_TOKEN=... .
- docker push cosmoconsult/azdevops-build-agent:dev-coreagent-2004

## Dockerfile.vsceagent

- docker build -t cosmoconsult/azdevops-build-agent:dev-vsceagent-2004 -f Dockerfile.vsceagent --build-arg BASE=2004 --build-arg AZP_URL=https://dev.azure.com/cc-ppi --build-arg AZP_TOKEN=... .
- docker push cosmoconsult/azdevops-build-agent:dev-vsceagent-2004
