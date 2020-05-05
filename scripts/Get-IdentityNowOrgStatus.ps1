function Get-IdentityNowOrgStatus {
    <#
.SYNOPSIS
Get an IdentityNow Org Status.

.DESCRIPTION
Get an IdentityNow Org Status.

.EXAMPLE
Get-IdentityNowOrgStatus

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param()

    $v3Token = Get-IdentityNowAuth
    
    if ($v3Token.access_token) {
        try {
            $status = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/system/getStatus" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }                                                                                     
            return $status
        }
        catch {
            Write-Error "Problem getting system status. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}