function Update-IdentityNowTransform {
    <#
.SYNOPSIS
Update an IdentityNow Transform.

.DESCRIPTION
Update an IdentityNow Transform.

.PARAMETER ID
(required) The ID of the Transform to update.

.PARAMETER transform
(required - JSON) The configuration for the IdentityNow Transform.

.EXAMPLE
$attributes = @{value = '$firstName.$lastname@$company.com.au'}
$transform = @{type = "static"; attributes = $attributes}
Update-IdentityNowTransform -transform ($transform | convertto-json) -ID "Firstname.LastName"

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$transform,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$ID
    )

    $v3Token = Get-IdentityNowAuth

    if ($v3Token.access_token) {
        try {
            $IDNUpdateTransform = Invoke-RestMethod -Method Post -Uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/transform/update/$($ID)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "content-type" = "application/json" } -Body $transform
            return $IDNUpdateTransform
        }
        catch {
            Write-Error "Update of the Transform failed. Check Transform Configuration. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

