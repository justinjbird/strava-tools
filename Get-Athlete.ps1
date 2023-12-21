./Get-AccessToken.ps1

## Get secrets, secure authorisation token
$secrets = Get-Content .Secrets.txt | ConvertFrom-Json
$authorisationToken = $secrets | Select-Object -ExpandProperty authorisationToken | ConvertTo-SecureString -AsPlainText -Force

## Get data and save
$data = (Invoke-RestMethod -Uri https://www.strava.com/api/v3/athlete -Authentication OAuth -Token $authorisationToken -Method Get)
$data | ConvertTo-Json -Depth 9 | Out-File ./data/Athlete.json

## Authorisation token expires after use
./Expire-AuthorisationToken.ps1

## If athlete Id is not set, set it
if (!$secrets.athleteId) {
  $secrets.athleteId = $data.id
  $secrets | ConvertTo-Json > .Secrets.txt
} 
