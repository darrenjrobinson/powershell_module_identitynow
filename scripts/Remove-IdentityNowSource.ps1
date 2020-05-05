function Remove-IdentityNowSource {
    <#
.SYNOPSIS
Deletes an IdentityNow Source.

.DESCRIPTION
Deletes an IdentityNow Source. This will often fail if tasks are running or the source is in use by a transform or access profile.

.PARAMETER sourceid
(Required) The ID of the IdentityNow Source.

.EXAMPLE
Remove-IdentityNowSource -sourceid 115737

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
            $url = "$privateuribase/cc/api/source/delete/$sourceid"
            $response = Invoke-WebRequest -Uri $url -Method Post -UseBasicParsing -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
            $sourceAccountProfile = $response.Content | ConvertFrom-Json
            return $sourceAccountProfile
        }
        catch {
            Write-Error "deletion of Source failed. if the following error message states 'currently in use' that could be equivalent to 'tasks are running' $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}