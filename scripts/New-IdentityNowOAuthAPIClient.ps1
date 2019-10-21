function New-IdentityNowOAuthAPIClient {
    <#
.SYNOPSIS
Create an IdentityNow v3 oAuth API Client.

.DESCRIPTION
Create an IdentityNow v3 oAuth API Client.

.PARAMETER grantTypes
(required) Grant Type options "AUTHORIZATION_CODE,CLIENT_CREDENTIALS,REFRESH_TOKEN,PASSWORD"

.PARAMETER description
(required) Description 

.PARAMETER redirectUris
(required) redirectUris e.g "https://localhost,https://myapp.com.au"

.EXAMPLE
New-IdentityNowOAuthAPIClient -description "oAuth Client via API" -grantTypes 'AUTHORIZATION_CODE,CLIENT_CREDENTIALS,REFRESH_TOKEN,PASSWORD' -redirectUris 'https://localhost'

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param( 
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]    
        [string]$grantTypes,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]    
        [string]$description,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]    
        [string]$redirectUris    
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
            $oAuthClientBody = @{ }
            $oAuthClientBody.add("enabled", $true)
            $oAuthClientBody.add("description", $description)
            $oAuthClientBody.add("name", $description)
            
            $grants = @()
            foreach ($grant in $grantTypes.Split(",")) {
                $grants += $grant
            }
            $oAuthClientBody.add("grantTypes", $grants)
            
            $replyURIs = @()
            foreach ($reply in $redirectUris.Split(",")) {
                $replyURIs += $reply
            }
            $oAuthClientBody.add("redirectUris", $replyURIs)

            $oAuthClientBody.add("accessTokenValiditySeconds", '750')
            $oAuthClientBody.add("refreshTokenValiditySeconds", '86400')
            $oAuthClientBody.add("accessType", 'OFFLINE')

            $IDNNewoAuthAPIClient = Invoke-RestMethod -Method Post -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/beta/oauth-clients" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "Content-Type" = "application/json" } -Body ($oAuthClientBody | convertTo-json)
            return $IDNNewoAuthAPIClient            
        }
        catch {
            Write-Error "Create oAuth API Client failed. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

