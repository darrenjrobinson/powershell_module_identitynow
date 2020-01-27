function Join-IdentityNowAccount {
    <#
.SYNOPSIS
    Join an IdentityNow User Account to an Identity.

.DESCRIPTION
    Manually correlate an IdentityNow User Account with an identity account.

.PARAMETER source
    SailPoint IdentityNow Source ID
    e.g 12345

.PARAMETER Identity
    Identity UID

.PARAMETER Account
    Account ID

.EXAMPLE
    Join-IdentityNowAccount -source 12345 -identity jsmith -account 012345

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$account,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$source,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Identity
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
            $csv = @()
            $csv = $csv + 'account,displayName,userName,type'
            $csv = $csv + "$account,$account,$identity,"
            $result = Invoke-restmethod -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/source/loadUncorrelatedAccounts/$source" `
                -Method "POST" `
                -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "Accept-Encoding" = "gzip, deflate, br"} `
                -ContentType "multipart/form-data; boundary=----WebKitFormBoundaryU1hSZTy7cff3WW27" `
                -Body ([System.Text.Encoding]::UTF8.GetBytes("------WebKitFormBoundaryU1hSZTy7cff3WW27$([char]13)$([char]10)Content-Disposition: form-data; name=`"file`"; filename=`"temp.csv`"$([char]13)$([char]10)Content-Type: application/vnd.ms-excel$([char]13)$([char]10)$([char]13)$([char]10)$($csv | out-string)$([char]13)$([char]10)------WebKitFormBoundaryU1hSZTy7cff3WW27--$([char]13)$([char]10)")) `
                -UseBasicParsing
            return $result           
        }
        catch {
            Write-Error "Account couldn't be joined. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

