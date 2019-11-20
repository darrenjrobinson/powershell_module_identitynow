function New-IdentityNowSourceAccountSchemaAttribute {
        <#
.SYNOPSIS
discover or add to a source's account schema.

.DESCRIPTION
Discover an IdentityNow Source Schema or add new attributes that may be imported.

.PARAMETER sourceID
(Required) IdentityNow Source ID.

.PARAMETER discover
this function may be run with just the Source ID and discover switch to trigger IdentityNows discover feature which will autopopulate the Account Schema

.PARAMETER name
the attribute name we wish to add to the account schema

.PARAMETER type
the attribute type

.PARAMETER description
a description of the attribute

.PARAMETER multivalue
a switch to indicate this attribute is multivalued

.EXAMPLE
new-IdentityNowSource -name 'Dev - JDBC - ASQL - Users Table' -description 'Azure SQL users table' -connectorname 'JDBC' -sourcetype DIRECT_CONNECT

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

.NOTES
written by Sean McGovern 11/20/2019 (twitter @410sean)

#>
    [cmdletbinding()]
        param(
            [Parameter(ParameterSetName='Discover',Mandatory = $true)]
            [switch]$discover,
            [Parameter(ParameterSetName='Add',Mandatory = $true, ValueFromPipeline = $true)]
            [string]$name, 
            [Parameter(ParameterSetName='Add',Mandatory = $false, ValueFromPipeline = $true)]
            [string]$description, 
            [Parameter(ParameterSetName='Add',Mandatory = $true, ValueFromPipeline = $true)]
            [string]$type,
            [Parameter(ParameterSetName='Add',Mandatory = $false, ValueFromPipeline = $true)]
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
        try {
            $privateuribase="https://$($IdentityNowConfiguration.orgName).api.identitynow.com"
            if ($discover){
                $url="$privateuribase/cc/api/source/discoverSchema/$sourceid"
                $response=Invoke-WebRequest -Uri $url -Method Post -UseBasicParsing -Headers $headerv3
                $sourceSchema=$response.Content | ConvertFrom-Json
                return $sourceSchema
            }else{
                $url="$privateuribase/cc/api/source/createSchemaAttribute/$sourceid"
                if ($multivalued -ne $true){
                    $body="name=$name&description=$description&type=$type&objectType=account"
                }else{
                    $body="name=$name&description=$description&type=$type&multi=true&objectType=account"
                }
                $response=Invoke-WebRequest -Uri $url -Method Post -UseBasicParsing -Headers $headerv3 -Body $body
                $sourceSchema=$response.Content | ConvertFrom-Json
                return $sourceSchema
            }
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