function Get-IdentityNowVACluster {
    <#
.SYNOPSIS
Get IdentityNow Virtual Appliance Cluster(s).

.DESCRIPTION
Get IdentityNow Virtual Appliance Cluster(s).

.EXAMPLE
Get-IdentityNowVACluster 

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param()

    $v3Token = Get-IdentityNowAuth
    
    if ($v3Token.access_token) {
        try {
            $IDNCluster = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/cluster/list" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
            return $IDNCluster
        }
        catch {
            Write-Error "Application doesn't exist. Check App ID. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

