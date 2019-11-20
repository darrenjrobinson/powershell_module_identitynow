function New-IdentityNowSource {
        <#
.SYNOPSIS
Create an IdentityNow Source.

.DESCRIPTION
Create an IdentityNow Source.

.PARAMETER name
(Required - string) The name of the new IdentityNow Source.

.PARAMETER description
(string) The description of the new IdentityNow Source. 

.PARAMETER connectorname
(Required) name of an available connector this source will use, for instance 'JDBC', 'Active Directory', 'Azure Active Directory', 'Web Services', or 'ServiceNow'

.PARAMETER sourcetype
(Required) must be 'DIRECT_CONNECT' for connecting to a source or 'DELIMITED_FILE' for flat file source

.EXAMPLE
new-IdentityNowSource -name 'Dev - JDBC - ASQL - Users Table' -description 'Azure SQL users table' -connectorname 'JDBC' -sourcetype DIRECT_CONNECT

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

.NOTES
written by Sean McGovern 11/20/2019 (twitter @410sean)

#>
    [cmdletbinding()]
        param(
            [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
            [string]$name, 
            [string]$description, 
            [string]$connectorname, 
            [validateset('DIRECT_CONNECT','DELIMITED_FILE')][string]$sourcetype
        )
    # IdentityNow Admin User
    $adminUSR = [string]$IdentityNowConfiguration.AdminCredential.UserName.ToLower()
    $adminPWDClear = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($IdentityNowConfiguration.AdminCredential.Password))

    # Generate the password hash
    # Requires Get-Hash from PowerShell Community Extensions (PSCX) Module 
    # https://www.powershellgallery.com/packages/Pscx/3.2.2
    $passwordHash = Get-Hash -Algorithm SHA256 -StringEncoding utf8 -InputObject ($($adminPWDClear) + (Get-Hash -Algorithm SHA256 -StringEncoding utf8 -InputObject ($adminUSR)).HashString.ToLower())
    $adminPWD = $passwordHash.ToString().ToLower() 

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
            $privateuribase="https://$($IdentityNowConfiguration.orgName).api.identitynow.com"
            $url="$privateuribase/cc/api/source/create"
            $body="serviceDefinitionName=$connectorname&name=$name&description=$description&sourceType=$sourcetype&serviceType=app"
            $response=Invoke-WebRequest -Uri $url -Method Post -UseBasicParsing -Body $body -ContentType 'application/x-www-form-urlencoded' -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"}
            $sourceAccountProfile=$response.Content | ConvertFrom-Json
            return $sourceAccountProfile
        }
        catch {
            Write-Error "Creation of new Source failed. Check Source Configuration. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}