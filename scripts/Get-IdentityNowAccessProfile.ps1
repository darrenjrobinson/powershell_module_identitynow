function Get-IdentityNowAccessProfile {
    <#
.SYNOPSIS
Get an IdentityNow Access Profile(s).

.DESCRIPTION
Get an IdentityNow Access Profile(s).

.PARAMETER profileID
(optional) The profile ID of an IdentityNow Access Profile.

.EXAMPLE
Get-IdentityNowAccessProfile 

.EXAMPLE
Get-IdentityNowAccessProfile -profileID 2c91808466a64e330112a96902ff1f69

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$profileID
    )

    $v3Token = Get-IdentityNowAuth

    if ($v3Token.access_token) {
        try {
            if ($profileID) {
                $IDNAccessProfiles = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/access-profiles/$($profileID)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
                return $IDNAccessProfiles
            }
            else {
                $IDNAccessProfiles = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/access-profiles" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
                return $IDNAccessProfiles
            }
        }
        catch {
            Write-Error "Access Profile doesn't exist. Check Profile ID. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

