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