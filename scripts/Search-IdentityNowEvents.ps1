function Search-IdentityNowEvents {
    <#
.SYNOPSIS
    Search IdentityNow Event(s) using Elasticsearch queries.

.DESCRIPTION
    Search IdentityNow Event(s) using Elasticsearch queries

.PARAMETER filter
    (required - JSON) filter 
    Elasticsearch Query Filter 
    e.g '{"query": {"query": "technicalName:USER_AUTHENTICATION_STEP_UP_SETUP_*","type":"USER_MANAGEMENT"}}'
    See https://community.sailpoint.com/t5/Admin-Help/How-do-I-use-Search-in-IdentityNow/ta-p/76960 

.PARAMETER searchLimit
    (optional - default 2500) number of results to return

.EXAMPLE
    $query = @{query = 'technicalName:USER_AUTHENTICATION_STEP_UP_SETUP_*'; type = 'USER_MANAGEMENT'}
    $queryFilter = @{query = $query}
    Search-IdentityNowEvents -filter ($queryFilter | convertto-json)

.EXAMPLE
    Search-IdentityNowEvents -filter ($queryFilter | convertto-json) -searchLimit 50
    Search-IdentityNowEvents -filter ($queryFilter | convertto-json) -searchLimit 5001

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$filter,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$searchLimit = 2500
    )

    $v3Token = Get-IdentityNowAuth

    if ($v3Token.access_token) {        
        try {             
            $sourceObjects = @()   
            if ($searchLimit -gt 2500) {
                $iterations = $searchLimit / 2500
                $offset = 2500
            }                     

            if ($searchLimit -gt 2500) { $limit = 2500 } else { $limit = $searchLimit }

            $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/beta/search/events?limit=$($limit)"

            $loop = 0
            if ($iterations -gt 1) {
                # Get First
                $results = Invoke-RestMethod -Method Post -Uri $searchURLBase -Headers @{Authorization = "Bearer $($v3Token.access_token)"; "Content-Type" = "application/json" } -Body $filter                                     
                $loop++
    
                if ($results) {
                    $sourceObjects += $results
                }
                # Get Rest 
                do {
                    if (($searchLimit - $offset) -gt 2500) {  
                        $results = Invoke-RestMethod -Method Post -Uri "$($searchURLBase)&start=$($offset)" -Headers @{Authorization = "Bearer $($v3Token.access_token)"; "Content-Type" = "application/json" } -Body $filter  
                        $loop++
                        $offset += $results.count 
                        if ($results) {
                            $sourceObjects += $results
                        }
                        else {
                            break 
                        }
                    }
                    else {
                        $limitCount = ($searchLimit - $sourceObjects.count)
                        $searchURL = $searchURLBase.Replace("limit=2500", "limit=$($limitCount)")
                        $results = Invoke-RestMethod -Method Post -Uri "$($searchURL)&start=$($offset)" -Headers @{Authorization = "Bearer $($v3Token.access_token)"; "Content-Type" = "application/json" } -Body $filter  
                        if ($results) {
                            $sourceObjects += $results
                        }
                        else {
                            break 
                        }
                        $loop++
                    }
                } until (($loop -gt $iterations))
            }
            else {
                # Get full set (<2500)
                $results = Invoke-RestMethod -Method Post -Uri $searchURLBase -Headers @{Authorization = "Bearer $($v3Token.access_token)"; "Content-Type" = "application/json" } -Body $filter                                                 
                $loop++
        
                if ($results) {
                    $sourceObjects += $results
                }
            }
            return $sourceObjects
        }
        catch {
            Write-Error "Event(s) not found? Check your Elasticsearch Query syntax. $($_)" 
        }
    }
}
