function Invoke-IdentityNowSourceReset {
    <#
.SYNOPSIS
    Reset an IdentityNow Source.

.DESCRIPTION
    Reset an IdentityNow Source.

.PARAMETER sourceID
    (required) The ID of an IdentityNow Source. eg. 45678

.EXAMPLE
    Invoke-IdentityNowSourceReset -sourceID 12345

.EXAMPLE
    Reset a Source but leave the entitlements
    Invoke-IdentityNowSourceReset -sourceID 12345 -skip entitlements

.EXAMPLE
    Reset a Source but leave the entitlements
    Invoke-IdentityNowSourceReset -sourceID 12345 -skip accounts

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$sourceID,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [ValidateSet("accounts", "entitlements")]
        [string]$skip        
    )

    $token = Get-IdentityNowAuth -return V2Header

    if ($token) {
        try {
            if ($skip) {
                $reset = Invoke-RestMethod -Method POST -uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/source/reset/$($sourceID)?skip=$($skip)" -Headers @{"Authorization" = "Bearer $($token.access_token)" }
                return $reset 
            }
            else {            
                $reset = Invoke-RestMethod -Method POST -uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/source/reset/$($sourceID)" -Headers @{"Authorization" = "Bearer $($token.access_token)" }
                return $reset 
            }
        }
        catch {
            Write-Error "Source doesn't exist? Check SourceID. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your v2 API credentials. $($_)"
    } 
}

