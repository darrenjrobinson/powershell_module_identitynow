function New-IdentityNowProfile {
    <#
.SYNOPSIS
Create new IdentityNow Identity Profile(s).

.DESCRIPTION
Create new IdentityNow Identity Profile(s).

.PARAMETER Name
The Name of the new IdentityNow Identity Profile.

.PARAMETER SourceID
The ID of the Source tied to the new IdentityNow Identity Profile.

.EXAMPLE
New-IdentityNowProfile -Name Contractors -SourceID 116329

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [int]$SourceID
    )

    $v3Token = Get-IdentityNowAuth

    if ($v3Token.access_token) {
        try {
            $body="name=$Name&sourceId=$SourceID"
            $IDNProfile = Invoke-RestMethod -Method Post -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/profile/create" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" } -Body $body
            return $IDNProfile
        }
        catch {
            Write-Error "Problem Creating Profile. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

