function Get-IdentityNowIdentityAttributePreview {
    <#
.SYNOPSIS
Get an IdentityNow Identity Attribute Mapping Preview.

.DESCRIPTION
see the before and after on a person for a single attribute

.PARAMETER attribute
(Required) The identity attribue to retrieve.

.PARAMETER uid
(Required) The uid of the user.

.PARAMETER IDP
(Required) the name or ID of the Identity Profile

.EXAMPLE
Get-IdentityNowIdentityAttributePreview -attribute country -uid testUser

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$attribute,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$uid,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$IDP
    )
    $queryFilter = "{`"query`":{`"query`":`"$uid`"},`"includeNested`":false}"
    $user=Search-IdentityNowIdentities $queryFilter
    $Uri="$((Get-IdentityNowOrg).'Private Base API URI')/user/preview/$($user[0].id)"
    $a=(Get-IdentityNowProfile).where{$_.name -eq $IDP -or $_.id -eq $IDP}.id | get-identitynowprofile
    $body=$a.attributeConfig | Select-Object attributeTransforms | convertto-json -depth 10
    $preview=Invoke-IdentityNowRequest -method POST -uri $uri -headers Headersv3_JSON -body $body
    $atr=$preview.previewAttributes.where{$_.name -eq $attribute}
    $result=@()
    if ($atr.messages){Write-Warning $atr.messages.message}else{$result+=$atr.previousValue;$result+="\/\/\/\/\/\/";$result+=$atr.value}
    return $result
}
