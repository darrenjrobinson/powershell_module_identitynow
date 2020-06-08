function Get-IdentityNowPersonalAccessToken {
    <#
.SYNOPSIS
List IdentityNow Personal Access Tokens.

.DESCRIPTION
List IdentityNow Personal Access Tokens. 

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

    $v3Token = Get-IdentityNowAuth

    if ($v3Token.access_token) {
        try {    
            $IDNGetPAT = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/beta/personal-access-tokens?limit=$($limit)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
            
            if ($IDNGetPAT) {
                return $IDNGetPAT
            }
            else {
                return "No 'Personal Access Tokens' found. Use New-IdentityNowPersonalAccessToken to create personal access tokens."
            }
            
        }
        catch {
            Write-Error "Get Personal Access Token failed. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

