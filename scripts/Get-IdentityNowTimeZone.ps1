function Get-IdentityNowTimeZone {
    <#
.SYNOPSIS
Get IdentityNow Time Zone(s).

.DESCRIPTION
Get IdentityNow Time Zone(s).

.PARAMETER list
(optional) List available timezone values

.EXAMPLE
Get-IdentityNowTimeZone 

.EXAMPLE
Get-IdentityNowTimeZone -list 

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [switch]$list
    )

    $v3Token = Get-IdentityNowAuth
    
    if ($v3Token.access_token) {
        try {                
            if ($list) {
                $getTZ = Invoke-RestMethod -Method Get -uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/beta/org-config/valid-time-zones" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "Content-Type" = "application/json" }
                return $getTZ 
            }
            else {
                $getTZ = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/beta/org-config" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "Content-Type" = "application/json" } 
                return $getTZ         
            }
        }
        catch {
            Write-Error "Failed to retrieve Time Zone(s). $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

