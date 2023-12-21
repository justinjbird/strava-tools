<#
.EXAMPLE
    ./Get-AccessToken.ps1
    ./Get-AccessToken.ps1 -reset
    ./Get-AccessToken.ps1 -scope "read,read_all,profile:read_all,activity:read" -reset
#>

param (
    [switch]$reset,
    [string]$scope = "read"
)

$path = "./.secrets.txt"
if (Test-Path -Path $path) {
    $secrets = (Get-Content -Path $path | ConvertFrom-Json)
}
## If no authorisationToken, authorise
if (!$secrets.authorisationToken -or $reset) {
    Write-Host "No access token found, authorising for the first time, manually save the authorisationToken"
    Start-Process "http://www.strava.com/oauth/authorize?client_id=$($secrets.clientId)&response_type=code&redirect_uri=http://localhost/exchange_token&approval_prompt=force&scope=${scope}"
    $authorisationToken = Read-Host "Enter authorisation token"
    $clientId = Read-Host "Enter client id"
    $clientSecret = Read-Host "Enter client secret"
}
else {
    ## If authorisationToken has expired, get a new one
    $epochTime = (Get-Date -UFormat %s)
    if ($epochTime -gt $secrets.expiresAt) {
        ## If refreshToken exists, use it
        if ($secrets.refreshToken) {
            Write-Host "Refreshing token"
            $body = @{
                client_id = $secrets.clientId
                client_secret = $secrets.clientSecret
                refresh_token = $secrets.refreshToken
                grant_type = "refresh_token"
            }
            $auth = (Invoke-RestMethod -Uri https://www.strava.com/oauth/token -Body $body -Method Post)
        }
        ## Otherwise, authenticate with authorisationToken
        else {
            Write-Host "Getting authorisation token"
            $body = @{
                client_id = $secrets.clientId
                client_secret = $secrets.clientSecret
                code = $secrets.authorisationToken
                grant_type = "authorization_code"
            }
            $auth = (Invoke-RestMethod -Uri https://www.strava.com/oauth/token -Body $body -Method Post)
        }  
    }
    else {
        Write-Host "Access token still valid, no need to refresh"
    }
}
## If access token returned, store it
if ($auth.access_token) {
    $data = @{
        athleteId = $secrets.athleteId
        authorisationToken = $auth.access_token
        clientId = $secrets.clientId
        clientSecret = $secrets.clientSecret
        expiresAt = $auth.expires_at
        refreshToken = $auth.refresh_token
    }
}
## If user input retrieved, store it
elseif ($authorisationToken) {
    $data = @{
        authorisationToken = $authorisationToken
        clientId = $clientId
        clientSecret = $clientSecret
    }
}
## Output to file
if ($data) {
    $data | ConvertTo-Json > $path
    Write-Host "Secrets.txt updated"
}