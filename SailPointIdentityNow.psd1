@{
    RootModule        = 'SailPointIdentityNow.psm1'
    ModuleVersion     = '1.0.5'
    GUID              = 'f82fe16a-7702-46f3-ab86-5de11b7305de'
    Author            = 'Darren J Robinson'
    Copyright         = '(c) 2019 . All rights reserved.'
    Description       = "Orchestration of SailPoint IdentityNow"
    PowerShellVersion = '5.0'
    FunctionsToExport = @('Complete-IdentityNowTask',
        'Get-IdentityNowAccessProfile',
        'Get-IdentityNowAccountActivities',
        'Get-IdentityNowAccountActivity',        
        'Get-IdentityNowAPIClient',
        'Get-IdentityNowApplication',
        'Get-IdentityNowCertCampaign',
        'Get-IdentityNowCertCampaignReport',
        'Get-IdentityNowEmailTemplate',
        'Get-IdentityNowGovernanceGroup',
        'Get-IdentityNowOAuthAPIClient',
        'Get-IdentityNowOrg',
        'Get-IdentityNowOrgConfig',
        'Get-IdentityNowProfile',
        'Get-IdentityNowProfileOrder',
        'Get-IdentityNowRole',
        'Get-IdentityNowRule',
        'Get-IdentityNowSource',
        'Get-IdentityNowSourceAccounts',
        'Get-IdentityNowTask',
        'Get-IdentityNowTransform',
        'Get-IdentityNowVACluster',
        'Invoke-IdentityNowAggregateSource',
        'Invoke-IdentityNowRequest',
        'New-IdentityNowAccessProfile',
        'New-IdentityNowAPIClient',
        'New-IdentityNowCertCampaign',
        'New-IdentityNowGovernanceGroup',
        'New-IdentityNowOAuthAPIClient',
        'New-IdentityNowRole',
        'New-IdentityNowUserSourceAccount',
        'New-IdentityNowTransform',
        'Remove-IdentityNowAccessProfile',
        'Remove-IdentityNowAPIClient',
        'Remove-IdentityNowGovernanceGroup',
        'Remove-IdentityNowOAuthAPIClient',
        'Remove-IdentityNowRole',
        'Remove-IdentityNowTransform',
        'Remove-IdentityNowUserSourceAccount',
        'Save-IdentityNowConfiguration',
        'Search-IdentityNowAuditEvents',
        'Search-IdentityNowEntitlements',
        'Search-IdentityNowEvents',
        'Search-IdentityNowUserProfile',
        'Search-IdentityNowUsers',
        'Set-IdentityNowCredential',
        'Set-IdentityNowOrg',
        'Start-IdentityNowCertCampaign',
        'Update-IdentityNowAccessProfile',
        'Update-IdentityNowApplication',
        'Update-IdentityNowEmailTemplate',
        'Update-IdentityNowGovernanceGroup',
        'Update-IdentityNowOrgConfig',
        'Update-IdentityNowProfileOrder',
        'Update-IdentityNowRole',
        'Update-IdentityNowSource',
        'Update-IdentityNowUserSourceAccount',
        'Update-IdentityNowTransform'
    )
    PrivateData       = @{
        PSData = @{
            ProjectUri = 'https://github.com/darrenjrobinson/powershell_module_identitynow'
        } 
    } 
}

