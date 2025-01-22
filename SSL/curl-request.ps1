<#
.SYNOPSIS
    Executes a cURL request to a specified URI with a provided API key.

.DESCRIPTION
    This script sends a GET request to a specified FHIR endpoint using the Invoke-RestMethod cmdlet. 
    It bypasses SSL certificate validation by implementing a custom certificate policy.

.PARAMETER apiKey
    The API key required for authentication with the FHIR endpoint.

.INPUTS
    None. The script prompts the user to enter the API key.

.OUTPUTS
    The response from the FHIR endpoint.

.NOTES
    This script is intended to be used when POSTMAN is not available for the task.
    The script is untested and should be used with caution, especially in production environments.

.EXAMPLE
    PS> .\curl-request.ps1
    Please enter the API Key: <your_api_key>
    (Response from the FHIR endpoint)
#>
# Runs curl request should POSTMAN not be available for the task.

# Untested


add-type @"

using http://System.Net ;

using System.Security.Cryptography.X509Certificates;

public class TrustAllCertsPolicy : ICertificatePolicy {

    public bool CheckValidationResult(

        ServicePoint srvPoint, X509Certificate certificate,

        WebRequest request, int certificateProblem) {

            return true;

        }

 }

"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

$apiKey = Read-Host "Please enter the API Key"

$headers = @{

    "api-key"= $apiKey

}

Invoke-RestMethod -Method Get -Uri 'https://localhost:8443/fhir/stu3/Patient?_tag=https://yhcr.nhs.uk/pix/registration/status|error,failed' -Headers $headers