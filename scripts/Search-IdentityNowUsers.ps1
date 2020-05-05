function Search-IdentityNowUsers {
        <#
.SYNOPSIS
    Get IdentityNow Users.

.DESCRIPTION
    Gets Users based on query

.PARAMETER query
    (required) User Search Query

.PARAMETER limit
    Search Limit e.g 10

.EXAMPLE
    Search-IdentityNowUsers -query "@accounts(accountId:darrenjrobinson)"

.EXAMPLE
    Search-IdentityNowUsers -query darrenjrobinson

.EXAMPLE
    Search-IdentityNowUsers -query "@access(source.name:'Active Directory')"

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$query,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$limit = 2500
    )

    $v3Token = Get-IdentityNowAuth

    if ($v3Token.access_token) {
        try {                         
            # Get Users Based on Query
            $sourceObjects = @() 
            $results = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/search/identities?limit=$($limit)&query=$($query)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }                
                            
            if ($results) {
                $sourceObjects += $results
            }
            $offset = 0
            do { 
                if ($results.Count -eq $limit) {
                    # Get Next Page
                    [int]$offset = $offset + $limit 
                    $results = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/search/identities?offset=$($offset)&limit=$($limit)&query=$($query)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }                
                    if ($results) {
                        $sourceObjects += $results
                    }
                }
            } until ($results.Count -lt $limit)
            return $sourceObjects
        }
        catch {
            Write-Error "Bad Query or more than 10,000 results? Check your query. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

