function Update-IdentityNowEmailTemplate {
    <#
.SYNOPSIS
Update an IdentityNow Email Template.

.DESCRIPTION
Update an IdentityNow Email Template.

.PARAMETER template
(required - JSON) The configuration for the changes to make to an IdentityNow Email Template.

.EXAMPLE
Update-IdentityNowEmailTemplate -template {"id": "2c91601362431b32016275b4241b08f0", "name": "Template v2" }

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$template
    )

    $v3Token = Get-IdentityNowAuth

    if ($v3Token.access_token) {
        try {
                $IDNETemplate = Invoke-RestMethod -Method Post -Uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/emailTemplate/update" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "content-type" = "application/json" } -body $template                                                                                    
                return $IDNETemplate
        }
        catch {
            Write-Error "Email Template doesn't exist or invalid configuration? $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

