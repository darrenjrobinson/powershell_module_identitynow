function Get-IdentityNowGovernanceGroup {
        <#
.SYNOPSIS
    Get an IdentityNow Governance Group.

.DESCRIPTION
    Get an IdentityNow Governance Group.

.PARAMETER group
    (optional) The Name of an IdentityNow Governance Group.

.EXAMPLE
    Get-IdentityNowGovernanceGroup 

.EXAMPLE
    Get-IdentityNowGovernanceGroup -group 6289788a-c73c-426b-9170-12340aaa6789

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$group
    )

    $v3Token = Get-IdentityNowAuth
    
    if ($v3Token.access_token) {
        try {
            if ($group) {
                $IDNGroups = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/workgroups/$($group)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
                return $IDNGroups
            }
            else {
                $IDNGroups = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/workgroups?org=$($IdentityNowConfiguration.orgName)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
                return $IDNGroups
            }
        }
        catch {
            Write-Error "Group doesn't exist. Check group ID. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

