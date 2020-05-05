function Get-IdentityNowRule {
    <#
.SYNOPSIS
Get IdentityNow Rule(s).

.DESCRIPTION
Get IdentityNow Rule(s).

.PARAMETER ID
(optional) The ID of an IdentityNow Rule.

.EXAMPLE
Get-IdentityNowRule 

.EXAMPLE
Get-IdentityNowRule -ID ToUpper 

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$ID
    )

    $v3Token = Get-IdentityNowAuth
    
    if ($v3Token.access_token) {
        try {
            if ($ID) {
                $IDNRule = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/rule/get/$($ID)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }                                                                                     
                return $IDNRule
            }
            else {
                $IDNRule = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/rule/list" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
                return $IDNRule.items
            }
        }
        catch {
            Write-Error "Rule doesn't exist? $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

