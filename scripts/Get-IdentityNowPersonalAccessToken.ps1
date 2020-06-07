function Get-IdentityNowPersonalAccessToken {
    <#
.SYNOPSIS
Create an IdentityNow Personal Access Token.

.DESCRIPTION
get details on an IdentityNow Personal Access Token. Personal Access Token 
allows this module to authenticate without prompting for credentials 
in a still supported grant type

.PARAMETER id
 id of the personal access token

.EXAMPLE
Get-IdentityNowPersonalAccessToken

.EXAMPLE
Get-IdentityNowPersonalAccessToken -id 5f74c080446b8d91ae55262ce73c6118

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param( 
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]    
        [string]$id    
    )

    $v3Token = Get-IdentityNowAuth

    if ($v3Token.access_token) {
        try {    
            $PATBody = @{ }
            $PATBody.add("name", $id)
            $IDNNewPAT = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/beta/personal-access-tokens" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
            return $IDNNewPAT
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

