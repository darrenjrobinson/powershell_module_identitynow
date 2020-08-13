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
    
    if (-not $IdentityNowConfiguration.JWT) { 
        $forcerefresh = $true 
    }

    if ($ForceRefresh -or ((Get-JWTDetails $IdentityNowConfiguration.JWT.access_token).expiryDateTime -lt (get-date).addminutes(1) -and (Get-JWTDetails $IdentityNowConfiguration.JWT.access_token).org -eq $IdentityNowConfiguration.orgName)) {
        Write-Verbose ($oAuthTokenBody | convertto-json)
        
        if ($oAuthTokenBody.grant_type -ne 'password') { 
            $Headersv3 = $null 
        }

        $v3Token = Invoke-RestMethod -Uri $oAuthURI -Method Post -Body $oAuthTokenBody -Headers $Headersv3
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
# MIIX8wYJKoZIhvcNAQcCoIIX5DCCF+ACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUwmuaA3dPwtdd5PH2CCyKx54i
# vomgghMmMIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
# AQUFADCBizELMAkGA1UEBhMCWkExFTATBgNVBAgTDFdlc3Rlcm4gQ2FwZTEUMBIG
# A1UEBxMLRHVyYmFudmlsbGUxDzANBgNVBAoTBlRoYXd0ZTEdMBsGA1UECxMUVGhh
# d3RlIENlcnRpZmljYXRpb24xHzAdBgNVBAMTFlRoYXd0ZSBUaW1lc3RhbXBpbmcg
# Q0EwHhcNMTIxMjIxMDAwMDAwWhcNMjAxMjMwMjM1OTU5WjBeMQswCQYDVQQGEwJV
# UzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFu
# dGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0EgLSBHMjCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBALGss0lUS5ccEgrYJXmRIlcqb9y4JsRDc2vCvy5Q
# WvsUwnaOQwElQ7Sh4kX06Ld7w3TMIte0lAAC903tv7S3RCRrzV9FO9FEzkMScxeC
# i2m0K8uZHqxyGyZNcR+xMd37UWECU6aq9UksBXhFpS+JzueZ5/6M4lc/PcaS3Er4
# ezPkeQr78HWIQZz/xQNRmarXbJ+TaYdlKYOFwmAUxMjJOxTawIHwHw103pIiq8r3
# +3R8J+b3Sht/p8OeLa6K6qbmqicWfWH3mHERvOJQoUvlXfrlDqcsn6plINPYlujI
# fKVOSET/GeJEB5IL12iEgF1qeGRFzWBGflTBE3zFefHJwXECAwEAAaOB+jCB9zAd
# BgNVHQ4EFgQUX5r1blzMzHSa1N197z/b7EyALt0wMgYIKwYBBQUHAQEEJjAkMCIG
# CCsGAQUFBzABhhZodHRwOi8vb2NzcC50aGF3dGUuY29tMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwPwYDVR0fBDgwNjA0oDKgMIYuaHR0cDovL2NybC50aGF3dGUuY29tL1Ro
# YXd0ZVRpbWVzdGFtcGluZ0NBLmNybDATBgNVHSUEDDAKBggrBgEFBQcDCDAOBgNV
# HQ8BAf8EBAMCAQYwKAYDVR0RBCEwH6QdMBsxGTAXBgNVBAMTEFRpbWVTdGFtcC0y
# MDQ4LTEwDQYJKoZIhvcNAQEFBQADgYEAAwmbj3nvf1kwqu9otfrjCR27T4IGXTdf
# plKfFo3qHJIJRG71betYfDDo+WmNI3MLEm9Hqa45EfgqsZuwGsOO61mWAK3ODE2y
# 0DGmCFwqevzieh1XTKhlGOl5QGIllm7HxzdqgyEIjkHq3dlXPx13SYcqFgZepjhq
# IhKjURmDfrYwggSjMIIDi6ADAgECAhAOz/Q4yP6/NW4E2GqYGxpQMA0GCSqGSIb3
# DQEBBQUAMF4xCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3Jh
# dGlvbjEwMC4GA1UEAxMnU3ltYW50ZWMgVGltZSBTdGFtcGluZyBTZXJ2aWNlcyBD
# QSAtIEcyMB4XDTEyMTAxODAwMDAwMFoXDTIwMTIyOTIzNTk1OVowYjELMAkGA1UE
# BhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMTQwMgYDVQQDEytT
# eW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIFNpZ25lciAtIEc0MIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAomMLOUS4uyOnREm7Dv+h8GEKU5Ow
# mNutLA9KxW7/hjxTVQ8VzgQ/K/2plpbZvmF5C1vJTIZ25eBDSyKV7sIrQ8Gf2Gi0
# jkBP7oU4uRHFI/JkWPAVMm9OV6GuiKQC1yoezUvh3WPVF4kyW7BemVqonShQDhfu
# ltthO0VRHc8SVguSR/yrrvZmPUescHLnkudfzRC5xINklBm9JYDh6NIipdC6Anqh
# d5NbZcPuF3S8QYYq3AhMjJKMkS2ed0QfaNaodHfbDlsyi1aLM73ZY8hJnTrFxeoz
# C9Lxoxv0i77Zs1eLO94Ep3oisiSuLsdwxb5OgyYI+wu9qU+ZCOEQKHKqzQIDAQAB
# o4IBVzCCAVMwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAO
# BgNVHQ8BAf8EBAMCB4AwcwYIKwYBBQUHAQEEZzBlMCoGCCsGAQUFBzABhh5odHRw
# Oi8vdHMtb2NzcC53cy5zeW1hbnRlYy5jb20wNwYIKwYBBQUHMAKGK2h0dHA6Ly90
# cy1haWEud3Muc3ltYW50ZWMuY29tL3Rzcy1jYS1nMi5jZXIwPAYDVR0fBDUwMzAx
# oC+gLYYraHR0cDovL3RzLWNybC53cy5zeW1hbnRlYy5jb20vdHNzLWNhLWcyLmNy
# bDAoBgNVHREEITAfpB0wGzEZMBcGA1UEAxMQVGltZVN0YW1wLTIwNDgtMjAdBgNV
# HQ4EFgQURsZpow5KFB7VTNpSYxc/Xja8DeYwHwYDVR0jBBgwFoAUX5r1blzMzHSa
# 1N197z/b7EyALt0wDQYJKoZIhvcNAQEFBQADggEBAHg7tJEqAEzwj2IwN3ijhCcH
# bxiy3iXcoNSUA6qGTiWfmkADHN3O43nLIWgG2rYytG2/9CwmYzPkSWRtDebDZw73
# BaQ1bHyJFsbpst+y6d0gxnEPzZV03LZc3r03H0N45ni1zSgEIKOq8UvEiCmRDoDR
# EfzdXHZuT14ORUZBbg2w6jiasTraCXEQ/Bx5tIB7rGn0/Zy2DBYr8X9bCT2bW+IW
# yhOBbQAuOA2oKY8s4bL0WqkBrxWcLC9JG9siu8P+eJRRw4axgohd8D20UaF5Mysu
# e7ncIAkTcetqGVvP6KUwVyyJST+5z3/Jvz4iaGNTmr1pdKzFHTx/kuDDvBzYBHUw
# ggUwMIIEGKADAgECAhAECRgbX9W7ZnVTQ7VvlVAIMA0GCSqGSIb3DQEBCwUAMGUx
# CzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3
# dy5kaWdpY2VydC5jb20xJDAiBgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9v
# dCBDQTAeFw0xMzEwMjIxMjAwMDBaFw0yODEwMjIxMjAwMDBaMHIxCzAJBgNVBAYT
# AlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2Vy
# dC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBDb2RlIFNp
# Z25pbmcgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQD407Mcfw4R
# r2d3B9MLMUkZz9D7RZmxOttE9X/lqJ3bMtdx6nadBS63j/qSQ8Cl+YnUNxnXtqrw
# nIal2CWsDnkoOn7p0WfTxvspJ8fTeyOU5JEjlpB3gvmhhCNmElQzUHSxKCa7JGnC
# wlLyFGeKiUXULaGj6YgsIJWuHEqHCN8M9eJNYBi+qsSyrnAxZjNxPqxwoqvOf+l8
# y5Kh5TsxHM/q8grkV7tKtel05iv+bMt+dDk2DZDv5LVOpKnqagqrhPOsZ061xPeM
# 0SAlI+sIZD5SlsHyDxL0xY4PwaLoLFH3c7y9hbFig3NBggfkOItqcyDQD2RzPJ6f
# pjOp/RnfJZPRAgMBAAGjggHNMIIByTASBgNVHRMBAf8ECDAGAQH/AgEAMA4GA1Ud
# DwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEFBQcDAzB5BggrBgEFBQcBAQRtMGsw
# JAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcw
# AoY3aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElE
# Um9vdENBLmNydDCBgQYDVR0fBHoweDA6oDigNoY0aHR0cDovL2NybDQuZGlnaWNl
# cnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDA6oDigNoY0aHR0cDov
# L2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDBP
# BgNVHSAESDBGMDgGCmCGSAGG/WwAAgQwKjAoBggrBgEFBQcCARYcaHR0cHM6Ly93
# d3cuZGlnaWNlcnQuY29tL0NQUzAKBghghkgBhv1sAzAdBgNVHQ4EFgQUWsS5eyoK
# o6XqcQPAYPkt9mV1DlgwHwYDVR0jBBgwFoAUReuir/SSy4IxLVGLp6chnfNtyA8w
# DQYJKoZIhvcNAQELBQADggEBAD7sDVoks/Mi0RXILHwlKXaoHV0cLToaxO8wYdd+
# C2D9wz0PxK+L/e8q3yBVN7Dh9tGSdQ9RtG6ljlriXiSBThCk7j9xjmMOE0ut119E
# efM2FAaK95xGTlz/kLEbBw6RFfu6r7VRwo0kriTGxycqoSkoGjpxKAI8LpGjwCUR
# 4pwUR6F6aGivm6dcIFzZcbEMj7uo+MUSaJ/PQMtARKUT8OZkDCUIQjKyNookAv4v
# cn4c10lFluhZHen6dGRrsutmQ9qzsIzV6Q3d9gEgzpkxYz0IGhizgZtPxpMQBvwH
# gfqL2vmCSfdibqFT+hKUGIUukpHqaGxEMrJmoecYpJpkUe8wggVVMIIEPaADAgEC
# AhAM7NF1d7OBuRMX7VCjxmCvMA0GCSqGSIb3DQEBCwUAMHIxCzAJBgNVBAYTAlVT
# MRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5j
# b20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBDb2RlIFNpZ25p
# bmcgQ0EwHhcNMjAwNjE0MDAwMDAwWhcNMjMwNjE5MTIwMDAwWjCBkTELMAkGA1UE
# BhMCQVUxGDAWBgNVBAgTD05ldyBTb3V0aCBXYWxlczEUMBIGA1UEBxMLQ2hlcnJ5
# YnJvb2sxGjAYBgNVBAoTEURhcnJlbiBKIFJvYmluc29uMRowGAYDVQQLExFEYXJy
# ZW4gSiBSb2JpbnNvbjEaMBgGA1UEAxMRRGFycmVuIEogUm9iaW5zb24wggEiMA0G
# CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDCPs8uaOSScUDQwhtE/BxPUnBT/FRn
# pQUzLoBTKW0YSKAxUbEURehXJuNBfAj2GGnMOHaB3EvdbxXl1NfLOo3wtRdro04O
# MjOH56Al/9+Rc6DNY48Pl9Ogvuabglah+5oDC/YOYjZS2C9AbBGGRTFjeGHT4w0N
# LLPbxyoTF/wfqZNNy5p+C7823gDR12OvWFgEdTiDnVkn3phxGy8xlK7yrJwFQ0Sn
# z8RknEFSaoKnuYqLvaOiOSG77q6M4+LbGAbwhYToaqWa4xWFFJS8XsX0+t6LA+0a
# Kb3ZEb1GyfySDW2TFf/V1RhuM4iBc6YTUUCj9BTqcpWKgkw2k2xUQHP9AgMBAAGj
# ggHFMIIBwTAfBgNVHSMEGDAWgBRaxLl7KgqjpepxA8Bg+S32ZXUOWDAdBgNVHQ4E
# FgQU6HpAuSSJdceLWep4ajN6JIQcAOgwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQM
# MAoGCCsGAQUFBwMDMHcGA1UdHwRwMG4wNaAzoDGGL2h0dHA6Ly9jcmwzLmRpZ2lj
# ZXJ0LmNvbS9zaGEyLWFzc3VyZWQtY3MtZzEuY3JsMDWgM6Axhi9odHRwOi8vY3Js
# NC5kaWdpY2VydC5jb20vc2hhMi1hc3N1cmVkLWNzLWcxLmNybDBMBgNVHSAERTBD
# MDcGCWCGSAGG/WwDATAqMCgGCCsGAQUFBwIBFhxodHRwczovL3d3dy5kaWdpY2Vy
# dC5jb20vQ1BTMAgGBmeBDAEEATCBhAYIKwYBBQUHAQEEeDB2MCQGCCsGAQUFBzAB
# hhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wTgYIKwYBBQUHMAKGQmh0dHA6Ly9j
# YWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFNIQTJBc3N1cmVkSURDb2RlU2ln
# bmluZ0NBLmNydDAMBgNVHRMBAf8EAjAAMA0GCSqGSIb3DQEBCwUAA4IBAQA1agcO
# M3seD1Cs5pnHRXwwrhzieRgF4UMJgDI/9KrBh4C0o8DsXvaa+YlXoTdhmeKW/xv5
# i9mkVNmvD3wa3AKe5CNwiPc5kx96lC7BXWfdLoY7ejfTGkoa7qHR3gusmQhuZW+L
# dFmvtTyu4eqcjhOBthoJYp3B8tv8JR99pSxFfsE6C4VGdhKHAmZkDMiaAHHava9Z
# xl4+Uof+TuS6lQBZJjw8Xw76W93DNU9JUNb4+hOp8jir1q7/RTvtQ3QWr+iEzJD8
# JRfvfXF4LpFvlOOWYOF22EU/ciGjUVfQYi7nk/LnHzipb46747K1BwAVnHbYMDx0
# BRtLc/s4g9qZxTrxMYIENzCCBDMCAQEwgYYwcjELMAkGA1UEBhMCVVMxFTATBgNV
# BAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTExMC8G
# A1UEAxMoRGlnaUNlcnQgU0hBMiBBc3N1cmVkIElEIENvZGUgU2lnbmluZyBDQQIQ
# DOzRdXezgbkTF+1Qo8ZgrzAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAig
# AoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgEL
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQU5ohr2lQC+MJ6D+9PJCTw
# oa5A5QYwDQYJKoZIhvcNAQEBBQAEggEAYXBdWbEUHVt6lj8mH4o3Ldm9ZjLixBEL
# ngm/VjtlyXBkby9uWHOkvWrRc1Y5jh7VdlqQyrEgaElQVF7CoGE/FoU6pOLERAt7
# idLgQRjcM5fwknLFfneV7dV+xfxt5ywU0HaCufPDHSP9UjgCzXZYxtC1Duk1+tub
# oyQ1H2lihufb15ECn0O4YHuaZDfwrrRH3/8JZ6Ma6GdX2IRqdMhHW+azciOXznvN
# o13z+TPPKtSY9+nfRjd/l+3eAlbulZoEu3iMYml6IYfqhlJeWXdJXpll50hT+rsB
# aVZFl/xf3nn/BmAkI/VrnLBDo2rmk8uuN7ncWGGDyMWMwjqV6GnIK6GCAgswggIH
# BgkqhkiG9w0BCQYxggH4MIIB9AIBATByMF4xCzAJBgNVBAYTAlVTMR0wGwYDVQQK
# ExRTeW1hbnRlYyBDb3Jwb3JhdGlvbjEwMC4GA1UEAxMnU3ltYW50ZWMgVGltZSBT
# dGFtcGluZyBTZXJ2aWNlcyBDQSAtIEcyAhAOz/Q4yP6/NW4E2GqYGxpQMAkGBSsO
# AwIaBQCgXTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEP
# Fw0yMDA4MTMwMTE2NDZaMCMGCSqGSIb3DQEJBDEWBBR0fQTxDBCyd5/oYlfPQPpO
# ij046TANBgkqhkiG9w0BAQEFAASCAQCTAPW3odciffQNi8aKpSifJ0omxJR3xcds
# RKRzsDUz07wolb9tTKPGS/5tN0YU5hFP4cHkWxy16C5ocHHF4SZ0xe1oj5q8Rju1
# oms2JYTOuY2UmGUyhID1uf/RMVKUfj/D2AC0VcxXPMyNjhNoSIQa/9S5tSYfL114
# ki+IgxWYCg1xXgDjbAEK/HTv/9R9lOt5Ff0GBDoo16lE8yr0ztJw2HH9pykzALnE
# IbFhFqW7zQrY2glstGpQMeZZF2soLoxLAbf6YVhz5J9iv/LFob+Kkns3EWulDd90
# KFGgehMNbvIpkNdh31VaqGiao5JLMRWKWb7rnDdtpp+Gc1LBubYf
# SIG # End signature block
