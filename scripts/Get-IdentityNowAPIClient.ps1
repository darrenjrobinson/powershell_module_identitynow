function Get-IdentityNowAPIClient {
    <#
.SYNOPSIS
Get IdentityNow API Client(s).

.DESCRIPTION
Get IdentityNow API Client(s).

.PARAMETER ID
(optional) The ID of an IdentityNow API Client.

.EXAMPLE
Get-IdentityNowAPIClient 

.EXAMPLE
Get-IdentityNowAPIClient -ID 123

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
                $IDNAPIClient = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/client/get/$($ID)?_dc=$($utime)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "Content-Type" = "application/json" }
                return $IDNAPIClient
            }
            else {
                $utime = [int][double]::Parse((Get-Date -UFormat %s))
                $IDNAPIClient = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/client/list?_dc=$($utime)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "Content-Type" = "application/json" }
                return $IDNAPIClient
            }
        }
        catch {
            Write-Error "Client doesn't exist. Check Client Configuration ID. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

