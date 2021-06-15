function Update-IdentityNowProfileMapping {
    <#
.SYNOPSIS
Update IdentityNow Profile Attribute Mapping.

.DESCRIPTION
Update IdentityNow Profile Attribute Mapping.

.PARAMETER ID
(required) ID of the Identity Profile to update

.PARAMETER IdentityAttribute
(required) Priority value for the Identity Profile

.PARAMETER sourceType
(required) specify Null to clear the mapping, complex for setting a rule, or Standard for account attribute or account attribute with transform

.PARAMETER source
not needed for null
for account attribute specify source:accountAttribute or as a two part array
for transform specify source:accountAttribute:transform or as a three part array
for complex provide the name of the rule

.EXAMPLE
Update-IdentityNowProfileMapping -id 1285 -IdentityAttribute uid -sourceType Standard -source 'AD:SamAccountName'

.EXAMPLE
Update-IdentityNowProfileMapping -id 1285 -IdentityAttribute uid -sourceType Standard -source @('AD','SamAccountName','transform-UID')

.EXAMPLE
Update-IdentityNowProfileMapping -id 1285 -IdentityAttribute uid -sourceType Null

.EXAMPLE
Update-IdentityNowProfileMapping -id 1285 -IdentityAttribute managerDn -sourceType Complex -source 'Rule - IdentityAttribute - Get Manager'

.EXAMPLE
$idp = Get-IdentityNowProfile
$source = @('AD','samAccountName','Transform-UID')
$idp.id | foreach {Update-IdentityNowProfileMapping -ID $_ -IdentityAttribute uid -sourceType Standard -source $source; Start-IdentityNowProfileUserRefresh -id $_}

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param( 
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$ID,
        [Parameter(Mandatory = $true)]
        [string]$IdentityAttribute,
        [Parameter(Mandatory = $true)]
        [validateset('Null', 'Standard', 'Complex')][string]$sourceType,
        $source
        
    )

    $v3Token = Get-IdentityNowAuth

    if ($v3Token.access_token) {
        try {
            $updateProfile = Get-IdentityNowProfile -ID $id
            switch ($sourceType) {
                Null { $mapping = $null }
                Standard {
                    $source = $source.Split(':')
                    $idnsource = Get-IdentityNowSource
                    $idnsource = $idnsource.where{ $_.name -eq $source[0] }[0]
                    if ($idnsource.count -ne 1) { Write-Error "Problem getting source '$($source[0])'"; exit }
                    $attributes = [pscustomobject]@{
                        applicationId   = $idnsource.externalId
                        applicationName = $idnsource.health.name
                        attributeName   = $source[1]
                        sourceName      = $idnsource.name
                    }
                    $mapping = [pscustomobject]@{
                        attributeName = $IdentityAttribute
                        attributes    = $null
                        type          = $null
                    }
                    switch ($source.count) {
                        2 {
                            $mapping.type = 'accountAttribute'
                            $mapping.attributes = $attributes
                        }
                        3 {
                            $mapping.type = 'reference'
                            $mapping.attributes = [pscustomobject]@{
                                id    = $source[2]
                                input = [pscustomobject]@{
                                    attributes = $attributes
                                }
                            }
                        }
                        default {
                            write-error "unable to get two or three items from source parameter $($_)"
                            quit
                        }
                    }

                }
                Complex {
                    $idnrule = Get-IdentityNowRule -ID $source
                    $rule = [pscustomobject]@{
                        id   = $idnrule.id
                        name = $idnrule.name
                    }
                    $mapping = [pscustomobject]@{
                        attributeName = $IdentityAttribute
                        attributes    = $rule
                        type          = 'rule'
                    }
                    if ($idnrule -eq $null) { Write-Error "rule $source not found"; exit }
                }
            }
            $body = [pscustomobject]@{
                id              = $id
                attributeConfig = $updateprofile.attributeConfig
            }
            if ($mapping) {
                if ($body.attributeConfig.attributeTransforms.attributename -contains $IdentityAttribute) {
                    $index = $body.attributeConfig.attributeTransforms.attributename.IndexOf($IdentityAttribute)
                    $body.attributeConfig.attributeTransforms[$index] = $mapping
                }
                else {
                    $body.attributeConfig.attributeTransforms += $mapping
                }
            }
            else {
                $index = $body.attributeConfig.attributeTransforms.attributename.IndexOf($IdentityAttribute)
                if ($index -ne -1) {
                    $body.attributeConfig.attributeTransforms = $body.attributeConfig.attributeTransforms.where{ $_.attributename -ne $identityattribute }
                }
            }
            
            $url = "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/profile/update/$($ID)"
            $response = (Invoke-WebRequest -Uri $url -Method Post -UseBasicParsing -Body ($body | convertto-json -depth 100) -ContentType 'application/json' -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }).Content | ConvertFrom-Json 
            return $response
        }
        catch {
            Write-Error "update failed $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}


# SIG # Begin signature block
# MIINSwYJKoZIhvcNAQcCoIINPDCCDTgCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUfDRwd4UrgIJ5GoFmUWq5C0HF
# NjigggqNMIIFMDCCBBigAwIBAgIQBAkYG1/Vu2Z1U0O1b5VQCDANBgkqhkiG9w0B
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
# BAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFFL+I4L2hxzB
# UDg9aqtEd9/OwhZYMA0GCSqGSIb3DQEBAQUABIIBAIRr5ROaublFNtLRCW1wbxb2
# 2kKGXSLfH/2BT29/UOiYvv+C2FqQyKT14PUAdXeQUETuZ6PnfNNVo08k9SCH6cvy
# I8gdjhqQQiN9QSWp07zIHDnhthkV3kh8Mv4D7gIFaQ4RpnuKT+Ura+bv6Wqe5DmV
# XlBvtwaySk0ynQrPWp/Y6lXUFi0/LzsHAp5hs8lnWj1HP60OrsBgBYzRyfnKfsgo
# csndLkFKSwynhVBP4gslAWOygB79OGobylUsrz0gB2bpmkvGaQjh4y7TcoVHvg6T
# 0V4Wqsmz5Z3Eqthj27tMe77WSem9V/RbFOkC6ViejykMEVKLY3cHRTllG+PRtlA=
# SIG # End signature block
