function New-IdentityNowSourceAccountSchemaAttribute {
    <#
.SYNOPSIS
Discover or add to a sources' account schema.

.DESCRIPTION
Discover an IdentityNow Source Schema or add new attributes that may be imported.

.PARAMETER sourceID
(Required) IdentityNow Source ID.

.PARAMETER discover
this function may be run with just the Source ID and the discover switch to trigger IdentityNow's discover feature which will auto-populate the Account Schema

.PARAMETER name
the attribute name we wish to add to the account schema

.PARAMETER type
the attribute type

.PARAMETER description
a description of the attribute

.PARAMETER multivalue
a switch to indicate this attribute is multivalued

.EXAMPLE
New-IdentityNowSourceAccountSchemaAttribute -sourceID 12345 -name 'myNewAttr' -description 'My new attribute' -type 'STRING' 

.EXAMPLE
New-IdentityNowSourceAccountSchemaAttribute -sourceID 12345 -discover

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

.NOTES
written by Sean McGovern 11/20/2019 (twitter @410sean)

#>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$sourceid,
        [Parameter(ParameterSetName = 'Discover', Mandatory = $false)]
        [switch]$discover,
        [Parameter(ParameterSetName = 'Add', Mandatory = $true, ValueFromPipeline = $true)]
        [string]$name, 
        [Parameter(ParameterSetName = 'Add', Mandatory = $false, ValueFromPipeline = $true)]
        [string]$description, 
        [Parameter(ParameterSetName = 'Add', Mandatory = $true, ValueFromPipeline = $true)]
        [string]$type,
        [Parameter(ParameterSetName = 'Add', Mandatory = $false, ValueFromPipeline = $true)]
        [switch]$multivalued            
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
        
        $privateuribase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com"
        if ($discover) {
            try {
                $url = "$privateuribase/cc/api/source/discoverSchema/$sourceid"
                $response = Invoke-WebRequest -Uri $url -Method Post -UseBasicParsing -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
                $sourceSchema = $response.Content | ConvertFrom-Json
                return $sourceSchema
            }
            catch {
                Write-Error "Discover of Source failed. $($_)" 
            }
        }
        else {
            try {
                $url = "$privateuribase/cc/api/source/createSchemaAttribute/$sourceid"
                if ($multivalued -ne $true) {
                    $body = "name=$name&description=$description&type=$type&objectType=account"
                }
                else {
                    $body = "name=$name&description=$description&type=$type&multi=true&objectType=account"
                }
                $response = Invoke-WebRequest -Uri $url -Method Post -UseBasicParsing -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" } -Body $body
                $sourceSchema = $response.Content | ConvertFrom-Json
                return $sourceSchema
            }
            catch {
                Write-Error "Adding attribute to Source account schema failed. $($_)" 
            }
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}