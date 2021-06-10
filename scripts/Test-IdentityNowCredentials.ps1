function Test-IdentityNowCredentials {
    <#
.SYNOPSIS
    Tests IdentityNow Live credentials.

.DESCRIPTION
    Test APIv3, APIv2 and Personal Access Token credentials.

.NOTES
    written by Sean McGovern 11/27/2019 (twitter @410sean)
    updated by Darren Robinson 6 Aug 2020

.EXAMPLE
    Test-IdentityNowCredentials

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow
#>

    [cmdletbinding()]
    param ( )
   
    # try {
    #     if ($IdentityNowConfiguration.v2) {            
    #         $profileList = Invoke-IdentityNowRequest -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/profile/list" -headers Headersv2_JSON 
    #         Write-Verbose "v2 Output: $($profileList)"
    #         "Validated APIv2 credentials."
    #     }
    #     else {
    #         "APIv2 credentials not stored in IdentityNow Configuration."
    #     }
    # }
    # catch {
    #     write-warning "Testing APIv2 credentials failed for $($IdentityNowConfiguration.orgName)."
    #     Write-Warning $_
    # }

    try {    
        if ($IdentityNowConfiguration.v3) { 
            $lowusersource = (Get-IdentityNowSource | Where-Object { $_.usercount -ne 0 } | Sort-Object usercount)[0]
            Write-Verbose "v3 Output: $($lowusersource)"
            "Validated APIv3 credentials."
        }
        else {
            "APIv3 credentials not stored in IdentityNow Configuration."
        }
    }
    catch {
        write-warning "Testing APIv3 credentials failed for $($IdentityNowConfiguration.orgName). Unable to continue."
        Write-Warning $_
    }
    
    try {    
        if ($IdentityNowConfiguration.PAT) { 
            try {
                # oAuth URI
                $oAuthURI = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/oauth/token" 

                $oAuthTokenBody = @{
                    grant_type    = "client_credentials"
                    client_id     = $IdentityNowConfiguration.PAT.UserName
                    client_secret = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($IdentityNowConfiguration.PAT.Password))
                }
            
                $v3PAT = Invoke-RestMethod -Uri $oAuthURI -Method Post -Body $oAuthTokenBody 
                if ($v3PAT) {
                    $requestHeaders = @{Authorization = "Bearer $($v3PAT.access_token)" }
                    $idnProfiles = $null 
                    $idnProfiles = Invoke-RestMethod -Method Get `
                        -Uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/profile/list" `
                        -Headers $requestHeaders  
                    if ($idnProfiles) {
                        "Validated Personal Access Token."
                    }
                    else {
                        "FAILED. Request using IdentityNow Personal Access Token failed."
                    }
                }
            }
            catch {
                "Unable to obtain an Access Token using the configured Personal Access Token."
            }
        }
        else {
            "Personal Access Token not stored in IdentityNow Configuration."
        }
    }
    catch {
        write-warning "Testing Personal Access Token credential failed for $($IdentityNowConfiguration.orgName). Unable to continue."
        Write-Warning $_
    }
}

# SIG # Begin signature block
# MIINSwYJKoZIhvcNAQcCoIINPDCCDTgCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUTcehXSbNY7fdYP1Z8vMQrzGm
# +SGgggqNMIIFMDCCBBigAwIBAgIQBAkYG1/Vu2Z1U0O1b5VQCDANBgkqhkiG9w0B
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
# BAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFF2s7mrynZ2A
# W6zz16mNNb8c8dboMA0GCSqGSIb3DQEBAQUABIIBAJWmQRdHdqXq9XGAjPJCz+gT
# E43mXZfw7GGqxAC2w3pcuiRhiSUHkdbLPkEhgMrjwMKR3uDZDyYIR/f04sVGNfFi
# YX+NyMCr/VxpgDhtT9epnqOqv5pV/8VQfgGXDftWEQPhGOxZj0V/OHRsJ3Cz5V7I
# s8PBu5hyqx6vUOmD9inr5QecEp3PUuY3Pm8uqfWgriSRyVhHbaXcb5/gYY3MxLEV
# A31O3E76tV0shTywyLm+fpNU2QYTsm0jRPTgSb9YCUCMGAVZm0BXYgL2FU4VdtIl
# r9ekGmTVIzau0/Fm/N7n08X7pAKv9MZoWys9BfiR6+P8eXiZYow+IYvn//EqlB4=
# SIG # End signature block
