function Invoke-IdentityNowAggregateEntitlement {
    <#
.SYNOPSIS
    Initiate Entitlement Aggregation of an IdentityNow Source.

.DESCRIPTION
    Initiate Entitlement Aggregation of an IdentityNow Source.

.PARAMETER sourceID
    (required) The ID of an IdentityNow Source. eg. 45678

.EXAMPLE
    Invoke-IdentityNowAggregateEntitlement -sourceID 12345

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$sourceID
    )

    $token = Get-IdentityNowAuth | Test-IdentityNowToken
    try {
        $aggregate = Invoke-RestMethod -Method POST -uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/source/loadAccounts/$($sourceID)" -Headers @{"Authorization" = "Bearer $($token.access_token)" } 
        return $aggregate.task  
            
    }
    catch {
        Write-Error "Source doesn't exist? Check SourceID. $($_)" 
    }
}
