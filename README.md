# strava-tools

## What is this

A collection of tools to get data from Strava.

## How to use

- Create an [API account](https://developers.strava.com/docs/getting-started/#account).
- Make a note of clientId and clientSecret.
- Run [Get-AccessToken.ps1](./Get-AccessToken.ps1), this will request authorisation from Strava. When you authorise the redirect will return to a page that can't be reached. Retrive the code from the URL and enter it into the prompt. This script will ask you to input:
  - authorisation token (the code from the URL)
  - client Id (retrieved from the API account page)
  - client secret (retrieved from the API account page)
- You can then run the other scripts, they will use the access token to get data from Strava and save to file in ./data
