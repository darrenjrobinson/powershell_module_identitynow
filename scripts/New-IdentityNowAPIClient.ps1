function New-IdentityNowAPIClient {
    <#
.SYNOPSIS
Create an IdentityNow v2 API Client.

.DESCRIPTION
Create an IdentityNow v2 API Client.

.EXAMPLE
New-IdentityNowAPIClient 

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param()

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
                $IDNAPIClient = Invoke-RestMethod -Method Post -Uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/client/create?type=API" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "Content-Type" = "application/json" }
                return $IDNAPIClient            
        }
        catch {
            Write-Error "Create API Client failed. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

