function Get-IdentityNowTransform {
    <#
.SYNOPSIS
Get IdentityNow Transform(s).

.DESCRIPTION
Get IdentityNow Transform(s).

.PARAMETER ID
(optional) The ID of an IdentityNow Transform.

.EXAMPLE
Get-IdentityNowTransform 

.EXAMPLE
Get-IdentityNowTransform -ID ToUpper 

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$ID,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [switch]$json
    )

    # IdentityNow Admin User
    $adminUSR = [string]$IdentityNowConfiguration.AdminCredential.UserName.ToLower()
    $adminPWDClear = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($IdentityNowConfiguration.AdminCredential.Password))

    # Generate the account hash
    $hashUser = Get-HashString $adminUSR.ToLower() 
    $adminPWD = Get-HashString "$($adminPWDClear)$($hashUser)"  

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
            if ($json) {
                if ($ID) {
                    $IDNTransform = Invoke-WebRequest -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/transform/get/$($ID)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" } 
                    return $IDNTransform.content
                }
                else {
                    $IDNTransform = Invoke-WebRequest -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/transform/list" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
                    return $IDNTransform.content
                }
            } else {
                if ($ID) {
                    $IDNTransform = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/transform/get/$($ID)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" } 
                    return $IDNTransform.items
                }
                else {
                    $IDNTransform = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/transform/list" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
                    return $IDNTransform.items
                }
            }
        }
        catch {
            Write-Error "Transform doesn't exist? $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

