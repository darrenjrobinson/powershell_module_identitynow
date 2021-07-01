function Get-IdentityNowCertCampaignReport {
    <#
.SYNOPSIS
    Get IdentityNow Certification Campaign Report(s).

.DESCRIPTION
    Get IdentityNow Certification Campaign Report(s).
    Output CSV Reports to file system or return reports as PS Object
    NOTE: Reports are generated on first request. If reports not returned retry after 60 seconds    

.PARAMETER campaignID
    An IdentityNow Certification Campaign Report(s).

.PARAMETER outputPath
    (optional) Report Output Path
    e.g c:\reports
    If omitted CSV Reports returned as PowerShell Object

.EXAMPLE
    Get-IdentityNowCertCampaignReport -period 365

.EXAMPLE
    Get-IdentityNowCertCampaignReport -period 365 -completed $false

.EXAMPLE
    Get-IdentityNowCertCampaignReport -campaignID '2c918085694a507f01694b9fcce6002f' 

.EXAMPLE
    Get-IdentityNowCertCampaignReport -campaignID '2c918085694a507f01694b9fcce6002f' -outputPath "c:\Reports"

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$campaignID,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$outputPath,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$period,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [boolean]$completed = $true
    )
    
    $v3Token = Get-IdentityNowAuth 
    $utime = [int][double]::Parse((Get-Date -UFormat %s))

    $ReportTemplate = [pscustomobject][ordered]@{ 
        ReportName = $null 
        Report     = $null 
    } 

    if ($v3Token.access_token) {
        # Encoded v3 Auth required to get the Reports
        $clientSecretv3 = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($IdentityNowConfiguration.v3.Password))
        # Basic Auth
        $Bytesv3 = [System.Text.Encoding]::utf8.GetBytes("$($IdentityNowConfiguration.v3.UserName):$($clientSecretv3)")
        $encodedAuthv3 = [Convert]::ToBase64String($Bytesv3)

        try {            
            if (!$campaignID) {           
                $IDNCertCampaigns = Get-IdentityNowCertCampaign -completed $completed 
                if ($IDNCertCampaigns) {
                    foreach ($campaign in $IDNCertCampaigns) {
                        # Get time of completion of the Campaign
                        $unixtime = $null 
                        [string]$unixtime = $campaign.deadline
                        $unixtime = $unixtime.Substring(0, 10)        
                        $time = [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($unixtime))

                        if ($time -gt (get-date).AddDays( - $($period))) {
                            $utime = [int][double]::Parse((Get-Date -UFormat %s))
                            $campaignReports = $null     
                            $campaignReports = Invoke-IdentityNowRequest -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/campaign/getReports?_dc=$($utime)&campaignId=$($campaign.id)&page=1&start=0&limit=50&sort=%5B%7B%22property%22%3A%22name%22%2C%22direction%22%3A%22ASC%22%7D%5D" -Headers HeadersV3
                            $reportsOut = @()
                            foreach ($report in $campaignReports) {                    
                                if ($outputPath) {
                                    if ($report.name.Equals("Campaign Status Report")) { $outputFile = "$($outputPath)\$($campaign.description) - StatusReport.csv" }
                                    if ($report.name.Equals("Campaign Remediation Status Report")) { $outputFile = "$($outputPath)\$($campaign.description) - RemediationReport.csv" }
                                    if ($report.name.Equals("Certification Signoff Report")) { $outputFile = "$($outputPath)\$($campaign.description) - SignoffReport.csv" }
                                    if ($report.name.Equals("Campaign Composition Report")) { $outputFile = "$($outputPath)\$($campaign.description) - CompositionReport.csv" }
                                }
                                # Get CSV Report                                
                                $reportDetails = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/report/get/$($report.taskResultId)?format=csv&name=Export+Campaign+Status+Report&url_signature=$($encodedAuthv3)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }                                    

                                if ($outputPath) {
                                    # Output Report to filesystem
                                    $reportDetails | out-file $outputFile                                    
                                }
                                else {
                                    $r = $ReportTemplate.PsObject.Copy()
                                    $r.ReportName = $report.name
                                    $r.Report = $reportDetails | convertfrom-csv 
                                    $reportsOut += $r
                                }
                            }
                            if (-not($outputPath)) { return $reportsOut }
                        }
                    }
                }
                else {
                    write-error "No Certification Campaigns retreived. $($_)"
                }
            }
            else {           
                $utime = [int][double]::Parse((Get-Date -UFormat %s))
                $campaignReports = $null     
                $campaignReports = Invoke-IdentityNowRequest -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/campaign/getReports?_dc=$($utime)&campaignId=$($campaignID)&page=1&start=0&limit=50&sort=%5B%7B%22property%22%3A%22name%22%2C%22direction%22%3A%22ASC%22%7D%5D" -Headers HeadersV3 
                    
                if ($campaignReports.count -gt 0) {
                    $reportsOut = @()
                    foreach ($report in $campaignReports) {                    
                        if ($outputPath) {
                            if ($report.name.Equals("Campaign Status Report")) { $outputFile = "$($outputPath)\$($campaign.displayName) - StatusReport.csv" }
                            if ($report.name.Equals("Campaign Remediation Status Report")) { $outputFile = "$($outputPath)\$($campaign.displayName) - RemediationReport.csv" }
                            if ($report.name.Equals("Certification Signoff Report")) { $outputFile = "$($outputPath)\$($campaign.displayName) - SignoffReport.csv" }
                            if ($report.name.Equals("Campaign Composition Report")) { $outputFile = "$($outputPath)\$($campaign.displayName) - CompositionReport.csv" }
                        }
                        
                        # Get CSV Report
                        $reportDetails = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/report/get/$($report.taskResultId)?format=csv&name=Export+Campaign+Status+Report&url_signature=$($encodedAuthv3)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }                                    
                        if ($outputPath) {
                            # Output Report to filesystem
                            $reportDetails | out-file $outputFile                                    
                        }
                        else {
                            $r = $ReportTemplate.PsObject.Copy()
                            $r.ReportName = $report.name
                            $r.Report = $reportDetails | convertfrom-csv 
                            $reportsOut += $r
                        }                                 
                    }
                    if (-not($outputPath)) { return $reportsOut }
                }
                else {
                    Write-Error "Certification Campaign with ID '$($campaignID)'not found."
                }
            }
        }
        catch {
            Write-Error "Failed to retrieve Certifcation Campaigns. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    }
}

# SIG # Begin signature block
# MIIX8wYJKoZIhvcNAQcCoIIX5DCCF+ACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUY0fI6ee/8cLUrXEbbs6b6JkI
# fNagghMmMIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUH09tscPJbUzvN/icyZ2C
# POFpL2YwDQYJKoZIhvcNAQEBBQAEggEAcS1ma6F4RyxvIsJktL6FimPSkQF/iAJF
# UafOiS3XzADbsb0ajtuDpeLZLsGr6bMLMCEYWhzQ4P9WbQDnyh7uoxQckkWDN9MA
# uPsMPROl4ZPDBXxnp3QBIkywha+rlRfaF4HtN4ZaLVOWULVGivKFwPBjcTPjlkeL
# 3x1TVuqyKL44ZE+FfoXuX608lcnsi+r3bwx+JA+azpCsUOcYOaS+5UcqjxiyPMPg
# /k0D4u4MPe1++pRuZ7EVEud6dDMpdP+Ou40qHcsUBOTQzG1kcQhlMVfYAxU8w1gA
# dr4mkQwpF0kgoSXu07tGOh3VmETux7fof4XgrxJ3RJ1HFaDb80dXJaGCAgswggIH
# BgkqhkiG9w0BCQYxggH4MIIB9AIBATByMF4xCzAJBgNVBAYTAlVTMR0wGwYDVQQK
# ExRTeW1hbnRlYyBDb3Jwb3JhdGlvbjEwMC4GA1UEAxMnU3ltYW50ZWMgVGltZSBT
# dGFtcGluZyBTZXJ2aWNlcyBDQSAtIEcyAhAOz/Q4yP6/NW4E2GqYGxpQMAkGBSsO
# AwIaBQCgXTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEP
# Fw0yMDA2MTUwMjAyMzNaMCMGCSqGSIb3DQEJBDEWBBTcYSULnRUWXqrd9RKTNY0W
# 6vpc5DANBgkqhkiG9w0BAQEFAASCAQBz8sHAK63JiiaDBVdqpfPxSxN+qH02Iozj
# KRqsJ3n6vg8S+EtoOJC0d2UrBAo/iimPsGpclxlL/AsVYDCuvUXMLbE4EVPyPWqA
# Xl6GjRi9E5DT0BIXsIw4ntF6PTcucyHKV7BBSLaz5jByj1qoA3Y3OWHmQ5KZlJwF
# wYMnhAqOIFJISNDVcA7to+0kNKWya6uAKtbJvM8Ab9aYtHsU1jE/QeNZ1UxFFYuW
# aUHr78ItV3LzMhY+GWBV584Z6ztMzAskRRfD968LB9cVsn/lLam+nB/qyV/mzCIJ
# BocVV4cj1GigjpMzIGK7LYvxtzFqSXmYIo4X+F6efZmY86W0U7ci
# SIG # End signature block
