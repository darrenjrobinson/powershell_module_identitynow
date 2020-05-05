function Invoke-IdentityNowAggregateSource {
    <#
.SYNOPSIS
    Initiate Aggregation of an IdentityNow Source.

.DESCRIPTION
    Initiate Aggregation of an IdentityNow Source.

.PARAMETER sourceID
    (required) The ID of an IdentityNow Source. eg. 45678

.PARAMETER disableOptimization
    (optional - switch) Disable Optimization for a full source aggregation

.EXAMPLE
    Invoke-IdentityNowAggregateSource -sourceID 12345

.EXAMPLE
    Invoke-IdentityNowAggregateSource -sourceID 12345 -disableOptimization

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$sourceID,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [switch]$disableOptimization = $false
    )

    $token = Get-IdentityNowAuth

    if ($token) {
        try {
            if ($disableOptimization) {        
                $aggregate = Invoke-RestMethod -Method POST -uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/source/loadAccounts/$($sourceID)" -Headers @{"Authorization" = "Bearer $($token.access_token)" } -Body "disableOptimization=true"
                return $aggregate.task 
            }
            else {
                $aggregate = Invoke-RestMethod -Method POST -uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/source/loadAccounts/$($sourceID)" -Headers @{"Authorization" = "Bearer $($token.access_token)" } 
                return $aggregate.task  
            }
        }
        catch {
            Write-Error "Source doesn't exist? Check SourceID. $($_)" 
        }
    }
    else {
        Write-Error "Failed to get v2 Token. Check v2 Credentials $($_)"
    }
}

