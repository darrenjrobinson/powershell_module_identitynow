function New-IdentityNowCertCampaign {
    <#
.SYNOPSIS
    Create an IdentityNow Certification Campaign.

.DESCRIPTION
    Create an IdentityNow Certification Campaign.

.PARAMETER campaign
    (required - JSON) IdentityNow Campaign for creation.
    
.PARAMETER start
    (required - Boolean) Start IdentityNow Campaign after creation. 
    Default: False

.EXAMPLE
    New-IdentityNowCertCampaign -start $false -campaign

.EXAMPLE
    New Certification Campaign using ID of the campaign (ID not campaignFilterId)
    New-IdentityNowCertCampaign -campaignID 2c9180856708ae38016709f4812345c3

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$campaign,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [boolean]$start = $false
    )
    
    $v3Token = Get-IdentityNowAuth

    if ($v3Token.access_token) {
        try {
            $createResult = Invoke-RestMethod -Method Post -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/campaign/create" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "Content-Type" = "application/json" } -Body $campaign
            # Give IDN a chance to create the campaign. May need longer for very large campaigns
            start-sleep -Seconds 15
            if ($createResult) {
                $campaignStatus = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/campaign/get/$($createResult.id)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }                                    
                if ($start) {
                    [int]$i = 0
                    do {
                        start-sleep -Seconds 5
                        $campaignStatus = Get-IdentityNowCertCampaign -campaignID $createResult.id -completed $false                         
                        $i++
                    } until ($campaignStatus[0].phase.Equals("Staged") -or ($i -eq 12))
                    
                    if ($campaignStatus[0].phase.Equals("Staged")) {
                        # Activate Campaign
                        $tz = ($campaign | convertfrom-json).timeZone
                        Add-Type -AssemblyName System.Web
                        $tzEncoded = [System.Web.HttpUtility]::UrlEncode($tz)

                        $activateBody = "campaignId=$($createResult.id)&timeZone=$($tzEncoded)"
                        Invoke-RestMethod -Method Post -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/campaign/activate" -Body $activateBody -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }                                    
                        
                        # Give IDN a chance to activate the campaign. May need longer for very large campaigns
                        start-sleep -Seconds 15
                        $campaignStatus = Get-IdentityNowCertCampaign -campaignID $createResult.id -completed $false
                        return $campaignStatus                        
                    }
                }
                else {
                    return $campaignStatus
                }
            }
        }
        catch {
            Write-Error "Failed to create Certifcation Campaign. $($_)" 
        }
        else {
            Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
            return $v3Token
        }
    }
}
