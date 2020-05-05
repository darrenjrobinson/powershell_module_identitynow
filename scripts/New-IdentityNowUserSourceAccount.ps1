function New-IdentityNowUserSourceAccount {
    <#
.SYNOPSIS
    Create an IdentityNow User Account on a Flat File Source.

.DESCRIPTION
    Create an IdentityNow User Account on a Flat File Source

.PARAMETER source
    SailPoint IdentityNow Source ID
    e.g 12345

.PARAMETER account
    (required - JSON) Account details
    e.g
    {
        "id":  "darrenjrobinson",
        "name":  "darrenjrobinson",
        "displayName":  "Darren Robinson",
        "email":  "darren.robinson@customer.com.au",
        "familyName":  "Robinson",
        "givenName":  "Darren"
    }

.EXAMPLE
    New-IdentityNowUserSourceAccount -source 12345 -account "{"id":  "darrenjrobinson","name":  "darrenjrobinson","displayName":  "Darren Robinson","email":  "darren.robinson@customer.com.au","familyName":  "Robinson","givenName":  "Darren"}"

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$account,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$sourceID
    )

    $v3Token = Get-IdentityNowAuth

    if ($v3Token.access_token) {
        try {                         
            $createAccount = Invoke-RestMethod -Method Post -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/accounts?sourceId=$($sourceId)&org=$($IdentityNowConfiguration.orgName)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "Content-Type" = "application/json"} -Body $account 
            return $createAccount           
        }
        catch {
            Write-Error "Account couldn't be created. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

