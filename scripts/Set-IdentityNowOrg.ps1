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
        [parameter(Mandatory=$true,
        ValueFromPipelineByPropertyName=$true)]
        [string]$orgName
    )

    process {
        $IdentityNowConfiguration.OrgName = $orgName
    }
}
