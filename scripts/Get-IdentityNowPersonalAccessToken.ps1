function Get-IdentityNowPersonalAccessToken {
    <#
.SYNOPSIS
List personal access tokens in IdentityNow.

.DESCRIPTION
List personal access tokens in IdentityNow.

.PARAMETER limit
(optional) Number of personal access tokens to return

.EXAMPLE
Get-IdentityNowPersonalAccessToken 

.EXAMPLE
Get-IdentityNowPersonalAccessToken -limit 10

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param( 
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]    
        [string]$limit = 999    
    )

    $v3Token = Get-IdentityNowAuthorization -return V3JWT

    if ($v3Token.access_token) {
        try {    
            $IDNGetPAT = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/beta/personal-access-tokens?limit=$($limit)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
            
            if ($IDNGetPAT) {
                return $IDNGetPAT
            } else {
                return "No 'Personal Access Tokens' found. Use New-IdentityNowPersonalAccessToken to create personal access tokens."
            }
        }
        catch {
            Write-Error "List Personal Access Token failed. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $_
    } 
}

