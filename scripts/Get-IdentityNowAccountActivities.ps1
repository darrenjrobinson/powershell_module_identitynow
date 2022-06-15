function Get-IdentityNowAccountActivities {
    <#
.SYNOPSIS
    Get IdentityNow Activities.    

.DESCRIPTION
    Get IdentityNow Activities.
    See https://community.sailpoint.com/t5/IdentityNow-Wiki/IdentityNow-REST-API-List-Account-Activities/ta-p/72189

.PARAMETER requestedFor
    (optional - ID) ID of identity that the activity was requested for

.PARAMETER requestedBy
    (optional - ID) The identity that requested the activity

.PARAMETER type
    (optional) The type of account activity e.g "Identity Refresh", "AccountAttributeUpdate", "CloudPasswordRequest", "appRequest", "AccountStateUpdate"

.PARAMETER searchLimit
    (optional - default 250) number of results to return

.EXAMPLE
    Get-IdentityNowAccountActivities -type appRequest -searchLimit 50

.EXAMPLE
    $user = Search-IdentityNowUsers -query "@accounts(accountId:darren.robinson)"    
    Get-IdentityNowAccountActivities -requestedFor $user.id

.EXAMPLE
    $user = Search-IdentityNowUsers -query "@accounts(accountId:darren.robinson)"
    $mgr = Search-IdentityNowUsers -query "@accounts(accountId:rick.sanchez)"
    Get-IdentityNowAccountActivities -requestedFor $user.id -requestedBy $mgr.id 

.EXAMPLE
    $user = Search-IdentityNowUsers -query "@accounts(accountId:darren.robinson)"
    Get-IdentityNowAccountActivities -regardingIdentity $user.id 

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$requestedBy,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$requestedFor,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$regardingIdentity,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$type,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [int]$searchLimit = 250
    )

    $v3Token = Get-IdentityNowAuth
    
    if ($v3Token.access_token) {        
        try {   
            $accountActivities = @()
            if ($searchLimit -gt 250) {
                $iterations = $searchLimit / 250
                $offset = 250
                $limit = 250
                Write-Verbose "Iterations ====> $($iterations)"
            } else { 
                $limit = $searchLimit 
            }
            
            switch ($requestedBy, $requestedFor, $type, $searchLimit, $limit) {
                { $requestedFor } {
                    $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities?requested-for=$($requestedFor)&limit=$($limit)"
                    Write-Verbose "RequestedFor Case - https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities?limit=250"
                }
                { $requestedBy -and $requestedFor } {
                    $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities?requested-for=$($requestedFor)&requested-by=$($requestedBy)&limit=$($limit)"
                    Write-Verbose "RequestedBy and RequestedFor Case - https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities?limit=250"
                }
                { $requestedBy } {
                    $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities?requested-by=$($requestedBy)&limit=$($limit)"
                    Write-Verbose "RequestedBy Case - https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities?limit=250"
                }                        
                { $requestedFor -and $type} {
                    $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities?requested-for=$($requestedFor)&type=$($type)&limit=$($limit)"
                    Write-Verbose "RequestedFor and Type Case - https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities?requested-for=$($requestedFor)&type=$($type)&limit=$($limit)"
                }
                { $requestedBy -and $requestedFor -and $type} {
                    $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities?requested-for=$($requestedFor)&requested-by=$($requestedBy)&type=$($type)&limit=$($limit)"
                    Write-Verbose "RequestedBy and RequestedFor and Type Case - https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities?requested-for=$($requestedFor)&requested-by=$($requestedBy)&type=$($type)&limit=$($limit)"
                }
                { $requestedBy -and $type} {
                    $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities?requested-by=$($requestedBy)&type=$($type)&limit=$($limit)"
                    Write-Verbose "RequestedBy and Type Case - https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities?requested-by=$($requestedBy)&type=$($type)&limit=$($limit)"
                }           
                {$regardingIdentity} {
                    $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities?regarding-identity=$($regardingIdentity)&limit=$($limit)"
                    Write-Verbose "RegardingIdentity Case - https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities?regarding-identity=$($regardingIdentity)&limit=$($limit)"
                }
                {$regardingIdentity -and $type} {
                    $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities?regarding-identity=$($regardingIdentity)&type=$($type)&limit=$($limit)"
                    Write-Verbose "RegardingIdentity and Type Case - https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities?regarding-identity=$($regardingIdentity)&type=$($type)&limit=$($limit)"
                }
                { $type } {
                    $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities?type=$($type)&limit=$($limit)"
                    Write-Verbose "Type Case - https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities?limit=250"
                }
                default {
                    $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities?limit=250"
                    Write-Verbose "Default Case - https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities?limit=250"
                }
            }

            $loop = 0
            if ($iterations -gt 1) {
                # Get First
                $results = Invoke-RestMethod -Method Get -URI $searchURLBase -Headers @{Authorization = "Bearer $($v3Token.access_token)"; "Content-Type" = "application/json" }
                $loop++
                Write-Verbose "Iteration ===> $($loop)"

                if ($results) {
                    $accountActivities += $results
                }
                # Get Rest 
                do {
                    if (($searchLimit - $offset) -gt 250) {  
                        Write-Verbose "Iteration ===> $($loop)"
                        $results = Invoke-RestMethod -Method Get -Uri "$($searchURLBase)&offset=$($offset)" -Headers @{Authorization = "Bearer $($v3Token.access_token)"; "Content-Type" = "application/json" }  
                        $loop++
                        $offset += $results.count 
                        if ($results) {
                            $accountActivities += $results
                        }
                        else {
                            break 
                        }
                    }
                    else {
                        $limitCount = ($searchLimit - $accountActivities.count)
                        $searchURL = $searchURLBase.Replace("limit=250", "limit=$($limitCount)")
                        $results = Invoke-RestMethod -Method Get -Uri "$($searchURL)&offset=$($offset)" -Headers @{Authorization = "Bearer $($v3Token.access_token)"; "Content-Type" = "application/json" } 
                        if ($results) {
                            $accountActivities += $results
                        }
                        else {
                            break 
                        }
                        Write-Verbose "Iteration ===> $($loop)"
                        $loop++
                    }
                } until (($loop -gt $iterations))
            }
            else {
                # Get full set (<250)
                $results = Invoke-RestMethod -Method Get -Uri $searchURLBase -Headers @{Authorization = "Bearer $($v3Token.access_token)"; "Content-Type" = "application/json" }                                                 
                $loop++
                Write-Verbose "Iteration ===> $($loop)"

                if ($results) {
                    $accountActivities += $results                    
                }
            }
            return $accountActivities
        }
        catch {
            Write-Error "Account Activities not found? $($_)" 
        }
    }
}

# SIG # Begin signature block
# MIIX8wYJKoZIhvcNAQcCoIIX5DCCF+ACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUXEq+B94T9isuUe2Mq+7BeUro
# UzKgghMmMIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUY5dOLu4j/LO0r1/UJUbz
# ARd3C5cwDQYJKoZIhvcNAQEBBQAEggEAkELeNzVODX1Gghviqga2YTa8voKoJr6G
# tpD+sdNVBu4zIwchs4AFZac7apORyeWEjo/m8tzeuRxM+rFgVwiVDYfAv1nRWfYl
# 2aMzFQ2L/lxX8cb0AAmRwQz0WFe89Cg8qqv1w2EkrwqFIwvZqM5E+rb3hJqp704X
# rr2BL6IOZ5Gb3ee3B5p5QsNBbkgjp487jVd3GAu45sE5ajU22nkLY01JTxvQ6WL0
# 0CpQ86bo5w4e+3tEof7ANU5GqfSbzEcy1rs3JXDmoxEy4OW8/utWa8JiZeXHijJR
# 0IZmHBH6GVOE9XzwnJ2N0oNcrHDOOZxaShEZTy4f0Diwu8s3LjF/xaGCAgswggIH
# BgkqhkiG9w0BCQYxggH4MIIB9AIBATByMF4xCzAJBgNVBAYTAlVTMR0wGwYDVQQK
# ExRTeW1hbnRlYyBDb3Jwb3JhdGlvbjEwMC4GA1UEAxMnU3ltYW50ZWMgVGltZSBT
# dGFtcGluZyBTZXJ2aWNlcyBDQSAtIEcyAhAOz/Q4yP6/NW4E2GqYGxpQMAkGBSsO
# AwIaBQCgXTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEP
# Fw0yMDA2MTUwMjAyMzFaMCMGCSqGSIb3DQEJBDEWBBQ+YduzX7D2qsUWjWocWuks
# fnCe4jANBgkqhkiG9w0BAQEFAASCAQBFsiBWP0X+lHnGvcBUz33L+VWU04mIqK+P
# yE1na/8UHF5rl4qO5CaQfgtEALPJDMJmSu1Tx4ZIkzMPsKHOrxGPRhQNuR9GgPyZ
# l3aKXFl2YXGElNTt8VGeDxnUpZDJFHD3SYqYP6P2bxkIYj7df67rd0vqUjL0vZsr
# CxkO4hrCDb2nbVPG6KGAreBRB0DR45I+lpXuejkY7HUvjd+hZc1q8wLclQUpHOFj
# 8fQcsM/djGHBmdBBpddGq9IoheYVzTootaHEXcy2A2xW+QZhLmyOOEl24CCq2XJ5
# MTd4UgBfo+rBa9clPH7vcsrH/AB5wt80aUK3L87KL+5urHu5w84U
# SIG # End signature block
