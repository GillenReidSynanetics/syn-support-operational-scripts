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