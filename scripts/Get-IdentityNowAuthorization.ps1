function Get-IdentityNowAuthorization {
    <#
.SYNOPSIS
Gets Identity Now JWT access token or basic auth header.

.DESCRIPTION
will return api v2 or v3 auth.


.PARAMETER returnType
(required) Headers for the request
Headersv2 Digest Auth
Headersv3 is JWT oAuth

.EXAMPLE
Invoke-IdentityNowRequest -return V2Header

.EXAMPLE
Invoke-IdentityNowRequest -return v3jwt

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [Parameter(ValueFromPipeline = $true)]
        [string][ValidateSet("V2Header", "V3Header", "V3JWT")]$Return='V3JWT',
        [switch]$ForceRefresh
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
    if ($IdentityNowConfiguration.JWT.refresh_token){
        $oAuthTokenBody = @{
            grant_type = "refresh_token"
            client_id = (get-jwtdetails $IdentityNowConfiguration.jwt.access_token).client_id
            client_secret = $null
            refresh_token = $IdentityNowConfiguration.JWT.refresh_token
        }
        if ($oAuthTokenBody.client_id -eq $IdentityNowConfiguration.v3.UserName){
            $oAuthTokenBody.client_secret=$clientSecretv3
        }elseif ($oAuthTokenBody.client_id -eq $IdentityNowConfiguration.PAT.UserName){
            $oAuthTokenBody.client_secret=[System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($IdentityNowConfiguration.PAT.Password))
        }
    }elseif($IdentityNowConfiguration.PAT){
        $oAuthTokenBody = @{
            grant_type = "client_credentials"
            client_id = $IdentityNowConfiguration.PAT.UserName
            client_secret = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($IdentityNowConfiguration.PAT.Password))
        }
    }else{
        $oAuthTokenBody = @{
            grant_type = "password"
            username = $adminUSR
            password = $adminPWD
        }        
    }
    if (-not $IdentityNowConfiguration.jwt){$forcerefresh=$true}
    if ($ForceRefresh -or ((get-jwtdetails $IdentityNowConfiguration.jwt.access_token).expiryDateTime -lt (get-date).addminutes(1) -and (get-jwtdetails $IdentityNowConfiguration.jwt.access_token).org -eq $IdentityNowConfiguration.org)){
        Write-Verbose ($oAuthTokenBody | convertto-json)
        if ($oAuthTokenBody.grant_type -ne 'password'){$Headersv3=$null}
        $v3Token = Invoke-RestMethod -Uri $oAuthURI -Method Post -Body $oAuthTokenBody -Headers $Headersv3
        $IdentityNowConfiguration.jwt=$v3Token
    }else{
        $v3Token=$IdentityNowConfiguration.jwt
    }

    # v2 Auth
    $clientSecretv2 = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($IdentityNowConfiguration.v2.Password))
    $Bytes = [System.Text.Encoding]::utf8.GetBytes("$($IdentityNowConfiguration.v2.UserName):$($clientSecretv2)") 
    $encodedAuth = [Convert]::ToBase64String($Bytes)     

    switch ($Return) {
        V2Header { 
            $requestHeaders = @{Authorization = "Basic $($encodedAuth)" }
            Write-Verbose "Authorization = Basic $($encodedAuth)"
        }
        V3Header { 
            $requestHeaders = @{Authorization = "Bearer $($v3Token.access_token)" }
            Write-Verbose "Authorization = Bearer $($v3Token.access_token)"
        }
        V3JWT { 
            $requestHeaders = $v3Token
            Write-Verbose $v3Token

        }
        default { 
            $requestHeaders = $headers 
        } 
    }
    
    Write-Verbose $requestHeaders
    return $requestHeaders
}
