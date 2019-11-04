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
    Get-IdentityNowCertCampaignReport -campaignID '2c918085694a507f01694b9fcce6002f' 

.EXAMPLE
    Get-IdentityNowCertCampaignReport -campaignID '2c918085694a507f01694b9fcce6002f' -outputPath "c:\Reports"

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$campaignID,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$outputPath
    )
    
    # IdentityNow Admin User
    $adminUSR = [string]$IdentityNowConfiguration.AdminCredential.UserName.ToLower()
    $adminPWDClear = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($IdentityNowConfiguration.AdminCredential.Password))

    # Generate the password hash
    # Requires Get-Hash from PowerShell Community Extensions (PSCX) Module 
    # https://www.powershellgallery.com/packages/Pscx/3.2.2
    $passwordHash = Get-Hash -Algorithm SHA256 -StringEncoding utf8 -InputObject ($($adminPWDClear) + (Get-Hash -Algorithm SHA256 -StringEncoding utf8 -InputObject ($adminUSR)).HashString.ToLower())
    $adminPWD = $passwordHash.ToString().ToLower() 
    
    $clientSecretv3 = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($IdentityNowConfiguration.v3.Password))
    # Basic Auth
    $Bytesv3 = [System.Text.Encoding]::utf8.GetBytes("$($IdentityNowConfiguration.v3.UserName):$($clientSecretv3)")
    $encodedAuthv3 = [Convert]::ToBase64String($Bytesv3)
    $Headersv3 = @{Authorization = "Basic $($encodedAuthv3)" }
    
    # Get v3 oAuth Token
    # oAuth URI
    $oAuthURI = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/oauth/token"
    $v3Token = Invoke-RestMethod -Method Post -Uri "$($oAuthURI)?grant_type=password&username=$($adminUSR)&password=$($adminPWD)" -Headers $Headersv3 
    $utime = [int][double]::Parse((Get-Date -UFormat %s))

    $ReportTemplate = [pscustomobject][ordered]@{ 
        ReportName = $null 
        Report     = $null 
    } 

    if ($v3Token.access_token) {
        try {            
            if (!$campaignID) {           
                $IDNCertCampaigns = Get-IdentityNowCertCampaign -completed $true 
                if ($IDNCertCampaigns) {
                    foreach ($campaign in $IDNCertCampaigns) {
                        # Get time of completion of the Campaign
                        $unixtime = $null 
                        [string]$unixtime = $campaign.deadline
                        $unixtime = $unixtime.Substring(0, 10)        
                        $time = [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($unixtime))
                        $accesst = $IDNv3.Headers.authorization.split(" ")   
                            
                        if ($time -gt (get-date).AddDays( - $($period))) {
                            $utime = [int][double]::Parse((Get-Date -UFormat %s))
                            $campaignReports = $null     
                            $campaignReports = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/campaign/getReports?_dc=$($utime)&campaignId=$($campaign.id)&page=1&start=0&limit=50&sort=%5B%7B%22property%22%3A%22name%22%2C%22direction%22%3A%22ASC%22%7D%5D" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }       
                            $reportsOut = @()
                            foreach ($report in $campaignReports) {                    
                                if ($outputPath) {
                                    if ($report.name.Equals("Campaign Status Report")) { $outputFile = "$($outputPath)\$($campaign.description) - StatusReport.csv" }
                                    if ($report.name.Equals("Campaign Remediation Status Report")) { $outputFile = "$($outputPath)\$($campaign.description) - RemediationReport.csv" }
                                    if ($report.name.Equals("Certification Signoff Report")) { $outputFile = "$($outputPath)\$($campaign.description) - SignoffReport.csv" }
                                    if ($report.name.Equals("Campaign Composition Report")) { $outputFile = "$($outputPath)\$($campaign.description) - CompositionReport.csv" }
                                }
                                # Get CSV Report                                
                                $reportDetails = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/report/get/$($report.taskResultId)?format=csv&name=Export+Campaign+Status+Report&url_signature=$($accesst[1])" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }                                    

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
                $campaign = Get-IdentityNowCertCampaign -campaignID $campaignID 
                if ($campaign) {                  
                    $accesst = $IDNv3.Headers.authorization.split(" ")               
                    $utime = [int][double]::Parse((Get-Date -UFormat %s))
                    $campaignReports = $null     
                    $campaignReports = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/campaign/getReports?_dc=$($utime)&campaignId=$($campaign.campaignId)&page=1&start=0&limit=50&sort=%5B%7B%22property%22%3A%22name%22%2C%22direction%22%3A%22ASC%22%7D%5D" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }       
                    $reportsOut = @()
                    foreach ($report in $campaignReports) {                    
                        if ($outputPath) {
                            if ($report.name.Equals("Campaign Status Report")) { $outputFile = "$($outputPath)\$($campaign.displayName) - StatusReport.csv" }
                            if ($report.name.Equals("Campaign Remediation Status Report")) { $outputFile = "$($outputPath)\$($campaign.displayName) - RemediationReport.csv" }
                            if ($report.name.Equals("Certification Signoff Report")) { $outputFile = "$($outputPath)\$($campaign.displayName) - SignoffReport.csv" }
                            if ($report.name.Equals("Campaign Composition Report")) { $outputFile = "$($outputPath)\$($campaign.displayName) - CompositionReport.csv" }
                        }
                        
                        # Get CSV Report
                        $reportDetails = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/report/get/$($report.taskResultId)?format=csv&name=Export+Campaign+Status+Report&url_signature=$($accesst[1])" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }                                    
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
                    Write-Error "Certification Campaign not found. $($_)"
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
