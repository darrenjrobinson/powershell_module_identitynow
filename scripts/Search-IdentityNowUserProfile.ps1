function Search-IdentityNowUserProfile {
    <#
.SYNOPSIS
Get an IdentityNow Users Identity Profile.

.DESCRIPTION
Get an IdentityNow Users Identity Profile from a query

.PARAMETER query
(required) User Search Query

.PARAMETER limit
(optional) Search Limit e.g 10

.EXAMPLE
Search-IdentityNowUserProfile -query "12345"

.EXAMPLE
Search-IdentityNowUserProfile -query darrenjrobinson

.EXAMPLE
Search-IdentityNowUserProfile -query "darren.robinson"

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$query,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$limit = 250
    )

    # IdentityNow Admin User
    $adminUSR = [string]$IdentityNowConfiguration.AdminCredential.UserName.ToLower()
    $adminPWDClear = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($IdentityNowConfiguration.AdminCredential.Password))
    # Generate the password hash
    # Requires Get-Hash from PowerShell Community Extensions (PSCX) Module 
    # https://www.powershellgallery.com/packages/Pscx/3.2.2
    $passwordHash = Get-Hash -Algorithm SHA256 -StringEncoding utf8 -InputObject ($($adminPWDClear) + (Get-Hash -Algorithm SHA256 -StringEncoding utf8 -InputObject ($adminUSR)).HashString.ToLower())
    $adminPWD = $passwordHash.ToString().ToLower() 
    $clientSecretv3 = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($IdentityNowConfiguration.v3.Password))
    # Basic Auth
    $Bytesv3 = [System.Text.Encoding]::utf8.GetBytes("$($IdentityNowConfiguration.v3.UserName):$($clientSecretv3)")
    $encodedAuthv3 = [Convert]::ToBase64String($Bytesv3)
    $Headersv3 = @{Authorization = "Basic $($encodedAuthv3)" }

    # Get v3 oAuth Token
    # oAuth URI
    $oAuthURI = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/oauth/token"
    $v3Token = Invoke-RestMethod -Method Post -Uri "$($oAuthURI)?grant_type=password&username=$($adminUSR)&password=$($adminPWD)" -Headers $Headersv3 

    if ($v3Token.access_token) {
        try {                         
            # Get User Profiles Based on Query
            $userProfiles = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/cc/api/user/list?_dc=$($utime)&listErrorFirst=true&useSds=true&start=0&limit=$($limit)&sorters=%5B%7B%22property%22%3A%22name%22%2C%22direction%22%3A%22ASC%22%7D%5D&filters=%5B%7B%22property%22%3A%22username%22%2C%22value%22%3A%22$($query)%22%7D%5D" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" } 
            return $userProfiles.items
        }
        catch {
            Write-Error "Bad Query. Check your query. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

