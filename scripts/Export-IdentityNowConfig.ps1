function Export-IdentityNowConfig {
    <#
.SYNOPSIS
    Export IdentityNow configuration items

.DESCRIPTION
    Exports IdentityNow Access Profiles, APIClients, Applications, Cert Campaigns, Email Templates, Governance Groups, Identity Attributes, Identity Profiles, OAuth API Clients, Roles, Rules, Sources, Transforms, VAClusters, to files to make comparisons or check into source control

.PARAMETER path
    (Required - string) folder path to export configuration items

.PARAMETER Items
    (optional - custom list array) if not specified, all items will be assumed, if specified you can list all items to be exported

.EXAMPLE
    Export-IdentityNowConfig -path 'c:\repos\IDN-Prod'

.EXAMPLE
    Export-IdentityNowConfig -path 'c:\repos\IDN-Prod' -Items Rules,Roles

.EXAMPLE
    Set-IdentityNowOrg myCompanyProd
    Export-IdentityNowConfig -path "C:\repos\IDNConfig\$((Get-IdentityNowOrg).'Organisation Name')" 
    Set-IdentityNowOrg myCompanySandbox
    Export-IdentityNowConfig -path "C:\repos\IDNConfig\$((Get-IdentityNowOrg).'Organisation Name')"

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$path,
        [ValidateSet('AccessProfile', 'APIClients', 'Applications', 'CertCampaigns', 'EmailTemplates', 'GovernanceGroups', 'IdentityAttributes', 'IdentityProfiles', 'OAuthAPIClients', 'Roles', 'Rules', 'Sources', 'Transforms', 'VAClusters')]
        [string[]]$Items
    )

    if ($PSVersionTable.PSVersion.Major -le 5) { 
        $outputpath = Get-ItemProperty -Path $path 
        if ($outputpath.mode -ne 'd-----') { Write-Error "provided path is not a directory: $outputpath"; break }
    }
    elseif ($PSVersionTable.PSVersion.Major -gt 5) { 
        [System.IO.FileInfo]$outputpath = $path
        if ($outputpath.mode -ne 'd----') { Write-Error "provided path is not a directory: $outputpath"; break }
    }
    
    if ($null -eq $Items) {
        $Items = @('AccessProfile', 'APIClients', 'Applications', 'CertCampaigns', 'EmailTemplates', 'GovernanceGroups', 'IdentityAttributes', 'IdentityProfiles', 'OAuthAPIClients', 'Roles', 'Rules', 'Sources', 'Transforms', 'VAClusters')
    }
    if ($outputpath.fullname.lastindexof('\') -eq $outputpath.fullname.length - 1) { [System.IO.FileInfo]$outputpath = $outputpath.FullName.Substring(0, $outputpath.FullName.length - 1) }
    if ($Items -contains 'AccessProfile') {
        write-progress -activity 'AccessProfile'
        $AccessProfile = Get-IdentityNowAccessProfile
        $AccessProfile | convertto-json -depth 10 | Set-Content "$($outputpath.FullName)\AccessProfile.json"
    }
    if ($Items -contains 'APIClients') {
        write-progress -activity 'APIClients'
        $APIClients = Get-IdentityNowAPIClient
        $detailedAPIClients = @()
        foreach ($client in $APIClients) {
            $client = Get-IdentityNowAPIClient -ID $client.id
            $detailedAPIClients += $client
        }
        $detailedAPIClients | convertto-json -depth 10 | Set-Content "$($outputpath.FullName)\APIClients.json"
    }
    if ($Items -contains 'Applications') {
        write-progress -activity 'Applications'
        $Applications = Get-IdentityNowApplication
        $detailedApplications = @()
        foreach ($app in $Applications) {
            $app = Get-IdentityNowApplication -appID $app.id
            $detailedApplications += $app
        }
        $detailedApplications | convertto-json -depth 10 | Set-Content "$($outputpath.FullName)\Applications.json"
    }
    if ($Items -contains 'CertCampaigns') {
        write-progress -activity 'CertCampaigns'
        $CertCampaigns = Get-IdentityNowCertCampaign
        $CertCampaigns | convertto-json -depth 10 | Set-Content "$($outputpath.FullName)\CertCampaigns.json"
    }
    if ($Items -contains 'EmailTemplates') {
        write-progress -activity 'EmailTemplates'
        $EmailTemplates = Get-IdentityNowEmailTemplate
        $EmailTemplates | convertto-json -depth 10 | Set-Content "$($outputpath.FullName)\EmailTemplates.json"
    }
    if ($Items -contains 'GovernanceGroups') {
        write-progress -activity 'GovernanceGroups'
        $GovernanceGroups = Get-IdentityNowGovernanceGroup
        $GovernanceGroups | convertto-json -depth 10 | Set-Content "$($outputpath.FullName)\GovernanceGroups.json"
    }
    if ($Items -contains 'IdentityAttributes') {
        write-progress -activity 'IdentityAttributes'
        $IdentityAttributes = Get-IdentityNowIdentityAttribute
        $IdentityAttributes | convertto-json -depth 10 | Set-Content "$($outputpath.FullName)\IdentityAttributes.json"
    }
    if ($Items -contains 'IdentityProfiles') {
        write-progress -activity 'IdentityProfiles'
        $idp = Get-IdentityNowProfile
        $detailedIDP = @()
        foreach ($profile in $idp) {
            $profile = Get-IdentityNowProfile -ID $profile.id
            $detailedIDP += $profile
        }
        $detailedIDP | convertto-json -depth 10 | Set-Content "$($outputpath.FullName)\IdentityProfiles.json"
    }
    if ($Items -contains 'OauthAPIClients') {
        write-progress -activity 'OauthAPIClients'
        $OauthAPIClients = Get-IdentityNowOAuthAPIClient
        $OauthAPIClients | convertto-json -depth 10 | Set-Content "$($outputpath.FullName)\OAuthAPIClients.json"
    }
    if ($Items -contains 'Roles') {
        write-progress -activity 'Roles'
        $roles = Get-IdentityNowRole
        $detailedroles = @()
        foreach ($role in $roles) {
            $temp = Get-IdentityNowRole -roleID $role.id
            $role | Add-Member -NotePropertyName selector -NotePropertyValue $temp.selector -Force
            $role | Add-Member -NotePropertyName approvalSchemes -NotePropertyValue $temp.approvalSchemes -Force
            $role | Add-Member -NotePropertyName deniedCommentsRequired -NotePropertyValue $temp.deniedCommentsRequired -Force
            $role | Add-Member -NotePropertyName identityCount -NotePropertyValue $temp.identityCount -Force
            $role | Add-Member -NotePropertyName revokeRequestApprovalSchemes -NotePropertyValue $temp.revokeRequestApprovalSchemes -Force
            $detailedroles += $role
        }
        $detailedroles | convertto-json -depth 10 | Set-Content "$($outputpath.FullName)\Roles.json"
    }
    if ($Items -contains 'Rules') {
        write-progress -activity 'Rules'
        $rules = Get-IdentityNowRule
        $rules | convertto-json -depth 10 | Set-Content "$($outputpath.FullName)\Rules.json"
    }
    if ($Items -contains 'Sources') {
        write-progress -activity 'Sources'
        $sources = Get-IdentityNowSource
        $detailedsources = @()
        foreach ($source in $sources) {
            Write-Verbose "$($source.name)($($source.id))"
            write-progress -activity "Sources" -status "$($source.name)($($source.id)) details"
            do {
                $temp = $null
                $temp = Get-IdentityNowSource -sourceID $source.id
                Start-Sleep -Milliseconds 100
            }until($null -ne $temp)
            $source = $temp
            Write-Verbose "getting account profiles"
            write-progress -activity "Sources" -status "$($source.name)($($source.id)) account profiles"
            $source | Add-Member -NotePropertyName 'accountProfiles' -NotePropertyValue (Get-IdentityNowSource -sourceID $source.id -accountProfiles) -Force
            Write-Verbose "getting schema"
            write-progress -activity "Sources" -status "$($source.name)($($source.id)) schema"
            $source | Add-Member -NotePropertyName 'Schema' -NotePropertyValue (Get-IdentityNowSourceSchema -sourceID $source.id) -Force
            $detailedsources += $source
        }
        $detailedsources | convertto-json -depth 10 | Set-Content "$($outputpath.FullName)\Sources.json"
    }    
    if ($Items -contains 'Transforms') {
        write-progress -activity 'Transforms'
        $transforms = Get-IdentityNowTransform
        $transforms | convertto-json -depth 10 | Set-Content "$($outputpath.FullName)\Transforms.json"
    }
    if ($Items -contains 'VAClusters') {
        write-progress -activity 'VAClusters'
        $VAClusters = Get-IdentityNowVACluster
        $VAClusters | convertto-json -depth 10 | Set-Content "$($outputpath.FullName)\VAClusters.json"
    }
}
# SIG # Begin signature block
# MIINSwYJKoZIhvcNAQcCoIINPDCCDTgCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUA6czXEby9kzQF3TloCytMven
# qYWgggqNMIIFMDCCBBigAwIBAgIQBAkYG1/Vu2Z1U0O1b5VQCDANBgkqhkiG9w0B
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
# BAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFOnXWtYMR4Fz
# ELi/ygUN8viLLkcTMA0GCSqGSIb3DQEBAQUABIIBAKdJnJqXSgvGGggvmaCNsZDX
# RCQ0F2FkGu9x2tZc9AXt3UIol5I4TasAQ5A2RC55za8hwZ8xaPyld0RpWQI1OzUC
# PAghgrexfuCW0ZwqrbxUBgVArMkO583AOb4X3GaKr+wtlyB6+qJnTF57gaEmvhF3
# GlsAPulI8qC9BQilG6IlmVhl+2v0Diy93oa6gYNmcAniw/HAnlGGov7hKRrkEk6b
# Xt686/hCJlaVrIcY4/Hdv4GAsjDUfQim5z0jIaMfqq+xqIcnyDVPkKwoZVAJhEZt
# ondtwEp8HF35Mw/auhfmRdueLm9RcrkEr5/Ii6NXyvWn5AGqOlO/mdwE02bKuCM=
# SIG # End signature block
