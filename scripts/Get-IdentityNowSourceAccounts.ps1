function Get-IdentityNowSourceAccounts {
    <#
.SYNOPSIS
    Get IdentityNow Accounts on a Source.

.DESCRIPTION
    Gets IdentityNow Accounts on a Source

.PARAMETER sourceID
    (required) The ID of an IdentityNow Source. eg. 45678

.EXAMPLE
    Get-IdentityNowSourceAccounts -sourceID 12345

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$sourceID
    )

    # v2 Auth
    $clientSecretv2 = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($IdentityNowConfiguration.v2.Password))
    $Bytes = [System.Text.Encoding]::utf8.GetBytes("$($IdentityNowConfiguration.v2.UserName):$($clientSecretv2)") 
    $encodedAuth = [Convert]::ToBase64String($Bytes)     
    $Headersv2 = @{Authorization = "Basic $($encodedAuth)" }
        
    try {
        if ($sourceID) {                
            $searchLimit = "2500"
            $sourceObjects = @()                 
            
            $results = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/accounts?sourceId=$($sourceID)&limit=$($searchLimit)&org=$($IdentityNowConfiguration.orgName)" -Headers $Headersv2                            
            if ($results) {
                $sourceObjects += $results
            }
            $offset = 0
            do { 
                if ($results.Count -eq $searchLimit) {
                    # Get Next Page
                    [int]$offset = $offset + $searchLimit 
                    $results = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/accounts?sourceId=$($sourceID)&limit=$($searchLimit)&offset=$($offset)&org=$($IdentityNowConfiguration.orgName)" -Headers $Headersv2      
                    if ($results) {
                        $sourceObjects += $results
                    }
                }
            } until ($results.Count -lt $searchLimit)
            return $sourceObjects
        }
    }
    catch {
        Write-Error "Source doesn't exist? Check SourceID and OrgName. $($_)" 
    }
}

