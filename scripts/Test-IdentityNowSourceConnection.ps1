function Test-IdentityNowSourceConnection {
    <#
.SYNOPSIS
Tests connection on an IdentityNow Source.

.DESCRIPTION
Test connection an IdentityNow Source.

.PARAMETER sourceid
(Required) The ID of the IdentityNow Source.

.EXAMPLE
Test-IdentityNowSourceConnection -sourceid 115340

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

.NOTES
written by Sean McGovern 11/20/2019 (twitter @410sean)

#>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$sourceid
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
            $privateuribase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com"
            $url = "$privateuribase/cc/api/source/testConnection/$sourceid"
            $response = Invoke-WebRequest -Uri $url -Method Post -UseBasicParsing -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
            $source = $response.Content | ConvertFrom-Json
            return $source
        }
        catch {
            Write-Error "Test connection of Source '$($sourceid)' failed. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}