function Invoke-IdentityNowRoleRefresh {
    <#
.SYNOPSIS
    Refresh all IdentityNow Roles.

.DESCRIPTION
    Refresh all IdentityNow Roles.

.EXAMPLE
    Invoke-IdentityNowRoleRefresh  

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>
    [cmdletbinding()]
    param()

    $token = Get-IdentityNowAuth -return V3JWT

    if ($token) {
        try {
            $refresh = Invoke-RestMethod -Method Post -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/role/refresh" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "Content-Type" = "application/json" }
            return $refresh 
        }
        catch {
            Write-Error "$($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your v3/PAT credentials. $($_)"
    } 
}

