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
    
    # IdentityNow Admin User
    $adminUSR = [string]$IdentityNowConfiguration.AdminCredential.UserName.ToLower()
    $adminPWDClear = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($IdentityNowConfiguration.AdminCredential.Password))
    Write-Debug $adminUSR
    Write-Debug $adminPWDClear
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
