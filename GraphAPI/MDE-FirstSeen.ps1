# Define your app registration details
$tenantId = "YOUR TENANT ID"
$clientId = "CLIENT ID/REGISTERED APP ID"
$clientSecret = "REGISTERED APP SECRET VALUE"

# $tenantId is your Directory (tenant) ID 
# $clientId is your Application (client) ID found in the App Registration
# $clientSecret is the Value of the secret (not the ID or description)

 #Prepare token request
$tokenUri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
$tokenBody = "client_id=$clientId&scope=https%3A%2F%2Fapi.securitycenter.microsoft.com%2F.default&client_secret=$clientSecret&grant_type=client_credentials"

# Get access token
$tokenResponse = Invoke-RestMethod -Method Post -Uri $tokenUri -Body $tokenBody -ContentType "application/x-www-form-urlencoded"
$accessToken = $tokenResponse.access_token

# Prepare headers for Defender API call
$headers = @{
    Authorization = "Bearer $accessToken"
}

# Query Defender for device info
$uri = "https://api.securitycenter.microsoft.com/api/machines"
$response = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers

# Display device name and first seen date
$response.value | Select-Object computerDnsName, firstSeen

# Export to CSV

$deviceData = $response.value | Select-Object computerDnsName, firstSeen

$csvPath = "defender_devices.csv"
$deviceData | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8

Write-Host "Device data exported to $csvPath"
