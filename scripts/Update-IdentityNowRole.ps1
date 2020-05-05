function Update-IdentityNowRole {
    <#
.SYNOPSIS
Update an IdentityNow Role.

.DESCRIPTION
Update an IdentityNow Role.

.PARAMETER update
(required - JSON) The configuration for the updates to the IdentityNow Role.

.EXAMPLE
Update-IdentityNowRole -update "{"id": "2c9180886cd58059016d1a4757d709a4", "description":  "Special Administrators Role","name":  "Role - Special Administrators","owner":  "darren.robinson","displayName":  "Special Administrators","disabled":  false}"

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$update
    )

    $v3Token = Get-IdentityNowAuth

    if ($v3Token.access_token) {
        try {
            $IDNUpdateRole = Invoke-RestMethod -Method Post -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/role/update" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "content-type" = "application/json" } -Body $update
            return $IDNUpdateRole
        }
        catch {
            Write-Error "Update of Role failed. Check Role Configuration. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

