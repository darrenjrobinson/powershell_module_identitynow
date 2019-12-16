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
    $v3Token = Invoke-RestMethod -Method Post -Uri "$($oAuthURI)?grant_type=password&username=$($adminUSR)&password=$($adminPWD)" -Headers $Headersv3 

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

