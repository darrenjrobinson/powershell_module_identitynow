function Get-IdentityNowIdentityAttribute {
    <#
.SYNOPSIS
Get an IdentityNow Identity Attribute(s).

.DESCRIPTION
Get an IdentityNow Identity Attribute(s).

.PARAMETER attribute
(optional) The identity attribue to retrieve.

.EXAMPLE
Get-IdentityNowIdentityAttribute 

.EXAMPLE
Get-IdentityNowGovernanceGroup -attribute firstname

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$attribute
    )

    $v3Token = Get-IdentityNowAuth
    
    if ($v3Token.access_token) {
        try {
            if ($attribute) {                
                $IdentityAttr = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/identityAttribute/get?name=$($attribute)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
                return $IdentityAttr
            }
            else {                
                $IdentityAttr = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/identityAttribute/list" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
                return $IdentityAttr
            }
        }
        catch {
            Write-Error "Identity Attribute doesn't exist. Check attribue name. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

