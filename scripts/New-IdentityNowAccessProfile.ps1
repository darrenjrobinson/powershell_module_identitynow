function New-IdentityNowAccessProfile {
    <#
.SYNOPSIS
Create an IdentityNow Access Profile.

.DESCRIPTION
Create an IdentityNow Access Profile.

.PARAMETER profile
(required - JSON) The profile of the IdentityNow Access Profile to create.

.EXAMPLE
New-IdentityNowAccessProfile -profile "{"entitlements":  ["2c91808668dcf3970168dd722e7a020d","2c91808468dcf4610168dd78d2e8531e"],"description":  "FS-SYDNEY-AUS-ENGINEERING","requestCommentsRequired":  true,"sourceId":  "39082","approvalSchemes":  "manager","ownerId":  "1397606","name":  "Sydney Engineering","deniedCommentsRequired":  true}"

.EXAMPLE
# Get Owner for Access Profile
$owner = Search-IdentityNowUserProfile -query "darren.robinson"

# Get Source for Access Proile
$sources = Get-IdentityNowSource 
$adSource = $sources | Select-Object | Where-Object {$_.name -like '*Active Directory*'}

# Entitlements
$entitlement = Search-IdentityNowEntitlements -query "FS-SYDNEY-AUS-ENGINEERING"
$e = $entitlement | Select-Object | Where-Object {$_.source.name -eq 'Active Directory'}

# Access Profile Details
$accessProfile = @{}
$accessProfile.add("name", "Sydney Engineering")
$accessProfile.add("description", "FS-SYDNEY-AUS-ENGINEERING")
$accessProfile.add("sourceId", $adSource.id)
$accessProfile.add("ownerId", $owner.id)

# Access Profile Entitlements
$entitlements = @()
ForEach($i in $e) {$entitlements += $i.id}
$entitlementsToAdd = @{"entitlements" = $entitlements}
$accessProfile.add("entitlements", $entitlementsToAdd.entitlements)

# Access Profile Type
$accessProfile.add("approvalSchemes", "manager")
$accessProfile.add("requestCommentsRequired", $true)
$accessProfile.add("deniedCommentsRequired", $true)

New-IdentityNowAccessProfile -profile ($accessProfile | convertto-json)

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$profile
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
            $IDNCreateAP = Invoke-RestMethod -Method Post -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/access-profiles" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" ; "Content-Type" = "application/json" } -Body $profile             
            return $IDNCreateAP
        }
        catch {
            Write-Error "Creation of Access Profile failed. Check Access Profile configuration (JSON). $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

