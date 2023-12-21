./Get-AccessToken.ps1

## Get secrets, secure authorisation token
$secrets = Get-Content .Secrets.txt | ConvertFrom-Json
$authorisationToken = $secrets | Select-Object -ExpandProperty authorisationToken | ConvertTo-SecureString -AsPlainText -Force

## Get athlete Id if not already set
if (!$secrets.atheleteId) {
  ./Get-Athlete.ps1
}

## Get data and save
$uri = "https://www.strava.com/api/v3/athlete/activities"
$data = (Invoke-RestMethod -Uri $uri -Authentication OAuth -Token $authorisationToken -Method Get)
$data | ConvertTo-Json -Depth 9 | Out-File ./data/Activities.json

## Authorisation token expires after use
./Expire-AuthorisationToken.ps1
