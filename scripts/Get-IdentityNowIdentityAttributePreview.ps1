function Get-IdentityNowIdentityAttributePreview {
    <#
.SYNOPSIS
Get an IdentityNow Identity Attribute Mapping Preview.

.DESCRIPTION
see the before and after on a person for a single attribute

.PARAMETER attribute
(optional) The identity attribue to retrieve. 

.PARAMETER uid
(Required) The uid of the user.

.PARAMETER IDP
(Required) the name or ID of the Identity Profile

.EXAMPLE
Get-IdentityNowIdentityAttributePreview -IDP "Employees" -attribute country -uid testUser

.EXAMPLE
Get-IdentityNowIdentityAttributePreview -uid testUser -IDP "Employees" -attributes @('division','c') -differencesOnly

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$uid,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$IDP,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string[]]$attributes,
        [switch]$differencesOnly
    )
    $queryFilter = "{`"query`":{`"query`":`"$uid`"},`"includeNested`":false}"
    $user=Search-IdentityNowIdentities $queryFilter
    $Uri="$((Get-IdentityNowOrg).'Private Base API URI')/user/preview/$($user[0].id)"
    $a=(Get-IdentityNowProfile).where{$_.name -eq $IDP -or $_.id -eq $IDP}.id | get-identitynowprofile
    $body=$a.attributeConfig | Select-Object attributeTransforms | convertto-json -depth 10
    $preview=Invoke-IdentityNowRequest -method POST -uri $uri -headers Headersv3_JSON -body $body
    if ($attributes){
        if ($differencesOnly){
            return $preview.previewAttributes.where{$_.previousValue -ne $_.value -and $_.name -in $attributes}
        }else{
            return $preview.previewAttributes.where{$_.name -in $attributes}
        }        
    }else{
        if ($differencesOnly){
            $preview.previewAttributes=$preview.previewAttributes.where{$_.previousValue -ne $_.value}
            return $preview
        }else{
            return $preview
        }
    }    
}