function New-IdentityNowTransform {
    <#
.SYNOPSIS
Create an IdentityNow Transform.

.DESCRIPTION
Create an IdentityNow Transform.

.PARAMETER transform
(required - JSON) The configuration for the new IdentityNow Transform.

.EXAMPLE
$attributes = @{value = '$firstName.$lastname'}
$transform = @{type = "static"; id = "FirstName.LastName"; attributes = $attributes}
New-IdentityNowTransform -transform ($transform | convertto-json) 

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$transform
    )

    $v3Token = Get-IdentityNowAuth 

    if ($v3Token.access_token) {
        try {
            $IDNNewTransform = Invoke-RestMethod -Method Post -Uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/transform/create" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "content-type" = "application/json" } -Body $transform
            return $IDNNewTransform
        }
        catch {
            Write-Error "Creation of new Transform failed. Check Transform Configuration. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

