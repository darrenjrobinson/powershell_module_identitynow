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
    
    $v3Token = Get-IdentityNowAuth

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