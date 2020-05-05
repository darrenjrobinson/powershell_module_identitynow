function Start-IdentityNowProfileUserRefresh {
    <#
.SYNOPSIS
Triggers a user refresh for an IdentityNow Identity Profile(s).

.DESCRIPTION
Triggers a user refresh for an IdentityNow Identity Profile(s).

.PARAMETER ID
The ID of the IdentityNow Identity Profile.

.EXAMPLE
Start-IdentityNowProfileUserRefresh -ID 116329

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
            $IDNProfile = Invoke-RestMethod -Method Post -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/profile/refresh/$($ID)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
            return $IDNProfile
        }
        catch {
            Write-Error "Problem Refreshing Profile. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

