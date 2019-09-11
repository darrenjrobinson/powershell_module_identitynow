function Set-IdentityNowCredential {
<#
.SYNOPSIS
    Sets the default IdentityNow API credentials.

.DESCRIPTION
    Sets the default IdentityNow API credentials. Configuration values can
    be securely saved to a user's profile using Save-IdentityNowConfiguration.

.PARAMETER AdminCredential
    A standard Powershell Credential object. Optional.

.PARAMETER v2APIKey
    A standard Powershell Credential object. Optional.

.PARAMETER v3APIKey
    A standard Powershell Credential object. Optional.
    
.EXAMPLE
    Set-IdentityNowCredential

    This will prompt the user for credentials and save them in memory.

.EXAMPLE
    $cred = Get-Credential -Message 'Custom message...' -UserName 'Custom Username'
    Set-IdentityNowCredential -Credential $cred

    This demonstrates prompting the user with a custom message and default username.

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>

    [CmdletBinding()]
    param (
        [PSCredential]$AdminCredential = $(Get-Credential -Message 'Enter IdentityNow Admin User Credentials.'),
        [PSCredential]$v2APIKey = $(Get-Credential -Message 'Enter IdentityNow v1/v2 API ClientID and Secret generated from the IdentityNow Admin Portal.'),
        [PSCredential]$v3APIKey = $(Get-Credential -Message 'Enter IdentityNow v3 API ClientID and Secret provided by SailPoint for your Org.')
    )

    $IdentityNowConfiguration.AdminCredential = $AdminCredential
    $IdentityNowConfiguration.v2 = $v2APIKey
    $IdentityNowConfiguration.v3 = $v3APIKey
}

