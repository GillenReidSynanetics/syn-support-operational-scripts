# List all resources in a subscription



Get-AzResource | Select-Object Name, ResourceType, Location | Export-Csv -Path "AzureResources.csv" -NoTypeInformation
