function Get-IdentityNowSource {
    <#
.SYNOPSIS
    Get IdentityNow Source(s).

.DESCRIPTION
    Gets the configuration of an IdentityNow Source(s)

.PARAMETER sourceID
    (optional) The ID of an IdentityNow Source. eg. 45678

.PARAMETER accountProfiles
    (optional) get the account profiles such as create/update profile of an IdentityNow Source.

.EXAMPLE
    Get-IdentityNowSource 

.EXAMPLE
    Get-IdentityNowSource -sourceID 12345

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$sourceID,
        [switch]$accountProfiles
    )
    
    if ($accountProfiles -and $null -eq $sourceID) { Write-Warning "exporting the provisionng profiles requires a sourceID"; break }

    $v3Token = Get-IdentityNowAuth

    if ($v3Token.access_token) {
        try {
            if ($sourceID) {
                if ($accountProfiles) {
                    $IDNSources = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/accountProfile/list/$($sourceID)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
                }
                else {
                    $IDNSources = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/source/get/$($sourceID)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
                }                
                return $IDNSources
            }
            else {
                $IDNSources = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/source/list" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
                return $IDNSources
            }
        }
        catch {
            Write-Error "Source doesn't exist. Check SourceID. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

