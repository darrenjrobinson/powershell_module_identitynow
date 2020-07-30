function Set-IdentityNowTransformLookup {
    <#
.SYNOPSIS
Update lookup transform

.DESCRIPTION
Create or update a dynamic reference transform based on external data

.PARAMETER Name
(string - Required) The name of the IdentityNow transform to update or create.

.PARAMETER Mappings
(hastable - required) Include full list of mappings and optionally 'default' key as a catch all

.EXAMPLE
$mappings = @{"US"="+1";"UK"="+44";"AU"="+61"}
Set-IdentityNowTransformLookup -Name "iso3166 2char to e164 prefix" -Mappings $mappings

.EXAMPLE
$mappings = @{"1"="Legal";"2"="Sales";"3"="IS";"default"="Corporate"}
Set-IdentityNowTransformLookup -Name "Team Code to Team Description" -Mappings $mappings

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false)]
        [string]$Name,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [hashtable]$Mappings
    )
    $body = [pscustomobject]@{
        id         = $Name
        type       = "lookup"
        attributes = [pscustomobject]@{
            table = $Mappings
        }
    }
    $testTransform = Get-IdentityNowTransform
    try {
        if ($testTransform.where{ $_.id -eq $name }) {
            $result = Update-IdentityNowTransform -transform ($body | convertto-json) -ID $name
        }
        else {
            $result = New-IdentityNowTransform -transform ($body | convertto-json)
        }
        return $result
    }
    catch {
        Write-Error "Failed to update transform. $($_)" 
    }
}