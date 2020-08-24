function Export-IdentityNowConfig {
    <#
.SYNOPSIS
    Export IdentityNow configuration items

.DESCRIPTION
    Exports IdentityNow sources, roles, access profiles, email templates, to files for your records or to check into source control

.PARAMETER path
    (Required - string) folder path to export configuration items

.PARAMETER Items
    (optional - custom list array) if not specified, all items will be assumed, if specified you can list all items to be exported

.EXAMPLE
    Export-IdentityNowConfig -path 'c:\repos\IDN-Prod'

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.IO.FileInfo]$path,
        [ValidateSet('AccessProfile','APIClients','Applications','CertCampaigns','EmailTemplates','GovernanceGroups','IdentityAttributes','IdentityProfiles','OauthAPIClients','Roles','Rules','Sources','Transforms','VAClusters')]
        [string[]]$Items
    )
    if ($null -eq $Items){
        $Items = @('AccessProfile','APIClients','Applications','CertCampaigns','EmailTemplates','GovernanceGroups','IdentityAttributes','IdentityProfiles','OauthAPIClients','Roles','Rules','Sources','Transforms','VAClusters')
    }
    if ($Items -contains 'AccessProfile'){
        write-progress -activity 'AccessProfile'
        $AccessProfile=Get-IdentityNowAccessProfile
        $AccessProfile | ConvertTo-Json | Set-Content "$($path.Directory)\AccessProfile.json"
    }
    if ($Items -contains 'APIClients'){
        write-progress -activity 'APIClients'
        $APIClients=Get-IdentityNowAPIClient
        $APIClients | ConvertTo-Json | Set-Content "$($path.Directory)\APIClients.json"
    }
    if ($Items -contains 'Applications'){
        write-progress -activity 'Applications'
        $Applications=Get-IdentityNowApplication
        $Applications | ConvertTo-Json | Set-Content "$($path.Directory)\Applications.json"
    }
    if ($Items -contains 'CertCampaigns'){
        write-progress -activity 'CertCampaigns'
        $CertCampaigns=Get-IdentityNowCertCampaign
        $CertCampaigns | ConvertTo-Json | Set-Content "$($path.Directory)\CertCampaigns.json"
    }
    if ($Items -contains 'EmailTemplates'){
        write-progress -activity 'EmailTemplates'
        $EmailTemplates=Get-IdentityNowEmailTemplate
        $EmailTemplates | ConvertTo-Json | Set-Content "$($path.Directory)\EmailTemplates.json"
    }
    if ($Items -contains 'GovernanceGroups'){
        write-progress -activity 'GovernanceGroups'
        $GovernanceGroups=Get-IdentityNowGovernanceGroup
        $GovernanceGroups | ConvertTo-Json | Set-Content "$($path.Directory)\GovernanceGroups.json"
    }
    if ($Items -contains 'IdentityAttributes'){
        write-progress -activity 'IdentityAttributes'
        $IdentityAttributes=Get-IdentityNowIdentityAttribute
        $IdentityAttributes | ConvertTo-Json | Set-Content "$($path.Directory)\IdentityAttributes.json"
    }
    if ($Items -contains 'IdentityProfiles'){
        write-progress -activity 'IdentityProfiles'
        $idp=Get-IdentityNowProfile
        foreach ($profile in $idp){
            $profile=Get-IdentityNowProfile -ID $profile.id
        }
        $idp | convertto-json | Set-Content "$($path.Directory)\IdentityProfiles.json"
    }
    if ($Items -contains 'OauthAPIClients'){
        write-progress -activity 'OauthAPIClients'
        $OauthAPIClients=Get-IdentityNowOAuthAPIClient
        $OauthAPIClients | ConvertTo-Json | Set-Content "$($path.Directory)\OauthAPIClients.json"
    }
    if ($Items -contains 'Roles'){
        write-progress -activity 'Roles'
        $roles=Get-IdentityNowRole
        $roles | ConvertTo-Json | Set-Content "$($path.Directory)\roles.json"
    }
    if ($Items -contains 'Rules'){
        write-progress -activity 'Rules'
        $rules=Get-IdentityNowRule
        $rules | convertto-json | Set-Content "$($path.Directory)\rules.json"
    }
    if ($Items -contains 'Sources'){
        write-progress -activity 'Sources'
        $sources=Get-IdentityNowSource
        foreach ($source in $sources){
            $source = Get-IdentityNowSource -sourceID $source.id
            $source | Add-Member -NotePropertyName 'accountProfiles' -NotePropertyValue (Get-IdentityNowSource -sourceID $source.id -accountProfiles) -Force
            $source | Add-Member -NotePropertyName 'Schema' -NotePropertyValue (Get-IdentityNowSourceSchema -sourceID $source.id) -Force
        }
        $sources | convertto-json | Set-Content "$($path.Directory)\sources.json"
    }    
    if ($Items -contains 'Transforms'){
        write-progress -activity 'Transforms'
        $transforms=Get-IdentityNowTransform
        $transforms | convertto-json | Set-Content "$($path.Directory)\Transforms.json"
    }
    if ($Items -contains 'VAClusters'){
        write-progress -activity 'VAClusters'
        $VAClusters=Get-IdentityNowVACluster
        $VAClusters | convertto-json | Set-Content "$($path.Directory)\VAClusters.json"
    }
}