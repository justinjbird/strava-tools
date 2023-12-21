$secrets = (Get-Content -Path .Secrets.txt) | ConvertFrom-Json
$secrets.expiresAt = 0
$secrets | ConvertTo-Json > .Secrets.txt