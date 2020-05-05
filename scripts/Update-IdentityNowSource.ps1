function Update-IdentityNowSource {
  <#
.SYNOPSIS
Update the configuration of an IdentityNow Source.

.DESCRIPTION
Update the configuration of an IdentityNow Source

.PARAMETER sourceID
(required) Id of the IdentityNow Source. e.g 12345

.PARAMETER update
(required) Sources change(s) to update 
e.g  name=SyntheticAttributes&description=Attributes for Provisioning Logic

.PARAMETER accountProfile
used to update the source account profile, pass the entire profile with updates

.EXAMPLE
Update-IdentityNowSource -sourceID 12345 -update 'name=SyntheticAttributes&description=Attributes for Provisioning Logic'

.EXAMPLE
Update-IdentityNowSource -sourceid 123456 -update 'connector_oauth_request_parameters={"scope":"users:read,users:write"}'

.EXAMPLE
$json='[{
  "description": null,
  "fields": [
    {
      "attributes": {},
      "isRequired": false,
      "multi": false,
      "name": "username",
      "transform": {
        "attributes": {
          "name": "uid"
        },
        "type": "identityAttribute"
      },
      "type": "string"
    }
  ],
  "name": "Account",
  "usage": "Create",
  "validPolicy": true
}]'
Update-IdentityNowSource -sourceID 123434 -accountProfile -update $json

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

  [cmdletbinding()]
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string]$sourceID,
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string]$update,
    [switch]$accountProfile
  )

  $v3Token = Get-IdentityNowAuth

  if ($v3Token.access_token) {
    try {                         
      if ($accountProfile) {
        $body = $update
        $updateSource = Invoke-RestMethod -Method Post -Uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/accountProfile/bulkUpdate/$($sourceID)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "Content-Type" = "application/json" } -Body $body
        return $updateSource
      }
      else {
        Write-Verbose "update ===> $($update)"
        $updateSource = Invoke-RestMethod -Method Post -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/source/update/$($sourceID)?$($update)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "Content-Type" = "application/json" }            
        return $updateSource
      }          
    }
    catch {
      Write-Error "Update failed. $($_)" 
    }
  }
  else {
    Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
    return $v3Token
  } 
}
