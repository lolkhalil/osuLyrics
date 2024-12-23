# osuLyrics - Game by kha - Inspired by shaz - 30/06/24
# used MusicBrainz and OVH API to get Duration and Lyrics of the songs
# TODO: enable setting to play song on spotify using start spotify:track

# getting the lyrics from a free ez apis with no api key/access token needed
$gotLyrics = $false
while ($gotLyrics -eq $false) {
    $artist = Read-Host "which artist made the song?"
    $song = read-host "what is the name of the song"
    
    # if the result isn't found "recordings" is returned null
    $brainzAPI = Invoke-RestMethod -Uri "https://musicbrainz.org/ws/2/recording/?query=recording:$song AND artist:$artist&fmt=json"
    if ($brainzAPI.recordings.count -eq 0) {
        Write-Host -ForegroundColor "Red" "`nCouldn't find the song Duration for $song by $artist. Check spelling or try a different song?`n"
    } else {
        try {
            # if it's not in the try-catch it'll throw an error
            $ovhAPI = Invoke-RestMethod -Uri "https://api.lyrics.ovh/v1/$artist/$song" -Method GET
            $gotLyrics = $true
        } catch {
            Write-Host -ForegroundColor "Red" "`nCouldn't find the song Lyrics for $song by $artist. Check spelling or try a different song?`n"
        }
    }
}

# formatting the lyrics
$SplitLyrics = $ovhAPI.lyrics.Replace("'","").Replace(",","").Replace("?","").Replace("!","").Replace(".","").Replace("youre","ur").ToLower().Split("`n")

# getting rid of the new lines between each lyric and splitting them up
$OrignialLyrics = @()
foreach ($Lyric in $SplitLyrics) {
    if ($Lyric -ne ""){
        $OrignialLyrics += "$Lyric`n"
    }
}
# calculating the seconds of the song
[int]$SongSeconds = $brainzAPI.recordings[0].length / 1000

Read-Host "Press Enter when you want to start"
# starting a timer
$timer = [Diagnostics.Stopwatch]::StartNew()

$UserLyrics = @()
$count = 0
while ($timer.Elapsed.TotalSeconds -lt $SongSeconds) {
    # showing the lyric to type
    Write-Host -ForegroundColor "White" "`n$($OrignialLyrics[$count])"
    $count++
    # adding the lyric to their current lyrics
    $UserLyrics += read-host
}

Write-Host "`nfinished"
Compare-Object -ReferenceObject $UserLyrics -DifferenceObject $OrignialLyrics
