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

    # v2 Auth
    $clientSecretv2 = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($IdentityNowConfiguration.v2.Password))
    $Bytes = [System.Text.Encoding]::utf8.GetBytes("$($IdentityNowConfiguration.v2.UserName):$($clientSecretv2)") 
    $encodedAuth = [Convert]::ToBase64String($Bytes) 

    $Headersv2 = @{Authorization = "Basic $($encodedAuth)"; "Content-Type" = "application/json" }

    try {          
        $IDNNewGroup = Invoke-RestMethod -Method Post -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/workgroups?&org=$($IdentityNowConfiguration.orgName)" -Headers $Headersv2 -Body $group
        return $IDNNewGroup              
    }
    catch {
        Write-Error "Failed to create group. Check group details. $($_)" 
    }
}
