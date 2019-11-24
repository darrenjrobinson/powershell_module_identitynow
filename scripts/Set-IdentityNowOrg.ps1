function Set-IdentityNowOrg {
    <#
.SYNOPSIS
    Sets the default Organisation name for an IdentityNow Tenant.

.DESCRIPTION
    Used to build the default Uri value for a particular Org. These values
    can be saved to a user's profile using Save-IdentityNowConfiguration.

.PARAMETER orgName
    The IdentityNow Organisation name. 

.EXAMPLE    
    Set-IdentityNowOrg -orgName 'MyCompany'
    Demonstrates how to set an Organisation Name value.

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow
#>

    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]$orgName
    )

    process {
        $IdentityNowConfiguration.OrgName = $orgName
        if ($null -ne $IdentityNowConfiguration.($orgName).AdminCredential) { $IdentityNowConfiguration.AdminCredential = $IdentityNowConfiguration.($orgName).AdminCredential }
        if ($null -ne $IdentityNowConfiguration.($orgName).v2) { $IdentityNowConfiguration.v2 = $IdentityNowConfiguration.($orgName).v2 }
        if ($null -ne $IdentityNowConfiguration.($orgName).v3) { $IdentityNowConfiguration.v3 = $IdentityNowConfiguration.($orgName).v3 }
    }
}
