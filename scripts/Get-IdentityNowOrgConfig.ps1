function Get-IdentityNowOrgConfig {
    <#
.SYNOPSIS
    Get IdentityNow Org Global Reminders and Escalation Policies Configuration.

.DESCRIPTION
    Get IdentityNow Org Global Reminders and Escalation Policies Configuration

.EXAMPLE  
    Get-IdentityNowOrgConfig 

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param()

    $v3Token = Get-IdentityNowAuth
    
    if ($v3Token.access_token) {
        try {
            $IDNOrgConfig = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/v2/org" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
            return $IDNOrgConfig
        }
        catch {
            Write-Error "$($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

