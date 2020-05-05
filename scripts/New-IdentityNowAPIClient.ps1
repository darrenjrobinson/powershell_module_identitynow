function New-IdentityNowAPIClient {
    <#
.SYNOPSIS
Create an IdentityNow v2 API Client.

.DESCRIPTION
Create an IdentityNow v2 API Client.

.EXAMPLE
New-IdentityNowAPIClient 

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param()

    $v3Token = Get-IdentityNowAuth

    if ($v3Token.access_token) {
        try {             
                $IDNAPIClient = Invoke-RestMethod -Method Post -Uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/client/create?type=API" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "Content-Type" = "application/json" }
                return $IDNAPIClient            
        }
        catch {
            Write-Error "Create API Client failed. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

