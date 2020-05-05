function Get-IdentityNowPersonalAccessToken {
    <#
.SYNOPSIS
Create an IdentityNow v3 oAuth API Client.

.DESCRIPTION
Create an IdentityNow v3 oAuth API Client.

.PARAMETER name
(required) Grant Type options "AUTHORIZATION_CODE,CLIENT_CREDENTIALS,REFRESH_TOKEN,PASSWORD"

.PARAMETER description
(required) Description 

.PARAMETER redirectUris
(required) redirectUris e.g "https://localhost,https://myapp.com.au"

.EXAMPLE
New-IdentityNowOAuthAPIClient -description "oAuth Client via API" -grantTypes 'AUTHORIZATION_CODE,CLIENT_CREDENTIALS,REFRESH_TOKEN,PASSWORD' -redirectUris 'https://localhost'

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param( 
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]    
        [string]$name    
    )

    $v3Token = Get-IdentityNowAuthorization -return V3JWT

    if ($v3Token.access_token) {
        try {    
            $PATBody = @{ }
            $PATBody.add("name", $name)
            $IDNNewPAT = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/beta/personal-access-tokens" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
            return $IDNNewPAT
        }
        catch {
            Write-Error "Create Personal Access Token failed. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

