function Update-IdentityNowApplication {
    <#
.SYNOPSIS
Update an IdentityNow Application.

.DESCRIPTION
Update an IdentityNow Application.

.PARAMETER appID
(required - JSON ) The Application ID of an IdentityNow Application.

.PARAMETER update
(required - JSON) Application configuration changes.

.EXAMPLE
Update-IdentityNowApplication -appID 24184 -update "{"launchpadEnabled":  false,"provisionRequestEnabled":  false,"appCenterEnabled":  false}"

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$appID,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$update 
    )

    $v3Token = Get-IdentityNowAuth

    if ($v3Token.access_token) {
        try {         
            Write-Verbose $update 
            $IDNApps = Invoke-RestMethod -Method Post -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/app/update/$($appID)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "Content-Type" = "application/json" } -Body $update 
            return $IDNApps
        }
        catch {
            Write-Error "Update to Application failed. Check App ID and update configuration. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

