function Remove-IdentityNowAPIClient {
    <#
.SYNOPSIS
Delete an IdentityNow API Client.

.DESCRIPTION
Delete an IdentityNow API Client.

.PARAMETER ID
(required) The ID of the IdentityNow API Client to be deleted.

.EXAMPLE
Remove-IdentityNowAPIClient -ID 123

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$ID
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
            $IDNDeleteAPIClient = Invoke-RestMethod -Method Post -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/client/remove/$($ID)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "Content-Type" = "application/json"} 
            return $IDNDeleteAPIClient
        }
        catch {
            Write-Error "Deletion of API Client failed. Check ID of API Client Configuration. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

