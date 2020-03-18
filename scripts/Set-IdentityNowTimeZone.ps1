function Set-IdentityNowTimeZone {
    <#
.SYNOPSIS
Set IdentityNow Time Zone.

.DESCRIPTION
Set IdentityNow Time Zone.

.PARAMETER tz
(required) The TZ to set the IdentityNow Org too.

.EXAMPLE
Set-IdentityNowTimeZone -tz 'Australia/Sydney'

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$tz
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
            $tzBody = $tzBody = '[{
                "op" : "replace",
                "path" : "/timeZone",
                "value" : "newtimezone"
                }]'     

            $tzBody = $tzBody.replace("newtimezone", $tz)    
            Write-Verbose $tzBody
            $updateTZ = Invoke-RestMethod -Method Patch -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/beta/org-config" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "Content-Type" = 'application/json-patch+json' } -Body $tzBody 
            return $updateTZ            
        }
        catch {
            Write-Error "Time Zone failed to update. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

