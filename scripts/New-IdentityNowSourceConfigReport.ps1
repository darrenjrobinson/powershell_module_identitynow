function New-IdentityNowSourceConfigReport {
    <#
.SYNOPSIS
Generate a HTML Report of IdentityNow Sources configuration and export each Source and Schema config.

.DESCRIPTION
Generate a HTML Report of IdentityNow Sources configuration and export each Source and Schema config.

.PARAMETER reportPath
(required) Folder to output configuration to. e.g c:\reports

.PARAMETER reportImagePath
(optional) Image to use for the HTML report. Default is the SailPointIdentityNow Log 
Recommended size 240px wide x 82px high.
e.g C:\Images\SailPoint IdentityNow 240px.png

.EXAMPLE
New-IdentityNowSourceConfigReport -reportPath 'C:\Reports'

.EXAMPLE
New-IdentityNowSourceConfigReport -reportPath 'C:\Reports' -reportImagePath 'C:\Images\myCompanyLogo-240px.png'

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$reportPath,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$reportImagePath 
    )

    # Document IdentityNow Source Configuration
    $orgName = $IdentityNowConfiguration.orgName
    $IDNSources = Get-IdentityNowSource 

    if ($reportImagePath) {
        try {
            if ($PSVersionTable.PSVersion.Major -le 5) {
                $ImageData = [Convert]::ToBase64String((Get-Content $reportImagePath -Encoding Byte))
            }
            elseif ($PSVersionTable.PSVersion.Major -gt 5) {
                $ImageData = [Convert]::ToBase64String((Get-Content $reportImagePath -AsByteStream))
            }

            $ImageFile = Get-Item $reportImagePath
            $ImageType = $ImageFile.Extension.Substring(1) #strip off the leading .
            $ImageTag = "<Img src='data:image/$($ImageType);base64,$($ImageData)' Alt='$($ImageFile.Name)' width='240' height='82' `hspace=10>"
        }
        catch {
            Write-Error "Report Image Path/Filename not found. $($_)"
            break 
        }
    }
    else {
        $ImageData = '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'

        $ImageTag = "<Img src='data:image/png;base64,$($ImageData)' Alt='SailPoint IdentityNow' width='240' height='82' hspace=10>"
    }

    if ($IDNSources) {
        write-output "$($IDNSources.Count) Sources found."
    }
    else {
        Write-Error "Check configuration of the SailPointIdentityNow PowerShell Module. No Sources found."
        break 
    }

    $reportDate = get-date -format "dd-MMM-yyyy HH-mm" 
    # Create Folder for Output with Report Date 
    $dir = "$($reportPath)\$($reportDate)" 
    if (!(Test-Path -Path $dir )) { 
        New-Item -ItemType directory -Path $dir | out-null 
        Write-Output "$($dir) Report output directory created."
    } 

    # Build up the HTML Report
    $htmlFragments = @() 
    # Headings and Title
    $top = @"
    <center>
        <h1>SailPoint IdentityNow Source Configuration Report</h1>
        <h2>Organisation - `'$($orgName.ToUpper())`'</h2>
        <h3>`'$($IDNSources.Count)`' Sources found<h3>
        <b><center>$ImageTag</center></b>
    </center>
"@
    $htmlFragments += $top

    $h2Text = "IdentityNow Source Configuration"
    $div = $h2Text.Replace(" ", "_")
    $htmlFragments += "<center><a href='javascript:toggleDiv(""$div"");' title='click to collapse or expand this section'><h2>$h2Text</h2></a><div id=""$div""><a href='javascript:toggleAll();' title='  Click to toggle all sections'>+ / -</a></center>"

    # Get Sources and Build the HTML Report 
    if ($IDNSources) {
        foreach ($source in $IDNSources) {
            # Sources
            Write-output "      Retrieving $($source.name) Source Configuration"
            # Get Detailed Source
            $sourceDetails = Get-IdentityNowSource -sourceID $source.id
            if ($sourceDetails) {
                # Output Source to File 
                $sourceDetails | Export-Clixml -Path "$($dir)\$($orgName)-$($source.name)-Details-$($reportDate).xml"         
            }

            # Get Schema        
            $sourceSchema = $null                
            $sourceSchema = Invoke-IdentityNowRequest -Method Get -Uri "https://$($orgName).api.identitynow.com/cc/api/source/getAccountSchema/$($source.id)" -headers HeadersV3         

            if ($sourceSchema) {
                # Output Schema to File 
                $sourceSchema | Export-Clixml -Path "$($dir)\$($orgName)-$($source.name)-Schema-$($reportDate).xml"         
            }

            # Source Title                
            $H3Text = "$($source.name)"
            $div = $H3Text.Replace(" ", "_")
            $htmlFragments += "<a href='javascript:toggleDiv(""$div"");' title='click to collapse or expand this section'><center><h3>$H3Text</h3></center></a><div id=""$div"" style=""display: none;"">"
        
            # Source Details
            $H4Text = "$($source.name) Details"
            $div = $H4Text.Replace(" ", "_")
            $htmlFragments += "<a href='javascript:toggleDiv(""$div"");' title='click to collapse or expand this section'><center><h4>$H4Text</h4></center></a><div id=""$div"" style=""display: none;"">"        
            $htmlFragments += "<center>"         
            
            $attrObjects = $sourceDetails | Get-Member | Where-Object { $_.Definition.contains("Object[]") } | Select-Object  
            foreach ($attrObj in $attrObjects) {
                $attrName = $attrObj.name     
                $sourceDetails.$attrName = $sourceDetails.$attrName -join ','
            }

            $htmlFragments += $sourceDetails | ConvertTo-Html -As LIST 
            $htmlFragments += "</center>"
            $htmlFragments += "</div>"

            # Schema Details
            $H4Text = "$($source.name) Schema Attributes"
            $div = $H4Text.Replace(" ", "_")
            $htmlFragments += "<a href='javascript:toggleDiv(""$div"");' title='click to collapse or expand this section'><center><h4>$H4Text</h4></center></a><div id=""$div"" style=""display: none;"">"                
            $htmlFragments += "<center>" 
            $htmlFragments += $sourceSchema | Select-Object $_ -ExpandProperty attributes | ConvertTo-Html -Fragment -Property Name, description, type, displayAttribute, entitlement, identityAttribute, managed, minable, multi    
            $htmlFragments += "</center>" 
            $htmlFragments += "</div>"
            $htmlFragments += "</div>"        
        }
    }      
    # Footer
    $htmlFragments += "<center><p class='footer'>Report Generated $($reportDate)</p></center>"
    # Header
    $head = @"
<Title>SailPoint IdentityNow Source(s) Report - $($orgName.ToUpper())</Title>
<style>
body {background-color:#ffffff; font:70%/1.5em Lato,sans-serif; padding:10px }
td,th {padding-left:8px}
th {color:black; background-color:cornflowerblue;}
table {border-spacing:1px; border-collapse:collapse; background:#F7F6F6; border-radius:6px; overflow:hidden; max-width:480px; width:70%; margin:0 auto; position:relative;}   
table, tr, td, th {padding: 10px; margin: 0px ;white-space:pre; word-break:break-all; width:70%;}
tr:nth-child(even) {background-color:#dae5f4;}
tr:nth-child(odd) {background:#b8d1f3;}
thead tr {height:60px;background:#367AB1;color:#F5F6FA;font-size:1.2em;font-weight:700;text-transform:uppercase}
tbody tr {height:35px;border-bottom:1px solid #367AB1; word-break:break-all; text-transform:capitalize; font-size:1em;}
h1 {font-family:Tahoma;color:#A9A9A9;}
h2 {font-family:Tahoma;color:#6D7B8D;}
h3 {font-family:Tahoma;color:#6D7B8D;}
.alert {color: red;}
.footer {color:green; margin-left:10px; font-family:Tahoma; font-size:8pt; font-style:italic;}
.transparent {background-color:#ffffff;}
</style>
<script type='text/javascript' src='https://ajax.googleapis.com/ajax/libs/jquery/1.4.4/jquery.min.js'>
</script>
<script type='text/javascript'>
function toggleDiv(divId) {
   `$("#"+divId).toggle();
}
function toggleAll() {
    var divs = document.getElementsByTagName('div');
    for (var i = 0; i < divs.length; i++) {
        var div = divs[i];
        `$("#"+div.id).toggle();
    }
}
</script>
"@

    # Output the Report
    $convertParams = @{ 
        head = $head 
        body = $htmlFragments
    }   

    convertto-html @convertParams | out-file -FilePath "$($dir)\$($IdentityNowConfiguration.orgName)-ConfigReport-$($reportDate).html" 
    write-output "Configuration Report generated to $($dir)\$($IdentityNowConfiguration.orgName)-ConfigReport-$($reportDate).html"

# SIG # Begin signature block
# MIIoKwYJKoZIhvcNAQcCoIIoHDCCKBgCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCsoFWahW7xta3A
# xe7l+aszrwLBHcNyB+5tw/w5HQUVAqCCIS4wggWNMIIEdaADAgECAhAOmxiO+dAt
# 5+/bUOIIQBhaMA0GCSqGSIb3DQEBDAUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQK
# EwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNV
# BAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0yMjA4MDEwMDAwMDBa
# Fw0zMTExMDkyMzU5NTlaMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2Vy
# dCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lD
# ZXJ0IFRydXN0ZWQgUm9vdCBHNDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoC
# ggIBAL/mkHNo3rvkXUo8MCIwaTPswqclLskhPfKK2FnC4SmnPVirdprNrnsbhA3E
# MB/zG6Q4FutWxpdtHauyefLKEdLkX9YFPFIPUh/GnhWlfr6fqVcWWVVyr2iTcMKy
# unWZanMylNEQRBAu34LzB4TmdDttceItDBvuINXJIB1jKS3O7F5OyJP4IWGbNOsF
# xl7sWxq868nPzaw0QF+xembud8hIqGZXV59UWI4MK7dPpzDZVu7Ke13jrclPXuU1
# 5zHL2pNe3I6PgNq2kZhAkHnDeMe2scS1ahg4AxCN2NQ3pC4FfYj1gj4QkXCrVYJB
# MtfbBHMqbpEBfCFM1LyuGwN1XXhm2ToxRJozQL8I11pJpMLmqaBn3aQnvKFPObUR
# WBf3JFxGj2T3wWmIdph2PVldQnaHiZdpekjw4KISG2aadMreSx7nDmOu5tTvkpI6
# nj3cAORFJYm2mkQZK37AlLTSYW3rM9nF30sEAMx9HJXDj/chsrIRt7t/8tWMcCxB
# YKqxYxhElRp2Yn72gLD76GSmM9GJB+G9t+ZDpBi4pncB4Q+UDCEdslQpJYls5Q5S
# UUd0viastkF13nqsX40/ybzTQRESW+UQUOsxxcpyFiIJ33xMdT9j7CFfxCBRa2+x
# q4aLT8LWRV+dIPyhHsXAj6KxfgommfXkaS+YHS312amyHeUbAgMBAAGjggE6MIIB
# NjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTs1+OC0nFdZEzfLmc/57qYrhwP
# TzAfBgNVHSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzAOBgNVHQ8BAf8EBAMC
# AYYweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdp
# Y2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwRQYDVR0fBD4wPDA6oDigNoY0
# aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENB
# LmNybDARBgNVHSAECjAIMAYGBFUdIAAwDQYJKoZIhvcNAQEMBQADggEBAHCgv0Nc
# Vec4X6CjdBs9thbX979XB72arKGHLOyFXqkauyL4hxppVCLtpIh3bb0aFPQTSnov
# Lbc47/T/gLn4offyct4kvFIDyE7QKt76LVbP+fT3rDB6mouyXtTP0UNEm0Mh65Zy
# oUi0mcudT6cGAxN3J0TU53/oWajwvy8LpunyNDzs9wPHh6jSTEAZNUZqaVSwuKFW
# juyk1T3osdz9HNj0d1pcVIxv76FQPfx2CWiEn2/K2yCNNWAcAgPLILCsWKAOQGPF
# mCLBsln1VWvPJ6tsds5vIy30fnFqI2si/xK4VC0nftg62fC2h5b9W9FcrBjDTZ9z
# twGpn1eqXijiuZQwggauMIIElqADAgECAhAHNje3JFR82Ees/ShmKl5bMA0GCSqG
# SIb3DQEBCwUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMx
# GTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0IFRy
# dXN0ZWQgUm9vdCBHNDAeFw0yMjAzMjMwMDAwMDBaFw0zNzAzMjIyMzU5NTlaMGMx
# CzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMy
# RGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcg
# Q0EwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDGhjUGSbPBPXJJUVXH
# JQPE8pE3qZdRodbSg9GeTKJtoLDMg/la9hGhRBVCX6SI82j6ffOciQt/nR+eDzMf
# UBMLJnOWbfhXqAJ9/UO0hNoR8XOxs+4rgISKIhjf69o9xBd/qxkrPkLcZ47qUT3w
# 1lbU5ygt69OxtXXnHwZljZQp09nsad/ZkIdGAHvbREGJ3HxqV3rwN3mfXazL6IRk
# tFLydkf3YYMZ3V+0VAshaG43IbtArF+y3kp9zvU5EmfvDqVjbOSmxR3NNg1c1eYb
# qMFkdECnwHLFuk4fsbVYTXn+149zk6wsOeKlSNbwsDETqVcplicu9Yemj052FVUm
# cJgmf6AaRyBD40NjgHt1biclkJg6OBGz9vae5jtb7IHeIhTZgirHkr+g3uM+onP6
# 5x9abJTyUpURK1h0QCirc0PO30qhHGs4xSnzyqqWc0Jon7ZGs506o9UD4L/wojzK
# QtwYSH8UNM/STKvvmz3+DrhkKvp1KCRB7UK/BZxmSVJQ9FHzNklNiyDSLFc1eSuo
# 80VgvCONWPfcYd6T/jnA+bIwpUzX6ZhKWD7TA4j+s4/TXkt2ElGTyYwMO1uKIqjB
# Jgj5FBASA31fI7tk42PgpuE+9sJ0sj8eCXbsq11GdeJgo1gJASgADoRU7s7pXche
# MBK9Rp6103a50g5rmQzSM7TNsQIDAQABo4IBXTCCAVkwEgYDVR0TAQH/BAgwBgEB
# /wIBADAdBgNVHQ4EFgQUuhbZbU2FL3MpdpovdYxqII+eyG8wHwYDVR0jBBgwFoAU
# 7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYDVR0PAQH/BAQDAgGGMBMGA1UdJQQMMAoG
# CCsGAQUFBwMIMHcGCCsGAQUFBwEBBGswaTAkBggrBgEFBQcwAYYYaHR0cDovL29j
# c3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAChjVodHRwOi8vY2FjZXJ0cy5kaWdp
# Y2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNydDBDBgNVHR8EPDA6MDig
# NqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9v
# dEc0LmNybDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwDQYJKoZI
# hvcNAQELBQADggIBAH1ZjsCTtm+YqUQiAX5m1tghQuGwGC4QTRPPMFPOvxj7x1Bd
# 4ksp+3CKDaopafxpwc8dB+k+YMjYC+VcW9dth/qEICU0MWfNthKWb8RQTGIdDAiC
# qBa9qVbPFXONASIlzpVpP0d3+3J0FNf/q0+KLHqrhc1DX+1gtqpPkWaeLJ7giqzl
# /Yy8ZCaHbJK9nXzQcAp876i8dU+6WvepELJd6f8oVInw1YpxdmXazPByoyP6wCeC
# RK6ZJxurJB4mwbfeKuv2nrF5mYGjVoarCkXJ38SNoOeY+/umnXKvxMfBwWpx2cYT
# gAnEtp/Nh4cku0+jSbl3ZpHxcpzpSwJSpzd+k1OsOx0ISQ+UzTl63f8lY5knLD0/
# a6fxZsNBzU+2QJshIUDQtxMkzdwdeDrknq3lNHGS1yZr5Dhzq6YBT70/O3itTK37
# xJV77QpfMzmHQXh6OOmc4d0j/R0o08f56PGYX/sr2H7yRp11LB4nLCbbbxV7HhmL
# NriT1ObyF5lZynDwN7+YAN8gFk8n+2BnFqFmut1VwDophrCYoCvtlUG3OtUVmDG0
# YgkPCr2B2RP+v6TR81fZvAT6gt4y3wSJ8ADNXcL50CN/AAvkdgIm2fBldkKmKYcJ
# RyvmfxqkhQ/8mJb2VVQrH4D6wPIOK+XW+6kvRBVK5xMOHds3OBqhK/bt1nz8MIIG
# sDCCBJigAwIBAgIQCK1AsmDSnEyfXs2pvZOu2TANBgkqhkiG9w0BAQwFADBiMQsw
# CQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cu
# ZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBUcnVzdGVkIFJvb3QgRzQw
# HhcNMjEwNDI5MDAwMDAwWhcNMzYwNDI4MjM1OTU5WjBpMQswCQYDVQQGEwJVUzEX
# MBUGA1UEChMORGlnaUNlcnQsIEluYy4xQTA/BgNVBAMTOERpZ2lDZXJ0IFRydXN0
# ZWQgRzQgQ29kZSBTaWduaW5nIFJTQTQwOTYgU0hBMzg0IDIwMjEgQ0ExMIICIjAN
# BgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA1bQvQtAorXi3XdU5WRuxiEL1M4zr
# PYGXcMW7xIUmMJ+kjmjYXPXrNCQH4UtP03hD9BfXHtr50tVnGlJPDqFX/IiZwZHM
# gQM+TXAkZLON4gh9NH1MgFcSa0OamfLFOx/y78tHWhOmTLMBICXzENOLsvsI8Irg
# nQnAZaf6mIBJNYc9URnokCF4RS6hnyzhGMIazMXuk0lwQjKP+8bqHPNlaJGiTUyC
# EUhSaN4QvRRXXegYE2XFf7JPhSxIpFaENdb5LpyqABXRN/4aBpTCfMjqGzLmysL0
# p6MDDnSlrzm2q2AS4+jWufcx4dyt5Big2MEjR0ezoQ9uo6ttmAaDG7dqZy3SvUQa
# khCBj7A7CdfHmzJawv9qYFSLScGT7eG0XOBv6yb5jNWy+TgQ5urOkfW+0/tvk2E0
# XLyTRSiDNipmKF+wc86LJiUGsoPUXPYVGUztYuBeM/Lo6OwKp7ADK5GyNnm+960I
# HnWmZcy740hQ83eRGv7bUKJGyGFYmPV8AhY8gyitOYbs1LcNU9D4R+Z1MI3sMJN2
# FKZbS110YU0/EpF23r9Yy3IQKUHw1cVtJnZoEUETWJrcJisB9IlNWdt4z4FKPkBH
# X8mBUHOFECMhWWCKZFTBzCEa6DgZfGYczXg4RTCZT/9jT0y7qg0IU0F8WD1Hs/q2
# 7IwyCQLMbDwMVhECAwEAAaOCAVkwggFVMBIGA1UdEwEB/wQIMAYBAf8CAQAwHQYD
# VR0OBBYEFGg34Ou2O/hfEYb7/mF7CIhl9E5CMB8GA1UdIwQYMBaAFOzX44LScV1k
# TN8uZz/nupiuHA9PMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEFBQcD
# AzB3BggrBgEFBQcBAQRrMGkwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2lj
# ZXJ0LmNvbTBBBggrBgEFBQcwAoY1aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29t
# L0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcnQwQwYDVR0fBDwwOjA4oDagNIYyaHR0
# cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcmww
# HAYDVR0gBBUwEzAHBgVngQwBAzAIBgZngQwBBAEwDQYJKoZIhvcNAQEMBQADggIB
# ADojRD2NCHbuj7w6mdNW4AIapfhINPMstuZ0ZveUcrEAyq9sMCcTEp6QRJ9L/Z6j
# fCbVN7w6XUhtldU/SfQnuxaBRVD9nL22heB2fjdxyyL3WqqQz/WTauPrINHVUHmI
# moqKwba9oUgYftzYgBoRGRjNYZmBVvbJ43bnxOQbX0P4PpT/djk9ntSZz0rdKOtf
# JqGVWEjVGv7XJz/9kNF2ht0csGBc8w2o7uCJob054ThO2m67Np375SFTWsPK6Wrx
# oj7bQ7gzyE84FJKZ9d3OVG3ZXQIUH0AzfAPilbLCIXVzUstG2MQ0HKKlS43Nb3Y3
# LIU/Gs4m6Ri+kAewQ3+ViCCCcPDMyu/9KTVcH4k4Vfc3iosJocsL6TEa/y4ZXDlx
# 4b6cpwoG1iZnt5LmTl/eeqxJzy6kdJKt2zyknIYf48FWGysj/4+16oh7cGvmoLr9
# Oj9FpsToFpFSi0HASIRLlk2rREDjjfAVKM7t8RhWByovEMQMCGQ8M4+uKIw8y4+I
# Cw2/O/TOHnuO77Xry7fwdxPm5yg/rBKupS8ibEH5glwVZsxsDsrFhsP2JjMMB0ug
# 0wcCampAMEhLNKhRILutG4UI4lkNbcoFUCvqShyepf2gpx8GdOfy1lKQ/a+FSCH5
# Vzu0nAPthkX0tGFuv2jiJmCG6sivqf6UHedjGzqGVnhOMIIGwjCCBKqgAwIBAgIQ
# BUSv85SdCDmmv9s/X+VhFjANBgkqhkiG9w0BAQsFADBjMQswCQYDVQQGEwJVUzEX
# MBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0
# ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENBMB4XDTIzMDcxNDAw
# MDAwMFoXDTM0MTAxMzIzNTk1OVowSDELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRp
# Z2lDZXJ0LCBJbmMuMSAwHgYDVQQDExdEaWdpQ2VydCBUaW1lc3RhbXAgMjAyMzCC
# AiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAKNTRYcdg45brD5UsyPgz5/X
# 5dLnXaEOCdwvSKOXejsqnGfcYhVYwamTEafNqrJq3RApih5iY2nTWJw1cb86l+uU
# UI8cIOrHmjsvlmbjaedp/lvD1isgHMGXlLSlUIHyz8sHpjBoyoNC2vx/CSSUpIIa
# 2mq62DvKXd4ZGIX7ReoNYWyd/nFexAaaPPDFLnkPG2ZS48jWPl/aQ9OE9dDH9kgt
# XkV1lnX+3RChG4PBuOZSlbVH13gpOWvgeFmX40QrStWVzu8IF+qCZE3/I+PKhu60
# pCFkcOvV5aDaY7Mu6QXuqvYk9R28mxyyt1/f8O52fTGZZUdVnUokL6wrl76f5P17
# cz4y7lI0+9S769SgLDSb495uZBkHNwGRDxy1Uc2qTGaDiGhiu7xBG3gZbeTZD+BY
# QfvYsSzhUa+0rRUGFOpiCBPTaR58ZE2dD9/O0V6MqqtQFcmzyrzXxDtoRKOlO0L9
# c33u3Qr/eTQQfqZcClhMAD6FaXXHg2TWdc2PEnZWpST618RrIbroHzSYLzrqawGw
# 9/sqhux7UjipmAmhcbJsca8+uG+W1eEQE/5hRwqM/vC2x9XH3mwk8L9CgsqgcT2c
# kpMEtGlwJw1Pt7U20clfCKRwo+wK8REuZODLIivK8SgTIUlRfgZm0zu++uuRONhR
# B8qUt+JQofM604qDy0B7AgMBAAGjggGLMIIBhzAOBgNVHQ8BAf8EBAMCB4AwDAYD
# VR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAgBgNVHSAEGTAXMAgG
# BmeBDAEEAjALBglghkgBhv1sBwEwHwYDVR0jBBgwFoAUuhbZbU2FL3MpdpovdYxq
# II+eyG8wHQYDVR0OBBYEFKW27xPn783QZKHVVqllMaPe1eNJMFoGA1UdHwRTMFEw
# T6BNoEuGSWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRH
# NFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdDQS5jcmwwgZAGCCsGAQUFBwEBBIGD
# MIGAMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wWAYIKwYB
# BQUHMAKGTGh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0
# ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdDQS5jcnQwDQYJKoZIhvcNAQEL
# BQADggIBAIEa1t6gqbWYF7xwjU+KPGic2CX/yyzkzepdIpLsjCICqbjPgKjZ5+PF
# 7SaCinEvGN1Ott5s1+FgnCvt7T1IjrhrunxdvcJhN2hJd6PrkKoS1yeF844ektrC
# QDifXcigLiV4JZ0qBXqEKZi2V3mP2yZWK7Dzp703DNiYdk9WuVLCtp04qYHnbUFc
# jGnRuSvExnvPnPp44pMadqJpddNQ5EQSviANnqlE0PjlSXcIWiHFtM+YlRpUurm8
# wWkZus8W8oM3NG6wQSbd3lqXTzON1I13fXVFoaVYJmoDRd7ZULVQjK9WvUzF4UbF
# KNOt50MAcN7MmJ4ZiQPq1JE3701S88lgIcRWR+3aEUuMMsOI5ljitts++V+wQtaP
# 4xeR0arAVeOGv6wnLEHQmjNKqDbUuXKWfpd5OEhfysLcPTLfddY2Z1qJ+Panx+VP
# NTwAvb6cKmx5AdzaROY63jg7B145WPR8czFVoIARyxQMfq68/qTreWWqaNYiyjvr
# moI1VygWy2nyMpqy0tg6uLFGhmu6F/3Ed2wVbK6rr3M66ElGt9V/zLY4wNjsHPW2
# obhDLN9OTH0eaHDAdwrUAuBcYLso/zjlUlrWrBciI0707NMX+1Br/wd3H3GXREHJ
# uEbTbDJ8WC9nR2XlG3O2mflrLAZG70Ee8PBf4NvZrZCARK+AEEGKMIIHbTCCBVWg
# AwIBAgIQCcjsXDR9ByBZzKg16Kdv+DANBgkqhkiG9w0BAQsFADBpMQswCQYDVQQG
# EwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xQTA/BgNVBAMTOERpZ2lDZXJ0
# IFRydXN0ZWQgRzQgQ29kZSBTaWduaW5nIFJTQTQwOTYgU0hBMzg0IDIwMjEgQ0Ex
# MB4XDTIzMDMyOTAwMDAwMFoXDTI2MDYyMjIzNTk1OVowdTELMAkGA1UEBhMCQVUx
# GDAWBgNVBAgTD05ldyBTb3V0aCBXYWxlczEUMBIGA1UEBxMLQ2hlcnJ5YnJvb2sx
# GjAYBgNVBAoTEURhcnJlbiBKIFJvYmluc29uMRowGAYDVQQDExFEYXJyZW4gSiBS
# b2JpbnNvbjCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAMesp+e1UZ5d
# oOnpL+epm6Iq6GYiqK8ZNcz1XBe7M7eBXwVy4tYP5ByIa6NORYEselVWI9XmO1M+
# cPS6jRMrpZb9xtUH+NpKZO+eSthgTAtnEO1dWaAK6Y7AH/ZVjmgOTWZXBVibjAE/
# JQKIfZyx4Hm5FOH6hq3bslA+RUQpo3NQxNv2AuzckKQwbW7AoXINudj0duYCiDYs
# hn/9mHzzgL0VpNYRpmgEa7WWgc1JH17V+SYlaf6qMWpYoWuODwuDltSH2p57qAI2
# /4J6rUYEvns7QZ9sgIUdGlUr596fp0Y4juypyVGE7Rr0a8PtByLWUupyV7Z5kKPr
# /MRjerXAmBnf6AdhI3kY6Gjz356fZkPA49UuCIXFgyTZT84Ao6Klw+0RqJ70JDt4
# 49Uky7hda+h8h2PiUdf7rXQamV57mY65+lHAmc4+UgTuWsnpwnTuNlkbZxRnCw2D
# +W3qto2aBhDebciKZzivfiAWlWfTcHtCpy96gM5L+OB45ezDpU6KAH1hwRSjORUl
# W5yoFTXUbPUBRflU3O2bZ0wdAJeyUYaHWAayNoyFfuKdrmCLtIx726O06dz9Kg+c
# Jf+1ZdJ7KcUvZgR2d8F19FV5G1CVMnOzhMZR2dnIeJ5h0EgcOKNHl3hMKFdVRx4l
# hW8tcrQQN4ZT2EgGfI9fBc0i3GXTFA0xAgMBAAGjggIDMIIB/zAfBgNVHSMEGDAW
# gBRoN+Drtjv4XxGG+/5hewiIZfROQjAdBgNVHQ4EFgQUBTFWqXTuYnNp+d03es2K
# M9JdGUgwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMIG1BgNV
# HR8Ega0wgaowU6BRoE+GTWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2Vy
# dFRydXN0ZWRHNENvZGVTaWduaW5nUlNBNDA5NlNIQTM4NDIwMjFDQTEuY3JsMFOg
# UaBPhk1odHRwOi8vY3JsNC5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRD
# b2RlU2lnbmluZ1JTQTQwOTZTSEEzODQyMDIxQ0ExLmNybDA+BgNVHSAENzA1MDMG
# BmeBDAEEATApMCcGCCsGAQUFBwIBFhtodHRwOi8vd3d3LmRpZ2ljZXJ0LmNvbS9D
# UFMwgZQGCCsGAQUFBwEBBIGHMIGEMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5k
# aWdpY2VydC5jb20wXAYIKwYBBQUHMAKGUGh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0
# LmNvbS9EaWdpQ2VydFRydXN0ZWRHNENvZGVTaWduaW5nUlNBNDA5NlNIQTM4NDIw
# MjFDQTEuY3J0MAkGA1UdEwQCMAAwDQYJKoZIhvcNAQELBQADggIBAFhACWjPMrca
# fwDfZ5me/nUrkv4yYgIi535cddPAm/2swGDTuzSVBVHIMBp8LWLmzXPA1GbxBOmA
# 4L8vvDgjEpQF9I9Ph5MNYgYhg0xSpAIp9/KAoc4OQnwlyRGPN+CjayY40xxTz4/h
# HohWg4rnJMIuVEjkMtKnMdTbpnqU85w78AQlfD79v/gWQ2dL1T3n18HOEjTt8VSu
# rxkEhQ5I3SH8Cr9YhUv94ObWIUbOKUt5SG7m/d+y2mfkKRSOmRluLSoYLPWbx35p
# ArsYkaPpjf5Yl5jiJPY3GQzEU/SRVW0rrwDAbtKSN0gKWtZxijPDbs8aQUYCijFf
# je6OWGF4RnmPSQh0Ff8AyzPQcx9LjQ/8W7gUELsE6IFuXP5bj2i6geLy65LRe46Q
# ZlYDq/bMazUoZQTlje/hs6pkOL4f1Kv7tbJZmMENVVURJNmeDRejvNliHaaGEAv/
# iF0Zo7pqvj4wCCCGG3j/sNR5WSRYnxf5xQ4r9i9gZqk4yjwk/DJCW2rmKNCUoxNI
# ZWh2EIlMSDzw3DMKk2ylZdiY/LAi5GmbCyGLt6sTz/IE1w1NYwrp/z6v4I91lDgd
# Xg+fTkhhxt47hWmjMOD3ZYVSFzQmg8al1iQ/+6RYKgfsww64tIky8JOOZX/3ss/u
# hxKUjPJxYJkOwQwUyoAYzjcu/AE7By0rMYIGUzCCBk8CAQEwfTBpMQswCQYDVQQG
# EwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xQTA/BgNVBAMTOERpZ2lDZXJ0
# IFRydXN0ZWQgRzQgQ29kZSBTaWduaW5nIFJTQTQwOTYgU0hBMzg0IDIwMjEgQ0Ex
# AhAJyOxcNH0HIFnMqDXop2/4MA0GCWCGSAFlAwQCAQUAoIGEMBgGCisGAQQBgjcC
# AQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYB
# BAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIDiR4sOoWizC
# xIPSb1rXMQ9qI9mwSPxlUTD0H/ExFgA0MA0GCSqGSIb3DQEBAQUABIICALdJ2Ajz
# Np3TxY5Qxk2auBO4j0OvSoxsuXQ92dXfIjFSBxH+CdLNFNtkrYqToCoiLwscJl48
# 2dqSFCyCSdd8flORCD3DVwcdG1USTiOeBVep+hIz2lHvEQaZ1sq7xJ4gT6V3+KRr
# a6kEO2YVSt/pa8c43v6DM99hAA6OkC3fkkhk2dqpWi1bPTXeaGMYmrz6y1VNsehA
# 5opmvbddZalvzNglN4TZ87uRFmeteg8fzHWSey2t/7P1iqoCu0DC7TvjLTVx7f7F
# Ki+xI0op6gKEqw9/DGRsbefP2PVZbeVBqNKbfYLejvbTBJ40fM7WWx8vioUT40vY
# ykYg7KO/P34fKkwjhoW9zLagKHoSc9dqHbD+he0Uu/w/GoFEMxAQ0BDRCCi4oHuz
# FdLJy99ukqEckIrq3X+kveCPqvPlAQSwbp0uJJk1LUtlXcDzuaN3Uus9gqG5C/JA
# NbY/69sWt7D+jhsU3Bj+wQyMb1jeVHOQDjBk9YjoqDrUq+2bLh0dIeY9iwugr6br
# 0FBzV7H2bdGubWp64R2uG681JihbQGMoFuYxCKz4tmbkZ4xof+egY7hqL1pBFZuK
# 0I1XTVN8zIPAJPgdFd9MboCVcsdaz+3fqB0VcH7H01RIKwtUlK9LoqxDR4ZyoYWm
# qjgadLFKckY2htw1RusVQ2mXCx9N5xHk52pKoYIDIDCCAxwGCSqGSIb3DQEJBjGC
# Aw0wggMJAgEBMHcwYzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJ
# bmMuMTswOQYDVQQDEzJEaWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2
# IFRpbWVTdGFtcGluZyBDQQIQBUSv85SdCDmmv9s/X+VhFjANBglghkgBZQMEAgEF
# AKBpMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTIz
# MTEwMjA4MzA0NVowLwYJKoZIhvcNAQkEMSIEIAOdX6rwDmDcUrc1cuZyXhGw827W
# +iIVGMb8n6VW5eGSMA0GCSqGSIb3DQEBAQUABIICAJDZ/XKnKVr/SPJzc0xiJwns
# gQFNaZBzXjA5zZzahx4/BoNYIk6BJpYZ3SXLJJIDxJhywG8O4TD+m3eypqGPtkdL
# +miuFho1e6cd26YbYj4xmnzY5jty9+PeqkD5C3JgIKOtWl6MsgAH/sfyYxfQ3MIP
# 3as0dQ6yJMJeioemOpU+kIxAJ4h/gOL/Wyix3SXhFrp9ISa0YiObfMSsr42qSgAS
# ONn7710/y9NMpS81vveO8xN9uWUTIDq0kLfY71msitQfII9feXZPb2F96/l1k1DU
# l01HxoVfa764HKBUpxZPD9dpHg+NJfq9DirxPDqusf/HEbirH93iHN5GVh/ihzCI
# iTQr07aMgXO5MealsLhohA/7FFM+N+vDYhWW9XnjUYt/dUctkEpzi92vtmKs4S/V
# ZhyCX5BV5mfAU26gJYjDQUWqbuY8qzDOvWWYNgdzbt+2T/c8BCEBuIG4Z8CZjBxz
# Mni2HWx5eprD59N8qmMhhNq8kTft0FYUB5kVsVj8tlLgVsCgnrwRBjN9ZWrHEJDa
# RDgiLQv7coXRi/V/ozDfzMsnz/RkhvHcI3mUjyeEoiC94PD1cKLQTnTMnx2IMPRt
# br6xKD4HMPC6N4ggYWKM1dnH9uolKlU+WxXw+A7zdczzUTgfbYebPdZCBdJ+k8MQ
# Z6FrCdxBUN/qBN37eZDb
# SIG # End signature block
