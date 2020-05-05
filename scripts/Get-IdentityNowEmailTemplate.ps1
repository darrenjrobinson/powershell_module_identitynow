function Get-IdentityNowEmailTemplate {
    <#
.SYNOPSIS
Get IdentityNow Email Template(s).

.DESCRIPTION
Get IdentityNow Email Template(s).

.PARAMETER ID
(optional) The ID of an IdentityNow Email Template.

.EXAMPLE
Get-IdentityNowEmailTemplate 

.EXAMPLE
Get-IdentityNowEmailTemplate -ID 2c91601362431b32016275b4241b08f0 

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$ID
    )

    $v3Token = Get-IdentityNowAuth

    if ($v3Token.access_token) {
        try {
            if ($ID) {
                $IDNETemplate = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/emailTemplate/get/$($ID)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }                                                                                     
                return $IDNETemplate
            }
            else {
                $IDNETemplate = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/emailTemplate/list" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
                return $IDNETemplate.items
            }
        }
        catch {
            Write-Error "Email Template doesn't exist? $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

