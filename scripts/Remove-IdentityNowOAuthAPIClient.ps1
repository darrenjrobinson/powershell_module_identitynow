function Remove-IdentityNowOAuthAPIClient {
    <#
.SYNOPSIS
Delete an IdentityNow oAuth API Client.

.DESCRIPTION
Delete an IdentityNow oAuth API Client.

.PARAMETER ID
(required) The ID of the IdentityNow oAuth API Client to be deleted.

.EXAMPLE
Remove-IdentityNowOAuthAPIClient -ID '9e23deaf-48aa-dead-beef-ab6821a12ab2'

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$ID
    )

    $v3Token = Get-IdentityNowAuth

    if ($v3Token.access_token) {
        try {
            $IDNDeleteOAuthClient = Invoke-RestMethod -Method Delete -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/beta/oauth-clients/$($ID)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "Content-Type" = "application/json"} 
            return $IDNDeleteOAuthClient
        }
        catch {
            Write-Error "Deletion of oAuth API Client failed. Check ID of oAuth Client Configuration. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

