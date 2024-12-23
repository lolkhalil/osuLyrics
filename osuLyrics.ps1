# osuLyrics - Game by kha - Inspired by shaz
# used MusicBrainz and OVH API to get Duration and Lyrics of the songs
# TODO: enable setting to play song on spotify using start spotify:track

function AskStart() {
    $SavedSong = ShowSongs # this will need to return the duration and the lyrics

    if ($SavedSong -eq $false) {
        $GetInfo = $false
        while ($GetInfo -eq $false) {
            $AskSong = Read-Host "What is the Name of the song?"
            $AskArtist = Read-Host "What is the Artist of the song?"

            $Lyrics = GetLyrics $AskSong $AskArtist
            $Duration = GetDuration $AskSong $AskArtist

            if (($Lyrics -ne $false) -and ($Duration -ne $false)) { $GetInfo = $true }
        }
    } else {
        [int]$Duration = [int]$SavedSong.Duration
        [array]$Lyrics = $SavedSong.Lyrics
    }
    PlayGame $Duration $Lyrics $AskSong $AskArtist
}

function ShowSongs() {
    $AskShowSongs = ""
    while ($AskShowSongs -eq "") {
        $AskShowSongs = Read-Host "`nDo you want to view your saved songs?"
        if ($AskShowSongs -like "*y*") {
            break
        } elseif ($AskShowSongs -like "*n*") {
            return $false
        } else {
            Write-Host "Wrong input. Y/N?"
            $AskShowSongs = ""
        }
    }

    if (Test-Path "E:\italy\osuLyrics\songs") { 
        $SongFiles = Get-ChildItem -Path "E:\italy\osuLyrics\songs" 
    }
    
    if ($SongFiles.Count -eq 0) { return $false }

    $SongNames = $SongFiles.Name.Replace(".txt","")
    Write-Host "Here are your current saved songs`n"

    [PSCustomObject]$SongsArray = @{} 
    $count = 0

    foreach ($song in $SongNames) {
        Write-Host "$count. $song"
        $SongsArray += @{$count=$song}
        $count++
    }

    $WhichSong = ""
    while ($WhichSong -eq "") {
        try {
            $WhichSong = Read-Host "`nWhich song do you want to play? e.g. 1,3,7 (type 'exit' to choose a new song)"
            if ($WhichSong -like "*exit*") { return $false }
            $SongNumber = [int]$WhichSong
        } catch {
            Write-Host "Wrong format entered, please enter a number"
            $WhichSong = ""
        }
    } 

    [PSCustomObject]$AllInfo = @{}
    $SplitLyrics = (Get-Content -Path "E:\italy\osuLyrics\songs\$($SongsArray.$SongNumber)").Split("`n")
    
    # getting rid of the new lines between each lyric and splitting them up
    $Lyrics = @()
    foreach ($Lyric in $SplitLyrics) {
        if ($Lyric -ne ""){
            $Lyrics += "$Lyric`n"
        }
    }
    $AllInfo += @{Lyrics=$Lyrics}
    $AllInfo += @{Duration=(($SongsArray.$SongNumber).Split("-")[1].Trim())}

    return $AllInfo
}

# function to save the current song they are on
function SaveSong($Duration, $Lyrics, $SongName, $ArtistName) {
    if (!(Test-Path "E:\italy\osuLyrics\songs")) { 
        Write-Host -ForegroundColor "Red" "Couldn't find the folder to save the song"
        return
    }

    New-Item -Path "E:\italy\osuLyrics\songs" -Name "$SongName ($ArtistName) - $Duration" | Out-Null

    foreach ($Lyric in $Lyrics) {
        Add-Content -Path "E:\italy\osuLyrics\songs\$SongName ($ArtistName) - $Duration" -Value $Lyric
    }

    Write-Host "$SongName ($ArtistName) has been saved"
    return
}

function GetLyrics($SongName, $ArtistName) {
    # getting the lyrics from a free ez apis with no api key/access token needed
    try {
        # if it's not in the try-catch it'll throw an error
        $ovhAPI = Invoke-RestMethod -Uri "https://api.lyrics.ovh/v1/$ArtistName/$SongName" -Method GET
    } catch {
        Write-Host -ForegroundColor "Red" "`nCouldn't find the song Lyrics for $SongName by $ArtistName. Check spelling or try a different song?"
        return $false
    }
    
    # formatting the lyrics
    $SplitLyrics = $ovhAPI.lyrics.Replace("'","").Replace(",","").Replace("?","").Replace("!","").Replace(".","").Replace("youre","ur").ToLower().Split("`n")
    
    # getting rid of the new lines between each lyric and splitting them up
    $OriginalLyrics = @()
    foreach ($Lyric in $SplitLyrics) {
        if ($Lyric -ne ""){
            $OriginalLyrics += "$Lyric`n"
        }
    }

    # returning the array of lyrics
    return $OriginalLyrics
}

function GetDuration($SongName, $ArtistName) {
    # if the result isn't found "recordings" is returned null
    $brainzAPI = Invoke-RestMethod -Uri "https://musicbrainz.org/ws/2/recording/?query=recording:$SongName AND artist:$ArtistName&fmt=json"
    if ($brainzAPI.recordings.count -eq 0) {
        Write-Host -ForegroundColor "Red" "`nCouldn't find the song Duration for $SongName by $ArtistName. Check spelling or try a different song?  "
        return $false
    }

    # calculating the seconds of the song
    [int]$SongSeconds = $brainzAPI.recordings[0].length / 1000
    return $SongSeconds
}

function PlayGame([int]$SongSeconds, $OriginalLyrics, $SongName, $ArtistName) {
    Read-Host "Press Enter when you want to start"
    # starting a timer
    $timer = [Diagnostics.Stopwatch]::StartNew()
    
    $UserLyrics = @()
    $count = 0
    while ($timer.Elapsed.TotalSeconds -lt $SongSeconds) {
        # showing the lyric to type and timer
        Write-Host -ForegroundColor "White" "`n$([math]::Round($timer.Elapsed.TotalSeconds,2)) | $SongSeconds"
        Write-Host -ForegroundColor "White" "$($OriginalLyrics[$count])"
        $count++
        # adding the lyric to their current lyrics
        $UserLyrics += Read-Host
    }   
    
    if (!(Test-Path "E:\italy\osuLyrics\songs\$SongName ($ArtistName) - $SongSeconds")) {
        $SaveSong = ""
        while ($SaveSong -eq "") {
            $SaveSong = Read-Host "`nDo you want to save this song? Y/N"
            if ($SaveSong -like "*y*") {
                SaveSong $SongSeconds $OriginalLyrics $SongName $ArtistName
            } elseif ($SaveSong -like "*n*") {
                break
            } else {
                Write-Host "Wrong input. Y/N?"
                $SaveSong = ""
            }
        }
    }

    #Compare-Object -ReferenceObject $UserLyrics -DifferenceObject $OriginalLyrics

    $PlayAgain = ""
    while ($PlayAgain -eq "") {
        $PlayAgain = Read-Host "`nDo you want to play again? Y/N"
        if ($PlayAgain -like "*y*") {
            AskStart
        } elseif ($PlayAgain -like "*n*") {
            exit
        } else {
            Write-Host "Wrong input. Y/N?"
            $PlayAgain = ""
        }
    }
}

Write-Host "`nWelcome to osuLyrics!`n"
AskStart