function Search-IdentityNowEntitlements {
    <#
.SYNOPSIS
    Get IdentityNow Entitlements.

.DESCRIPTION
    Gets Entitlements based on query

.PARAMETER query
    (required) Entitlements Search Query. To query source entitlements use the source.internalID.

.PARAMETER limit
    (optional) Search Page Result Size
    
.EXAMPLE
    Search-IdentityNowEntitlements -query "source.name:'Active Directory'" 

.EXAMPLE
    Search-IdentityNowEntitlements -query "source.id:2c918083670df373016835e063ff6b5b" 

.EXAMPLE
    Search-IdentityNowEntitlements -query "@accounts.entitlementAttributes.'App_Group_*'"

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
            $results = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/search/entitlements?limit=$($limit)&query=$($query)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }                        

            if ($results) {
                $sourceObjects += $results
            }
            $offset = 0
            do { 
                if ($results.Count -eq $limit) {
                    # Get Next Page
                    [int]$offset = $offset + $limit 
                    $results = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/search/entitlements?offset=$($offset)&limit=$($limit)&query=$($query)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }                
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

