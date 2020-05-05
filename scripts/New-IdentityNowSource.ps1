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
New-IdentityNowSource -name 'Dev - JDBC - ASQL - Users Table' -description 'Azure SQL users table' -connectorname 'JDBC' -sourcetype DIRECT_CONNECT

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
        [validateset('DIRECT_CONNECT', 'DELIMITED_FILE')][string]$sourcetype
    )
    $v3Token = Get-IdentityNowAuth

    if ($v3Token.access_token) {
        try {
            $privateuribase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com"
            $url = "$privateuribase/cc/api/source/create"
            $body = "serviceDefinitionName=$connectorname&name=$name&description=$description&sourceType=$sourcetype&serviceType=app"
            $response = Invoke-WebRequest -Uri $url -Method Post -UseBasicParsing -Body $body -ContentType 'application/x-www-form-urlencoded' -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
            $sourceAccountProfile = $response.Content | ConvertFrom-Json
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