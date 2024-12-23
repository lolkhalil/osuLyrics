# osuLyrics
osu! but with Lyrics (idea by some dude on tiktok)

# Notes
## getting the current time
```powershell
$SplitCurrentTime = (Get-Date -Format "mm:ss").Split(':')
$CurrentTime = [int]$SplitCurrentTime[0] * [int]$SplitCurrentTime[1]
write $currentTime 
```

## adding the seconds to the current time to see what second of the hour we would be at once the song is finished
```powershell
$AddSecondsTime = (Get-Date).AddSeconds($SongSeconds)
$SplitTime = $AddSecondsTime.ToString("mm:ss").Split(':')
$FinishedTime = ([int]$SplitTime[0] * [int]$SplitTime[1]) + $SongSeconds
write $FinishedTime
```

## changing the current time to update when the song gets finished
```powershell
$SplitCurrentTime = (Get-Date -Format "mm:ss").Split(':')
$CurrentTime = [int]$SplitCurrentTime[1] * 60

if ($CurrentTime -gt $FinishedTime) { break }
```

## API STUFF
``` powershell
$clientID = "REDACTED"
$clientSecret = "REDACTED"

$accessToken = (Invoke-RestMethod -Uri "https://accounts.spotify.com/api/token" -Method POST -Body "grant_type=client_credentials&client_id=$clientID&client_secret=$clientSecret").access_token
$LastDanceID = "5XQ72uyYxhXHQwhB23ToWM"
$lastdance = Invoke-RestMethod -Uri "https://api.spotify.com/v1/tracks/$LastDanceID" -Method GET -Headers @{Authorization="Bearer  $accessToken"}
```
