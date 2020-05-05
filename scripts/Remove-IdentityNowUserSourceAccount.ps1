function Remove-IdentityNowUserSourceAccount {
    <#
.SYNOPSIS
Delete an IdentityNow User Account on a Flat File Source.

.DESCRIPTION
Delete an IdentityNow User Account on a Flat File Source.

.PARAMETER account
(required) Id of the Flat File Account to Delete. e.g 2c91808365bd1f010165caf761625bcd

.EXAMPLE
Remove-IdentityNowUserSourceAccount -account 2c91808365bd1f010165caf761625bcd 

.Example
    $user = Search-IdentityNowUsers -query "@accounts(accountId:darrenjrobinson)"
    $userIndirectAccounts = $user.accounts | select-object | where-object {($_.source.type.contains("DelimitedFile"))}
    $account = $userIndirectAccounts[0].id     

    Remove-IdentityNowUserSourceAccount -account $account  

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$account
    )

    $v3Token = Get-IdentityNowAuth

    if ($v3Token.access_token) {
        try {                         
            $deleteAccount = Invoke-RestMethod -Method Delete -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/accounts/$($account)?org=$($IdentityNowConfiguration.orgName)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "Content-Type" = "application/json"} 
            return $deleteAccount          
        }
        catch {
            Write-Error "Account not found. Account Deletion failed. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

