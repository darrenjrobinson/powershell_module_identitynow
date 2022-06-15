function Get-IdentityNowAuth {
    <#
.SYNOPSIS
Get IdentityNow JWT access token or basic auth header.

.DESCRIPTION
Will return API v2 / v3 Auth Headers or JWT.

.PARAMETER return
authentication header/token to return (defaults to V3JWT)
- V2Header Digest Auth
- V3Header oAuth Access Token Bearer Header
- V3JWT oAuth JWT Token

.EXAMPLE
Get-IdentityNowAuth -return V2Header

.EXAMPLE
Get-IdentityNowAuth -return V3JWT

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [Parameter(ValueFromPipeline = $true)]
        [string][ValidateSet("V2Header", "V3Header", "V3JWT")]$return = 'V3JWT',
        [switch]$ForceRefresh
    )
    function Get-JWTDetails {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
            [string]$token
        )
    
        <#
    .SYNOPSIS
    Decode a JWT Access Token and convert to a PowerShell Object.
    JWT Access Token updated to include the JWT Signature (sig), JWT Token Expiry (expiryDateTime) and JWT Token time to expiry (timeToExpiry).
    .DESCRIPTION
    Decode a JWT Access Token and convert to a PowerShell Object.
    JWT Access Token updated to include the JWT Signature (sig), JWT Token Expiry (expiryDateTime) and JWT Token time to expiry (timeToExpiry).
    .PARAMETER token
    The JWT Access Token to decode and udpate with expiry time and time to expiry
    .INPUTS
    Token from Pipeline 
    .OUTPUTS
    PowerShell Object
    .SYNTAX
    Get-JWTDetails(accesstoken)
    .EXAMPLE
    PS> Get-JWTDetails('eyJ0eXAiOi........XmN4GnWQAw7OwMA')
    or
    PS> 'eyJ0eXAiOi........XmN4GnWQAw7OwMA' | Get-JWTDetails
    aud             : https://graph.microsoft.com
    iss             : https://sts.windows.net/74ea519d-1234-4aa9-86d9-b7cab8204aaa/
    iat             : 1564472277
    nbf             : 1564472277
    exp             : 1564476177
    acct            : 0
    acr             : 1
    aio             : AVQAq/8MAAAAAzB0vSr6FzZdn+4Rl0mv/akAo4CoJGUOzDRebOAz2s8IgJyRK7IONYU/57PHkLZYUswizziQS7QQ5l9w0DrqH4urxrexTpLbagQHvJlEaD6c=
    amr             : {pwd, mfa}
    app_displayname : Reporting
    appid           : 2c29e80e-ec64-43f7-b07a-137ae9c1d70c
    appidacr        : 1
    ipaddr          : 1.129.1.112
    name            : Darren J Robinson
    oid             : 5fddc979-ef08-4947-abcd-2430bc1234e0
    platf           : 3
    puid            : C1373BFDAE1A48F6
    scp             : AuditLog.Read.All Directory.Read.All Reports.Read.All
                      User.Read User.Read.All
    sub             : _31PG9C137LXuAkWDB93YM_eoRl9auP21qHOn5hO-s9w
    tid             : 74ea519d-9792-4aa9-c137-b7cab8204aaa
    unique_name     : darren@mytenant.onmicrosoft.com
    upn             : darren@mytenant.onmicrosoft.com
    uti             : eoWKGl9uZ0Gnc13715Qdff
    ver             : 1.0
    wids            : {4a5d8f65-41da-4de4-c137-f035b65339ca, c4e39bd9-c137-46d3-8c65-fb160df0071a, 5d6b6bb7-c137-4623-bafa-96380f352509}
    xms_tcdt        : 1341026666
    sig             : PUpl4F61Ql12nfxkLDeTA2Tucb7KfzrfbmI1+gNDPFfbe8WD3wlfr0EK2M89JNPJ1Z8H7Z8/JVU9Jbat2u+657D8IM81+NhnCpMvEWyC5565ZmIgE3vQKlBK3wD24kSzEFj6J2yL 
                      Zou1u/NrBvEakiiZdCJRKOB9nf4/euHHfYJNSKtPhLiPImyc137JxbPUG/MPjAQBkBPuUCyYtmFoBynGvsoSVvzZ6JQS5O2nxZPAqOFUzj5q3fjhh/oqPpu/6Qw1bdt3O37HgMLn 
                      UrBK3psjwUfP/X6//L6S1FwomenNoFVeKcUNcM5Ne6loDwRSW1Ig8XHXmN4GnWQAw7OwMA==
    expiryDateTime  : 30/07/2019 6:42:57 PM
    timeToExpiry    : -00:32:56.1103767
    .EXAMPLE
    PS> Get-JWTDetails($myAccessToken)
    or 
    PS> $myAccessToken | Get-JWTDetails
    tenant_id             : cd988f3c-710c-43eb-9e25-123456789
    internal              : False
    pod                   : uswest2
    org                   : myOrd
    identity_id           : 1c818084624f8babcdefgh9a4
    user_name             : adminDude
    strong_auth_supported : True
    user_id               : 100666
    scope                 : {read, write}
    exp                   : 1564474732
    jti                   : 1282411c-ffff-1111-a9d0-f9314a123c7a
    sig                   : SWPhCswizzleQWdM4K8A8HotX5fP/PT8kBWnaaAf2g6k=
    expiryDateTime        : 30/07/2019 6:18:52 PM
    timeToExpiry          : -00:57:37.4457299
    .LINK
    https://blog.darrenjrobinson.com
    https://blog.darrenjrobinson.com/jwtdetails-powershell-module-for-decoding-jwt-access-tokens-with-readable-token-expiry-time/ 
    #>
    
    
        if (!$token.Contains(".") -or !$token.StartsWith("eyJ")) { Write-Error "Invalid token" -ErrorAction Stop }
    
        # Token
        foreach ($i in 0..1) {
            $data = $token.Split('.')[$i].Replace('-', '+').Replace('_', '/')
            switch ($data.Length % 4) {
                0 { break }
                2 { $data += '==' }
                3 { $data += '=' }
            }
        }
    
        $decodedToken = [System.Text.Encoding]::UTF8.GetString([convert]::FromBase64String($data)) | ConvertFrom-Json 
        Write-Verbose "JWT Token:"
        Write-Verbose $decodedToken
    
        # Signature
        foreach ($i in 0..2) {
            $sig = $token.Split('.')[$i].Replace('-', '+').Replace('_', '/')
            switch ($sig.Length % 4) {
                0 { break }
                2 { $sig += '==' }
                3 { $sig += '=' }
            }
        }
        Write-Verbose "JWT Signature:"
        Write-Verbose $sig
        $decodedToken | Add-Member -Type NoteProperty -Name "sig" -Value $sig
    
        # Convert Expiry time to PowerShell DateTime
        $orig = (Get-Date -Year 1970 -Month 1 -Day 1 -hour 0 -Minute 0 -Second 0 -Millisecond 0)
        $timeZone = Get-TimeZone
        $utcTime = $orig.AddSeconds($decodedToken.exp)
        $offset = $timeZone.GetUtcOffset($(Get-Date)).TotalMinutes #Daylight saving needs to be calculated
        $localTime = $utcTime.AddMinutes($offset)     # Return local time,
        $decodedToken | Add-Member -Type NoteProperty -Name "expiryDateTime" -Value $localTime
        
        # Time to Expiry
        $timeToExpiry = ($localTime - (get-date))
        $decodedToken | Add-Member -Type NoteProperty -Name "timeToExpiry" -Value $timeToExpiry
    
        return $decodedToken
    }

    if ($IdentityNowConfiguration.AdminCredential -and $IdentityNowConfiguration.AdminCredential.UserName -and $IdentityNowConfiguration.AdminCredential.Password) {
        # IdentityNow Admin User
        $adminUSR = [string]$IdentityNowConfiguration.AdminCredential.UserName.ToLower()
        $adminPWDClear = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($IdentityNowConfiguration.AdminCredential.Password))
        
        # Generate the account hash
        $hashUser = Get-HashString $adminUSR.ToLower() 
        $adminPWD = Get-HashString "$($adminPWDClear)$($hashUser)"  
    }
    else {
        Write-verbose "No admin credentials available"
    }

    if ($IdentityNowConfiguration.v3 -and $IdentityNowConfiguration.v3.Username -and $IdentityNowConfiguration.v3.Password) {
        $clientSecretv3 = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($IdentityNowConfiguration.v3.Password))
        # Basic Auth
        $Bytesv3 = [System.Text.Encoding]::utf8.GetBytes("$($IdentityNowConfiguration.v3.UserName):$($clientSecretv3)")
        $encodedAuthv3 = [Convert]::ToBase64String($Bytesv3)
        $Headersv3 = @{Authorization = "Basic $($encodedAuthv3)" }
    }
    else {
        Write-verbose "No v3 credentials available"
    }
    
    # Get v3 oAuth Token
    # oAuth URI
    $oAuthURI = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/oauth/token"
    if ($IdentityNowConfiguration.JWT.refresh_token) {

        if ((Convert-UnixTime (Get-JWTDetails $IdentityNowConfiguration.JWT.refresh_token).exp) -lt (get-date) ) {
            $refreshTokenExpiry = (Get-JWTDetails $IdentityNowConfiguration.JWT.refresh_token).exp
            Write-Verbose "Refresh Token expired: $($refreshTokenExpiry)" 
            
            # Can't use Refresh Token to get a new Access Token
            Write-Verbose "AuthType: Admin Creds"
            $oAuthTokenBody = @{
                grant_type = "password"
                username   = $adminUSR
                password   = $adminPWD
            } 
        }
        else {
            $oAuthTokenBody = @{
                grant_type    = "refresh_token"
                client_id     = (Get-JWTDetails $IdentityNowConfiguration.JWT.access_token).client_id
                client_secret = $null
                refresh_token = $IdentityNowConfiguration.JWT.refresh_token
            }
            Write-Verbose "AuthType: v3 JWT Refresh Token"

            if ($oAuthTokenBody.client_id -eq $IdentityNowConfiguration.v3.UserName) {
                Write-Verbose "AuthType: v3"
                $oAuthTokenBody.client_secret = $clientSecretv3
            }
            elseif ($oAuthTokenBody.client_id -eq $IdentityNowConfiguration.PAT.UserName) {
                Write-Verbose "AuthType: Personal Access Token"
                $oAuthTokenBody.client_secret = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($IdentityNowConfiguration.PAT.Password))
            }
        }
    }
    elseif ($IdentityNowConfiguration.PAT) {
        Write-Verbose "AuthType: Personal Access Token"
        $oAuthTokenBody = @{
            grant_type    = "client_credentials"
            client_id     = $IdentityNowConfiguration.PAT.UserName
            client_secret = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($IdentityNowConfiguration.PAT.Password))
        }
    }
    else {
        $oAuthTokenBody = @{
            grant_type = "password"
            username   = $adminUSR
            password   = $adminPWD
        }
        Write-Verbose "AuthType: Admin Creds"        
    }
    
    if (-not $IdentityNowConfiguration.JWT -or (-not $IdentityNowConfiguration.JWT.access_token)) { 
        $forcerefresh = $true 
    }

    if ($ForceRefresh -or ((Get-JWTDetails $IdentityNowConfiguration.JWT.access_token).expiryDateTime -lt (get-date).addminutes(1) -and (Get-JWTDetails $IdentityNowConfiguration.JWT.access_token).org -eq $IdentityNowConfiguration.orgName)) {
        Write-Verbose ($oAuthTokenBody | convertto-json)
        
        if ($oAuthTokenBody.grant_type -ne 'password') { 
            $Headersv3 = $null 
        }

        try {
            $v3Token = Invoke-RestMethod -Uri $oAuthURI -Method Post -Body $oAuthTokenBody -Headers $Headersv3
        }
        catch {
            Write-Error "unable to auth $($oAuthTokenBody.grant_type) grant type
for $($IdentityNowConfiguration.orgName)
v2:$($null -ne $IdentityNowConfiguration.v2)
v3:$($null -ne $IdentityNowConfiguration.v3)
cred:$($null -ne $IdentityNowConfiguration.AdminCredential)
pat:$($null -ne $IdentityNowConfiguration.PAT)
$_" -ErrorAction 'stop'
        }
        $IdentityNowConfiguration.JWT = $v3Token
        Write-Verbose "AuthType: v3 JWT Access Token"
    }
    else {
        $v3Token = $IdentityNowConfiguration.JWT
        Write-Verbose "AuthType: v3 JWT Access Token"
    }

    # v2 Auth
    # Check to see if v2 API Client exists before generating v2 Headers
    if ($IdentityNowConfiguration.v2) {
        $clientSecretv2 = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($IdentityNowConfiguration.v2.Password))
        $Bytes = [System.Text.Encoding]::utf8.GetBytes("$($IdentityNowConfiguration.v2.UserName):$($clientSecretv2)") 
        $encodedAuth = [Convert]::ToBase64String($Bytes)     
        Write-Verbose "AuthType: v2 Basic Auth"
    }

    switch ($return) {
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
            $requestHeaders = $Headersv3 
        } 
    }
    
    Write-Verbose $requestHeaders
    return $requestHeaders
}


# SIG # Begin signature block
# MIINSwYJKoZIhvcNAQcCoIINPDCCDTgCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AQsFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVk
# IElEIFJvb3QgQ0EwHhcNMTMxMDIyMTIwMDAwWhcNMjgxMDIyMTIwMDAwWjByMQsw
# CQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cu
# ZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFzc3VyZWQgSUQg
# Q29kZSBTaWduaW5nIENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
# +NOzHH8OEa9ndwfTCzFJGc/Q+0WZsTrbRPV/5aid2zLXcep2nQUut4/6kkPApfmJ
# 1DcZ17aq8JyGpdglrA55KDp+6dFn08b7KSfH03sjlOSRI5aQd4L5oYQjZhJUM1B0
# sSgmuyRpwsJS8hRniolF1C2ho+mILCCVrhxKhwjfDPXiTWAYvqrEsq5wMWYzcT6s
# cKKrzn/pfMuSoeU7MRzP6vIK5Fe7SrXpdOYr/mzLfnQ5Ng2Q7+S1TqSp6moKq4Tz
# rGdOtcT3jNEgJSPrCGQ+UpbB8g8S9MWOD8Gi6CxR93O8vYWxYoNzQYIH5DiLanMg
# 0A9kczyen6Yzqf0Z3yWT0QIDAQABo4IBzTCCAckwEgYDVR0TAQH/BAgwBgEB/wIB
# ADAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAwwCgYIKwYBBQUHAwMweQYIKwYBBQUH
# AQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wQwYI
# KwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFz
# c3VyZWRJRFJvb3RDQS5jcnQwgYEGA1UdHwR6MHgwOqA4oDaGNGh0dHA6Ly9jcmw0
# LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwOqA4oDaG
# NGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RD
# QS5jcmwwTwYDVR0gBEgwRjA4BgpghkgBhv1sAAIEMCowKAYIKwYBBQUHAgEWHGh0
# dHBzOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwCgYIYIZIAYb9bAMwHQYDVR0OBBYE
# FFrEuXsqCqOl6nEDwGD5LfZldQ5YMB8GA1UdIwQYMBaAFEXroq/0ksuCMS1Ri6en
# IZ3zbcgPMA0GCSqGSIb3DQEBCwUAA4IBAQA+7A1aJLPzItEVyCx8JSl2qB1dHC06
# GsTvMGHXfgtg/cM9D8Svi/3vKt8gVTew4fbRknUPUbRupY5a4l4kgU4QpO4/cY5j
# DhNLrddfRHnzNhQGivecRk5c/5CxGwcOkRX7uq+1UcKNJK4kxscnKqEpKBo6cSgC
# PC6Ro8AlEeKcFEehemhor5unXCBc2XGxDI+7qPjFEmifz0DLQESlE/DmZAwlCEIy
# sjaKJAL+L3J+HNdJRZboWR3p+nRka7LrZkPas7CM1ekN3fYBIM6ZMWM9CBoYs4Gb
# T8aTEAb8B4H6i9r5gkn3Ym6hU/oSlBiFLpKR6mhsRDKyZqHnGKSaZFHvMIIFVTCC
# BD2gAwIBAgIQDOzRdXezgbkTF+1Qo8ZgrzANBgkqhkiG9w0BAQsFADByMQswCQYD
# VQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGln
# aWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFzc3VyZWQgSUQgQ29k
# ZSBTaWduaW5nIENBMB4XDTIwMDYxNDAwMDAwMFoXDTIzMDYxOTEyMDAwMFowgZEx
# CzAJBgNVBAYTAkFVMRgwFgYDVQQIEw9OZXcgU291dGggV2FsZXMxFDASBgNVBAcT
# C0NoZXJyeWJyb29rMRowGAYDVQQKExFEYXJyZW4gSiBSb2JpbnNvbjEaMBgGA1UE
# CxMRRGFycmVuIEogUm9iaW5zb24xGjAYBgNVBAMTEURhcnJlbiBKIFJvYmluc29u
# MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwj7PLmjkknFA0MIbRPwc
# T1JwU/xUZ6UFMy6AUyltGEigMVGxFEXoVybjQXwI9hhpzDh2gdxL3W8V5dTXyzqN
# 8LUXa6NODjIzh+egJf/fkXOgzWOPD5fToL7mm4JWofuaAwv2DmI2UtgvQGwRhkUx
# Y3hh0+MNDSyz28cqExf8H6mTTcuafgu/Nt4A0ddjr1hYBHU4g51ZJ96YcRsvMZSu
# 8qycBUNEp8/EZJxBUmqCp7mKi72jojkhu+6ujOPi2xgG8IWE6GqlmuMVhRSUvF7F
# 9PreiwPtGim92RG9Rsn8kg1tkxX/1dUYbjOIgXOmE1FAo/QU6nKVioJMNpNsVEBz
# /QIDAQABo4IBxTCCAcEwHwYDVR0jBBgwFoAUWsS5eyoKo6XqcQPAYPkt9mV1Dlgw
# HQYDVR0OBBYEFOh6QLkkiXXHi1nqeGozeiSEHADoMA4GA1UdDwEB/wQEAwIHgDAT
# BgNVHSUEDDAKBggrBgEFBQcDAzB3BgNVHR8EcDBuMDWgM6Axhi9odHRwOi8vY3Js
# My5kaWdpY2VydC5jb20vc2hhMi1hc3N1cmVkLWNzLWcxLmNybDA1oDOgMYYvaHR0
# cDovL2NybDQuZGlnaWNlcnQuY29tL3NoYTItYXNzdXJlZC1jcy1nMS5jcmwwTAYD
# VR0gBEUwQzA3BglghkgBhv1sAwEwKjAoBggrBgEFBQcCARYcaHR0cHM6Ly93d3cu
# ZGlnaWNlcnQuY29tL0NQUzAIBgZngQwBBAEwgYQGCCsGAQUFBwEBBHgwdjAkBggr
# BgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tME4GCCsGAQUFBzAChkJo
# dHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRTSEEyQXNzdXJlZElE
# Q29kZVNpZ25pbmdDQS5jcnQwDAYDVR0TAQH/BAIwADANBgkqhkiG9w0BAQsFAAOC
# AQEANWoHDjN7Hg9QrOaZx0V8MK4c4nkYBeFDCYAyP/SqwYeAtKPA7F72mvmJV6E3
# YZnilv8b+YvZpFTZrw98GtwCnuQjcIj3OZMfepQuwV1n3S6GO3o30xpKGu6h0d4L
# rJkIbmVvi3RZr7U8ruHqnI4TgbYaCWKdwfLb/CUffaUsRX7BOguFRnYShwJmZAzI
# mgBx2r2vWcZePlKH/k7kupUAWSY8PF8O+lvdwzVPSVDW+PoTqfI4q9au/0U77UN0
# Fq/ohMyQ/CUX731xeC6Rb5TjlmDhdthFP3Iho1FX0GIu55Py5x84qW+Ou+OytQcA
# FZx22DA8dAUbS3P7OIPamcU68TGCAigwggIkAgEBMIGGMHIxCzAJBgNVBAYTAlVT
# MRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5j
# b20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBDb2RlIFNpZ25p
# bmcgQ0ECEAzs0XV3s4G5ExftUKPGYK8wCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcC
# AQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYB

# SIG # End signature block
