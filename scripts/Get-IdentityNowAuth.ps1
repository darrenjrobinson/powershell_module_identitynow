function Get-IdentityNowAuth {
    <#
.SYNOPSIS
Get IdentityNow JWT access token or basic auth header.

.DESCRIPTION
Will return API v2 / v3 Auth Headers or JWT.

.PARAMETER return
authentication header/token to return (defaults to V3JWT)
- V2Header Digest Auth
- V3Header oAuth Access Token Bearer Header
- V3JWT oAuth JWT Token

.EXAMPLE
Get-IdentityNowAuth -return V2Header

.EXAMPLE
Get-IdentityNowAuth -return V3JWT

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [Parameter(ValueFromPipeline = $true)]
        [string][ValidateSet("V2Header", "V3Header", "V3JWT")]$return = 'V3JWT',
        [switch]$ForceRefresh
    )
    function Get-JWTDetails {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
            [string]$token
        )
    
        <#
    .SYNOPSIS
    Decode a JWT Access Token and convert to a PowerShell Object.
    JWT Access Token updated to include the JWT Signature (sig), JWT Token Expiry (expiryDateTime) and JWT Token time to expiry (timeToExpiry).
    .DESCRIPTION
    Decode a JWT Access Token and convert to a PowerShell Object.
    JWT Access Token updated to include the JWT Signature (sig), JWT Token Expiry (expiryDateTime) and JWT Token time to expiry (timeToExpiry).
    .PARAMETER token
    The JWT Access Token to decode and udpate with expiry time and time to expiry
    .INPUTS
    Token from Pipeline 
    .OUTPUTS
    PowerShell Object
    .SYNTAX
    Get-JWTDetails(accesstoken)
    .EXAMPLE
    PS> Get-JWTDetails('eyJ0eXAiOi........XmN4GnWQAw7OwMA')
    or
    PS> 'eyJ0eXAiOi........XmN4GnWQAw7OwMA' | Get-JWTDetails
    aud             : https://graph.microsoft.com
    iss             : https://sts.windows.net/74ea519d-1234-4aa9-86d9-b7cab8204aaa/
    iat             : 1564472277
    nbf             : 1564472277
    exp             : 1564476177
    acct            : 0
    acr             : 1
    aio             : AVQAq/8MAAAAAzB0vSr6FzZdn+4Rl0mv/akAo4CoJGUOzDRebOAz2s8IgJyRK7IONYU/57PHkLZYUswizziQS7QQ5l9w0DrqH4urxrexTpLbagQHvJlEaD6c=
    amr             : {pwd, mfa}
    app_displayname : Reporting
    appid           : 2c29e80e-ec64-43f7-b07a-137ae9c1d70c
    appidacr        : 1
    ipaddr          : 1.129.1.112
    name            : Darren J Robinson
    oid             : 5fddc979-ef08-4947-abcd-2430bc1234e0
    platf           : 3
    puid            : C1373BFDAE1A48F6
    scp             : AuditLog.Read.All Directory.Read.All Reports.Read.All
                      User.Read User.Read.All
    sub             : _31PG9C137LXuAkWDB93YM_eoRl9auP21qHOn5hO-s9w
    tid             : 74ea519d-9792-4aa9-c137-b7cab8204aaa
    unique_name     : darren@mytenant.onmicrosoft.com
    upn             : darren@mytenant.onmicrosoft.com
    uti             : eoWKGl9uZ0Gnc13715Qdff
    ver             : 1.0
    wids            : {4a5d8f65-41da-4de4-c137-f035b65339ca, c4e39bd9-c137-46d3-8c65-fb160df0071a, 5d6b6bb7-c137-4623-bafa-96380f352509}
    xms_tcdt        : 1341026666
    sig             : PUpl4F61Ql12nfxkLDeTA2Tucb7KfzrfbmI1+gNDPFfbe8WD3wlfr0EK2M89JNPJ1Z8H7Z8/JVU9Jbat2u+657D8IM81+NhnCpMvEWyC5565ZmIgE3vQKlBK3wD24kSzEFj6J2yL 
                      Zou1u/NrBvEakiiZdCJRKOB9nf4/euHHfYJNSKtPhLiPImyc137JxbPUG/MPjAQBkBPuUCyYtmFoBynGvsoSVvzZ6JQS5O2nxZPAqOFUzj5q3fjhh/oqPpu/6Qw1bdt3O37HgMLn 
                      UrBK3psjwUfP/X6//L6S1FwomenNoFVeKcUNcM5Ne6loDwRSW1Ig8XHXmN4GnWQAw7OwMA==
    expiryDateTime  : 30/07/2019 6:42:57 PM
    timeToExpiry    : -00:32:56.1103767
    .EXAMPLE
    PS> Get-JWTDetails($myAccessToken)
    or 
    PS> $myAccessToken | Get-JWTDetails
    tenant_id             : cd988f3c-710c-43eb-9e25-123456789
    internal              : False
    pod                   : uswest2
    org                   : myOrd
    identity_id           : 1c818084624f8babcdefgh9a4
    user_name             : adminDude
    strong_auth_supported : True
    user_id               : 100666
    scope                 : {read, write}
    exp                   : 1564474732
    jti                   : 1282411c-ffff-1111-a9d0-f9314a123c7a
    sig                   : SWPhCswizzleQWdM4K8A8HotX5fP/PT8kBWnaaAf2g6k=
    expiryDateTime        : 30/07/2019 6:18:52 PM
    timeToExpiry          : -00:57:37.4457299
    .LINK
    https://blog.darrenjrobinson.com
    https://blog.darrenjrobinson.com/jwtdetails-powershell-module-for-decoding-jwt-access-tokens-with-readable-token-expiry-time/ 
    #>
    
    
        if (!$token.Contains(".") -or !$token.StartsWith("eyJ")) { Write-Error "Invalid token" -ErrorAction Stop }
    
        # Token
        foreach ($i in 0..1) {
            $data = $token.Split('.')[$i].Replace('-', '+').Replace('_', '/')
            switch ($data.Length % 4) {
                0 { break }
                2 { $data += '==' }
                3 { $data += '=' }
            }
        }
    
        $decodedToken = [System.Text.Encoding]::UTF8.GetString([convert]::FromBase64String($data)) | ConvertFrom-Json 
        Write-Verbose "JWT Token:"
        Write-Verbose $decodedToken
    
        # Signature
        foreach ($i in 0..2) {
            $sig = $token.Split('.')[$i].Replace('-', '+').Replace('_', '/')
            switch ($sig.Length % 4) {
                0 { break }
                2 { $sig += '==' }
                3 { $sig += '=' }
            }
        }
        Write-Verbose "JWT Signature:"
        Write-Verbose $sig
        $decodedToken | Add-Member -Type NoteProperty -Name "sig" -Value $sig
    
        # Convert Expiry time to PowerShell DateTime
        $orig = (Get-Date -Year 1970 -Month 1 -Day 1 -hour 0 -Minute 0 -Second 0 -Millisecond 0)
        $timeZone = Get-TimeZone
        $utcTime = $orig.AddSeconds($decodedToken.exp)
        $hoursOffset = $timeZone.GetUtcOffset($(Get-Date)).hours #Daylight saving needs to be calculated
        $localTime = $utcTime.AddHours($hoursOffset)     # Return local time,
        $decodedToken | Add-Member -Type NoteProperty -Name "expiryDateTime" -Value $localTime
        
        # Time to Expiry
        $timeToExpiry = ($localTime - (get-date))
        $decodedToken | Add-Member -Type NoteProperty -Name "timeToExpiry" -Value $timeToExpiry
    
        return $decodedToken
    }
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
    if ($IdentityNowConfiguration.JWT.refresh_token) {
        $oAuthTokenBody = @{
            grant_type    = "refresh_token"
            client_id     = (get-jwtdetails $IdentityNowConfiguration.JWT.access_token).client_id
            client_secret = $null
            refresh_token = $IdentityNowConfiguration.JWT.refresh_token
        }
        if ($oAuthTokenBody.client_id -eq $IdentityNowConfiguration.v3.UserName) {
            $oAuthTokenBody.client_secret = $clientSecretv3
        }
        elseif ($oAuthTokenBody.client_id -eq $IdentityNowConfiguration.PAT.UserName) {
            $oAuthTokenBody.client_secret = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($IdentityNowConfiguration.PAT.Password))
        }
    }
    elseif ($IdentityNowConfiguration.PAT) {
        $oAuthTokenBody = @{
            grant_type    = "client_credentials"
            client_id     = $IdentityNowConfiguration.PAT.UserName
            client_secret = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($IdentityNowConfiguration.PAT.Password))
        }
    }
    else {
        $oAuthTokenBody = @{
            grant_type = "password"
            username   = $adminUSR
            password   = $adminPWD
        }        
    }
    if (-not $IdentityNowConfiguration.JWT) { $forcerefresh = $true }
    if ($ForceRefresh -or ((get-jwtdetails $IdentityNowConfiguration.JWT.access_token).expiryDateTime -lt (get-date).addminutes(1) -and (get-jwtdetails $IdentityNowConfiguration.JWT.access_token).org -eq $IdentityNowConfiguration.orgName)) {
        Write-Verbose ($oAuthTokenBody | convertto-json)
        if ($oAuthTokenBody.grant_type -ne 'password') { $Headersv3 = $null }
        $v3Token = Invoke-RestMethod -Uri $oAuthURI -Method Post -Body $oAuthTokenBody -Headers $Headersv3
        $IdentityNowConfiguration.JWT = $v3Token
    }
    else {
        $v3Token = $IdentityNowConfiguration.JWT
    }

    # v2 Auth
    $clientSecretv2 = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($IdentityNowConfiguration.v2.Password))
    $Bytes = [System.Text.Encoding]::utf8.GetBytes("$($IdentityNowConfiguration.v2.UserName):$($clientSecretv2)") 
    $encodedAuth = [Convert]::ToBase64String($Bytes)     

    switch ($return) {
        V2Header { 
            $requestHeaders = @{Authorization = "Basic $($encodedAuth)" }
            Write-Verbose "Authorization = Basic $($encodedAuth)"
        }
        V3Header { 
            $requestHeaders = @{Authorization = "Bearer $($v3Token.access_token)" }
            Write-Verbose "Authorization = Bearer $($v3Token.access_token)"
        }
        V3JWT { 
            $requestHeaders = $v3Token
            Write-Verbose $v3Token
        }
        default { 
            $requestHeaders = $Headersv3 
        } 
    }
    
    Write-Verbose $requestHeaders
    return $requestHeaders
}
