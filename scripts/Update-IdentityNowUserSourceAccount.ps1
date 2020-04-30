function Update-IdentityNowUserSourceAccount {
    <#
.SYNOPSIS
Update an IdentityNow User Account on a Flat File Source.

.DESCRIPTION
Update an IdentityNow User Account on a Flat File Source

.PARAMETER account
(required) Id of the Account to Update. e.g 2c91808365bd1f010165caf761625bcd

.PARAMETER update
(required - JSON) Account changes to update account
{
    "department":  "Identity Architects",
    "organization":  "Kloud",
    "country":  "Australia"
}

.EXAMPLE
Update-IdentityNowUserSourceAccount -account 2c91808365bd1f010165caf761625bcd -update "{"department":  "Identity Architects","organization":  "Kloud","country":  "Australia"}"

.Example
    $user = Search-IdentityNowUsers -query "@accounts(accountId:darrenjrobinson)"
    $userIndirectAccounts = $user.accounts | select-object | where-object {($_.source.type.contains("DelimitedFile"))}
    $account = $userIndirectAccounts[0].id 
    $update = @{"country" = "Australia"; "department" = "Identity Architects"; "organization" = "Kloud"} | ConvertTo-Json 

    Update-IdentityNowUserSourceAccount -account $account -update $update 

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$account,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$update
    )

    # IdentityNow Admin User
    $adminUSR = [string]$IdentityNowConfiguration.AdminCredential.UserName.ToLower()
    $adminPWDClear = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($IdentityNowConfiguration.AdminCredential.Password))

    # Generate the account hash
    $hashUser = Get-HashString $adminUSR.ToLower() 
    $adminPWD = Get-HashString "$($adminPWDClear)$($hashUser)"  

    $clientSecretv3 = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($IdentityNowConfiguration.v3.Password))

    # Basic Auth
    $Bytesv3 = [System.Text.Encoding]::utf8.GetBytes("$($IdentityNowConfiguration.v3.UserName):$($clientSecretv3)")
    $encodedAuthv3 = [Convert]::ToBase64String($Bytesv3)
    $Headersv3 = @{Authorization = "Basic $($encodedAuthv3)" }

    # Get v3 oAuth Token
    # oAuth URI
    $oAuthURI = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/oauth/token"
    $oAuthTokenBody = @{
        grant_type = "password"
        username = $adminUSR
        password = $adminPWD
    }
    $v3Token = Invoke-RestMethod -Uri $oAuthURI -Method Post -Body $oAuthTokenBody -Headers $Headersv3 

    if ($v3Token.access_token) {
        try {                         
            $updateAccount = Invoke-RestMethod -Method Patch -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/accounts/$($account)?org=$($IdentityNowConfiguration.orgName)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "Content-Type" = "application/json"} -Body $update
            return $updateAccount           
        }
        catch {
            Write-Error "User not found. Update failed. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

