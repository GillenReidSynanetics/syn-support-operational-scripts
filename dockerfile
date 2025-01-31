FROM mcr.microsoft.com/powershell:latest

workdir /operational-scripts

copy scripts/ /operational-scripts

copy entrypoint.ps1 /operational-scripts

runchmod +x /operational-scripts/entrypoint.ps1

entrypoint [ "pwsh", "/operational-scripts/entrypoint.ps1" ]