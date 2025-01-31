# # Use the official PowerShell image
# FROM mcr.microsoft.com/powershell:latest

# # Set working directory
# WORKDIR /operational-scripts

# # Copy scripts to the container
# COPY scripts/ /scripts/
# COPY entrypoint.ps1 /scripts/

# # Set execution permissions (Linux only)
# RUN chmod +x /scripts/entrypoint.ps1

# # Set default command to execute PowerShell script
# ENTRYPOINT ["pwsh", "/scripts/entrypoint.ps1"]
