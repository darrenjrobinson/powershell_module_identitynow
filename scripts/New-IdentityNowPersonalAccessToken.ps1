function New-IdentityNowPersonalAccessToken {
    <#
.SYNOPSIS
Create an IdentityNow Personal Access Token.

.DESCRIPTION
Create an IdentityNow Personal Access Token. This is a supported way of authenticating to 
IdentityNow API without browser prompt.

.PARAMETER name
(required) Identifiable name for a new Personal access token like postman, powershell, or 'sailpointidentitynow module'

.PARAMETER accessToken
(optional) if a personal access token needs to be made for an account not saved in this module 
we can pull the access token from https://{org}.identitynow.com/ui/session?refresh=true
after pulling up the admin section

.EXAMPLE
New-IdentityNowPersonalAccessToken -name "Sean's Sailpoint IdentityNow module"

.EXAMPLE
New-IdentityNowPersonalAccessToken -name "Sean's Sailpoint IdentityNow module" -accessToken baa2c01cb5674636b8c0f063f3f13db3

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

.LINK
https://community.sailpoint.com/t5/IdentityNow-Wiki/IdentityNow-REST-API-Create-Personal-Access-Token/ta-p/150462


#>
    [cmdletbinding()]
    param( 
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]    
        [string]$name,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]   
        [string]$accessToken
    )
    if ($accessToken) {
        $v3Token = $accessToken
    }
    else {
        $v3Token = Get-IdentityNowAuth
    }

    if ($v3Token.access_token) {
        try {    
            $PATBody = @{ }
            $PATBody.add("name", $name)
            $IDNNewPAT = Invoke-RestMethod -Method Post -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/beta/personal-access-tokens" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "Content-Type" = "application/json" } -Body ($PATBody | convertTo-json)
            return $IDNNewPAT
        }
        catch {
            if ($_ -like '*"methodName":"create","fileName":"PersonalAccessTokenRepository.java"*') {
                Write-Error "A Personal Access Token with that name already exists. New Personal Access Token not created."
                Write-Error $_
            }
            else {
                Write-Error "Create Personal Access Token failed. $($_)" 
            }
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

