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
        [PSCredential]$AdminCredential,
        [PSCredential]$v2APIKey,
        [PSCredential]$v3APIKey,
        [PSCredential]$PersonalAccessToken
    )

    if ($AdminCredential){$IdentityNowConfiguration.AdminCredential = $AdminCredential}
    if ($v2APIKey){$IdentityNowConfiguration.v2 = $v2APIKey}
    if ($v3apikey){$IdentityNowConfiguration.v3 = $v3APIKey}
    if ($PersonalAccessToken){$IdentityNowConfiguration.PAT = $PersonalAccessToken}
}

