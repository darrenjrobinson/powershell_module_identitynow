function Start-IdentityNowCertCampaign {
    <#
.SYNOPSIS
    Start an IdentityNow Certification Campaign that is currently 'Staged'.

.DESCRIPTION
    Start an IdentityNow Certification Campaign that is currently 'Staged'.

.PARAMETER campaignID
    (required) IdentityNow Campaign to activate.
    
.PARAMETER timezone
    (required) IdentityNow Campaign timezone.
    e.g GMT+1100

.EXAMPLE
    Start-IdentityNowCertCampaign -campaignID 2c9180856d17db72016d18ed75560036 -timezone GMT+1100

.EXAMPLE
    Start Certification Campaign using ID of the campaign (ID not campaignFilterId)
    $incompleteCampaigns = Get-IdentityNowCertCampaign -completed $false
    $myCampaign = $incompleteCampaigns | select-object | Where-Object {$_.name -like '*Restricted App X Campaign*'}
    Start-IdentityNowCertCampaign -campaignID $myCampaign.id -timezone "GMT+1100"

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$campaignID,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$timezone 
    )
    
    $v3Token = Get-IdentityNowAuth

    if ($v3Token.access_token) {
        try {
            $campaignStatus = Get-IdentityNowCertCampaign -campaignID $campaignID -completed $false
            if ($campaignStatus) {
                if ($campaignStatus[0].phase.Equals("Staged")) {
                    # Activate Campaign
                    $tzEncoded = [System.Web.HttpUtility]::UrlEncode($timezone)
                    $activateBody = "campaignId=$($campaignID)&timeZone=$($tzEncoded)"
                    Invoke-RestMethod -Method Post -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/campaign/activate" -Body $activateBody -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }                                    
                    # Give it a 10 moments 
                    start-sleep -Seconds 10
                    $campaignStatus = Get-IdentityNowCertCampaign -campaignID $campaignID -completed $false
                    return $campaignStatus
                }                
            }
            else {
                Write-Error "Campaign $($campaignID) not found."
            }            
        }
        catch {
            Write-Error "Failed to activate Certifcation Campaign. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    }
}
