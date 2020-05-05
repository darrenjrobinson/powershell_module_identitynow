function Get-IdentityNowSourceAccounts {
    <#
.SYNOPSIS
    Get IdentityNow Accounts on a Source.

.DESCRIPTION
    Gets IdentityNow Accounts on a Source

.PARAMETER sourceID
    (required) The ID of an IdentityNow Source. eg. 45678

.PARAMETER attributes
    (optional -Switch) defaults to False. If specified each account on the Source is queried to obtain their attributes
    NOTE: For large sources this will take time. 

.EXAMPLE
    Get-IdentityNowSourceAccounts -sourceID 12345

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$sourceID,
        [switch]$attributes
    )

    
    $Headersv2 = Get-IdentityNowAuth -return V2Header
        
    try {
        if ($sourceID) {                
            $searchLimit = "2500"
            $sourceObjects = @()                 
            
            $results = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/accounts?sourceId=$($sourceID)&limit=$($searchLimit)&org=$($IdentityNowConfiguration.orgName)" -Headers $Headersv2                            
            if ($results) {
                $sourceObjects += $results
            }
            $offset = 0
            do { 
                if ($results.Count -eq $searchLimit) {
                    # Get Next Page
                    [int]$offset = $offset + $searchLimit
                    $results = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/accounts?sourceId=$($sourceID)&limit=$($searchLimit)&offset=$($offset)&org=$($IdentityNowConfiguration.orgName)" -Headers $Headersv2
                    if ($results) {
                        $sourceObjects += $results
                    }
                }
            } until ($results.Count -lt $searchLimit)

            if ($attributes) {
                $temp = $sourceObjects
                $sourceObjects = @()
                $i = 0
                $currenterroraction = $ErrorActionPreference
                $ErrorActionPreference = 'continue'
                
                foreach ($object in $temp) {
                    $i++
                    Write-Progress -Activity "fetching account attributes $($i) of $($temp.count)" -PercentComplete ($i / $temp.count * 100)
                    do {
                        $result = $null
                        try {
                            $result = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/accounts/$($object.id)" -Headers $Headersv2
                        }
                        catch {
                            write-host "Sleeping 2 seconds:$($_)"
                            Start-Sleep -Seconds 2
                        }
                    }until($null -ne $result)
                    
                    $sourceObjects += $result
                }
                $ErrorActionPreference = $currenterroraction
            }
            return $sourceObjects
        }
    }
    catch {
        Write-Error "Source doesn't exist? Check SourceID and OrgName. $($_)" 
    }
}

