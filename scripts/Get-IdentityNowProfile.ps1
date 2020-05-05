function Get-IdentityNowProfile {
    <#
.SYNOPSIS
Get IdentityNow Identity Profile(s).

.DESCRIPTION
Get IdentityNow Identity Profile(s).

.PARAMETER ID
(optional) The ID of an IdentityNow Identity Profile.

.EXAMPLE
Get-IdentityNowProfile 

.EXAMPLE
Get-IdentityNowProfile -ID 1066 

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
                $IDNProfile = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/profile/get/$($ID)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }                                                                                     
                return $IDNProfile
            }
            else {
                $IDNProfile = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/profile/list" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
                return $IDNProfile
            }
        }
        catch {
            Write-Error "Profile doesn't exist? $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

