# List all resources in a subscription - export command - do we need to install module?

Get-AzResource | Select-Object Name, ResourceType, Location | Export-Csv -Path "AzureResources.csv" -NoTypeInformation

# Potential heart beat solution for FHIR stores.

# Run on task scheduler - 15 minute intervals

$fhirestoreheartbeat = @("")

foreach ($store in $fhirestoreheartbeat) {
    try {
        $response = Invoke-RestMethod -Uri "$store/metadata" -Method Get
        Write-Output "Store $store is healthy."
    } catch {
        Write-Error "store $store is down : $_"
    }
}

#==================

$mainmenu = {
    Write-Host  "***************"
    Write-Host  "* Menu *"
    Write-Host  
    Write-Host  "1. Backup Script"
    Write-Host  "2. Validation Script"
    Write-Host  "3. Exit"
    Write-Host  "Select option and press enter"
    }
    
    Do {
    Invoke-Command $mainmenu
    $select = Read-Host
    switch ($select) 
        {
        1{
    
        }  
    
    
        2 {
    
        }
        
        3{ 
    
    
        }
    }
    While ($select -ne 5)

    ### =================