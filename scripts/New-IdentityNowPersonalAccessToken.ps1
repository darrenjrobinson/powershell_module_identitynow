function New-IdentityNowPersonalAccessToken {
    <#
.SYNOPSIS
Create an IdentityNow v3 oAuth Personal Access Token.

.DESCRIPTION
Create an IdentityNow v3 oAuth Personal Access Token.

.PARAMETER name
(required) e.g MyApps

.EXAMPLE
New-IdentityNowPersonalAccessToken -name "MyApp" 

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param( 
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]    
        [string]$name    
    )

    $v3Token = Get-IdentityNowAuthorization -return V3JWT

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

