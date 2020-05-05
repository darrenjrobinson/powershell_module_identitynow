function Remove-IdentityNowAPIClient {
    <#
.SYNOPSIS
Delete an IdentityNow API Client.

.DESCRIPTION
Delete an IdentityNow API Client.

.PARAMETER ID
(required) The ID of the IdentityNow API Client to be deleted.

.EXAMPLE
Remove-IdentityNowAPIClient -ID 123

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
            $IDNDeleteAPIClient = Invoke-RestMethod -Method Post -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/client/remove/$($ID)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "Content-Type" = "application/json"} 
            return $IDNDeleteAPIClient
        }
        catch {
            Write-Error "Deletion of API Client failed. Check ID of API Client Configuration. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

