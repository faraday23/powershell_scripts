# a PowerShell script that automates the process of querying and managing RESTful APIs, including parsing JSON and XML responses.

# Define the API endpoint and required parameters
$apiUrl = "https://api.example.com/"
$apiMethod = "GET"
$apiEndpoint = "users"
$apiParams = @{
    "page" = "1"
    "per_page" = "10"
}
$apiHeaders = @{
    "Authorization" = "Bearer xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}

# Set the maximum number of retries and time delay between retries
$maxRetries = 3
$retryDelay = [System.TimeSpan]::FromSeconds(5)

# Send the API request with retry mechanism
$retryCount = 0
do {
    try {
        $apiResponse = Invoke-RestMethod -Uri "$apiUrl$apiEndpoint" -Method $apiMethod -Headers $apiHeaders -Body $apiParams
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.Value__

        if ($statusCode -eq 429) {
            Write-Warning "HTTP 429 status code received. Retrying in $retryDelay seconds..."
            Start-Sleep -Seconds $retryDelay.TotalSeconds

            $retryCount++
            if ($retryCount -gt $maxRetries) {
                Write-Error "Maximum number of retries exceeded. Aborting request."
                break
            }
        } else {
            Write-Error "Error: $_"
            break
        }
    }
} while (!$apiResponse -and $retryCount -le $maxRetries)

# Parse the response data
if ($apiResponse) {
    if ($apiResponse -is [xml]) {
        $users = $apiResponse | ConvertFrom-Xml
    } else {
        $users = $apiResponse | ConvertFrom-Json
    }

    # Process the user data as needed
    foreach ($user in $users) {
        Write-Output "User: $($user.name) (ID: $($user.id))"
    }
} else {
    Write-Warning "No users found"
}