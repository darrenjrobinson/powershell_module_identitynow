function Export-IdentityNowConfig {
    <#
.SYNOPSIS
    Export IdentityNow configuration items

.DESCRIPTION
    Exports IdentityNow Access Profiles, APIClients, Applications, Cert Campaigns, Email Templates, Governance Groups, Identity Attributes, Identity Profiles, OAuth API Clients, Roles, Rules, Sources, Transforms, VAClusters, to files to make comparisons or check into source control

.PARAMETER path
    (Required - string) folder path to export configuration items

.PARAMETER Items
    (optional - custom list array) if not specified, all items will be assumed, if specified you can list all items to be exported

.PARAMETER NullDynamicValues
    (optional - custom list) if included, will null frequently changing values
    Full = more thurough in nulling values
    Minimal = will leave in some values such as VA version, identity count, account count
    
.EXAMPLE
    Export-IdentityNowConfig -path 'c:\repos\IDN-Prod'

.EXAMPLE
    Export-IdentityNowConfig -path 'c:\repos\IDN-Prod' -Items Rules,Roles

.EXAMPLE
    Set-IdentityNowOrg myCompanyProd
    Export-IdentityNowConfig -path "C:\repos\IDNConfig\$((Get-IdentityNowOrg).'Organisation Name')" 
    Set-IdentityNowOrg myCompanySandbox
    Export-IdentityNowConfig -path "C:\repos\IDNConfig\$((Get-IdentityNowOrg).'Organisation Name')"

.EXAMPLE
    #check in changes to git repository, change path to fit your local git repo
    foreach ($org in @('contoso','contosotest')){
        Set-IdentityNowOrg $org
        $path="C:\scripts\IdentityNow\IdentityNow\$((Get-IdentityNowOrg).'Organisation Name')"
        if (-not (test-path $path)){mkdir $path}
        Remove-Item -Path "$path\*" -Recurse
        Export-IdentityNowConfig -path $path -NullDynamicValues Full
    }
    git add .
    git commit -m "auto $((get-date).ToString())"
    git push

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$path,
        [Parameter(Mandatory = $false)]
        [ValidateSet('Minimal', 'Full')]
        [string]$NullDynamicValues,
        [ValidateSet('AccessProfile', 'APIClients', 'Applications', 'CertCampaigns', 'EmailTemplates', 'GovernanceGroups', 'IdentityAttributes', 'IdentityProfiles', 'OAuthAPIClients', 'Roles', 'Rules', 'Sources', 'Transforms', 'VAClusters')]
        [string[]]$Items
    )
    
    if ($PSVersionTable.PSVersion.Major -le 5) { 
        $outputpath = Get-ItemProperty -Path $path 
        if ($outputpath.mode -ne 'd-----') { Write-Error "provided path is not a directory: $outputpath"; break }
    }
    elseif ($PSVersionTable.PSVersion.Major -gt 5) { 
        [System.IO.FileInfo]$outputpath = $path
        if ($outputpath.mode -ne 'd----') { Write-Error "provided path is not a directory: $outputpath"; break }
    }

    if ($null -eq $Items) {
        $Items = @('AccessProfile', 'APIClients', 'Applications', 'CertCampaigns', 'EmailTemplates', 'GovernanceGroups', 'IdentityAttributes', 'IdentityProfiles', 'OAuthAPIClients', 'Roles', 'Rules', 'Sources', 'Transforms', 'VAClusters')
    }
    if ($outputpath.fullname.lastindexof('\') -eq $outputpath.fullname.length - 1) { [System.IO.FileInfo]$outputpath = $outputpath.FullName.Substring(0, $outputpath.FullName.length - 1) }
    if ($Items -contains 'AccessProfile') {
        write-progress -activity 'AccessProfile'
        $AccessProfile = Get-IdentityNowAccessProfile
        if ($NullDynamicValues) {
            #no dynamic values in this output
        }
        #"set-content $($outputpath.FullName)\AccessProfile.json"
        $AccessProfile | convertto-json -depth 10 | Set-Content "$($outputpath.FullName)\AccessProfile.json"
    }
    if ($Items -contains 'APIClients') {
        write-progress -activity 'APIClients'
        $APIClients = Get-IdentityNowAPIClient
        $detailedAPIClients = @()
        foreach ($client in $APIClients) {
            $client = Get-IdentityNowAPIClient -ID $client.id
            $detailedAPIClients += $client
        }
        if ($NullDynamicValues) {
            foreach ($client in $detailedAPIClients) {
                if ($client.configuration.cookbook) {
                    $client.configuration.cookbook = $null
                }
                if ($client.configuration.jobType) {
                    $client.configuration.jobType = $null
                }
                if ($client.configuration.va_version) {
                    $client.configuration.va_version = $null
                }
                if ($client.lastSeen) {
                    $client.lastSeen = $null
                }
                if ($client.maintenance) {
                    $client.maintenance.windowStartTime = $null
                    $client.maintenance.windowClusterTime = $null
                    $client.maintenance.windowFinishTime = $null
                }
                if ($client.pollingPeriodTimestamp) {
                    $client.pollingPeriodTimestamp = $null
                }
                if ($client.sinceLastSeen) {
                    $client.sinceLastSeen = $null
                }
                if ($client.clusterJobCount -or $client.clusterJobCount -eq 0) {
                    $client.clusterJobCount = $null
                }
                if ($client.jobs) {
                    $client.jobs = @()
                }
                if ($NullDynamicValues -eq 'Full') {
                    if ($client.va_version) {
                        $client.va_version = $null
                    }
                }
            }
        }
        #"set-content $($outputpath.FullName)\APIClients.json"
        $detailedAPIClients | convertto-json -depth 10 | Set-Content "$($outputpath.FullName)\APIClients.json"
    }
    if ($Items -contains 'Applications') {
        write-progress -activity 'Applications'
        $Applications = Get-IdentityNowApplication
        $detailedApplications = @()
        foreach ($app in $Applications) {
            $app = Get-IdentityNowApplication -appID $app.id
            $detailedApplications += $app
        }
        if ($NullDynamicValues) {
            foreach ($app in $detailedApplications) {
                if ($app.health.lastChanged) {
                    $app.health.lastChanged = $null
                }
            }
        }
        #"set-content $($outputpath.FullName)\Applications.json"
        $detailedApplications | convertto-json -depth 10 | Set-Content "$($outputpath.FullName)\Applications.json"
    }
    if ($Items -contains 'CertCampaigns') {
        write-progress -activity 'CertCampaigns'
        $CertCampaigns = Get-IdentityNowCertCampaign -completed $true
        $activeCertCampaigns = Get-IdentityNowCertCampaign -completed $false 
        $CertCampaigns += $activeCertCampaigns
        if ($NullDynamicValues) {
            foreach ($campaign in $CertCampaigns) {
                if ($campaign.completedEntities) { $campaign.completedEntities = $null }
                if ($campaign.completedItems) { $campaign.completedItems = $null }
                if ($campaign.finished) { $campaign.finished = $null }
                if ($campaign.percentComplete) { $campaign.percentComplete = $null }
                if ($campaign.phase) { $campaign.phase = $null }
                if ($campaign.status) { $campaign.status = $null }
                if ($campaign.completedCertifications) { $campaign.completedCertifications = $null }
                if ($campaign.totalCertifications) { $campaign.totalCertifications = $null }
            }
        }
        #"set-content $($outputpath.FullName)\CertCampaigns.json"
        $CertCampaigns | convertto-json -depth 10 | Set-Content "$($outputpath.FullName)\CertCampaigns.json"
    }
    if ($Items -contains 'EmailTemplates') {
        write-progress -activity 'EmailTemplates'
        $EmailTemplates = Get-IdentityNowEmailTemplate
        if ($NullDynamicValues) {
            foreach ($template in $EmailTemplates) {
                if ($NullDynamicValues -eq 'Full') {
                    if ($template.meta.modified) {
                        $template.meta.modified = $null
                    }
                }                
            }
        }
        #"set-content $($outputpath.FullName)\EmailTemplates.json"
        $EmailTemplates | convertto-json -depth 10 | Set-Content "$($outputpath.FullName)\EmailTemplates.json"
    }
    if ($Items -contains 'GovernanceGroups') {
        write-progress -activity 'GovernanceGroups'
        $GovernanceGroups = Get-IdentityNowGovernanceGroup
        if ($NullDynamicValues) {
            foreach ($gGroup in $GovernanceGroups) {
                if ($gGroup.modified) {
                    $gGroup.modified = $null 
                }
            }
        }
        #"set-content $($outputpath.FullName)\GovernanceGroups.json"
        $GovernanceGroups | convertto-json -depth 10 | Set-Content "$($outputpath.FullName)\GovernanceGroups.json"
    }
    if ($Items -contains 'IdentityAttributes') {
        write-progress -activity 'IdentityAttributes'
        $IdentityAttributes = Get-IdentityNowIdentityAttribute
        if ($NullDynamicValues) {
            #no dynamic values in this output
        }
        #"set-content $($outputpath.FullName)\IdentityAttributes.json"
        $IdentityAttributes | convertto-json -depth 10 | Set-Content "$($outputpath.FullName)\IdentityAttributes.json"
    }
    if ($Items -contains 'IdentityProfiles') {
        write-progress -activity 'IdentityProfiles'
        $idp = Get-IdentityNowProfile
        $detailedIDP = @()
        foreach ($singleidp in $idp) {
            $singleidp = Get-IdentityNowProfile -ID $singleidp.id
            $detailedIDP += $singleidp
        }
        if ($NullDynamicValues) {
            foreach ($singleidp in $detailedIDP) {
                if ($singleidp.source.lastAggregated) {
                    $singleidp.source.lastAggregated = $null                
                }
                if ($singleidp.source.sinceLastAggregated) {
                    $singleidp.source.sinceLastAggregated = $null
                }
                if ($singleidp.report.date) {
                    $singleidp.report.date = $null
                }
                if ($singleidp.report.duration) {
                    $singleidp.report.duration = $null
                }
                if ($singleidp.report.id) {
                    $singleidp.report.id = $null
                }
                if ($NullDynamicValues -eq 'Full') {
                    if ($singleidp.identityCount -or $singleidp.identityCount -eq 0) {
                        $singleidp.identityCount = $null
                    }
                    if ($singleidp.report) {
                        $singleidp.report = $null
                    }
                    foreach ($state in $singleidp.configuredStates) {
                        if ($state.identitycount) {
                            $state.identitycount = $null
                        }
                    }
                }
            }
        }
        #"set-content $($outputpath.FullName)\IdentityProfiles.json"
        $detailedIDP | convertto-json -depth 10 | Set-Content "$($outputpath.FullName)\IdentityProfiles.json"
    }
    if ($Items -contains 'OauthAPIClients') {
        write-progress -activity 'OauthAPIClients'
        $OauthAPIClients = Get-IdentityNowOAuthAPIClient
        if ($NullDynamicValues) {
            #need to sort properties
            $proporder = ('id', 'name', 'description', 'enabled', 'type')
            $sortedOauthAPIClients = @()
            foreach ($oauthapi in $OauthAPIClients) {
                $sortedOauthAPIClients += $oauthapi | Select-Object -Property ($proporder + ($oauthapi | Get-Member -MemberType NoteProperty).name.where{ $_ -notin $proporder }  )
            }
            $OauthAPIClients = $SortedOauthAPIClients
        }
        #"set-content $($outputpath.FullName)\OAuthAPIClients.json"
        $OauthAPIClients | convertto-json -depth 10 | Set-Content "$($outputpath.FullName)\OAuthAPIClients.json"
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
        if ($NullDynamicValues) {
            #need to sort roles
            $sortedRoles = $detailedroles | Sort-Object -prop id
            $detailedroles = $sortedRoles
            foreach ($role in $detailedroles) {
                if ($role.synced) {
                    $role.synced = $null
                }
                if ($NullDynamicValues -eq 'Full') {
                    if ($role.modified) {
                        $role.modified = $null
                    }
                    if ($role.identityCount -or $role.identityCount -eq 0) {
                        $role.identityCount = $null
                    }
                }
            }
        }
        #"set-content $($outputpath.FullName)\Roles.json"
        $detailedroles | convertto-json -depth 10 | Set-Content "$($outputpath.FullName)\Roles.json"
    }
    if ($Items -contains 'Rules') {
        write-progress -activity 'Rules'
        $rules = Get-IdentityNowRule
        if ($NullDynamicValues) {
            #no dynamic values in this output
        }
        #"set-content $($outputpath.FullName)\Rules.json"
        $rules | convertto-json -depth 10 | Set-Content "$($outputpath.FullName)\Rules.json"
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
        if ($NullDynamicValues) {
            $detailedsources | Add-Member -NotePropertyName hasFullAggregationCompleted -NotePropertyValue $null -Force
            foreach ($source in $detailedsources) {
                if ($source.health.since) {
                    $source.health.since = $null
                }
                if ($source.health.lastSeen) {
                    $source.health.lastSeen = $null
                }
                if ($source.health.hostname) {
                    $source.health.hostname = $null
                }
                if ($source.health.lastChanged) {
                    $source.health.lastChanged = $null
                }
                if ($source.cloudCacheUpdate) {
                    $source.cloudCacheUpdate = $null
                }
                if ($source.groupDeltaLink) {
                    $source.groupDeltaLink = $null
                }
                if ($source.accountDeltaLink) {
                    $source.accountDeltaLink = $null
                }
                if ($source.acctAggregationStart) {
                    $source.acctAggregationStart = $null
                }
                if ($source.acctAggregationEnd) {
                    $source.acctAggregationEnd = $null
                }
                if ($source.lastAggrgationDateTime) {
                    $source.lastAggrgationDateTime = $null
                }
                if ($source.access_token) {
                    $source.access_token = $null
                }
                if ($source.access_token_create_time) {
                    $source.access_token_create_time = $null
                }
                if ($source.entitlementsCount -or $source.entitlementsCount -eq 0) {
                    $source.entitlementsCount = $null
                }
                if ($source.deltaAggregation) {
                    $source.deltaAggregation = $null
                }
                if ($source.expires_in) {
                    $source.expires_in = $null
                }
                if ($source.health.type) {
                    $source.health.type = $null
                }
                foreach ($sku in $source.subscribedSkus) {
                    if ($sku.consumedUnits -or $sku.consumedUnits -eq 0) {
                        $sku.consumedUnits = $null
                    }
                    if ($NullDynamicValues -eq 'Full') {
                        if ($sku.prepaidUnits.enabled -or $sku.prepaidUnits.enabled -eq 0) {
                            $sku.prepaidUnits.enabled = $null
                        }
                        if ($sku.prepaidUnits.suspended -or $sku.prepaidUnits.suspended -eq 0) {
                            $sku.prepaidUnits.suspended = $null
                        }
                        if ($sku.prepaidUnits.warning -or $sku.prepaidUnits.warning -eq 0) {
                            $sku.prepaidUnits.warning = $null
                        }
                    }
                }
                if ($NullDynamicValues -eq 'Full') {
                    if ($source.userCount -or $source.userCount -eq 0) {
                        $source.userCount = $null
                    }
                    if ($source.accountsCount -or $source.accountsCount -eq 0) {
                        $source.accountsCount = $null
                    }
                    if ($source.uncorrelatedAccountsFileFeedHistory) {
                        $source.uncorrelatedAccountsFileFeedHistory = @()
                    }
                }
            }
        }
        #"set-content $($outputpath.FullName)\Sources.json"
        $detailedsources | convertto-json -depth 12 | Set-Content "$($outputpath.FullName)\Sources.json"
    }    
    if ($Items -contains 'Transforms') {
        write-progress -activity 'Transforms'
        $transforms = Get-IdentityNowTransform
        if ($NullDynamicValues) {
            #no dynamic values in this output
        }
        #"set-content $($outputpath.FullName)\Transforms.json"
        $transforms | convertto-json -depth 12 | Set-Content "$($outputpath.FullName)\Transforms.json"
    }
    if ($Items -contains 'VAClusters') {
        write-progress -activity 'VAClusters'
        $VAClusters = Get-IdentityNowVACluster
        if ($NullDynamicValues) {
            foreach ($vac in $VAClusters) {
                if ($vac.pollingPeriodTimestamp) {
                    $vac.pollingPeriodTimestamp = $null
                }
                if ($vac.configuration.va_version) {
                    $vac.configuration.va_version = $null
                }
                if ($vac.configuration.jobType) {
                    $vac.configuration.jobType = $null
                }
                if ($vac.configuration.cookbook) {
                    $vac.configuration.cookbook = $null
                }
                if ($vac.va_version) {
                    $vac.va_version = $null
                }
                if ($vac.maintenance.windowStartTime) {
                    $vac.maintenance.windowStartTime = $null
                }
                if ($vac.maintenance.windowClusterTime) {
                    $vac.maintenance.windowClusterTime = $null
                }
                if ($vac.maintenance.windowFinishTime) {
                    $vac.maintenance.windowFinishTime = $null
                }
                if ($vac.jobs) {
                    $vac.jobs = @()
                }
                if ($vac.clients) {
                    $vac.clients = $vac.clients | Sort-Object -Property id
                }
            }
        }
        #"set-content $($outputpath.FullName)\VAClusters.json"
        $VAClusters | convertto-json -depth 10 | Set-Content "$($outputpath.FullName)\VAClusters.json"
    }

# SIG # Begin signature block
# MIIoKwYJKoZIhvcNAQcCoIIoHDCCKBgCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBsDoOCZJos4i0n
# G8spgW4os+3gtgOb/aCoWm91V34obaCCIS4wggWNMIIEdaADAgECAhAOmxiO+dAt
# 5+/bUOIIQBhaMA0GCSqGSIb3DQEBDAUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQK
# EwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNV
# BAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0yMjA4MDEwMDAwMDBa
# Fw0zMTExMDkyMzU5NTlaMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2Vy
# dCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lD
# ZXJ0IFRydXN0ZWQgUm9vdCBHNDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoC
# ggIBAL/mkHNo3rvkXUo8MCIwaTPswqclLskhPfKK2FnC4SmnPVirdprNrnsbhA3E
# MB/zG6Q4FutWxpdtHauyefLKEdLkX9YFPFIPUh/GnhWlfr6fqVcWWVVyr2iTcMKy
# unWZanMylNEQRBAu34LzB4TmdDttceItDBvuINXJIB1jKS3O7F5OyJP4IWGbNOsF
# xl7sWxq868nPzaw0QF+xembud8hIqGZXV59UWI4MK7dPpzDZVu7Ke13jrclPXuU1
# 5zHL2pNe3I6PgNq2kZhAkHnDeMe2scS1ahg4AxCN2NQ3pC4FfYj1gj4QkXCrVYJB
# MtfbBHMqbpEBfCFM1LyuGwN1XXhm2ToxRJozQL8I11pJpMLmqaBn3aQnvKFPObUR
# WBf3JFxGj2T3wWmIdph2PVldQnaHiZdpekjw4KISG2aadMreSx7nDmOu5tTvkpI6
# nj3cAORFJYm2mkQZK37AlLTSYW3rM9nF30sEAMx9HJXDj/chsrIRt7t/8tWMcCxB
# YKqxYxhElRp2Yn72gLD76GSmM9GJB+G9t+ZDpBi4pncB4Q+UDCEdslQpJYls5Q5S
# UUd0viastkF13nqsX40/ybzTQRESW+UQUOsxxcpyFiIJ33xMdT9j7CFfxCBRa2+x
# q4aLT8LWRV+dIPyhHsXAj6KxfgommfXkaS+YHS312amyHeUbAgMBAAGjggE6MIIB
# NjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTs1+OC0nFdZEzfLmc/57qYrhwP
# TzAfBgNVHSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzAOBgNVHQ8BAf8EBAMC
# AYYweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdp
# Y2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwRQYDVR0fBD4wPDA6oDigNoY0
# aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENB
# LmNybDARBgNVHSAECjAIMAYGBFUdIAAwDQYJKoZIhvcNAQEMBQADggEBAHCgv0Nc
# Vec4X6CjdBs9thbX979XB72arKGHLOyFXqkauyL4hxppVCLtpIh3bb0aFPQTSnov
# Lbc47/T/gLn4offyct4kvFIDyE7QKt76LVbP+fT3rDB6mouyXtTP0UNEm0Mh65Zy
# oUi0mcudT6cGAxN3J0TU53/oWajwvy8LpunyNDzs9wPHh6jSTEAZNUZqaVSwuKFW
# juyk1T3osdz9HNj0d1pcVIxv76FQPfx2CWiEn2/K2yCNNWAcAgPLILCsWKAOQGPF
# mCLBsln1VWvPJ6tsds5vIy30fnFqI2si/xK4VC0nftg62fC2h5b9W9FcrBjDTZ9z
# twGpn1eqXijiuZQwggauMIIElqADAgECAhAHNje3JFR82Ees/ShmKl5bMA0GCSqG
# SIb3DQEBCwUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMx
# GTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0IFRy
# dXN0ZWQgUm9vdCBHNDAeFw0yMjAzMjMwMDAwMDBaFw0zNzAzMjIyMzU5NTlaMGMx
# CzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMy
# RGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcg
# Q0EwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDGhjUGSbPBPXJJUVXH
# JQPE8pE3qZdRodbSg9GeTKJtoLDMg/la9hGhRBVCX6SI82j6ffOciQt/nR+eDzMf
# UBMLJnOWbfhXqAJ9/UO0hNoR8XOxs+4rgISKIhjf69o9xBd/qxkrPkLcZ47qUT3w
# 1lbU5ygt69OxtXXnHwZljZQp09nsad/ZkIdGAHvbREGJ3HxqV3rwN3mfXazL6IRk
# tFLydkf3YYMZ3V+0VAshaG43IbtArF+y3kp9zvU5EmfvDqVjbOSmxR3NNg1c1eYb
# qMFkdECnwHLFuk4fsbVYTXn+149zk6wsOeKlSNbwsDETqVcplicu9Yemj052FVUm
# cJgmf6AaRyBD40NjgHt1biclkJg6OBGz9vae5jtb7IHeIhTZgirHkr+g3uM+onP6
# 5x9abJTyUpURK1h0QCirc0PO30qhHGs4xSnzyqqWc0Jon7ZGs506o9UD4L/wojzK
# QtwYSH8UNM/STKvvmz3+DrhkKvp1KCRB7UK/BZxmSVJQ9FHzNklNiyDSLFc1eSuo
# 80VgvCONWPfcYd6T/jnA+bIwpUzX6ZhKWD7TA4j+s4/TXkt2ElGTyYwMO1uKIqjB
# Jgj5FBASA31fI7tk42PgpuE+9sJ0sj8eCXbsq11GdeJgo1gJASgADoRU7s7pXche
# MBK9Rp6103a50g5rmQzSM7TNsQIDAQABo4IBXTCCAVkwEgYDVR0TAQH/BAgwBgEB
# /wIBADAdBgNVHQ4EFgQUuhbZbU2FL3MpdpovdYxqII+eyG8wHwYDVR0jBBgwFoAU
# 7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYDVR0PAQH/BAQDAgGGMBMGA1UdJQQMMAoG
# CCsGAQUFBwMIMHcGCCsGAQUFBwEBBGswaTAkBggrBgEFBQcwAYYYaHR0cDovL29j
# c3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAChjVodHRwOi8vY2FjZXJ0cy5kaWdp
# Y2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNydDBDBgNVHR8EPDA6MDig
# NqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9v
# dEc0LmNybDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwDQYJKoZI
# hvcNAQELBQADggIBAH1ZjsCTtm+YqUQiAX5m1tghQuGwGC4QTRPPMFPOvxj7x1Bd
# 4ksp+3CKDaopafxpwc8dB+k+YMjYC+VcW9dth/qEICU0MWfNthKWb8RQTGIdDAiC
# qBa9qVbPFXONASIlzpVpP0d3+3J0FNf/q0+KLHqrhc1DX+1gtqpPkWaeLJ7giqzl
# /Yy8ZCaHbJK9nXzQcAp876i8dU+6WvepELJd6f8oVInw1YpxdmXazPByoyP6wCeC
# RK6ZJxurJB4mwbfeKuv2nrF5mYGjVoarCkXJ38SNoOeY+/umnXKvxMfBwWpx2cYT
# gAnEtp/Nh4cku0+jSbl3ZpHxcpzpSwJSpzd+k1OsOx0ISQ+UzTl63f8lY5knLD0/
# a6fxZsNBzU+2QJshIUDQtxMkzdwdeDrknq3lNHGS1yZr5Dhzq6YBT70/O3itTK37
# xJV77QpfMzmHQXh6OOmc4d0j/R0o08f56PGYX/sr2H7yRp11LB4nLCbbbxV7HhmL
# NriT1ObyF5lZynDwN7+YAN8gFk8n+2BnFqFmut1VwDophrCYoCvtlUG3OtUVmDG0
# YgkPCr2B2RP+v6TR81fZvAT6gt4y3wSJ8ADNXcL50CN/AAvkdgIm2fBldkKmKYcJ
# RyvmfxqkhQ/8mJb2VVQrH4D6wPIOK+XW+6kvRBVK5xMOHds3OBqhK/bt1nz8MIIG
# sDCCBJigAwIBAgIQCK1AsmDSnEyfXs2pvZOu2TANBgkqhkiG9w0BAQwFADBiMQsw
# CQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cu
# ZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBUcnVzdGVkIFJvb3QgRzQw
# HhcNMjEwNDI5MDAwMDAwWhcNMzYwNDI4MjM1OTU5WjBpMQswCQYDVQQGEwJVUzEX
# MBUGA1UEChMORGlnaUNlcnQsIEluYy4xQTA/BgNVBAMTOERpZ2lDZXJ0IFRydXN0
# ZWQgRzQgQ29kZSBTaWduaW5nIFJTQTQwOTYgU0hBMzg0IDIwMjEgQ0ExMIICIjAN
# BgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA1bQvQtAorXi3XdU5WRuxiEL1M4zr
# PYGXcMW7xIUmMJ+kjmjYXPXrNCQH4UtP03hD9BfXHtr50tVnGlJPDqFX/IiZwZHM
# gQM+TXAkZLON4gh9NH1MgFcSa0OamfLFOx/y78tHWhOmTLMBICXzENOLsvsI8Irg
# nQnAZaf6mIBJNYc9URnokCF4RS6hnyzhGMIazMXuk0lwQjKP+8bqHPNlaJGiTUyC
# EUhSaN4QvRRXXegYE2XFf7JPhSxIpFaENdb5LpyqABXRN/4aBpTCfMjqGzLmysL0
# p6MDDnSlrzm2q2AS4+jWufcx4dyt5Big2MEjR0ezoQ9uo6ttmAaDG7dqZy3SvUQa
# khCBj7A7CdfHmzJawv9qYFSLScGT7eG0XOBv6yb5jNWy+TgQ5urOkfW+0/tvk2E0
# XLyTRSiDNipmKF+wc86LJiUGsoPUXPYVGUztYuBeM/Lo6OwKp7ADK5GyNnm+960I
# HnWmZcy740hQ83eRGv7bUKJGyGFYmPV8AhY8gyitOYbs1LcNU9D4R+Z1MI3sMJN2
# FKZbS110YU0/EpF23r9Yy3IQKUHw1cVtJnZoEUETWJrcJisB9IlNWdt4z4FKPkBH
# X8mBUHOFECMhWWCKZFTBzCEa6DgZfGYczXg4RTCZT/9jT0y7qg0IU0F8WD1Hs/q2
# 7IwyCQLMbDwMVhECAwEAAaOCAVkwggFVMBIGA1UdEwEB/wQIMAYBAf8CAQAwHQYD
# VR0OBBYEFGg34Ou2O/hfEYb7/mF7CIhl9E5CMB8GA1UdIwQYMBaAFOzX44LScV1k
# TN8uZz/nupiuHA9PMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEFBQcD
# AzB3BggrBgEFBQcBAQRrMGkwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2lj
# ZXJ0LmNvbTBBBggrBgEFBQcwAoY1aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29t
# L0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcnQwQwYDVR0fBDwwOjA4oDagNIYyaHR0
# cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcmww
# HAYDVR0gBBUwEzAHBgVngQwBAzAIBgZngQwBBAEwDQYJKoZIhvcNAQEMBQADggIB
# ADojRD2NCHbuj7w6mdNW4AIapfhINPMstuZ0ZveUcrEAyq9sMCcTEp6QRJ9L/Z6j
# fCbVN7w6XUhtldU/SfQnuxaBRVD9nL22heB2fjdxyyL3WqqQz/WTauPrINHVUHmI
# moqKwba9oUgYftzYgBoRGRjNYZmBVvbJ43bnxOQbX0P4PpT/djk9ntSZz0rdKOtf
# JqGVWEjVGv7XJz/9kNF2ht0csGBc8w2o7uCJob054ThO2m67Np375SFTWsPK6Wrx
# oj7bQ7gzyE84FJKZ9d3OVG3ZXQIUH0AzfAPilbLCIXVzUstG2MQ0HKKlS43Nb3Y3
# LIU/Gs4m6Ri+kAewQ3+ViCCCcPDMyu/9KTVcH4k4Vfc3iosJocsL6TEa/y4ZXDlx
# 4b6cpwoG1iZnt5LmTl/eeqxJzy6kdJKt2zyknIYf48FWGysj/4+16oh7cGvmoLr9
# Oj9FpsToFpFSi0HASIRLlk2rREDjjfAVKM7t8RhWByovEMQMCGQ8M4+uKIw8y4+I
# Cw2/O/TOHnuO77Xry7fwdxPm5yg/rBKupS8ibEH5glwVZsxsDsrFhsP2JjMMB0ug
# 0wcCampAMEhLNKhRILutG4UI4lkNbcoFUCvqShyepf2gpx8GdOfy1lKQ/a+FSCH5
# Vzu0nAPthkX0tGFuv2jiJmCG6sivqf6UHedjGzqGVnhOMIIGwjCCBKqgAwIBAgIQ
# BUSv85SdCDmmv9s/X+VhFjANBgkqhkiG9w0BAQsFADBjMQswCQYDVQQGEwJVUzEX
# MBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0
# ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENBMB4XDTIzMDcxNDAw
# MDAwMFoXDTM0MTAxMzIzNTk1OVowSDELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRp
# Z2lDZXJ0LCBJbmMuMSAwHgYDVQQDExdEaWdpQ2VydCBUaW1lc3RhbXAgMjAyMzCC
# AiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAKNTRYcdg45brD5UsyPgz5/X
# 5dLnXaEOCdwvSKOXejsqnGfcYhVYwamTEafNqrJq3RApih5iY2nTWJw1cb86l+uU
# UI8cIOrHmjsvlmbjaedp/lvD1isgHMGXlLSlUIHyz8sHpjBoyoNC2vx/CSSUpIIa
# 2mq62DvKXd4ZGIX7ReoNYWyd/nFexAaaPPDFLnkPG2ZS48jWPl/aQ9OE9dDH9kgt
# XkV1lnX+3RChG4PBuOZSlbVH13gpOWvgeFmX40QrStWVzu8IF+qCZE3/I+PKhu60
# pCFkcOvV5aDaY7Mu6QXuqvYk9R28mxyyt1/f8O52fTGZZUdVnUokL6wrl76f5P17
# cz4y7lI0+9S769SgLDSb495uZBkHNwGRDxy1Uc2qTGaDiGhiu7xBG3gZbeTZD+BY
# QfvYsSzhUa+0rRUGFOpiCBPTaR58ZE2dD9/O0V6MqqtQFcmzyrzXxDtoRKOlO0L9
# c33u3Qr/eTQQfqZcClhMAD6FaXXHg2TWdc2PEnZWpST618RrIbroHzSYLzrqawGw
# 9/sqhux7UjipmAmhcbJsca8+uG+W1eEQE/5hRwqM/vC2x9XH3mwk8L9CgsqgcT2c
# kpMEtGlwJw1Pt7U20clfCKRwo+wK8REuZODLIivK8SgTIUlRfgZm0zu++uuRONhR
# B8qUt+JQofM604qDy0B7AgMBAAGjggGLMIIBhzAOBgNVHQ8BAf8EBAMCB4AwDAYD
# VR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAgBgNVHSAEGTAXMAgG
# BmeBDAEEAjALBglghkgBhv1sBwEwHwYDVR0jBBgwFoAUuhbZbU2FL3MpdpovdYxq
# II+eyG8wHQYDVR0OBBYEFKW27xPn783QZKHVVqllMaPe1eNJMFoGA1UdHwRTMFEw
# T6BNoEuGSWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRH
# NFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdDQS5jcmwwgZAGCCsGAQUFBwEBBIGD
# MIGAMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wWAYIKwYB
# BQUHMAKGTGh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0
# ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdDQS5jcnQwDQYJKoZIhvcNAQEL
# BQADggIBAIEa1t6gqbWYF7xwjU+KPGic2CX/yyzkzepdIpLsjCICqbjPgKjZ5+PF
# 7SaCinEvGN1Ott5s1+FgnCvt7T1IjrhrunxdvcJhN2hJd6PrkKoS1yeF844ektrC
# QDifXcigLiV4JZ0qBXqEKZi2V3mP2yZWK7Dzp703DNiYdk9WuVLCtp04qYHnbUFc
# jGnRuSvExnvPnPp44pMadqJpddNQ5EQSviANnqlE0PjlSXcIWiHFtM+YlRpUurm8
# wWkZus8W8oM3NG6wQSbd3lqXTzON1I13fXVFoaVYJmoDRd7ZULVQjK9WvUzF4UbF
# KNOt50MAcN7MmJ4ZiQPq1JE3701S88lgIcRWR+3aEUuMMsOI5ljitts++V+wQtaP
# 4xeR0arAVeOGv6wnLEHQmjNKqDbUuXKWfpd5OEhfysLcPTLfddY2Z1qJ+Panx+VP
# NTwAvb6cKmx5AdzaROY63jg7B145WPR8czFVoIARyxQMfq68/qTreWWqaNYiyjvr
# moI1VygWy2nyMpqy0tg6uLFGhmu6F/3Ed2wVbK6rr3M66ElGt9V/zLY4wNjsHPW2
# obhDLN9OTH0eaHDAdwrUAuBcYLso/zjlUlrWrBciI0707NMX+1Br/wd3H3GXREHJ
# uEbTbDJ8WC9nR2XlG3O2mflrLAZG70Ee8PBf4NvZrZCARK+AEEGKMIIHbTCCBVWg
# AwIBAgIQCcjsXDR9ByBZzKg16Kdv+DANBgkqhkiG9w0BAQsFADBpMQswCQYDVQQG
# EwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xQTA/BgNVBAMTOERpZ2lDZXJ0
# IFRydXN0ZWQgRzQgQ29kZSBTaWduaW5nIFJTQTQwOTYgU0hBMzg0IDIwMjEgQ0Ex
# MB4XDTIzMDMyOTAwMDAwMFoXDTI2MDYyMjIzNTk1OVowdTELMAkGA1UEBhMCQVUx
# GDAWBgNVBAgTD05ldyBTb3V0aCBXYWxlczEUMBIGA1UEBxMLQ2hlcnJ5YnJvb2sx
# GjAYBgNVBAoTEURhcnJlbiBKIFJvYmluc29uMRowGAYDVQQDExFEYXJyZW4gSiBS
# b2JpbnNvbjCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAMesp+e1UZ5d
# oOnpL+epm6Iq6GYiqK8ZNcz1XBe7M7eBXwVy4tYP5ByIa6NORYEselVWI9XmO1M+
# cPS6jRMrpZb9xtUH+NpKZO+eSthgTAtnEO1dWaAK6Y7AH/ZVjmgOTWZXBVibjAE/
# JQKIfZyx4Hm5FOH6hq3bslA+RUQpo3NQxNv2AuzckKQwbW7AoXINudj0duYCiDYs
# hn/9mHzzgL0VpNYRpmgEa7WWgc1JH17V+SYlaf6qMWpYoWuODwuDltSH2p57qAI2
# /4J6rUYEvns7QZ9sgIUdGlUr596fp0Y4juypyVGE7Rr0a8PtByLWUupyV7Z5kKPr
# /MRjerXAmBnf6AdhI3kY6Gjz356fZkPA49UuCIXFgyTZT84Ao6Klw+0RqJ70JDt4
# 49Uky7hda+h8h2PiUdf7rXQamV57mY65+lHAmc4+UgTuWsnpwnTuNlkbZxRnCw2D
# +W3qto2aBhDebciKZzivfiAWlWfTcHtCpy96gM5L+OB45ezDpU6KAH1hwRSjORUl
# W5yoFTXUbPUBRflU3O2bZ0wdAJeyUYaHWAayNoyFfuKdrmCLtIx726O06dz9Kg+c
# Jf+1ZdJ7KcUvZgR2d8F19FV5G1CVMnOzhMZR2dnIeJ5h0EgcOKNHl3hMKFdVRx4l
# hW8tcrQQN4ZT2EgGfI9fBc0i3GXTFA0xAgMBAAGjggIDMIIB/zAfBgNVHSMEGDAW
# gBRoN+Drtjv4XxGG+/5hewiIZfROQjAdBgNVHQ4EFgQUBTFWqXTuYnNp+d03es2K
# M9JdGUgwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMIG1BgNV
# HR8Ega0wgaowU6BRoE+GTWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2Vy
# dFRydXN0ZWRHNENvZGVTaWduaW5nUlNBNDA5NlNIQTM4NDIwMjFDQTEuY3JsMFOg
# UaBPhk1odHRwOi8vY3JsNC5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRD
# b2RlU2lnbmluZ1JTQTQwOTZTSEEzODQyMDIxQ0ExLmNybDA+BgNVHSAENzA1MDMG
# BmeBDAEEATApMCcGCCsGAQUFBwIBFhtodHRwOi8vd3d3LmRpZ2ljZXJ0LmNvbS9D
# UFMwgZQGCCsGAQUFBwEBBIGHMIGEMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5k
# aWdpY2VydC5jb20wXAYIKwYBBQUHMAKGUGh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0
# LmNvbS9EaWdpQ2VydFRydXN0ZWRHNENvZGVTaWduaW5nUlNBNDA5NlNIQTM4NDIw
# MjFDQTEuY3J0MAkGA1UdEwQCMAAwDQYJKoZIhvcNAQELBQADggIBAFhACWjPMrca
# fwDfZ5me/nUrkv4yYgIi535cddPAm/2swGDTuzSVBVHIMBp8LWLmzXPA1GbxBOmA
# 4L8vvDgjEpQF9I9Ph5MNYgYhg0xSpAIp9/KAoc4OQnwlyRGPN+CjayY40xxTz4/h
# HohWg4rnJMIuVEjkMtKnMdTbpnqU85w78AQlfD79v/gWQ2dL1T3n18HOEjTt8VSu
# rxkEhQ5I3SH8Cr9YhUv94ObWIUbOKUt5SG7m/d+y2mfkKRSOmRluLSoYLPWbx35p
# ArsYkaPpjf5Yl5jiJPY3GQzEU/SRVW0rrwDAbtKSN0gKWtZxijPDbs8aQUYCijFf
# je6OWGF4RnmPSQh0Ff8AyzPQcx9LjQ/8W7gUELsE6IFuXP5bj2i6geLy65LRe46Q
# ZlYDq/bMazUoZQTlje/hs6pkOL4f1Kv7tbJZmMENVVURJNmeDRejvNliHaaGEAv/
# iF0Zo7pqvj4wCCCGG3j/sNR5WSRYnxf5xQ4r9i9gZqk4yjwk/DJCW2rmKNCUoxNI
# ZWh2EIlMSDzw3DMKk2ylZdiY/LAi5GmbCyGLt6sTz/IE1w1NYwrp/z6v4I91lDgd
# Xg+fTkhhxt47hWmjMOD3ZYVSFzQmg8al1iQ/+6RYKgfsww64tIky8JOOZX/3ss/u
# hxKUjPJxYJkOwQwUyoAYzjcu/AE7By0rMYIGUzCCBk8CAQEwfTBpMQswCQYDVQQG
# EwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xQTA/BgNVBAMTOERpZ2lDZXJ0
# IFRydXN0ZWQgRzQgQ29kZSBTaWduaW5nIFJTQTQwOTYgU0hBMzg0IDIwMjEgQ0Ex
# AhAJyOxcNH0HIFnMqDXop2/4MA0GCWCGSAFlAwQCAQUAoIGEMBgGCisGAQQBgjcC
# AQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYB
# BAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIFQZLPPstOiF
# jifn0VP2OSxsVkb4IOjgb8r0bXPYUmq/MA0GCSqGSIb3DQEBAQUABIICAGBSjgMI
# mANkEp/LHivxPzGvzy5IPQUyGsXpWnSlpnCQQwaqql/ICZdavb5Kxgz2q5P2WGZm
# NacDaAAK6hgzYwKWrA3rBBcWdhZna8YlaiwKZgw42MHmv6iRQo5tL51BQ3DRWBZv
# J2UvtiRjBLwzA1TXGywaKjeiHVZI1zY4FBpOAmPLqXQ+Ihav0VLGyTHrvfAqYhaX
# at58Nq5T0tqy2AXvo6iyIy3bzzyViUxPtNUzJl04KLrNtLhOimrjhLG45dVHEzyw
# 7o43I2lZQpYqTMuAfznWCa51E1UYdr2V/dt9Q4+mpQUoojkgVUXYXNvT1Q24OBV5
# 5Px0sg06qTiQnWsiCn6NXbsXD/ofcXpJGX3/6RpDjVTxjeW/H6Dx0B71BsHoIryd
# weUYKhNR1cIdixwr36xjYdFKvJIrr+oZBM3T+CaWfeoP2ue1u9cjXVRNxdea4Edx
# /uXQjnu34p5LC00nmQaohl0LNpCHApvN9Tpr30pBQhlHFYAEZwc1KlPKsWFLHMNM
# zjjpaan1E/DRx/k0JBQxI8ZQv1rB259AeKIWqt2KjGHmso4A1qR3t9pd5J84Sh3W
# wME2F/Zc7kDYTdj8poVPBPRw7P/eQ017FuR4jdnq3M+XsuNXemzq6QW9//PGGUn9
# FxrPhXLbu7Y9nT1amhZydgd97XK44bWYm8o4oYIDIDCCAxwGCSqGSIb3DQEJBjGC
# Aw0wggMJAgEBMHcwYzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJ
# bmMuMTswOQYDVQQDEzJEaWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2
# IFRpbWVTdGFtcGluZyBDQQIQBUSv85SdCDmmv9s/X+VhFjANBglghkgBZQMEAgEF
# AKBpMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTIz
# MTEwMjA4MzAwMlowLwYJKoZIhvcNAQkEMSIEIPtTJ96f04X+EFiiyOG63flv2ojK
# GiJfMtlXqU+ho5otMA0GCSqGSIb3DQEBAQUABIICAEwKQOzFboeGtchi8mEKSlot
# 9nzGaobW2GQhTqKURi24zG3J5kY5wpuqPWQvWYI3s7vbw8RY1fELr8AZYET+oMEv
# bQJrANErxbNdTIYPN3Gk25GswaUIK25rVnTCAMxIN7AudWeiN9GhEaltAdeJ88Hl
# H/9WOOgKxEvhtBk0Lbv1/vXODYI/HbHqgsDcmirXFUcSxiG9d3SSwpDeep8IU/Zk
# D5niSXw9wOfpcBialBCx0g8THUVX7tmqlR4d80/qjbK+GRhWY4icGsucuxLA7YdI
# 3YrPJvC8cy8y6HLFr6ej6zxCDMbUOXfudLY6QFaThz9orNWqSe2Ixt1jX+s07UUw
# bhJKnDdEq4suUImkL4cqsIBttrEFn+5gPaKga9VjeDhJtKM16K9l/Ix6fw4sJeYs
# gjsenCkWizATYsmbYSnoASeZkC3LtyxwQ7wGLU8/gIrlQA+lC9AgKHunWNktFecS
# lqGAFyWkqnVcQ7JVosm7CkA6SOJNprbtdJGMUOPHzaFnMEmkjubhOFd2l/mO2Z4R
# 9mSYgRLSTQRU58eGfBXrInFjjwoU36iwtDE2876XIE1/LzXib7dPBQKJklYxZyvv
# f5VEhTMx0vstz7yPLnlMpBv0AIVh/dEzT6IgK6dRHAE7JP29AbERTAr7KOqteeW/
# dphJHNnnWa0dcXeW4W+3
# SIG # End signature block
