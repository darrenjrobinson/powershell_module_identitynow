function Set-IdentityNowTimeZone {
    <#
.SYNOPSIS
Set IdentityNow Time Zone.

.DESCRIPTION
Set IdentityNow Time Zone.

.PARAMETER tz
(required) The TZ to set the IdentityNow Org too.

.EXAMPLE
Set-IdentityNowTimeZone -tz 'Australia/Sydney'

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$tz
    )

    $v3Token = Get-IdentityNowAuth

    if ($v3Token.access_token) {
        try {    
            $tzBody = $tzBody = '[{
                "op" : "replace",
                "path" : "/timeZone",
                "value" : "newtimezone"
                }]'     

            $tzBody = $tzBody.replace("newtimezone", $tz)    
            Write-Verbose $tzBody
            $updateTZ = Invoke-RestMethod -Method Patch -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/beta/org-config" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "Content-Type" = 'application/json-patch+json' } -Body $tzBody 
            return $updateTZ            
        }
        catch {
            Write-Error "Time Zone failed to update. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

