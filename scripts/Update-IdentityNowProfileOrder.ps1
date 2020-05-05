function Update-IdentityNowProfileOrder {
    <#
.SYNOPSIS
Update IdentityNow Profile Order.

.DESCRIPTION
Update IdentityNow Profile Order.

.PARAMETER ID
(required) ID of the Identity Profile to update

.PARAMETER priority
(required) Priority value for the Identity Profile

.EXAMPLE
Update-IdentityNowProfileOrder -id 1285 -priority 20

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param( 
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$ID,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$priority
    )

    $v3Token = Get-IdentityNowAuth

    if ($v3Token.access_token) {
        try {
            $updateProfile = Invoke-RestMethod -Method Post -uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/profile/update/$($ID)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "Content-Type" = "application/json" } -Body (@{"priority" = $priority } | convertto-json)            
            return $updateProfile
        }
        catch {
            Write-Error "Profile doesn't exist? $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

