function Remove-IdentityNowGovernanceGroup {
    <#
.SYNOPSIS
    Delete an IdentityNow Governance Group.

.DESCRIPTION
    Delete an IdentityNow Governance Group.

.PARAMETER groupID
    (required) The Governance Group ID to delete.

.EXAMPLE
    Remove-IdentityNowGovernanceGroup -groupID "8b155c95-cda6-4dc9-9f62-e73c24019c57" 

.EXAMPLE
    $govGroups = Get-IdentityNowGovernanceGroup
    $IDNGovGroup = $govGroups | Select-Object | Where-Object {$_.description -like "*My Gov Group*"}
    $groupID = $IDNGovGroup[0].id 

    Remove-IdentityNowGovernanceGroup -groupID $groupID 

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$groupID
    )

    $Headersv2 = Get-IdentityNowAuth -return V2Header
    $Headersv2."Content-Type" = "application/json"

    try {        
        $grpID = @($groupID)
        $ids = (@{ids = $grpID } | convertto-json)
        $DeleteGovGroup = Invoke-RestMethod -Method Post -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/workgroups/bulk-delete" -Headers $Headersv2 -Body $ids
        return $DeleteGovGroup 
    }
    catch {
        Write-Error "Failed to delete Governance Group. Check group details including associations. Only Governance Groups without associations can be deleted. $($_)" 
    }
}
