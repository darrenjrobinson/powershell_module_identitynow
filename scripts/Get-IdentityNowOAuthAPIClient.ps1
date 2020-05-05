function Get-IdentityNowOAuthAPIClient {
    <#
.SYNOPSIS
Get IdentityNow oAuth API Client(s).

.DESCRIPTION
Get an IdentityNow oAuth API Client(s).

.PARAMETER ID
(optional) The SailPoint Configuration ID of an IdentityNow oAuth API Client.

.EXAMPLE
Get-IdentityNowOAuthAPIClient 

.EXAMPLE
Get-IdentityNowOAuthAPIClient -ID 8432e57d-dead-beef-9ebb-abcdef12345

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
                $utime = [int][double]::Parse((Get-Date -UFormat %s))
                $IDNAPIClient = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/beta/oauth-clients/$($ID)?_dc=$($utime)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "Content-Type" = "application/json" }
                return $IDNAPIClient
            }
            else {
                $utime = [int][double]::Parse((Get-Date -UFormat %s))
                $IDNAPIClient = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/beta/oauth-clients?_dc=$($utime)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "Content-Type" = "application/json" }
                return $IDNAPIClient
            }
        }
        catch {
            Write-Error "oAuth Client doesn't exist. Check Client Configuration ID. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

