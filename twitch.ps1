$channelNames = @("channel1", "channel2")
$clientId = ""
$auth = ""

$uri = "https://gql.twitch.tv/gql"
$headers = @{
    "Accept" = "*/*"
    "Accept-Encoding" = "gzip, deflate, br"
    "Accept-Language" = "en-US"
    "Authorization" = $auth
    "Client-Id" = $clientId
    "Connection" = "keep-alive"
    "Content-Type" = "application/json"
    "DNT" = 1
    "Host" = "gql.twitch.tv"
    "Origin" = "https://www.twitch.tv"
    "Referer" = "https://www.twitch.tv/"
    "User-Agent" = "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4204.0 Safari/537.36 Edg/86.0.587.0"
}

$targetChannel = ""
foreach ($channel in $channelNames){
    $targetChannel = $targetChannel + "\`"$($channel.ToLower())\`","
}

$bodyClaimId = "{`"query`":`",query{channels(names: [$($targetChannel)]){id name self{communityPoints{balance availableClaim{id}}}}}`"}"

DO
{
    Write-Host "› $(Get-Date)" -foreground Green
    try
    {
        $responseClaimId = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $bodyClaimId

        foreach ($claimId in $responseClaimId.data.channels){
            if(!([string]::IsNullOrEmpty($claimid.name))){
                Write-Host "-> Channel: " -nonewline
                Write-Host "$($claimid.name)" -foreground ("DarkGreen", "DarkRed", "DarkYellow", "Cyan", "Magenta", "Yellow", "Blue" | Get-Random)
                Write-Host "   Current points: $($claimid.self.communityPoints.balance)"
                
                $currentId = $claimId.id
                $claimLoot = $claimId.self.communityPoints.availableClaim.id
                
                if(!([string]::IsNullOrEmpty($claimLoot))){
                    Write-Host "   Found available loot with id: $($claimLoot)"
                    $bodyRedeem = "{`"query`":`"mutation ClaimOurPoints(`$input: ClaimCommunityPointsInput!){\n  claimCommunityPoints(input: `$input){\n    claim{\n      id\n    }\n    currentPoints\n  }\n}`",`"variables`":{`"input`":{`"channelID`":`"$($currentId)`",`"claimID`":`"$($claimLoot)`"}},`"operationName`":`"ClaimOurPoints`"}"
                    
                    try
                    {
                        $responseRedeem = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $bodyRedeem
                        $currPoints = $responseRedeem.data.claimCommunityPoints.currentPoints
                    
                        if(!([string]::IsNullOrEmpty($currPoints))){
                            Write-Host "   Points after redeem loot: $($currPoints)"
                        }
                    }
                    catch
                    {
                        Write-Host "   An error occurred [Line 49]: " -nonewline
                        Write-Host $_
                    }
                }
            }
        }
    }
    catch
    {
        Write-Host "An error occurred [Line 33]: " -nonewline
        Write-Host $_
    }

    Write-Host "Sleep for 7 minutes..."
    Write-Host ""
    Start-Sleep -Seconds 420
}While (1)