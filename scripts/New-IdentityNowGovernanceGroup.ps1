function New-IdentityNowGovernanceGroup {
    <#
.SYNOPSIS
    Create a new IdentityNow Governance Group.

.DESCRIPTION
    Create a new IdentityNow Governance Group.

.PARAMETER group
    The Governance Group details.

.EXAMPLE
    New-IdentityNowGovernanceGroup 

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$group
    )
    $Headersv2 = Get-IdentityNowAuth -return V2Header
    $Headersv2."Content-Type" = "application/json" 

    try {          
        $IDNNewGroup = Invoke-RestMethod -Method Post -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/workgroups?&org=$($IdentityNowConfiguration.orgName)" -Headers $Headersv2 -Body $group
        return $IDNNewGroup              
    }
    catch {
        Write-Error "Failed to create group. Check group details. $($_)" 
    }
}
