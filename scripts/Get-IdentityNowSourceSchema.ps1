function Get-IdentityNowSourceSchema {
    <#
.SYNOPSIS
    Get the Schema for an IdentityNow Source.

.DESCRIPTION
    Get the Schema for an IdentityNow Source.

.PARAMETER sourceID
    (required) The ID of an IdentityNow Source. eg. 45678

.EXAMPLE
    Get-IdentityNowSourceSchema -sourceID 12345

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$sourceID
    )

    $v3Token = Get-IdentityNowAuth
  
    if ($v3Token.access_token) {
        try {
            $sourceSchema = Invoke-RestMethod -method Get -uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/cc/api/source/getAccountSchema/$($sourceID)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
                return $sourceSchema
        }
        catch {
            Write-Error "Source doesn't exist? Check SourceID and OrgName. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}
