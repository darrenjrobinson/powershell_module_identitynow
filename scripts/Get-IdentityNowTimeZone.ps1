function Get-IdentityNowTimeZone {
    <#
.SYNOPSIS
Get IdentityNow Time Zone(s).

.DESCRIPTION
Get IdentityNow Time Zone(s).

.PARAMETER list
(optional) List available timezone values

.EXAMPLE
Get-IdentityNowTimeZone 

.EXAMPLE
Get-IdentityNowTimeZone -list 

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [switch]$list
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
    $oAuthTokenBody = @{
        grant_type = "password"
        username = $adminUSR
        password = $adminPWD
    }
    $v3Token = Invoke-RestMethod -Uri $oAuthURI -Method Post -Body $oAuthTokenBody -Headers $Headersv3 
    
    if ($v3Token.access_token) {
        try {                
            if ($list) {
                $getTZ = Invoke-RestMethod -Method Get -uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/beta/org-config/valid-time-zones" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "Content-Type" = "application/json" }
                return $getTZ 
            }
            else {
                $getTZ = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/beta/org-config" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "Content-Type" = "application/json" } 
                return $getTZ         
            }
        }
        catch {
            Write-Error "Failed to retrieve Time Zone(s). $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

