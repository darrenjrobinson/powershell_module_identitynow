function Remove-IdentityNowPersonalAccessToken {
    <#
.SYNOPSIS
Delete a personal access token in IdentityNow.

.DESCRIPTION
Delete a personal access token in IdentityNow.

.PARAMETER id
(required) id of personal access token to delete

.EXAMPLE
Remove-IdentityNowPersonalAccessToken -id 36480043060f4562af28123456

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param( 
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]    
        [string]$id    
    )

    $v3Token = Get-IdentityNowAuthorization -return V3JWT

    if ($v3Token.access_token) {
        try {    
            $IDNDeletePAT = Invoke-RestMethod -Method Delete -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/beta/personal-access-tokens/$($id)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
            return $IDNDeletePAT
        }
        catch {
            Write-Error "Remove Personal Access Token failed. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $_
    } 
}

