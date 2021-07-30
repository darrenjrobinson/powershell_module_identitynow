function Test-IdentityNowToken {
    <#
.SYNOPSIS
Helper function to test valid token.

.DESCRIPTION
Helper function to test valid token.

.EXAMPLE
Test-IdentityNowToken -v3Token $token

.LINK
http://darrenjrobinson.com/sailpoint-identitynow
#>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSCustomObject]$v3Token
    )
    if (-not ($v3Token.access_token)) {
        throw "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
    } 
    return $v3Token
}