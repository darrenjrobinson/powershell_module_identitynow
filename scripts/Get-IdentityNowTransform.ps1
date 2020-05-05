function Get-IdentityNowTransform {
    <#
.SYNOPSIS
Get IdentityNow Transform(s).

.DESCRIPTION
Get IdentityNow Transform(s).

.PARAMETER ID
(optional) The ID of an IdentityNow Transform.

.PARAMETER json
(optional) Return IdentityNow Transform(s) as JSON.

.EXAMPLE
Get-IdentityNowTransform 

.EXAMPLE
Get-IdentityNowTransform -ID ToUpper 

.EXAMPLE
Get-IdentityNowTransform -ID ToUpper -json 

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$ID,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [switch]$json
    )

    $v3Token = Get-IdentityNowAuth
    
    if ($v3Token.access_token) {
        try {
            if ($json) {
                if ($ID) {
                    $IDNTransform = Invoke-WebRequest -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/transform/get/$($ID)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" } 
                    return $IDNTransform.content
                }
                else {
                    $IDNTransform = Invoke-WebRequest -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/transform/list" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
                    return $IDNTransform.content
                }
            } else {
                if ($ID) {
                    $IDNTransform = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/transform/get/$($ID)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" } 
                    return $IDNTransform.items
                }
                else {
                    $IDNTransform = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/transform/list" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
                    return $IDNTransform.items
                }
            }
        }
        catch {
            Write-Error "Transform doesn't exist? $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

