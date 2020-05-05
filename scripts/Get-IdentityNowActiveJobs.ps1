function Get-IdentityNowActiveJobs {
    <#
.SYNOPSIS
Get IdentityNow Active Jobs.

.DESCRIPTION
Get IdentityNow Active Jobs.

.EXAMPLE
Get-IdentityNowActiveJobs

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>
    [cmdletbinding()]
    param()

    $v3Token = Get-IdentityNowAuth
    
    if ($v3Token.access_token) {
        try {
            $Jobs = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/message/getActiveJobs" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }                                                                                     
            return $Jobs
        }
        catch {
            Write-Error "Problem getting Active Jobs. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}