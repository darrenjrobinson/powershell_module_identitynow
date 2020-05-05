function Remove-IdentityNowTransform {
    <#
.SYNOPSIS
Delete an IdentityNow Transform.

.DESCRIPTION
Delete an IdentityNow Transform.

.PARAMETER ID
The ID of the Transform to delete.

.EXAMPLE
Remove-IdentityNowTransform -ID "Firstname.LastName"

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$ID
    )

    $v3Token = Get-IdentityNowAuth

    if ($v3Token.access_token) {
        try {
            $IDNDeleteTransform = Invoke-RestMethod -Method Post -Uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/transform/delete/$($ID)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" } 
            return $IDNDeleteTransform
        }
        catch {
            Write-Error "Deletion of the Transform failed. Check Transform ID. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

