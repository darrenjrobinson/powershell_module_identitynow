function Save-IdentityNowConfiguration {
<#
.SYNOPSIS
    Saves default IdentityNow configuration to a file in the current users Profile.

.DESCRIPTION
    Saves default IdentityNow configuration to a file within the current
    users Profile. If it exists, this file is then read, each time the
    IdentityNow Module is imported. Allowing settings to persist between
    sessions.

.EXAMPLE
    Save-IdentityNowConfiguration

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow
#>

    [CmdletBinding()]
    param ([switch]$default)
    if ($default){$IdentityNowConfiguration.DefaultOrg=$IdentityNowConfiguration.orgName}
    $IdentityNowConfiguration.($IdentityNowConfiguration.orgName)=@{
        orgName = $IdentityNowConfiguration.orgName 
        v2  = $IdentityNowConfiguration.v2
        v3  = $IdentityNowConfiguration.v3
        AdminCredential = $IdentityNowConfiguration.AdminCredential
    }
    Export-Clixml -Path $IdentityNowConfigurationFile -InputObject $IdentityNowConfiguration
}
