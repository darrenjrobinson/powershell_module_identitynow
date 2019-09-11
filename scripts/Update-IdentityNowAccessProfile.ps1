function Update-IdentityNowAccessProfile {
    <#
.SYNOPSIS
Update an IdentityNow Access Profile(s).

.DESCRIPTION
Update an IdentityNow Access Profile(s).

.PARAMETER profileID
(required) The profile ID of the IdentityNow Access Profile to update.

.EXAMPLE
Update-IdentityNowAccessProfile -profileID 2c91808466a64e330112a96902ff1f69 -update "{"deniedCommentsRequired":  true,"requestCommentsRequired":  true}"

.EXAMPLE
$ap = Get-IdentityNowAccessProfile 
$accessProfile = $ap | Select-Object | Where-Object {$_.description -like '*Darren*'}

$updateAccessProfile = @{} 
$updateAccessProfile.Add("requestCommentsRequired", $true) 
$updateAccessProfile.Add("deniedCommentsRequired", $true) 

Update-IdentityNowAccessProfile -profileID $accessProfile.id -update ($updateAccessProfile | convertto-JSON)

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$profileID,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$update
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
    $v3Token = Invoke-RestMethod -Method Post -Uri "$($oAuthURI)?grant_type=password&username=$($adminUSR)&password=$($adminPWD)" -Headers $Headersv3 -SessionVariable IDNv3

    if ($v3Token.access_token) {
        try {
            $IDNUpdateAP = Invoke-RestMethod -Method Patch -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/access-profiles/$($profileID)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" ; "Content-Type" = "application/json" } -Body $update 
            return $IDNUpdateAP
        }
        catch {
            Write-Error "Access Profile doesn't exist or bad update config. Check Profile ID and Update payload (JSON). $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

