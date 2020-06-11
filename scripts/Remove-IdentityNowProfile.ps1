function Remove-IdentityNowProfile {
    <#
.SYNOPSIS
Delete an IdentityNow Identity Profile.

.DESCRIPTION
Delete an IdentityNow Identity Profile.

.PARAMETER profileIDs
(required) The profile ID or IDs of the IdentityNow Identity Profile to delete.

.EXAMPLE
Remove-IdentityNowProfile -profileIDs 1234

.EXAMPLE
$ExistingIDPs = Get-IdentityNowProfile
$myIDP = $ExistingIDPs | Select-Object | Where-Object {$_.name -like "*My Identity Profile*"}
Remove-IdentityNowProfile -profileIDs $myIDP.id

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$profileIDs
    )

    $v3Token = Get-IdentityNowAuth

    if ($v3Token.access_token) {
        try {   
            $profID = "profileIds=$($profileIds -join ',')"
            Write-Verbose $profID
            $IDNDeleteIDP = Invoke-RestMethod -Method Post -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/profile/bulkDelete" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" ; "Content-Type" = "application/x-www-form-urlencoded; charset=UTF-8"} -Body $profID
            return $IDNDeleteIDP
        }
        catch {
            Write-Error "Deletion of Identity Profile failed. Check Identity Profile ID and format (JSON). $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

