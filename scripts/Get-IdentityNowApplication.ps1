function Get-IdentityNowApplication {
    <#
.SYNOPSIS
Get IdentityNow Application(s).

.DESCRIPTION
Get IdentityNow Application(s).

.PARAMETER appID
(optional) The Application ID of an IdentityNow Application.

.PARAMETER org
(optional - Boolean) Org Default Apps.
Get-IdentityNowApplication -org $true

.EXAMPLE
Get-IdentityNowApplication 

.EXAMPLE
Get-IdentityNowApplication -appID 24184

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$appID,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [boolean]$org = $false 
    )

    $v3Token = Get-IdentityNowAuth

    if ($v3Token.access_token) {
        try {
            if ($appID) {
                $utime = [int][double]::Parse((Get-Date -UFormat %s))
                $IDNApps = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/app/get/$($appID)?_dc=$($utime)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
                return $IDNApps
            }
            else {
                if ($org) {
                    $IDNApps = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/app/list?filter=org&_dc=$($utime)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
                    return $IDNApps
                }
                else {
                    $IDNApps = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/app/list" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
                    return $IDNApps
                }
            }
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

