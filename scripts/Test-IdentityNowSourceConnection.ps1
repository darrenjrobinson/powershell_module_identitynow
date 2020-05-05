function Test-IdentityNowSourceConnection {
    <#
.SYNOPSIS
Tests connection on an IdentityNow Source.

.DESCRIPTION
Test connection an IdentityNow Source.

.PARAMETER sourceid
(Required) The ID of the IdentityNow Source.

.EXAMPLE
Test-IdentityNowSourceConnection -sourceid 115340

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

.NOTES
written by Sean McGovern 11/20/2019 (twitter @410sean)

#>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$sourceid
    )
    $v3Token = Get-IdentityNowAuth

    if ($v3Token.access_token) {
        try {
            $privateuribase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com"
            $url = "$privateuribase/cc/api/source/testConnection/$sourceid"
            $response = Invoke-WebRequest -Uri $url -Method Post -UseBasicParsing -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
            $source = $response.Content | ConvertFrom-Json
            return $source
        }
        catch {
            Write-Error "Test connection of Source '$($sourceid)' failed. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}