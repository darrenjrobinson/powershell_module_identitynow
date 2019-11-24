function Invoke-IdentityNowSourceReset {
    <#
.SYNOPSIS
    Reset an IdentityNow Source.

.DESCRIPTION
    Reset an IdentityNow Source.

.PARAMETER sourceID
    (required) The ID of an IdentityNow Source. eg. 45678

.EXAMPLE
    Invoke-IdentityNowSourceReset -sourceID 12345

.EXAMPLE
    Reset a Source but leave the entitlements
    Invoke-IdentityNowSourceReset -sourceID 12345 -skip entitlements

.EXAMPLE
    Reset a Source but leave the entitlements
    Invoke-IdentityNowSourceReset -sourceID 12345 -skip accounts

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$sourceID,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [ValidateSet("accounts", "entitlements")]
        [string]$skip        
    )

    # IdentityNow Admin User
    $adminUSR = [string]$IdentityNowConfiguration.AdminCredential.UserName.ToLower()
    $adminPWDClear = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($IdentityNowConfiguration.AdminCredential.Password))

    $passwordHash = Get-Hash -Algorithm SHA256 -StringEncoding utf8 -InputObject ($($adminPWDClear) + (Get-Hash -Algorithm SHA256 -StringEncoding utf8 -InputObject ($adminUSR)).HashString.ToLower())
    $adminPWD = $passwordHash.ToString().ToLower() 

    $tokenURI = "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/oauth/token?grant_type=password&username=$($adminUSR)&password=$($adminPWD)"
    
    # v2 Auth
    $clientSecretv2 = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($IdentityNowConfiguration.v2.Password))
    $Bytes = [System.Text.Encoding]::utf8.GetBytes("$($IdentityNowConfiguration.v2.UserName):$($clientSecretv2)") 
    $encodedAuth = [Convert]::ToBase64String($Bytes)     

    # Get Token
    $token = Invoke-RestMethod -Method POST -Uri $tokenURI -Headers @{Authorization = "Basic $($encodedAuth)" } 

    if ($token) {
        try {
            if ($skip) {
                $reset = Invoke-RestMethod -Method POST -uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/source/reset/$($sourceID)?skip=$($skip)" -Headers @{"Authorization" = "Bearer $($token.access_token)" }
                return $reset 
            }
            else {            
                $reset = Invoke-RestMethod -Method POST -uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/source/reset/$($sourceID)" -Headers @{"Authorization" = "Bearer $($token.access_token)" }
                return $reset 
            }
        }
        catch {
            Write-Error "Source doesn't exist? Check SourceID. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your v2 API credentials. $($_)"
    } 
}

