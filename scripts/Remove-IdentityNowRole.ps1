function Remove-IdentityNowRole {
    <#
.SYNOPSIS
Delete an IdentityNow Role.

.DESCRIPTION
Delete an IdentityNow Role.

.PARAMETER roleID
(required) The ID of the IdentityNow Role to be deleted.

.EXAMPLE
Remove-IdentityNowRole -role 2c9180886cd58059016d1a4757d709a4

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$roleID
    )

    $v3Token = Get-IdentityNowAuth

    if ($v3Token.access_token) {
        try {
            $IDNDeleteRole = Invoke-RestMethod -Method Post -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/role/delete/$($roleID)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; } -Body $update
            return $IDNDeleteRole
        }
        catch {
            Write-Error "Update of Role failed. Check Role Configuration. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

