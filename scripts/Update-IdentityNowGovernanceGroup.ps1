function Update-IdentityNowGovernanceGroup {
    <#
.SYNOPSIS
    Add or Remove member(s) from an IdentityNow Governance Group.

.DESCRIPTION
    Add or Remove member(s) from an IdentityNow Governance Group.

.PARAMETER groupID
    (required) The Governance Group ID to update.

.PARAMETER update
    (required - JSON) The details of members to add and/or remove.
    e.g 

.EXAMPLE
    Update-IdentityNowGovernanceGroup -groupID "8b155c95-cda6-4dc9-9f62-e73c24019c57" -update "{"add":  ["2c91808869110cc901694377a7ce5def","2c91808869110cc901694381c5612657"],"remove":  ["2c91808869110cc901694381c5618319"]}"

.EXAMPLE
    $govGroups = Get-IdentityNowGovernanceGroup
    $IDNGovGroup = $govGroups | Select-Object | Where-Object {$_.description -like "*My Gov Group*"}
    $groupID = $IDNGovGroup[0].id 

    $user1 = Search-IdentityNowUsers -query "@accounts(accountId:darrenjrobinson)"
    $user2 = Search-IdentityNowUsers -query "@accounts(accountId:ricksanchez)"
    $user3 = Search-IdentityNowUsers -query "@accounts(accountId:mortysmith)"

    $add=@() 
    $remove=@() 
    $add += $user1.id
    $add += $user2.id 
    $remove += $user3.id 

    $update = (@{
        add = $add 
        remove = $remove
    }) | convertto-json  

    Update-IdentityNowGovernanceGroup -groupID $groupID -update $update

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$groupID,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$update
    )

    $Headersv2 = Get-IdentityNowAuth -Return V2Header
    $Headersv2."Content-Type" = "application/json"

    try {
        $UpdateGovGroup = Invoke-RestMethod -Method Post -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/workgroups/$($groupID)/members" -Headers $Headersv2 -Body $update
        return $UpdateGovGroup 
    }
    catch {
        Write-Error "Failed to update Governance Group. Check group details. $($_)" 
    }
}
