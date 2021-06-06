function Export-IdentityNowConfig {
    <#
.SYNOPSIS
    Export IdentityNow configuration items

.DESCRIPTION
    Exports IdentityNow Access Profiles, APIClients, Applications, Cert Campaigns, Email Templates, Governance Groups, Identity Attributes, Identity Profiles, OAuth API Clients, Roles, Rules, Sources, Transforms, VAClusters, to files to make comparions or check into source control

.PARAMETER path
    (Required - string) folder path to export configuration items

.PARAMETER Items
    (optional - custom list array) if not specified, all items will be assumed, if specified you can list all items to be exported

.EXAMPLE
    Export-IdentityNowConfig -path 'c:\repos\IDN-Prod'

.EXAMPLE
    Export-IdentityNowConfig -path 'c:\repos\IDN-Prod' -Items Rules,Roles

.EXAMPLE
    Set-IdentityNowOrg myCompanyProd
    Export-IdentityNowConfig -path "C:\repos\IDNConfig\$((Get-IdentityNowOrg).'Organisation Name')" 
    Set-IdentityNowOrg myCompanySandbox
    Export-IdentityNowConfig -path "C:\repos\IDNConfig\$((Get-IdentityNowOrg).'Organisation Name')"

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.IO.FileInfo]$path,
        [ValidateSet('AccessProfile', 'APIClients', 'Applications', 'CertCampaigns', 'EmailTemplates', 'GovernanceGroups', 'IdentityAttributes', 'IdentityProfiles', 'OAuthAPIClients', 'Roles', 'Rules', 'Sources', 'Transforms', 'VAClusters')]
        [string[]]$Items
    )
    if ($path.mode -ne 'd----') { Write-Error "provided path is not a directory: $path"; break }
    if ($null -eq $Items) {
        $Items = @('AccessProfile', 'APIClients', 'Applications', 'CertCampaigns', 'EmailTemplates', 'GovernanceGroups', 'IdentityAttributes', 'IdentityProfiles', 'OAuthAPIClients', 'Roles', 'Rules', 'Sources', 'Transforms', 'VAClusters')
    }
    if ($path.fullname.lastindexof('\') -eq $path.fullname.length - 1) { [System.IO.FileInfo]$path = $path.FullName.Substring(0, $path.FullName.length - 1) }
    if ($Items -contains 'AccessProfile') {
        write-progress -activity 'AccessProfile'
        $AccessProfile = Get-IdentityNowAccessProfile
        $AccessProfile | convertto-json -depth 10 | Set-Content "$($path.FullName)\AccessProfile.json"
    }
    if ($Items -contains 'APIClients') {
        write-progress -activity 'APIClients'
        $APIClients = Get-IdentityNowAPIClient
        $detailedAPIClients = @()
        foreach ($client in $APIClients) {
            $client = Get-IdentityNowAPIClient -ID $client.id
            $detailedAPIClients += $client
        }
        $detailedAPIClients | convertto-json -depth 10 | Set-Content "$($path.FullName)\APIClients.json"
    }
    if ($Items -contains 'Applications') {
        write-progress -activity 'Applications'
        $Applications = Get-IdentityNowApplication
        $detailedApplications = @()
        foreach ($app in $Applications) {
            $app = Get-IdentityNowApplication -appID $app.id
            $detailedApplications += $app
        }
        $detailedApplications | convertto-json -depth 10 | Set-Content "$($path.FullName)\Applications.json"
    }
    if ($Items -contains 'CertCampaigns') {
        write-progress -activity 'CertCampaigns'
        $CertCampaigns = Get-IdentityNowCertCampaign
        $CertCampaigns | convertto-json -depth 10 | Set-Content "$($path.FullName)\CertCampaigns.json"
    }
    if ($Items -contains 'EmailTemplates') {
        write-progress -activity 'EmailTemplates'
        $EmailTemplates = Get-IdentityNowEmailTemplate
        $EmailTemplates | convertto-json -depth 10 | Set-Content "$($path.FullName)\EmailTemplates.json"
    }
    if ($Items -contains 'GovernanceGroups') {
        write-progress -activity 'GovernanceGroups'
        $GovernanceGroups = Get-IdentityNowGovernanceGroup
        $GovernanceGroups | convertto-json -depth 10 | Set-Content "$($path.FullName)\GovernanceGroups.json"
    }
    if ($Items -contains 'IdentityAttributes') {
        write-progress -activity 'IdentityAttributes'
        $IdentityAttributes = Get-IdentityNowIdentityAttribute
        $IdentityAttributes | convertto-json -depth 10 | Set-Content "$($path.FullName)\IdentityAttributes.json"
    }
    if ($Items -contains 'IdentityProfiles') {
        write-progress -activity 'IdentityProfiles'
        $idp = Get-IdentityNowProfile
        $detailedIDP = @()
        foreach ($profile in $idp) {
            $profile = Get-IdentityNowProfile -ID $profile.id
            $detailedIDP += $profile
        }
        $detailedIDP | convertto-json -depth 10 | Set-Content "$($path.FullName)\IdentityProfiles.json"
    }
    if ($Items -contains 'OauthAPIClients') {
        write-progress -activity 'OauthAPIClients'
        $OauthAPIClients = Get-IdentityNowOAuthAPIClient
        $OauthAPIClients | convertto-json -depth 10 | Set-Content "$($path.FullName)\OAuthAPIClients.json"
    }
    if ($Items -contains 'Roles') {
        write-progress -activity 'Roles'
        $roles = Get-IdentityNowRole
        $detailedroles = @()
        foreach ($role in $roles) {
            $temp = Get-IdentityNowRole -roleID $role.id
            $role | Add-Member -NotePropertyName selector -NotePropertyValue $temp.selector -Force
            $role | Add-Member -NotePropertyName approvalSchemes -NotePropertyValue $temp.approvalSchemes -Force
            $role | Add-Member -NotePropertyName deniedCommentsRequired -NotePropertyValue $temp.deniedCommentsRequired -Force
            $role | Add-Member -NotePropertyName identityCount -NotePropertyValue $temp.identityCount -Force
            $role | Add-Member -NotePropertyName revokeRequestApprovalSchemes -NotePropertyValue $temp.revokeRequestApprovalSchemes -Force
            $detailedroles += $role
        }
        $detailedroles | convertto-json -depth 10 | Set-Content "$($path.FullName)\Roles.json"
    }
    if ($Items -contains 'Rules') {
        write-progress -activity 'Rules'
        $rules = Get-IdentityNowRule
        $rules | convertto-json -depth 10 | Set-Content "$($path.FullName)\Rules.json"
    }
    if ($Items -contains 'Sources') {
        write-progress -activity 'Sources'
        $sources = Get-IdentityNowSource
        $detailedsources = @()
        foreach ($source in $sources) {
            Write-Verbose "$($source.name)($($source.id))"
            write-progress -activity "Sources" -status "$($source.name)($($source.id)) details"
            do {
                $temp = $null
                $temp = Get-IdentityNowSource -sourceID $source.id
                Start-Sleep -Milliseconds 100
            }until($null -ne $temp)
            $source = $temp
            Write-Verbose "getting account profiles"
            write-progress -activity "Sources" -status "$($source.name)($($source.id)) account profiles"
            $source | Add-Member -NotePropertyName 'accountProfiles' -NotePropertyValue (Get-IdentityNowSource -sourceID $source.id -accountProfiles) -Force
            Write-Verbose "getting schema"
            write-progress -activity "Sources" -status "$($source.name)($($source.id)) schema"
            $source | Add-Member -NotePropertyName 'Schema' -NotePropertyValue (Get-IdentityNowSourceSchema -sourceID $source.id) -Force
            $detailedsources += $source
        }
        $detailedsources | convertto-json -depth 10 | Set-Content "$($path.FullName)\Sources.json"
    }    
    if ($Items -contains 'Transforms') {
        write-progress -activity 'Transforms'
        $transforms = Get-IdentityNowTransform
        $transforms | convertto-json -depth 10 | Set-Content "$($path.FullName)\Transforms.json"
    }
    if ($Items -contains 'VAClusters') {
        write-progress -activity 'VAClusters'
        $VAClusters = Get-IdentityNowVACluster
        $VAClusters | convertto-json -depth 10 | Set-Content "$($path.FullName)\VAClusters.json"
    }
}