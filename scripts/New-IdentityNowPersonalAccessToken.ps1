function New-IdentityNowPersonalAccessToken {
    <#
.SYNOPSIS
Create an IdentityNow Personal Access Token.

.DESCRIPTION
Create an IdentityNow Personal Access Token. this is a supported way of authenticating to 
IdentityNow API without browser prompt.

.PARAMETER name
(required) identifiable name for a new Personal access token like postman, powershell, or 'sailpointidentitynow module'

.PARAMETER accessToken
if a personal access token needs to be made for an account not saved in this module 
we can pull the access token from https://{org}.identitynow.com/ui/session?refresh=true
after pulling up the admin section

.EXAMPLE
New-IdentityNowPersonalAccessToken -name "Sean's SailpointIdentitynow module"

.EXAMPLE
New-IdentityNowPersonalAccessToken -name "Sean's SailpointIdentitynow module" -accessToken $at

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

.LINK
https://community.sailpoint.com/t5/IdentityNow-Wiki/IdentityNow-REST-API-Create-Personal-Access-Token/ta-p/150462


#>

    [cmdletbinding()]
    param( 
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]    
        [string]$name,
        [string]$accessToken
    )
    if ($accessToken){
        $v3Token=$accessToken
    }else{
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
            Write-Error "Create Personal Access Token failed. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

