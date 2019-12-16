function Get-IdentityNowIdentityAttribute {
    <#
.SYNOPSIS
Get an IdentityNow Identity Attribute(s).

.DESCRIPTION
Get an IdentityNow Identity Attribute(s).

.PARAMETER attribute
(optional) The identity attribue to retrieve.

.EXAMPLE
Get-IdentityNowIdentityAttribute 

.EXAMPLE
Get-IdentityNowGovernanceGroup -attribute firstname

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$attribute
    )

    # IdentityNow Admin User
    $adminUSR = [string]$IdentityNowConfiguration.AdminCredential.UserName.ToLower()
    $adminPWDClear = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($IdentityNowConfiguration.AdminCredential.Password))

    # Generate the password hash
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
            if ($attribute) {                
                $IdentityAttr = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/identityAttribute/get?name=$($attribute)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
                return $IdentityAttr
            }
            else {                
                $IdentityAttr = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/identityAttribute/list" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
                return $IdentityAttr
            }
        }
        catch {
            Write-Error "Identity Attribute doesn't exist. Check attribue name. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

