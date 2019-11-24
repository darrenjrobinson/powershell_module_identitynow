function Get-IdentityNowOrg {
    <#
.SYNOPSIS
    Displays the default Uri value for all or a particular Organisation based on configured OrgName.

.DESCRIPTION
    Displays the default Uri value for all or a particular Organisation based on configured OrgName.

.EXAMPLE
    Get-IdentityNowOrg 

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow
#>

    [CmdletBinding()]
    param ()

    if ($IdentityNowConfiguration.orgName) {
        $identityNowOrg = [ordered]@{
            "Organisation Name"         = $IdentityNowConfiguration.orgName;
            "Organisation URI"          = "https://$($IdentityNowConfiguration.orgName).identitynow.com";
            "v1 Base API URI"           = "https://$($IdentityNowConfiguration.orgName).identitynow.com/api";
            "v2 Base API URI"           = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2";
            "v3 / Private Base API URI" = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api"
        }
        return $identityNowOrg
    }
    else {
        Write-Output "No Organisation name held in configuration."
    }
}
