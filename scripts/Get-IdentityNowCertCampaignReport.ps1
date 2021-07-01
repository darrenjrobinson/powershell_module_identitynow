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
# MIINSwYJKoZIhvcNAQcCoIINPDCCDTgCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUankT9YekiHYnd5qqAGWuUo5w
# 1J6gggqNMIIFMDCCBBigAwIBAgIQBAkYG1/Vu2Z1U0O1b5VQCDANBgkqhkiG9w0B
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
# BAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFGYFNbHqprqS
# yG9EQtaLfYrUYd4PMA0GCSqGSIb3DQEBAQUABIIBAHMDt48eX7uhnuqFSRlxYBEt
# zAs0g1ZiMM1JOeH86STkC4/0JCocZB17AqBtDt7tqOk3oQC4tyajXq6No4AncbmT
# nV9X5KNaHgWkJfJba9bLxJt2AxplBD9J74v1lQAuRVFWq1DwJxFkVGZAMrs/YF8l
# ewRL//+fquXpXrylqnoadJZ4h3IPDSJJls7gTu86Va779sa7wteBBeKL7folLYsF
# dT2qHUmgEo3s8mFTwDxWgRQ5GxpJDiZxEU5wklrOOCKiMPDVv7UYjYKTurhvTEin
# SVyymC1Tu8fvfxiVYIyFaW4JrzfXph+WkOkdFke6I0vn3uoWtIQVrxoLjArFJe0=
# SIG # End signature block
