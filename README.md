# SailPoint IdentityNow PowerShell Module #
<b>NOTE: This is not an official SailPoint Module.</b>

## Description ##
A PowerShell Module enabling simple methods for accessing the SailPoint IdentityNow REST API's.

This PowerShell Module has been written to fulfil my colleagues IdentityNow automation needs. It is based heavily off the extensive work I've done reverse engineering the SailPoint IdentityNow Portal in order to allow me to orchestrate IdentityNow using PowerShell. That work is covered [on my blog here](https://blog.darrenjrobinson.com/sailpoint-identitynow/) 

As such this module very much a shot into the wind at a point in time (Sept/Oct 2019). SailPoint IdentityNow is a SaaS product. The functions and functionality of it is constantly evolving as are the API's that underpin those functions. As such I've attempted to keep each cmdlet lean. The ability to submit a request and get something back. 

I get a lot of requests for assistance with IdentityNow API integration so here is a module that makes the barrier to entry considerably lower. You may find it helpful and may even wish to comment or contribute. I have hosted the source on GitHub  (https://github.com/darrenjrobinson/powershell_module_identitynow).

## Features ##
* Easy command-line use, after setting default configuration options and securely saving them to the current user's profile.
* Get an IdentityNow Organisation and Get / Update an Organisation Configuration
* Search IdentityNow Users
* Search IdentityNow Users Profiles
* Search IdentityNow Entitlements
* Create / Get / Update / Remove IdentityNow Access Profiles
* Create / Get / Start IdentityNow Certification Campaigns
* Get IdentityNow Certification Campaign Reports (output to file or return as PSObject)
* Create / Get / Update / Remove IdentityNow Governance Groups
* Create / Get / Update / Remove IdentityNow Roles
* Get / IdentityNow Sources
* Get Accounts from an IdentityNow Source
* Create / Update / Remove IdentityNow Source Account (Flat File / Delimited Sources)
* Get / Complete IdentityNow Tasks
* Get IdentityNow Virtual Appliance Clusters (and clients (VA's))
* Get / Update IdentityNow Applications
* Create / Get / Update / Remove IdentityNow Transforms
* Get IdentityNow Rules
* Get / Update Email Templates
* Get IdentityNow Profiles
* Get / Update IdentityNow Profiles Order
* Create / Get / Remove API Management Clients (Legacy v2)
* Create / Get / Remove oAuth API Clients (v3)
* .... and if they don't fit Invoke-IdentityNowRequest to make any other API call (examples for Get Source Schema, Get IdentityNow Profiles, Get IdentityNow Identity Attributes)

## Installation ##

The dependencies are PowerShell version 5 and the PowerShell Community eXtension. The manual installation and module scripts should install the PSCx module automatically for you. If for some reason (like you're on an airgapped network), you can get [PSCx it from here](https://github.com/Pscx/Pscx)

To install either...

* Download the files 
* As an Administrator execute the script Install-IdentityNowModule.ps1

or

* From an Admin PowerShell session, install from the PowerShell Gallery 
```
install-module -name SailPointIdentityNow
```

## Examples ##
### Setting up Credentials and Organisation Configuration ###

[Reference Post](https://blog.darrenjrobinson.com/generate-sailpoint-identitynow-v2-v3-api-credentials/)
<b>Note: You can configure oAuth Client Authentication configuration and then use the New-IdentityNowAPIClient cmdlet to generate the v2 API Client.</b>

```
    $orgName = "customername-sb"
    Set-IdentityNowOrg -orgName $orgName

    # IdentityNow Admin User
    $adminUSR = "identityNow_admin_User"
    $adminPWD = 'idnAdminUserPassword'
    $adminCreds = [pscredential]::new($adminUSR, ($adminPWD | ConvertTo-SecureString -AsPlainText -Force))

    # Customer IdentityNow Org v3 API Creds generated from the Security Settings => API Management section of the IdentityNow Admin Portal 
    $clientIDv3 = "badbeef6-5f24-4448-ac0b-abcdefG"
    $clientSecretv3 = "770a71abcdef5301848d00000d8760fe0d9f632383775b315aa1234567890"
    $v3Creds = [pscredential]::new($clientIDv3, ($clientSecretv3 | ConvertTo-SecureString -AsPlainText -Force))

    # Customer IdentityNow API Client ID & Secret generated in IdentityNow Portal
    $clientID = 'zo7ABCDaTHjA0Rwv'
    # Your API Client Secret
    $clientSecret = '3Zm9Qod4sWhihABCdefgCX9DIfmwAZiP'
    $v2Creds = [pscredential]::new($clientID, ($clientSecret | ConvertTo-SecureString -AsPlainText -Force))

    Set-IdentityNowCredential -AdminCredential $adminCreds -v2APIKey $v2Creds -v3APIKey $v3Creds 
    Save-IdentityNowConfiguration
```

### IdentityNow PowerShell Module Cmdlets ###
```
    Get-Command -Module SailPointIdentityNow | Sort-Object Name | Get-Help | Format-Table Name, Synopsis -Autosize

    Complete-IdentityNowTask            Complete an IdentityNow Task.
    Get-IdentityNowAccessProfile        Get an IdentityNow Access Profile(s).
    Get-IdentityNowAPIClient            Get IdentityNow API Client(s).
    Get-IdentityNowApplication          Get IdentityNow Application(s).
    Get-IdentityNowCertCampaign         Get IdentityNow Certification Campaign(s).
    Get-IdentityNowCertCampaignReport   Get IdentityNow Certification Campaign Report(s).
    Get-IdentityNowEmailTemplate        Get IdentityNow Email Template(s).
    Get-IdentityNowGovernanceGroup      Get an IdentityNow Governance Group.
    Get-IdentityNowOAuthAPIClient       Get IdentityNow oAuth API Client(s).
    Get-IdentityNowOrg                  Displays the default Uri value for all or a particular Organisation based on configured OrgName.
    Get-IdentityNowOrgConfig            Get IdentityNow Org Global Reminders and Escalation Policies Configuration.
    Get-IdentityNowProfile              Get IdentityNow Profile(s).
    Get-IdentityNowProfileOrder         Get IdentityNow Profiles Order.
    Get-IdentityNowRole                 Get an IdentityNow Role(s).
    Get-IdentityNowRule                 Get IdentityNow Rule(s).
    Get-IdentityNowSource               Get IdentityNow Source(s).
    Get-IdentityNowSourceAccounts       Get IdentityNow Accounts on a Source.
    Get-IdentityNowTask                 Get an IdentityNow Task(s).
    Get-IdentityNowTransform            Get IdentityNow Transform(s).
    Get-IdentityNowVACluster            Get IdentityNow Virtual Appliance Cluster(s).
    Invoke-IdentityNowAggregateSource   Initiate Aggregation of an IdentityNow Source.
    Invoke-IdentityNowRequest           Submit an IdentityNow API Request.
    New-IdentityNowAccessProfile        Create an IdentityNow Access Profile.
    New-IdentityNowAPIClient            Create an IdentityNow v2 API Client.
    New-IdentityNowCertCampaign         Create an IdentityNow Certification Campaign.
    New-IdentityNowGovernanceGroup      Create a new IdentityNow Governance Group.
    New-IdentityNowOAuthAPIClient       Create an IdentityNow v3 oAuth API Client.
    New-IdentityNowRole                 Create an IdentityNow Role.
    New-IdentityNowTransform            Create an IdentityNow Transform.
    New-IdentityNowUserSourceAccount    Create an IdentityNow User Account on a Flat File Source.
    Remove-IdentityNowAccessProfile     Delete an IdentityNow Access Profile.
    Remove-IdentityNowAPIClient         Delete an IdentityNow API Client.
    Remove-IdentityNowGovernanceGroup   Delete an IdentityNow Governance Group.
    Remove-IdentityNowOAuthAPIClient    Delete an IdentityNow oAuth API Client.
    Remove-IdentityNowRole              Delete an IdentityNow Role.
    Remove-IdentityNowTransform         Delete an IdentityNow Transform.
    Remove-IdentityNowUserSourceAccount Delete an IdentityNow User Account on a Flat File Source.
    Save-IdentityNowConfiguration       Saves default IdentityNow configuration to a file in the current users Profile.
    Search-IdentityNowEntitlements      Get IdentityNow Entitlements.
    Search-IdentityNowUserProfile       Get an IdentityNow Users Identity Profile.
    Search-IdentityNowUsers             Get IdentityNow Users.
    Set-IdentityNowCredential           Sets the default IdentityNow API credentials.
    Set-IdentityNowOrg                  Sets the default Organisation name for an IdentityNow Tenant.
    Start-IdentityNowCertCampaign       Start an IdentityNow Certification Campaign that is currently 'Staged'.
    Update-IdentityNowAccessProfile     Update an IdentityNow Access Profile(s).
    Update-IdentityNowApplication       Update an IdentityNow Application.
    Update-IdentityNowEmailTemplate     Update an IdentityNow Email Template.
    Update-IdentityNowGovernanceGroup   Add or Remove member(s) from an IdentityNow Governance Group.
    Update-IdentityNowOrgConfig         Update IdentityNow Org Global Reminders and Escalation Policies Configuration.
    Update-IdentityNowProfileOrder      Update IdentityNow Profile Order.
    Update-IdentityNowRole              Update an IdentityNow Role.
    Update-IdentityNowTransform         Update an IdentityNow Transform.
    Update-IdentityNowUserSourceAccount Update an IdentityNow User Account on a Flat File Source.
```

### Get an IdentityNow Organisation and Get / Update an Organisation Configuration ###

* Display the configured IdentityNow Organisation as set by "Set-IdentityNowOrg"
* API endpoints for currently configured organisation

Example
```
Get-IdentityNowOrg 

Name                           Value                                                                                                                       
----                           -----                                                                                                                       
Organisation Name              customer-sb                                                                                                                   
Organisation URI               https://customer-sb.identitynow.com                                                                                           
v1 Base API URI                https://customer-sb.identitynow.com/api
v2 Base API URI                https://customer-sb.api.identitynow.com/v2
v3 / Private Base API URI      https://customer-sb.api.identitynow.com/cc/api
```

Update an IdentityNow Organisation Setting
[Reference post](https://blog.darrenjrobinson.com/get-update-sailpoint-identitynow-global-reminders-and-escalation-policies/)

Example
```
$orgConfig = Get-IdentityNowOrgConfig

$approvalConfig = $orgConfig.approvalConfig
# global reminders and escalation policies for access request approvals
$daysBetweenReminders = 3
$daysTillEscalation = 5
$maxReminders = 10
# SailPoint user name of the identity 
$fallbackApprover = "darren.robinson"

# Set Config options to update
$approvalConfig.daysBetweenReminders = $daysBetweenReminders
$approvalConfig.daysTillEscalation = $daysTillEscalation
$approvalConfig.maxReminders = $maxReminders
$approvalConfig.fallbackApprover = $fallbackApprover
$approvalConfigBody = @{"approvalConfig" = $approvalConfig }

Update-IdentityNowOrgConfig -update ($approvalConfigBody | convertto-json)

```

### Search IdentityNow Users ###
Search for IdentityNow Users
[Reference post](https://blog.darrenjrobinson.com/reporting-on-sailpoint-identitynow-identities-using-the-search-beta-api-and-powershell/)

Examples
```
Search-IdentityNowUsers -query darrenjrobinson
Search-IdentityNowUsers -query "@accounts(accountId:darren.robinson)"
Search-IdentityNowUsers -query "@source(id:2c91808469110d6a016954d4dad138a3)"
Search-IdentityNowUsers -query "@access(source.name:*Active Directory*) AND attributes.company:Kloud" 
```

### Search IdentityNow Users Profiles ###
Search for a user's IdentityNow Profile from the IdentityNow Identity List
[Reference post - See Profile Owner Section](https://blog.darrenjrobinson.com/creating-sailpoint-identitynow-access-profiles-via-api-and-powershell/)

Example
```
Search-IdentityNowUserProfile -query "darrenjrobinson"
```

### Search IdentityNow Entitlements ###
Search for Entitlements associated with IdentityNow Sources
[Reference post](https://blog.darrenjrobinson.com/searching-and-returning-sailpoint-identitynow-entitlements-using-the-api-and-powershell/)

Example
```
Search-IdentityNowEntitlements -query "File_Share_Sydney"
```

### Create / Get / Update / Remove IdentityNow Access Profiles ###
Get all IdentityNow Access Profiles
[Reference post](https://blog.darrenjrobinson.com/creating-sailpoint-identitynow-access-profiles-via-api-and-powershell/)

Example
```
Get-IdentityNowAccessProfile
```

Get a specific IdentityNow Access Profile
```
Get-IdentityNowAccessProfile -profileID 2c91808369a606f00169c756f0a00017
```

Create an IdentityNow Access Profile

Example 1
```
New-IdentityNowAccessProfile -profile "{"entitlements":  ["2c91808668dcf3970168dd722e7a020d","2c91808468dcf4610168dd78d2e8531e"],"description":  "FS-SYDNEY-AUS-ENGINEERING","requestCommentsRequired":  true,"sourceId":  "39082","approvalSchemes":  "manager","ownerId":  "1397606","name":  "Sydney Engineering","deniedCommentsRequired":  true}"
```
Example 2
```
# Get Owner for Access Profile
$owner = Search-IdentityNowUserProfile -query "darren.robinson"

# Get Source for Access Profile
$sources = Get-IdentityNowSource 
$adSource = $sources | Select-Object | Where-Object {$_.name -like '*Active Directory*'}

# Entitlements
$entitlement = Search-IdentityNowEntitlements -query "FS-SYDNEY-AUS-ENGINEERING"
$e = $entitlement | Select-Object | Where-Object {$_.source.name -eq 'Active Directory'}

# Access Profile Details
$accessProfile = @{}
$accessProfile.add("name", "Sydney Engineering")
$accessProfile.add("description", "FS-SYDNEY-AUS-ENGINEERING")
$accessProfile.add("sourceId", $adSource.id)
$accessProfile.add("ownerId", $owner.id)

# Access Profile Entitlements
$entitlements = @()
ForEach($i in $e) {$entitlements += $i.id}
$entitlementsToAdd = @{"entitlements" = $entitlements}
$accessProfile.add("entitlements", $entitlementsToAdd.entitlements)

# Access Profile Type
$accessProfile.add("approvalSchemes", "manager")
$accessProfile.add("requestCommentsRequired", $true)
$accessProfile.add("deniedCommentsRequired", $true)

New-IdentityNowAccessProfile -profile ($accessProfile | convertto-json)

```

Update an IdentityNow Access Profile
Example 1
```
Update-IdentityNowAccessProfile -profileID 2c91808466a64e330112a96902ff1f69 -update "{"deniedCommentsRequired":  true,"requestCommentsRequired":  true}"
```

Example 2
```
$ap = Get-IdentityNowAccessProfile 
$accessProfile = $ap | Select-Object | Where-Object {$_.description -like '*Darren*'}

$updateAccessProfile = @{} 
$updateAccessProfile.Add("requestCommentsRequired", $true) 
$updateAccessProfile.Add("deniedCommentsRequired", $true) 

Update-IdentityNowAccessProfile -profileID $accessProfile.id -update ($updateAccessProfile | convertto-JSON)
```

Remove an IdentityNow Access Profile
Example 1
```
Remove-IdentityNowAccessProfile -profileID 2c91808369a606f00169c756f0a00017
```
Example 2
```
$ExistingAPs = Get-IdentityNowAccessProfile
$myAP = $ExistingAPs | Select-Object | Where-Object {$_.name -like "*My Access Profile*"}
Remove-IdentityNowAccessProfile -profileID $myAP.id
```

### Create / Get / Start IdentityNow Certification Campaigns ###
Get all (active and completed) IdentityNow Certification Campaigns
[Reference post](https://blog.darrenjrobinson.com/accessing-sailpoint-identitynow-certification-campaigns-using-powershell/)

Example 
```
Get-IdentityNowCertCampaign -completed $false
```

Get a specific IdentityNow Certification Campaign 
Example
```
Get-IdentityNowCertCampaign -campaignID 2c9180856708ae38016709f4812345c3
```

Create an IdentityNow Certification Campaign
[Reference post](https://blog.darrenjrobinson.com/creating-sailpoint-identitynow-certification-campaigns-using-powershell/)

Example
```
$query = "@apps.name:'Special Application'"
$campaignFilter = Search-IdentityNowUsers -query $query  

$entitlements = $null 
$e = $campaignFilter.access | where-object { $_.type -eq "ENTITLEMENT" } | Select-Object id 
$entitlements = $e | Select-Object -Property id -Unique

$roles = $null 
$r = $campaignFilter.access | where-object { $_.type -eq "ROLES" } | Select-Object id 
$roles = $r | Select-Object -Property id  -Unique 

$accessProfiles = $null
$a = $campaignFilter.access | where-object { $_.type -eq "ACCESS_PROFILE" } | Select-Object id 
$accessProfiles = $a | Select-Object -Property id -Unique 

$inclusionList = @()

$InclusionTemplate = [pscustomobject][ordered]@{
    id   = $null 
    type = $null 
}

# ROLES
foreach ($role in $roles) {
    $incRole = $InclusionTemplate.PsObject.Copy()
    $incRole.id = $role.id 
    $incRole.type = "ROLE"
    $inclusionList += $incRole
}

# ENTITLEMENTS
foreach ($entitlement in $entitlements) {
    $incEntitlement = $InclusionTemplate.PsObject.Copy()
    $incEntitlement.id = $entitlement.id 
    $incEntitlement.type = "ENTITLEMENT"
    $inclusionList += $incEntitlement
}

# ACCESS PROFILES
foreach ($accessProfile in $accessProfiles) {
    $incAccessProfile = $InclusionTemplate.PsObject.Copy()
    $incAccessProfile.id = $accessProfile.id 
    $incAccessProfile.type = "ACCESS_PROFILE"
    $inclusionList += $incAccessProfile
}

$e = $inclusionList | select-object -Property type | Where-Object { $_.type -eq "ENTITLEMENT" }
$a = $inclusionList | select-object -Property type | Where-Object { $_.type -eq "ACCESS_PROFILE" }
$r = $inclusionList | select-object -Property type | Where-Object { $_.type -eq "ROLE" }

write-host -ForegroundColor Blue "Campaign scope covers $($r.type.count) Role(s), $($e.type.count) Entitlement(s) and $($a.type.count) Access Profile(s)."

# Create Campaign
$campaignOptions = @{ }
$campaignOptions.Add("type", "Identity")
$campaignOptions.Add("timeZone", "GMT+1000")
$campaignOptions.Add("name", "Oct 2019 Special App Campaign")
$campaignOptions.Add("allowAutoRevoke", $false)
$campaignOptions.Add("deadline", "2019-11-1")
$campaignOptions.Add("description", "Special App Oct 2019")
$campaignOptions.Add("disableEmail", $true)
$campaignOptions.Add("identityIdList", @())
$campaignOptions.Add("identityQueryString", $query )
$campaignOptions.Add("accessInclusionList", $inclusionList)
$campaignBody = $campaignOptions | ConvertTo-Json

New-IdentityNowCertCampaign -start $true -campaign $campaignBody 

```

### Get IdentityNow Certification Campaign Reports ###
Get all certification campaign reports from the last year and output them to a local folder
[Reference post](https://blog.darrenjrobinson.com/retrieving-sailpoint-identitynow-certification-reports-using-powershell/)

Example
```
Get-IdentityNowCertCampaignReport -period "365" -outputPath "C:\Reports"
```

Get certification campaign reports for a specific campaign and return as PSObject 
Example
```
Get-IdentityNowCertCampaign -campaignID '2c918085694a507f01694b9fcce6002f' 
```

### Create / Get / Update / Remove IdentityNow Governance Groups ###
Get IdentityNow Governance Groups
[Reference post](https://blog.darrenjrobinson.com/managing-sailpoint-identitynow-governance-groups-via-the-api-with-powershell/)

Example
```
Get-IdentityNowGovernanceGroup 
```

Get a specific IdentityNow Governance Group
Example
```
Get-IdentityNowGovernanceGroup -groupID 4fc249bd-46ff-405a-93b9-21372f97c352
```

Update an IdentityNow Governance Group to remove one member and add two members
Example
```
# Get Group
$govGroups = Get-IdentityNowGovernanceGroup
$myGroup = $govGroups | Select-Object | Where-Object { $_.description -like "*My IDN Governance Group*" }

# Add
$user1 = Search-IdentityNowUsers -query "@accounts(accountId:darren.robinson)"
$user2 = Search-IdentityNowUsers -query "@accounts(accountId:rick.sanchez)"
$user3 = Search-IdentityNowUsers -query "@accounts(accountId:morty.smith)"

$add = @() 
$remove = @() 
$add += $user3.id
$add += $user2.id 
$remove += $user1.id 

$update = (@{
    add    = $add 
    remove = $remove
}) 

Update-IdentityNowGovernanceGroup -groupID $myGroup.id -update ($update | convertto-json)
```

Create an IdentityNow Governance Group and assign an owner
Example
```
$GovGroupOwner = Search-IdentityNowUsers -query "@accounts(accountId:darren.robinson)"

$body = @{"name"  = "New IDN Module Gov Group"; 
    "displayName" = "New Module Gov Group"; 
    "description" = "New Module Gov Group"; 
    "owner"       = @{"displayName" = $GovGroupOwner.displayName; 
        "emailAddress"        = $GovGroupOwner.email; 
        "id"                  = $GovGroupOwner.id; 
        "name"                = $GovGroupOwner.name                     
    } 
}
New-IdentityNowGovernanceGroup -group ($body | convertto-json) 
```

Delete an IdentityNow Governance Group
```
Remove-IdentityNowGovernanceGroup -groupID 4fc249bd-46ff-405a-93b9-21372f97c352
```

### Create / Get / Update / Remove IdentityNow Roles ###
Get IdentityNow Roles
[Reference post](https://blog.darrenjrobinson.com/managing-sailpoint-identitynow-roles-via-api-and-powershell/)

Example
```
Get-IdentityNowRole 
```

Get a specific IdentityNow Role
Example
```
Get-IdentityNowRole -roleID 2c918084691653af01695182a78b05ec
```

Update an IdentityNow Role
[Reference post](https://blog.darrenjrobinson.com/enabling-requestable-roles-in-sailpoint-identitynow-using-powershell/)

Example 
```
$body = @{
    "id"          = "2c9180886cd58059016d1a4757d709a4"
    "name"        = "Role - Special Admins";
    "displayName" = "Special Admins";
    "description" = "Special Admins Role";
    "disabled"    = $false;
    "owner"       = "darrenjrobinson"             
}    
Update-IdentityNowRole -update ($body | convertto-json)
```

Create an IdentityNow Role
Example
```
$body = @{
    "name"        = "Role - Special Administrators";
    "displayName" = "Special Administrators";
    "description" = "Special Administrators Role";
    "disabled"    = $true;
    "owner"       = "darrenjrobinson"             
}    

New-IdentityNowRole -role ($body | convertto-json) 
```

Delete an IdentityNow Role
Example
```
Remove-IdentityNowRole -roleID 2c9180886cd58059016d1a5a23f609a8
```

### Get / IdentityNow Sources ###
Get all IdentityNow Sources
[Reference post](https://blog.darrenjrobinson.com/managing-sailpoint-identitynow-sources-via-the-api-with-powershell/)

Example
```
Get-IdentityNowSource
```

Get a specific IdentityNow Source
Example
```
Get-IdentityNowSource -sourceID 12345
```

### Get Accounts from an IdentityNow Source ###
Get accounts from an IdentityNow Source
[Reference post](https://blog.darrenjrobinson.com/searching-returning-all-objects-users-from-a-sailpoint-identitynow-source/)

Example
```
Get-IdentityNowSourceAccounts -sourceID 40113
```

### Create / Update / Remove IdentityNow Source Account (Flat File / Delimited Sources)  ###
Create an account on an indirect IdentityNow Source
[Reference post](https://blog.darrenjrobinson.com/authoring-identities-in-sailpoint-identitynow-via-the-api-and-powershell/)

Example
```
$account = @{"id"    = 'darrenjrobinson'; 
        "name"        = 'darrenjrobinson'; 
        "givenName"   = 'Darren';             
        "familyName"  = 'Robinson'; 
        "displayName" = 'Darren Robinson'; 
        "email"       = 'darren.robinson@customer.com.au' 
    }

New-IdentityNowUserSourceAccount -source 36702 -account ($account | convertto-json)
```

Update an account on an indirect IdentityNow Source
[Reference post](https://blog.darrenjrobinson.com/lifecycle-management-of-identities-in-sailpoint-identitynow-via-api-and-powershell/)

Example
```
$update = @{
    "country" = "Australia"
    "department" = "Identity Architects"
    "organization" = "Kloud" 
} 

Update-IdentityNowUserSourceAccount -account 2c91808469110d6a016954d4dad138a3 -update ($update | ConvertTo-Json)
```

Delete an IdentityNow account from an indirect IdentityNow Source
[Reference post](https://blog.darrenjrobinson.com/lifecycle-management-of-identities-in-sailpoint-identitynow-via-api-and-powershell/)
Example (assumes user only has a single account on an indirect source)
```
$user = Search-IdentityNowUsers -query "@accounts(accountId:darrenjrobinson)"
$userIndirectAccounts = $user.accounts | select-object | where-object { ($_.source.type.contains("DelimitedFile")) }
$account = $userIndirectAccounts.id 

Remove-IdentityNowUserSourceAccount -account $account 
```

### Get / Complete IdentityNow Tasks ###
Get IdentityNow Tasks
[Reference post](https://blog.darrenjrobinson.com/managing-sailpoint-identitynow-tasks-with-powershell/)

Example
```
Get-IdentityNowTask
```

Get a specific IdentityNow Task
Example
```
Get-IdentityNowTask -taskID 2c918084691120d0016926a6a94251d6
```

Mark and IdentityNow Task as complete
Example
```
Complete-IdentityNowTask -taskID 2c918084691120d0016926a6a94251d6
```

### Get IdentityNow Virtual Appliances & Clusters ###
Get IdentityNow Virtual Appliance Clusters 
[Reference post](https://blog.darrenjrobinson.com/querying-sailpoint-identitynow-virtual-appliance-clusters-with-powershell/)

Example
```
Get-IdentityNowVACluster
```

Get IdentityNow Virtual Appliances from a cluster
Example
```
$clusters = Get-IdentityNowVACluster
foreach($va in $clusters){
    "Cluster: $($va.description) VA ID: $($va.clients.id) VA Description: $($va.client.description)"
}
```

### Get / Update IdentityNow Applications ###
Get IdentityNow Customer Created and Managed Applications
[Reference post](https://blog.darrenjrobinson.com/managing-sailpoint-identitynow-applications-via-api-with-powershell/)

Example
```
Get-IdentityNowApplication
```

Get IdentityNow Customer default configured SailPoint Applications
Example
```
Get-IdentityNowApplication -org $true
```

Get a specific IdentityNow Applications
Example
```
Get-IdentityNowApplication -appID 32128
```

Update an IdentityNow Application
Example
```
$appBody = @{ 
    "launchpadEnabled"        = $false   
    "provisionRequestEnabled" = $false
    "appCenterEnabled"        = $false
} 
Update-IdentityNowApplication -appID 24188 -update ($appBody | ConvertTo-Json) 
```

### Initiate Aggregation of an IdentityNow Source ###
Aggregate an IdentityNow Source
[Reference post](https://blog.darrenjrobinson.com/aggregating-sailpoint-identitynow-sources-via-api-with-powershell/)

Example
```
Invoke-IdentityNowAggregateSource -sourceID 12345
```

Aggregate an IdentityNow Source without optimization
[Reference post](https://blog.darrenjrobinson.com/aggregating-sailpoint-identitynow-sources-via-api-with-powershell/)

Example
```
Invoke-IdentityNowAggregateSource -sourceID 12345 -disableOptimization $true 
```

### Create / Get / Update / Remove IdentityNow Transforms ###
Get IdentityNow Transforms

Example
```
Get-IdentityNowTransform
```

Get an IdentityNow Transform

Example
```
Get-IdentityNowTransform -ID ToUpper
```

Update an IdentityNow Transform

Example
```
$attributes = @{value = '$firstName.$lastname@$company.com.au'}
$transform = @{type = "static"; attributes = $attributes}
Update-IdentityNowTransform -transform ($transform | convertto-json) -ID "Firstname.LastName"
```

Create an IdentityNow Transform

Example
```
$attributes = @{value = '$firstName.$lastname'}
$transform = @{type = "static"; id = "FirstName.LastName"; attributes = $attributes}
New-IdentityNowTransform -transform ($transform | convertto-json) 
```

Delete an IdentityNow Transform

Example 
```
Remove-IdentityNowTransform -ID "Firstname.LastName"
```

### Get IdentityNow Rules ###
Get IdentityNow Rules

Example
``` 
Get-IdentityNowRule
```

Get an IdentityNow Rule

Example
``` 
Get-IdentityNowRule -ID 2c9170826219ab41014275b47fc40b0a
```

### Get / Update Email Templates ###
Get Email Templates

Example
```
Get-IdentityNowEmailTemplate
```

Get an Email Template

Example
```
Get-IdentityNowEmailTemplate -ID 2c91601362431b32016275b4241b08f0
```

Update Email Template

Example
```
$templateChanges = @{}
$templateChanges.add("id","2c91601362431b32016275b4241b08f0")
$templateChanges.add("subject",'Access Request requires completion of Work Item ID : $workItemName')

Update-IdentityNowEmailTemplate -template ($templateChanges | ConvertTo-Json)
```
### Get IdentityNow Profiles ###
Get IdentityNow Identity Profiles

Example 
```
Get-IdentityNowProfile
```

Get an IdentityNow Profile

Example 
```
Get-IdentityNowProfile -ID 1033
```

### Get / Update IdentityNow Profiles Order ###
Get IdentityNow Profiles Order

Example
```
Get-IdentityNowProfileOrder 

ProfileName           Priority   ID
-----------           --------   --
IdentityNow Admins          10 1066
Cloud Identities            30 1285
Guest Identities            40 1286
Special Identities          60 1372
Non Employee Identities     70 1380
Employee Identities         80 1387
```

Update IdentityNow Profile Order

Example
```
Update-IdentityNowProfileOrder -id 1285 -priority 20
```

### Create / Get / Remove API Management Clients (Legacy v2) ###
Get v2 API Clients

Example
```
Get-IdentityNowAPIClient
```

Create a v2 API Client

Example 
```
New-IdentityNowAPIClient 
```

Remove a v2 API Client

Example
```
Remove-IdentityNowAPIClient -ID 123
```

### Create / Get / Remove oAuth API Clients ###
Get oAuth API (v3) Clients

Example
```
Get-IdentityNowOAuthAPIClient 
```

Get an oAuth API (v3) Client

Example
```
Get-IdentityNowOAuthAPIClient -clientID '8432e57d-5f8f-dead-beef-a7bf123456a1'
```

Create an oAuth API Client (v3)

Example
```
New-IdentityNowOAuthAPIClient -description 'oAuth Client' -grantTypes 'AUTHORIZATION_CODE,CLIENT_CREDENTIALS,REFRESH_TOKEN,PASSWORD' -redirectUris 'https://localhost,https://myapp.com.au'
```

Remove an oAuth API Client (v3)

Example
```
Remove-IdentityNowOAuthAPIClient -ID '9e23deaf-48aa-dead-beef-ab6821a12ab2'
```

### ... and the ultimate flexible cmdlet Invoke-IdentityNowRequest ###
The cmdlet that lets you do your thing, with a little help. 
This cmdlet has options for v2 and v3 authentication and will provide the web request headers (with and without content-type = application/json set).
You supply the URI for the request, the method (POST, GET, DELETE, PATCH) and the request will be sent, and the results sent back.

Request Methods are;
* Get
* Put
* Patch
* Delete
* Post

Header options are; 
* HeadersV2 - Headersv2 Digest Auth with no Content-Type set 
* HeadersV3 - Headersv3 is JWT oAuth with no Content-Type set 
* Headersv2_JSON - Headersv2_JSON is Digest Auth with Content-Type set for application/json
* Headersv3_JSON - Headersv3_JSON is JWT oAuth with Content-Type set for application/json

Example 1
Get the Schema of a Source
[Reference post](https://blog.darrenjrobinson.com/creating-sailpoint-identitynow-source-configuration-backups-and-html-reports-with-powershell/)

```
$orgName = "customer-sb"
$sourceID = "12345"
Invoke-IdentityNowRequest -Method Get -Uri "https://$($orgName).api.identitynow.com/cc/api/source/getAccountSchema/$($sourceID)" -headers HeadersV3                
```

Example 2
List Identity Profiles
[Reference post](https://blog.darrenjrobinson.com/changing-sailpoint-identitynow-identity-profiles-priorities-using-powershell/)

```
$orgName = "customer-sb"
Invoke-IdentityNowRequest -Method Get -Uri "https://$($orgName).identitynow.com/api/profile/list" -headers Headersv2_JSON 
```

Example 3
Get IdentityNow Identity Attributes
[Reference post](https://blog.darrenjrobinson.com/indexing-a-sailpoint-identitynow-attribute-in-an-identity-cube-for-use-in-correlation-rules/)

```
$orgName = "customer-sb"
Invoke-IdentityNowRequest -Method Get -Uri "https://$($orgName).api.identitynow.com/cc/api/identityAttribute/list" -headers HeadersV3 
```

## Disclaimer - Fine Print ##
I am not a SailPoint employee. I wrote this for our needs and am sharing it with the community.

**** Please use with caution. These cmdlets come with full functionality. Use this power responsibly AND AT YOUR OWN RISK. ****

## How can I contribute to the project?
* Found an issue and want us to fix it? [Log it](https://github.com/darrenjrobinson/powershell_module_identitynow/issues)
* Want to fix an issue yourself or add functionality? Clone the project and submit a pull request.
* Any and all contributions are more than welcome and appreciated. 

## More information on managing SailPoint IdentityNow via API 
I've wrirten extensive posts on many of these functions. Details are in this section [on my blog](https://blog.darrenjrobinson.com/sailpoint-identitynow/)

## Keep up to date
* [Visit my blog](https://blog.darrenjrobinson.com)
* [Follow darrenjrobinson on Twitter](https://twitter.com/darrenjrobinson)![](http://twitter.com/favicon.ico)
