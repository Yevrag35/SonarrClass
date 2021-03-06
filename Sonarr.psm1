class SonarrPVR
{
    # Defined Properties
    [string]$ApiKey
    [string]$SonarrUrl

    # Required Property
    SonarrPVR([string]$Url)
    {
        $this.SonarrUrl=$Url
    }

    # ApiKey Methods
    [void] GetApiKey()
    {
        $regkey = "HKCU:\Software\Mike Garvey\Sonarr"
        $binary = (Get-ItemProperty $regkey).ApiKey
        $hash = $binary | %{ $x = [CHAR][BYTE]"$($_)" ; [string]$decrypt = $x ; $decrypt }
        $hash = ($hash -join '').Trim()
        $api = $hash | ConvertTo-SecureString | ConvertFrom-SecureToPlain
        $this.ApiKey=$api
    }
    [void] SaveApiKey([string]$Key)
    {
        $step1 = "HKCU:\SOFTWARE\Mike Garvey"
        if (!(Test-path $step1)) {
            New-Item $step1 -ItemType Key -Force
        }
        $step2 = "HKCU:\SOFTWARE\Mike Garvey\Sonarr"
        if (!(Test-path $step2)) {
            New-Item $step2 -ItemType Key -Force
        }
        $hash = $Key | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString
        $binary = [System.Text.Encoding]::UTF8.GetBytes($hash)
        Set-ItemProperty $step2 -Name ApiKey -Value $binary -Force
    }

    # Format API Uri Methods
    hidden [string] FormatUri([string]$Endpoint)
    {
        $base = $this.SonarrUrl
        $key = $this.ApiKey
        $uri = $Base+'/api/'+$Endpoint+'?apikey='+$Key
        Write-Debug $uri
        return $uri
    }
    hidden [string] FormatUri([string]$Endpoint, [int]$ItemId)
    {
        $base = $this.SonarrUrl
        $key = $this.ApiKey
        $uri = $base+'/api/'+$Endpoint+'/'+$ItemId+'?apikey='+$Key
        Write-Debug $uri
        return $uri
    }
    hidden [string] FormatUri([string]$Endpoint, [string]$Condition, [int]$ConditionId)
    {
        $base = $this.SonarrUrl
        $key = $this.ApiKey
        $uri = $Base+'/api/'+$EndPoint+'?&'+$Condition+'='+$ConditionId+'&apikey='+$Key
        Write-Debug $uri
        return $uri
    }

    # Convert to Json Blocks
    hidden [string] ToJson([string]$Command)
    {
        $json = @{ Name = $Command } | ConvertTo-Json
        return $json
    }
    hidden [string] ToJson([hashtable]$hash)
    {
        $json = $hash | ConvertTo-Json
        return $json
    }

    # Issue the API Call
    hidden [object] Call([string]$Uri)
    {
        $result = Invoke-RestMethod -Uri $Uri -Method Get
        return $result
    }
    hidden [object] Call([string]$Uri, [string]$Method, [string]$Json)
    {
        $result = Invoke-RestMethod -Uri $Uri -Method $Method -Body $Json
        return $result
    }

    # Series
    [psobject] GetSeries()
    {
        $query = $this.FormatUri("series")
        $results = $this.Call($query)
        $retObj = $results | %{
            New-Object PSObject -Property @{
                Show = $_.title
                seasonCount = $_.seasonCount
                totalEpisodeCount = $_.totalEpisodeCount
                sizeOnDiskInGB = [math]::Round(($($_.sizeOnDisk)/1GB),2)
                status = $_.status
                nextAiring = $_.nextAiring
                previousAiring = $_.previousAiring
                network = $_.network
                airTime = $_.airTime
                seasons = $_.seasons
                year = $_.year
                path = $_.path
                profileId = $_.profileId
                seasonFolder = $_.seasonFolder
                monitored = $_.monitored
                runtime = $_.runtime
                tvdbId = $_.tvdbId
                cleanTitle = $_.cleanTitle
                certification = $_.certification
                genres = $_.genres
                added = $_.added
                ratings = $_.ratings
                qualityProfileId = $_.qualityProfileId
                id = $_.id
            }
        }
        return $retObj
    }
    [psobject] GetSeries([string]$Show)
    {
        $query = $this.FormatUri("series")
        $results = $this.Call($query)
        $retObj = $results | ? title -eq $Show | %{
            New-Object PSObject -Property @{
                Show = $_.title
                seasonCount = $_.seasonCount
                totalEpisodeCount = $_.totalEpisodeCount
                sizeOnDiskInGB = [math]::Round(($($_.sizeOnDisk)/1GB),2)
                status = $_.status
                nextAiring = $_.nextAiring
                previousAiring = $_.previousAiring
                network = $_.network
                airTime = $_.airTime
                seasons = $_.seasons
                year = $_.year
                path = $_.path
                profileId = $_.profileId
                seasonFolder = $_.seasonFolder
                monitored = $_.monitored
                runtime = $_.runtime
                tvdbId = $_.tvdbId
                cleanTitle = $_.cleanTitle
                certification = $_.certification
                genres = $_.genres
                added = $_.added
                ratings = $_.ratings
                qualityProfileId = $_.qualityProfileId
                id = $_.id
            }
        }
        return $retObj
    }
    [psobject] GetSeries([int]$ShowId)
    {
        $query = $this.FormatUri("series", $ShowId)
        $results = $this.Call($query)
        $retObj = $results | %{
            New-Object PSObject -Property @{
                Show = $_.title
                seasonCount = $_.seasonCount
                totalEpisodeCount = $_.totalEpisodeCount
                sizeOnDiskInGB = [math]::Round(($($_.sizeOnDisk)/1GB),2)
                status = $_.status
                nextAiring = $_.nextAiring
                previousAiring = $_.previousAiring
                network = $_.network
                airTime = $_.airTime
                seasons = $_.seasons
                year = $_.year
                path = $_.path
                profileId = $_.profileId
                seasonFolder = $_.seasonFolder
                monitored = $_.monitored
                runtime = $_.runtime
                tvdbId = $_.tvdbId
                cleanTitle = $_.cleanTitle
                certification = $_.certification
                genres = $_.genres
                added = $_.added
                ratings = $_.ratings
                qualityProfileId = $_.qualityProfileId
                id = $_.id
            }
        }
        return $retObj
    }

    # Episode
    [object] GetEpisode([string]$Show)
    {
        $showId = ($this.GetSeries($Show)).id
        if (!$showId) {
            throw "$Show is not a valid show..."
        }
        $findEP = $this.FormatUri("episode", "seriesId", $ShowId)
        $results = $this.Call($findEP)
        return $results
    }
    [object] GetEpisode([int]$EpisodeId)
    {
        $query = $this.FormatUri("episode", $EpisodeId)
        $epRes = $this.Call($query)
        return $epRes
    }
    [object] GetEpisode([string]$Show, [int]$EpisodeNo)
    {
        $showId = ($this.GetSeries($Show)).id
        if (!$showId) {
            throw "$Show is not a valid show..."
        }
        $findEp = $this.FormatUri("episode", "seriesId", $ShowId)
        $epRes = $this.Call($findEP)
        $realEP = $epRes | ? episodeNumber -eq $EpisodeNo
        return $realEP
    }
    [object] GetEpisode([int]$ShowId, [int]$EpisodeNo)
    {
        $findEPs = $this.FormatUri("episode", "seriesId", $ShowId)
        $allEps = $this.Call($findEPs)
        if (!$allEps) {
            throw "$ShowId is not a valid ShowID..."
        }
        $realEP = $allEps | ? episodeNumber -eq $EpisodeNo
        return $realEP
    }
    [object] GetSeason([string]$Show, [int]$SeasonNo)
    {
        $eps = $this.GetEpisode($Show)
        $season = $eps | ? seasonNumber -eq $SeasonNo
        return $season
    }
    [object] GetSeason([int]$ShowId, [int]$SeasonNo)
    {
        $series = ($this.GetSeries($ShowId)).Show
        $eps = $this.GetEpisode($series)
        $season = $eps | ? seasonNumber -eq $SeasonNo
        return $season
    }

    # Command
    [object] GetJob()
    {
        $get = $this.FormatUri("command")
        $results = $this.Call($get)
        return $results
    }
    [object] GetJob([int]$CommandId)
    {
        $get = $this.FormatUri("command", $CommandId)
        $results = $this.Call($get)
        return $results
    }
    [string] StartRssSync()
    {
        $json = $this.ToJson("RssSync")
        $post = $this.FormatUri("command")
        $res = $this.Call($post, "Post", $json)
        return $res
    }
    [object] RefreshSeries()
    {
        $post = $this.FormatUri("command")
        $json = $this.ToJson("RefreshSeries")
        $res = $this.Call($post, "Post", $json)
        return $res
    }
    [object] RefreshSeries([string]$Show)
    {
        $getShow = ($this.GetSeries($Show)).id
        $post = $this.FormatUri("command")
        $json = $this.ToJson(@{
            Name = "RefreshSeries"
            seriesId = $getShow
        })
        $res = $this.Call($post, "Post", $json)
        return $res
    }
    [object] RefreshSeries([int]$ShowId)
    {
        $post = $this.FormatUri("command")
        $json = $this.ToJson(@{
            Name = "RefreshSeries"
            seriesId = $ShowId
        })
        $res = $this.Call($post, "Post", $json)
        return $res
    }
    [object] SearchSeason([string]$Show, [int]$SeasonNo)
    {
        $post = $this.FormatUri("command")
        $showId = ($this.GetSeries($Show)).id
        $json = $this.ToJson(@{
            Name = "SeasonSearch"
            seriesId = $showId
            seasonNumber = $SeasonNo
        })
        $res = $this.Call($post, "Post", $json)
        return $res
    }
    [object] SearchSeason([int]$ShowId, [int]$SeasonNo)
    {
        $post = $this.FormatUri("command")
        $json = $this.ToJson(@{
            Name = "SeasonSearch"
            seriesId = $showId
            seasonNumber = $SeasonNo
        })
        $res = $this.Call($post, "Post", $json)
        return $res
    }

    # System-Backup
    [object] Backup()
    {
        $post = $this.FormatUri("command")
        $json = $this.ToJson("Backup")
        $res = $this.Call($post, "Post", $json)
        return $res
    }

    # System-Status
    [psobject] CheckSystemStatus()
    {
        $get = $this.FormatUri("system/status")
        $res = $this.Call($get)
        $retObj = $res | %{
            New-Object PSObject -Property @{
                Version = $_.Version
                BuildTime = ([datetime]$($_.buildTime)).ToString("MM/dd/yyyy hh:mm:ss tt")
                IsDebug = $_.isDebug
                IsProduction = $_.isProduction
                IsAdmin = $_.isAdmin
                IsUserInteractive = $_.isUserInteractive
                StartupPath = $_.startupPath
                AppData = $_.appData
                OSVersion = $_.osVersion
                IsMono = $_.isMono
                IsLinux = $_.isLinux
                IsWindows = $_.isWindows
                Branch = $_.branch
                Authentication = $_.authentication
                StartOfWeek = $_.startOfWeek
                URLBase = $_.urlBase
            }
        }
        return $retObj
    }

    # Diskspace
    [psobject] CheckDisks()
    {
        $get = $this.FormatUri("diskspace")
        $res = $this.Call($get)
        $retObj = $res | %{
            New-Object PSObject -Property @{
                Path = $_.path
                "Free Space" = [math]::Round(($_.freeSpace/1GB),2)
                "Total Space" = [math]::Round(($_.totalSpace/1GB),2)
            }
        }
        return $retObj
    }
}