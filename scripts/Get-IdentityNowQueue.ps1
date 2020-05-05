function Get-IdentityNowQueue {
    <#
.SYNOPSIS
Get IdentityNow Queues.

.DESCRIPTION
Get IdentityNow Queues.

.EXAMPLE
Get-IdentityNowQueue

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param()

    $v3Token = Get-IdentityNowAuth
    
    if ($v3Token.access_token) {
        try {
            $Queue = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/message/getQueueStatus" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }                                                                                     
            return $Queue            
        }
        catch {
            Write-Error "Problem getting Queue. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}