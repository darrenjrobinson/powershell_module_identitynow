function New-IdentityNowRole {
    <#
.SYNOPSIS
Create an IdentityNow Role.

.DESCRIPTION
Create an IdentityNow Role.

.PARAMETER role
(required - JSON) The configuration for the new IdentityNow Role.

.EXAMPLE
New-IdentityNowRole -role "{"description":  "Special Admins Role","name":  "Role - Special Admins","owner":  "darren.robinson","displayName":  "Special Admins","disabled":  false}"

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$role
    )

    $v3Token = Get-IdentityNowAuth

    if ($v3Token.access_token) {
        try {
            $IDNNewRoles = Invoke-RestMethod -Method Post -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/role/create" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "content-type" = "application/json" } -Body $role
            return $IDNNewRoles
        }
        catch {
            Write-Error "Creation of new Role failed. Check Role Configuration. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

