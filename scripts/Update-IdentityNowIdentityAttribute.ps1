function Update-IdentityNowIdentityAttribute {
    <#
.SYNOPSIS
Update an IdentityNow Identity Attribute to be listed in Identity Profiles.

.DESCRIPTION
Update an IdentityNow Identity Attribute to be listed in Identity Profiles.

.PARAMETER attribute
(required) The identity attribue to index.

.EXAMPLE
Update-IdentityNowGovernanceGroup -attribute adSID

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$attribute
    )

    $v3Token = Get-IdentityNowAuth

    if ($v3Token.access_token) {
        try {
            $identityAttr = Get-IdentityNowIdentityAttribute -attribute $attribute
            # Update an Attribute to be searchable 
            $identityAttr.searchable = $true 
            $identityAttrSources = $identityAttr.sources | convertto-json 
            $identityAttr.sources = $null 
            $identityAttr.targets = $null 
            $identityAttrUpdate = $identityAttr | convertTo-json

            $identityAttrSources = '"sources": [' + $identityAttrSources + ']' 

            $identityAttrBody = $identityAttrUpdate.Replace("`"sources`":  null", $identityAttrSources)
            $identityAttrBody = $identityAttrBody.Replace("`"extendedNumber`":  null,", "" )
            $identityAttrBody = $identityAttrBody.Replace("`"targets`":  null,", "" )

            $updateAttribute = Invoke-RestMethod -Method Post -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/identityAttribute/update?name=$($attribute)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" ; "content-type" = "application/json"} -Body $identityAttrBody
#            $updateAttribute = Invoke-RestMethod -Method Post -Uri "https://$($orgName).api.identitynow.com/cc/api/identityAttribute/update?name=$($attrToIndex.name)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "content-type" = "application/json"} -Body $identityAttrBody 
            return $updateAttribute
        }
        catch {
            Write-Error "Identity Attribute doesn't exist. Check attribue name. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

