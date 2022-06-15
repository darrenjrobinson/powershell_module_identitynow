# SailPoint IdentityNow PowerShell Module #

**NOTE: This is not an official SailPoint Module.**

[![PSGallery Version](https://img.shields.io/powershellgallery/v/SailPointIdentityNow.svg?style=flat&logo=powershell&label=PSGallery%20Version)](https://www.powershellgallery.com/packages/SailPointIdentityNow) [![PSGallery Downloads](https://img.shields.io/powershellgallery/dt/SailPointIdentityNow.svg?style=flat&logo=powershell&label=PSGallery%20Downloads)](https://www.powershellgallery.com/packages/SailPointIdentityNow)

## Description ##

A PowerShell Module enabling simple methods for accessing the SailPoint IdentityNow REST API's.

This PowerShell Module has been written to fulfil my colleagues IdentityNow automation needs. It is based heavily off the extensive work I've done reverse engineering the SailPoint IdentityNow Portal in order to allow me to orchestrate IdentityNow using PowerShell. That work is covered [on my blog here](https://blog.darrenjrobinson.com/sailpoint-identitynow/)

SailPoint IdentityNow is a SaaS product. The functions and functionality of it is constantly evolving as are the API's that underpin those functions. As such I've attempted to keep each cmdlet lean. The ability to submit a request and get something back.

I get a lot of requests for assistance with IdentityNow API integration so here is a module that makes the barrier to entry considerably lower. You may find it helpful and may even wish to comment or contribute. I have hosted the source on GitHub  (<https://github.com/darrenjrobinson/powershell_module_identitynow>).

## Features ##

* Easy command-line use, after setting default configuration options and securely saving them to the current user's profile.
* Get an IdentityNow Organisation and Get / Update an Organisation Configuration
* Test IdentityNow Credentials
* Get IdentityNow Queue
* Get IdentityNow Active Jobs
* Get IdentityNow Org Status
* Get / Set IdentityNow TimeZone
* Search IdentityNow Users
* Search IdentityNow Users Profiles
* Search IdentityNow Entitlements
* Search IdentityNow Identities
* Search IdentityNow Access Profiles, Account Activities, Accounts, Aggregations, Entitlements, Events, Identities, Roles
* Create / Get / Update / Remove IdentityNow Access Profiles
* Get Access Profiles associated with an IdentityNow Application
* Create / Get / Start IdentityNow Certification Campaigns
* Get IdentityNow Certification Campaign Reports (output to file or return as PSObject)
* Create / Get / Update / Remove IdentityNow Governance Groups
* Create / Get / Update / Remove IdentityNow Roles
* Get / Update / Test / Create / Remove IdentityNow Sources
* Get IdentityNow Source Schema
* Create IdentityNow Source Account Schema Attributes
* Export IdentityNow Configuration
* Generate IdentityNow Sources Configuration Report
* Generate IdentityNow Identity Profiles Configuration Report
* Get Accounts from an IdentityNow Source
* Create / Update / Remove IdentityNow Source Account (Flat File / Delimited Sources)
* Create / Update IdentityNow Source Entitlements (Flat File / Delimited Sources)
* Join IdentityNow Account
* Get / Complete IdentityNow Tasks
* Get IdentityNow Virtual Appliance Clusters (and clients (VA's))
* Get / Update IdentityNow Applications
* Create / Get / Update / Remove IdentityNow Transforms
* Set Identity Transforms Lookup
* Get IdentityNow Rules
* Get / Update Email Templates
* Create / Get / Remove IdentityNow Identity Profiles
* Refresh an IdentityNow Identity Profile
* Get / Update IdentityNow Profiles Order
* Get / Update Identity Attributes
* Get Identity Attribute Preview
* Create / Get / Remove API Management Clients (Legacy v2)
* Create / Get / Remove oAuth API Clients (v3)
* Search Events - Elasticsearch
* List Account Activities
* Get Account Activity
* Reset an IdentityNow Source
* .... and if they don't fit **Invoke-IdentityNowRequest** to make any other API call (examples for Get Source Schema, Get IdentityNow Identity Profiles, Get IdentityNow Identity Attributes)

## Installation ##

### v1.0.6 and later ###

No dependencies. v1.0.6 and later is compatible with PowerShell Desktop 5+ and PowerShell Core 6+ / PowerShell 7

~~v1.0.5 and earlier~~

~~The dependencies are PowerShell version 5 and the PowerShell Community eXtension. If for some reason (like you're on an airgapped network), you can get [PSCx it from here](https://github.com/Pscx/Pscx)~~

To install either...

* Download the module files from the [GitHub Repo](https://github.com/darrenjrobinson/powershell_module_identitynow)
* As an Administrator execute the script Install-IdentityNowModule.ps1

```powershell
./Install-IdentityNowModule.ps1 
```

or

* From an Admin PowerShell session, install from the PowerShell Gallery

```powershell
install-module -name SailPointIdentityNow
```

## Examples ##

These examples are also available as an interactive PowerShell Jupyter Notebook. You can download the examples [PowerShell Jupyter Notebook from here](https://gist.github.com/darrenjrobinson/dfbf7470212fb295fc13c6608d91c0f1).

To get started with Local PowerShell Jupyter Notebook [see this post](https://blog.darrenjrobinson.com/getting-started-with-local-powershell-jupyter-notebook/).

### Setting up Credentials and Organisation Configuration ###

[Reference Post](https://blog.darrenjrobinson.com/generate-sailpoint-identitynow-v2-v3-api-credentials/)
**Note: You can configure oAuth Client Authentication configuration and then use the New-IdentityNowAPIClient cmdlet to generate the v2 API Client.**

**Update: Aug 2020 - v2 API Clients have been deprecated for API use. They still exist for VA use and can still be generated, but now must reference the VA Cluster. The New-IdentityNowAPIClient now contains the mandatory -clusterId option to achieve this.**

**Update: June 2021 - The Password Grant Type has been deprecated. [Reference Post](https://community.sailpoint.com/t5/SaaS-Updates/Introducing-Personal-Access-Tokens/ba-p/172974) Configuring access and credentials for IdentityNow MUST utilise Personal Access Tokens. While logged into the IdentityNow Portal select your Identity Name in the top right corner of the menu, select Preferences => Personal Access Tokens => New Token => Create.**

```powershell
    $orgName = "customername-sb"
    Set-IdentityNowOrg -orgName $orgName

    # IdentityNow Admin User
    $adminUSR = "identityNow_admin_User"
    $adminPWD = 'idnAdminUserPassword'
    $adminCreds = [pscredential]::new($adminUSR, ($adminPWD | ConvertTo-SecureString -AsPlainText -Force))

    # IdentityNow Personal Access Token as generated through the IdentityNow Portal and your personal identity profile preferences
    $patClientID = 'yourClientID'
    $patClientSecret = 'yourClientSecret'
    $patCreds = [pscredential]::new("$($patClientID)", ($patClientSecret | ConvertTo-SecureString -AsPlainText -Force))

    Set-IdentityNowCredential -AdminCredential $adminCreds -PersonalAccessToken $patCreds
    Save-IdentityNowConfiguration
```

_Optional_ v2 Credentials are now only used for VA's.
If you have previously generated v2 creds and wish to utilise them with Invoke-IdentityNowRequest, they can be saved to your profile.

Example

```powershell
    # IdentityNow API Client ID & Secret generated using New-IdentityNowAPIClient
    $clientID = 'zo7ABCDaTHjA0Rwv'
    # Your API Client Secret
    $clientSecret = '3Zm9Qod4sWhihABCdefgCX9DIfmwAZiP'
    $v2Creds = [pscredential]::new($clientID, ($clientSecret | ConvertTo-SecureString -AsPlainText -Force))

    Set-IdentityNowCredential -AdminCredential $adminCreds -v3APIKey $v3Creds -v2APIKey $v2Creds -PersonalAccessToken $patCreds
    Save-IdentityNowConfiguration
```

**Note:** you can use New-IdentityNowAPIClient to generate v2 credentials after setting just the v3 credentials (via the IdentityNow Portal for your first API key).

or with credential prompts

```powershell
    Set-IdentityNowOrg 'myPrimaryIDNOrg'
    Set-IdentityNowCredential
    Save-IdentityNowConfiguration -default

    Set-IdentityNowOrg 'mySecondaryIDNOrg'
    Set-IdentityNowCredential
    Save-IdentityNowConfiguration
```

Switch IdentityNow Credentials. From v1.0.5 if you have multiple credentials save you can switch the credentials used (to switch IdentityNow Org's).

Example

```powershell
Set-IdentityNowOrg 'otherOrg'
```

Switch IdentityNow Credentials and make them the default configuration. From v1.0.5 if you have multiple credentials save you can switch the credentials used (to switch IdentityNow Org's).

Example

```powershell
Set-IdentityNowOrg 'otherOrg'
Save-IdentityNowConfiguration -default
```

### IdentityNow PowerShell Module Cmdlets ###

```powershell
Get-Command -Module SailPointIdentityNow | Sort-Object Name | Get-Help | Format-Table Name, Synopsis -Autosize

Name                                        Synopsis
----                                        --------
Complete-IdentityNowTask                    Complete an IdentityNow Task.
Convert-UnixTime                            Convert UnixTime to PowerShell DateTime
Export-IdentityNowConfig                    Export IdentityNow configuration items
Get-HashString                              Generate IdentityNow Admin User Password Hash to obtain oAuth Access Token.
Get-IdentityNowAccessProfile                Get an IdentityNow Access Profile(s).
Get-IdentityNowAccountActivities            Get IdentityNow Activities.
Get-IdentityNowAccountActivity              Get IdentityNow Activity for an account.
Get-IdentityNowActiveJobs                   Get IdentityNow Active Jobs.
Get-IdentityNowAPIClient                    Get IdentityNow API Client(s).
Get-IdentityNowApplication                  Get IdentityNow Application(s).
Get-IdentityNowApplicationAccessProfile     Get IdentityNow Access Profile(s) of an application.
Get-IdentityNowAuth                         Get IdentityNow JWT access token or basic auth header.
Get-IdentityNowCertCampaign                 Get IdentityNow Certification Campaign(s).
Get-IdentityNowCertCampaignReport           Get IdentityNow Certification Campaign Report(s).
Get-IdentityNowEmailTemplate                Get IdentityNow Email Template(s).
Get-IdentityNowGovernanceGroup              Get an IdentityNow Governance Group.
Get-IdentityNowIdentityAttribute            Get an IdentityNow Identity Attribute(s).
Get-IdentityNowIdentityAttributePreview     Get an IdentityNow Identity Attribute Mapping Preview.
Get-IdentityNowOAuthAPIClient               Get IdentityNow oAuth API Client(s).
Get-IdentityNowOrg                          Displays the default Uri value for all or a particular Organisation based on configured OrgName.
Get-IdentityNowOrgConfig                    Get IdentityNow Org Global Reminders and Escalation Policies Configuration.
Get-IdentityNowOrgStatus                    Get an IdentityNow Org Status.
Get-IdentityNowPersonalAccessToken          List IdentityNow Personal Access Tokens.
Get-IdentityNowProfile                      Get IdentityNow Identity Profile(s).
Get-IdentityNowProfileOrder                 Get IdentityNow Profiles Order.
Get-IdentityNowQueue                        Get IdentityNow Queues.
Get-IdentityNowRole                         Get IdentityNow Role(s).
Get-IdentityNowRule                         Get IdentityNow Rule(s).
Get-IdentityNowSource                       Get IdentityNow Source(s).
Get-IdentityNowSourceAccounts               Get IdentityNow Accounts on a Source.
Get-IdentityNowSourceSchema                 Get the Schema for an IdentityNow Source.
Get-IdentityNowTask                         Get an IdentityNow Task(s).
Get-IdentityNowTimeZone                     Get IdentityNow Time Zone(s).
Get-IdentityNowTransform                    Get IdentityNow Transform(s).
Get-IdentityNowVACluster                    Get IdentityNow Virtual Appliance Cluster(s).
Invoke-IdentityNowAccountCorrelation        Find uncorrelated accounts that can be joined
Invoke-IdentityNowAggregateEntitlement      Initiate Entitlement Aggregation of an IdentityNow Source.
Invoke-IdentityNowAggregateSource           Initiate Aggregation of an IdentityNow Source.
Invoke-IdentityNowRequest                   Submit an IdentityNow API Request.
Invoke-IdentityNowSourceReset               Reset an IdentityNow Source.
Join-IdentityNowAccount                     Join an IdentityNow User Account to an Identity.
New-IdentityNowAccessProfile                Create an IdentityNow Access Profile.
New-IdentityNowAPIClient                    Create an IdentityNow v2 API Client for use with a Virtual Appliance.
New-IdentityNowCertCampaign                 Create an IdentityNow Certification Campaign.
New-IdentityNowGovernanceGroup              Create a new IdentityNow Governance Group.
New-IdentityNowIdentityProfilesReport       Generate a HTML Report of IdentityNow Identity Profiles and export each Identity Profile config.
New-IdentityNowOAuthAPIClient               Create an IdentityNow v3 oAuth API Client.
New-IdentityNowPersonalAccessToken          Create an IdentityNow v3 oAuth Personal Access Token.
New-IdentityNowProfile                      Create new IdentityNow Identity Profile(s).
New-IdentityNowRole                         Create an IdentityNow Role.
New-IdentityNowSource                       Create an IdentityNow Source.
New-IdentityNowSourceAccountSchemaAttribute Discover or add to a sources account schema.
New-IdentityNowSourceConfigReport           Generate a HTML Report of IdentityNow Sources configuration and export each Source and Schema config.
New-IdentityNowSourceEntitlements           Create/Update IdentityNow Entitlements on a Flat File Source.
New-IdentityNowTransform                    Create an IdentityNow Transform.
New-IdentityNowUserSourceAccount            Create an IdentityNow User Account on a Flat File Source.
Remove-IdentityNowAccessProfile             Delete an IdentityNow Access Profile.
Remove-IdentityNowAPIClient                 Delete an IdentityNow API Client.
Remove-IdentityNowGovernanceGroup           Delete an IdentityNow Governance Group.
Remove-IdentityNowOAuthAPIClient            Delete an IdentityNow oAuth API Client.
Remove-IdentityNowPersonalAccessToken       Delete a personal access token in IdentityNow.
Remove-IdentityNowProfile                   Delete an IdentityNow Identity Profile.
Remove-IdentityNowRole                      Delete an IdentityNow Role.
Remove-IdentityNowSource                    Deletes an IdentityNow Source.
Remove-IdentityNowTransform                 Delete an IdentityNow Transform.
Remove-IdentityNowUserSourceAccount         Delete an IdentityNow User Account on a Flat File Source.
Save-IdentityNowConfiguration               Saves default IdentityNow configuration to a file in the current users Profile.
Search-IdentityNow                          Search IdentityNow Access Profiles, Account Activities, Accounts, Aggregations, Entitlements, Events, Identities, Roles.
Search-IdentityNowEntitlements              Get IdentityNow Entitlements.
Search-IdentityNowEvents                    Search IdentityNow Event(s) using Elasticsearch queries.
Search-IdentityNowIdentities                Search IdentityNow Identitie(s) using Elasticsearch queries.
Search-IdentityNowUserProfile               Get an IdentityNow Users Identity Profile.
Search-IdentityNowUsers                     Get IdentityNow Users.
Set-IdentityNowCredential                   Sets the default IdentityNow API credentials.
Set-IdentityNowOrg                          Sets the default Organisation name for an IdentityNow Tenant.
Set-IdentityNowTimeZone                     Set IdentityNow Time Zone.
Set-IdentityNowTransformLookup              Update lookup transform
Start-IdentityNowCertCampaign               Start an IdentityNow Certification Campaign that is currently 'Staged'.
Start-IdentityNowProfileUserRefresh         Triggers a user refresh for an IdentityNow Identity Profile(s).
Test-IdentityNowCredentials                 Tests IdentityNow Live credentials.
Test-IdentityNowSourceConnection            Tests connection on an IdentityNow Source.
Test-IdentityNowToken                       Helper function to test valid token.
Test-IdentityNowTransforms                  Test IdentityNow transforms to detect common problems
Update-IdentityNowAccessProfile             Update an IdentityNow Access Profile(s).
Update-IdentityNowApplication               Update an IdentityNow Application.
Update-IdentityNowEmailTemplate             Update an IdentityNow Email Template.
Update-IdentityNowGovernanceGroup           Add or Remove member(s) from an IdentityNow Governance Group.
Update-IdentityNowIdentityAttribute         Update an IdentityNow Identity Attribute to be listed in Identity Profiles.
Update-IdentityNowOrgConfig                 Update IdentityNow Org Global Reminders and Escalation Policies Configuration.
Update-IdentityNowProfileMapping            Update IdentityNow Profile Attribute Mapping.
Update-IdentityNowProfileOrder              Update IdentityNow Profile Order.
Update-IdentityNowRole                      Update an IdentityNow Role.
Update-IdentityNowSource                    Update the configuration of an IdentityNow Source.
Update-IdentityNowTransform                 Update an IdentityNow Transform.
Update-IdentityNowUserSourceAccount         Update an IdentityNow User Account on a Flat File Source.
```

### Get an IdentityNow Organisation and Get / Update an Organisation Configuration ###

* Display the configured IdentityNow Organisation as set by "Set-IdentityNowOrg"
* API endpoints for currently configured organisation

Example

```powershell
Get-IdentityNowOrg 

Name                           Value                                                                                                                                     
----                           -----                                                                                                                                     
Organisation Name              customer-sb
Organisation URI               https://customer-sb.identitynow.com
v1 Base API URI                https://customer-sb.identitynow.com/api
v2 Base API URI                https://customer-sb.api.identitynow.com/v2
v3 Base API URI                https://customer-sb.api.identitynow.com/v3
Private Base API URI           https://customer-sb.api.identitynow.com/cc/api
Beta                           https://customer-sb.api.identitynow.com/beta
```

Update an IdentityNow Organisation Setting
[Reference post](https://blog.darrenjrobinson.com/get-update-sailpoint-identitynow-global-reminders-and-escalation-policies/)

Example

```powershell
# Get Current Config
$orgConfig = Get-IdentityNowOrgConfig
# Get Fallback Approver User Profile
$fallbackApprover = (Search-IdentityNowUserProfile -query "darren.robinson").alias

$approvalConfig = $orgConfig.approvalConfig

# global reminders and escalation policies for access request approvals
$daysBetweenReminders = 3
$daysTillEscalation = 5
$maxReminders = 10

# Set Config options to update
$approvalConfig.daysBetweenReminders = $daysBetweenReminders
$approvalConfig.daysTillEscalation = $daysTillEscalation
$approvalConfig.maxReminders = $maxReminders
$approvalConfig.fallbackApprover = $fallbackApprover
$approvalConfigBody = @{"approvalConfig" = $approvalConfig }

Update-IdentityNowOrgConfig -update ($approvalConfigBody | convertto-json)

```

### Test IdentityNow Credentials ###

Test saved IdentityNow PowerShell Module credentials.
Validates the saved credentials (v2 and v3) against the configured Org.

Example

```powershell
Test-IdentityNowCredentials
```

### Test IdentityNow Transforms ###

Test IdentityNow transforms to detect common problems

Example

```powershell
Test-IdentityNowTransforms 
```

### Get IdentityNow Queue ###

Query the IdentityNow Org for currently queued events.
Equivalent of the Portal Dashboard -> monitor, how busy in your tenant

Example

```powershell
Get-IdentityNowQueue
```

### Get IdentityNow Active Jobs ###

Query the IdentityNow Org for Active Jobs.
Equivalent of the Portal Dashboard -> monitor, how busy in your tenant

Example

```powershell
Get-IdentityNowActiveJobs
```

### Get IdentityNow Org Status ###

Query the IdentityNow Org for current status.
Equivalent of the info you see on the Overview page. A count of Identities, VAs, Sources, and Applications including any in an error state,

Example

```powershell
Get-IdentityNowOrgStatus
```

### Get IdentityNow TimeZone(s) ###

Get the configured Organisation Time Zone configuration

Example

```powershell
Get-IdentityNowTimeZone
```

Get a list of time zones that can be configured.

Example

```powershell
Get-IdentityNowTimeZone -list
```

### Set IdentityNow Time Zone ###

Set the time zone for an IdentityNow Organisation to a valid value (as retrieved using Get-IdentityNowTimeZone - list)

Example

```powershell
Set-IdentityNowTimeZone -tz 'Australia/Sydney'
```

### Search IdentityNow Users ###

Search for IdentityNow Users
[Reference post](https://blog.darrenjrobinson.com/reporting-on-sailpoint-identitynow-identities-using-the-search-beta-api-and-powershell/)

Examples

```powershell
Search-IdentityNowUsers -query darrenjrobinson
Search-IdentityNowUsers -query "@accounts(accountId:darren.robinson)"
Search-IdentityNowUsers -query "@source(id:2c91808469110d6a016954d4dad138a3)"
Search-IdentityNowUsers -query "@access(source.name:*Active Directory*) AND attributes.company:Kloud" 
```

### Search IdentityNow Users Profiles ###

Search for a user's IdentityNow Profile from the IdentityNow Identity List
[Reference post - See Profile Owner Section](https://blog.darrenjrobinson.com/creating-sailpoint-identitynow-access-profiles-via-api-and-powershell/)

Example

```powershell
Search-IdentityNowUserProfile -query "darrenjrobinson"
```

### Search IdentityNow Entitlements ###

Search for Entitlements associated with IdentityNow Sources
[Reference post](https://blog.darrenjrobinson.com/searching-and-returning-sailpoint-identitynow-entitlements-using-the-api-and-powershell/)

Example

```powershell
Search-IdentityNowEntitlements -query "File_Share_Sydney"
```

Search for entitlements on a Source. Use Source externalId (rather than Source Name)

Example

```powershell
Search-IdentityNowEntitlements -query "source.id:2c918083670df373016835e063ff6b5b"
```

### Search IdentityNow Access Profiles, Account Activities, Accounts, Aggregations, Entitlements, Events, Identities, Roles ###

A Search cmdlet that allows you to specify the search indice.

query
    Query in Elasticsearch Syntax
    [Reference Elasticsearch Syntax](https://community.sailpoint.com/t5/Admin-Help/How-do-I-use-Search-in-IdentityNow/ta-p/76960)

limit
    results to be returned

indice
    (required) v3 Search Indice to search.
    valid indices are "accessprofiles", "accountactivities", "accounts", "aggregations", "entitlements", "events", "identities", "roles"

nested
    (optional) defaults to True
    Indicates if nested objects from returned search results should be included

Example

```powershell
Search-IdentityNow -query "source.name:'Active Directory'" -indice "accessprofiles" -nested $false
```

Example

```powershell
Search-IdentityNow -query "source.id:2c918083670df373016835e063ff6b5b" -indice "entitlements" -nested $false
```

Example

```powershell
Search-IdentityNow -query "@accounts.entitlementAttributes.'App_Group_*'" -indice "accounts" -nested $false
```

### Search IdentityNow Identities (Beta - Elasticsearch) ###

Search IdentityNow Identities using the new IdentityNow Search (Elasticsearch).
Results defaults to 2500. If you want more or less use the -searchLimit option.

[Reference Elasticsearch Syntax](https://community.sailpoint.com/t5/Admin-Help/How-do-I-use-Search-in-IdentityNow/ta-p/76960)

Search for Entitlements that include the name 'File Share' including nested groups.

Example

```powershell
$queryFilter = '{"query":{"query":"@access(type:ENTITLEMENT AND name:*File Share*)"},"includeNested":true}'
Search-IdentityNowIdentities -filter $queryFilter 
```

Search for Entitlements that include the name 'File Share' including nested groups but only return 100 results

Example

```powershell
$queryFilter = '{"query":{"query":"@access(type:ENTITLEMENT AND name:*File Share*)"},"includeNested":true}'
Search-IdentityNowIdentities -filter $queryFilter -searchLimit 100
```

### Create / Get / Update / Remove IdentityNow Access Profiles ###

Get all IdentityNow Access Profiles
[Reference post](https://blog.darrenjrobinson.com/creating-sailpoint-identitynow-access-profiles-via-api-and-powershell/)

Example

```powershell
Get-IdentityNowAccessProfile
```

Get a specific IdentityNow Access Profile

```powershell
Get-IdentityNowAccessProfile -profileID 2c91808369a606f00169c756f0a00017
```

Create an IdentityNow Access Profile

Example 1

```powershell
New-IdentityNowAccessProfile -profile "{"entitlements":  ["2c91808668dcf3970168dd722e7a020d","2c91808468dcf4610168dd78d2e8531e"],"description":  "FS-SYDNEY-AUS-ENGINEERING","requestCommentsRequired":  true,"sourceId":  "39082","approvalSchemes":  "manager","ownerId":  "1397606","name":  "Sydney Engineering","deniedCommentsRequired":  true}"
```

Example 2

```powershell
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

```powershell
Update-IdentityNowAccessProfile -profileID 2c91808466a64e330112a96902ff1f69 -update "{"deniedCommentsRequired":  true,"requestCommentsRequired":  true}"
```

Example 2

```powershell
$ap = Get-IdentityNowAccessProfile 
$accessProfile = $ap | Select-Object | Where-Object {$_.description -like '*Darren*'}

$updateAccessProfile = @{} 
$updateAccessProfile.Add("requestCommentsRequired", $true) 
$updateAccessProfile.Add("deniedCommentsRequired", $true) 

Update-IdentityNowAccessProfile -profileID $accessProfile.id -update ($updateAccessProfile | convertto-JSON)
```

Remove an IdentityNow Access Profile

Example 1

```powershell
Remove-IdentityNowAccessProfile -profileID 2c91808369a606f00169c756f0a00017
```

Example 2

```powershell
$ExistingAPs = Get-IdentityNowAccessProfile
$myAP = $ExistingAPs | Select-Object | Where-Object {$_.name -like "*My Access Profile*"}
Remove-IdentityNowAccessProfile -profileID $myAP.id
```

### Update IdentityNow Identity Profile Mapping ###

Update IdentityNow Profile Attribute Mapping.

Example 1 - Map SamAccountName from the AD Source to Identity Attribute UID on Identity Profile ID 1285

```powershell
Update-IdentityNowProfileMapping -id 1285 -IdentityAttribute uid -sourceType Standard -source 'AD:SamAccountName'
```

Example 2 - Map SamAccountName from the AD Source to Identity Attribute UID using Transform 'transform-UID' on Identity Profile ID 1285

```powershell
Update-IdentityNowProfileMapping -id 1285 -IdentityAttribute uid -sourceType Standard -source @('AD','SamAccountName','transform-UID')
```

Example 3 - Clear the mapping for UID on Identity Profile ID 1285

```powershell
Update-IdentityNowProfileMapping -id 1285 -IdentityAttribute uid -sourceType Null 
```

Example 4 - Map managerDN to the returned value from the 'Rule - IdentityAttribute - Get Manager' rule on Identity Profile ID 1285

```powershell
Update-IdentityNowProfileMapping -id 1285 -IdentityAttribute managerDn -sourceType Complex -source 'Rule - IdentityAttribute - Get Manager'
```

### Get Access Profiles associated with an IdentityNow Application ###

Get the IdentityNow Access Profiles associated with an IdentityNow Application.

Example

```powershell
Get-IdentityNowApplicationAccessProfile -appID 50608
```

### Create / Get / Start IdentityNow Certification Campaigns ###

Get all (active and completed) IdentityNow Certification Campaigns
[Reference post](https://blog.darrenjrobinson.com/accessing-sailpoint-identitynow-certification-campaigns-using-powershell/)

Example

```powershell
Get-IdentityNowCertCampaign -completed $false
```

Get a specific IdentityNow Certification Campaign

Example

```powershell
Get-IdentityNowCertCampaign -campaignID 2c9180856708ae38016709f4812345c3
```

#### Create an IdentityNow Certification Campaign ####

[Reference post](https://blog.darrenjrobinson.com/creating-sailpoint-identitynow-certification-campaigns-using-powershell/)

Example

```powershell
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

#### Start IdentityNow Certification Campaigns ####

Start a Certification Campaign where the campaign(s) have been created using the module and you've looked at the preview via the portal etc and now want to start them.

Start Certification Campaign using ID of the campaign (ID not campaignFilterId)

Example

```powershell
Start-IdentityNowCertCampaign -campaignID 2c9180856d17db72016d18ed75560036 -timezone GMT+1100
```

Example

```powershell
$incompleteCampaigns = Get-IdentityNowCertCampaign -completed $false
$myCampaign = $incompleteCampaigns | select-object | Where-Object {$_.name -like '*Restricted App X Campaign*'}
Start-IdentityNowCertCampaign -campaignID $myCampaign.id -timezone "GMT+1100"
```

### Get IdentityNow Certification Campaign Reports ###

Get all certification campaign reports from the last year and output them to a local folder
[Reference post](https://blog.darrenjrobinson.com/retrieving-sailpoint-identitynow-certification-reports-using-powershell/)

Example

```powershell
Get-IdentityNowCertCampaignReport -period "365" -outputPath "C:\Reports"
```

Get incomplete certification reports from the last 30 days

```powershell
Get-IdentityNowCertCampaignReport -period "30" -completed $false
```

Get certification campaign reports for a specific campaign and return as PSObject

Example

```powershell
Get-IdentityNowCertCampaignReport -campaignID '2c918085694a507f01694b9fcce6002f' 
```

### Create / Get / Update / Remove IdentityNow Governance Groups ###

Get IdentityNow Governance Groups
[Reference post](https://blog.darrenjrobinson.com/managing-sailpoint-identitynow-governance-groups-via-the-api-with-powershell/)

Example

```powershell
Get-IdentityNowGovernanceGroup 
```

Get a specific IdentityNow Governance Group

Example

```powershell
Get-IdentityNowGovernanceGroup -groupID 4fc249bd-46ff-405a-93b9-21372f97c352
```

Update an IdentityNow Governance Group to remove one member and add two members

Example

```powershell
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

```powershell
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

```powershell
Remove-IdentityNowGovernanceGroup -groupID 4fc249bd-46ff-405a-93b9-21372f97c352
```

### Create / Get / Update / Remove IdentityNow Roles ###

Get IdentityNow Roles
[Reference post](https://blog.darrenjrobinson.com/managing-sailpoint-identitynow-roles-via-api-and-powershell/)

Example

```powershell
Get-IdentityNowRole 
```

Get a specific IdentityNow Role

Example

```powershell
Get-IdentityNowRole -roleID 2c918084691653af01695182a78b05ec
```

Sort the return of IdentityNow Roles

Sorters are: name, created modified

For reverse sort use: -name -modified -created

Multiple sorts are also valid

Example 1

```powershell
Get-IdentityNowRole -sorters name 
```

Example 2

```powershell
Get-IdentityNowRole -sorters modified, name
```

Example 3

```powershell
Get-IdentityNowRole -sorters "-modified", created
```

Update an IdentityNow Role
[Reference post](https://blog.darrenjrobinson.com/enabling-requestable-roles-in-sailpoint-identitynow-using-powershell/)

Example

```powershell
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

```powershell
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

```powershell
Remove-IdentityNowRole -roleID 2c9180886cd58059016d1a5a23f609a8
```

### Get / Update / Test / Create / Remove IdentityNow Sources ###

Get all IdentityNow Sources

[Reference post](https://blog.darrenjrobinson.com/managing-sailpoint-identitynow-sources-via-the-api-with-powershell/)

Example

```powershell
Get-IdentityNowSource
```

Get a specific IdentityNow Source

Example

```powershell
Get-IdentityNowSource -sourceID 12345
```

Get Account Profiles associated with a Source
**Note:** If there are no Account Profiles associated with the source, nothing is returned.

Example

```powershell
Get-IdentityNowSource -sourceID 12345 -accountProfiles
```

Update an IdentityNow Source
[Reference post](https://blog.darrenjrobinson.com/managing-sailpoint-identitynow-sources-via-the-api-with-powershell/)

**Note:** the format is dependant on the update to the source.
e.g Updating a simple attribute is x=value (name=new name).
Multiple updates us & to join. e.g name=new name&description=new description
Values with special characters need to be URL encoded before sending.
Updates to Sources for items such as Filters often require 'connector_' prepended. e.g

Example

```powershell
Update-IdentityNowSource -sourceID 12345 -update 'description=Attributes that drive Lifecycle and Certification Logic'
```

Update a Workday Source Response Groups to include Background Check and Account Provisioning data

Example

```powershell
$WordaySource = Get-IdentityNowSource -sourceID 12345
$RGroups = $WordaySource.Configure_Response_Group
$RGroups.Include_Background_Check_Data = "true"
$RGroups.Include_Account_Provisioning = "true"

$update = ("connector_Configure_Response_Group=$RGroups").Replace("@","")
$update = $update.Replace("true","'true'")
$update = $update.Replace("false","'false'")

Update-IdentityNowSource -sourceID 12345 -update $update 
```

Test an IdentityNow Source (Health Check)

Example

```powershell
Test-IdentityNowSourceConnection -sourceid 12345
```

Create an IdentityNow Source
Source type can be 'DIRECT_CONNECT' or 'DELIMITED_FILE'
Mandatory attributes are name, description and connectorname (e.g 'JDBC', 'Active Directory', 'Azure Active Directory', 'Web Services', 'ServiceNow')

Example

```powershell
New-IdentityNowSource -name 'Dev - JDBC - ASQL - Users Table' -description 'Azure SQL users table' -connectorname 'JDBC' -sourcetype DIRECT_CONNECT
```

Remove an IdentityNow Source

Example

```powershell
Remove-IdentityNowSource -sourceid 12345
```

### Get IdentityNow Source Schema ###

Get the Schema for an IdentityNow Source.

Example

```powershell
Get-IdentityNowSourceSchema -sourceID 12345
```

### Create IdentityNow Source Account Schema Attributes ###

Discover an IdentityNow Source Schema or add new attributes to the schema for a Source.

Discover Schema changes on a source

Example

```powershell
New-IdentityNowSourceAccountSchemaAttribute -sourceID 12345 -discover
```

Create a new string attribute on a source.

Example

```powershell
New-IdentityNowSourceAccountSchemaAttribute -sourceID 12345 -name 'myNewAttr' -description 'My new attribute' -type 'STRING' 
```

### Export IdentityNow Configuration ###

Exports IdentityNow Access Profiles, APIClients, Applications, Cert Campaigns, Email Templates, Governance Groups, Identity Attributes, Identity Profiles, OAuth API Clients, Roles, Rules, Sources, Transforms, VAClusters, to files to make comparisons or check into source control.

Example: Export all configuration items

```powershell
Export-IdentityNowConfig -path 'c:\repos\IDN-Prod'
```

Example: Export only Rules and Roles configurations

```powershell
Export-IdentityNowConfig -path 'c:\repos\IDN-Prod' -Items Rules,Roles
```

### IdentityNow Sources Configuration HTML Report ###

Generate an HTML Report of all configured IdentityNow Sources.
Outputs the configuration of each Source and the Source Schema to a local directory

[Reference post](https://blog.darrenjrobinson.com/creating-sailpoint-identitynow-source-configuration-backups-and-html-reports-with-powershell/)

Generate a Source Configuration Report to the C:\Reports directory
By default the report uses an embedded SailPoint IdentityNow Image logo.

Example

```powershell
New-IdentityNowSourceConfigReport -reportPath 'C:\Reports'
```

Generate a Source Configuration Report to the C:\Reports directory and use a custom image from C:\Images\myCompanyLogo-240px.png
Image size must be 240px x 82px or close to it.

Example

```powershell
New-IdentityNowSourceConfigReport -reportPath 'C:\Reports' -reportImagePath 'C:\Images\myCompanyLogo-240px.png'
```

### Generate IdentityNow Identity Profiles Configuration HTML Report ###

Generate an HTML Report of all configured IdentityNow Identity Profiles.
Outputs the configuration of each IdentityNow Identity Profile to a local directory

[Reference post](https://blog.darrenjrobinson.com/sailpoint-identitynow-identity-profiles-mapping-report/)

Generate an Identity Profile Configuration Report to the C:\Reports directory
By default the report uses an embedded SailPoint IdentityNow Image logo.

Example

```powershell
New-IdentityNowIdentityProfilesReport -reportPath 'C:\Reports'
```

Generate an Identity Profile Configuration Report to the C:\Reports directory and use a custom image from C:\Images\myCompanyLogo-240px.png
Recommended image size 240px x 82px

Example

```powershell
New-IdentityNowIdentityProfilesReport -reportPath 'C:\Reports' -reportImagePath 'C:\Images\myCompanyLogo-240px.png'
```

### Get Accounts from an IdentityNow Source ###

Get accounts from an IdentityNow Source
[Reference post](https://blog.darrenjrobinson.com/searching-returning-all-objects-users-from-a-sailpoint-identitynow-source/)

Example

```powershell
Get-IdentityNowSourceAccounts -sourceID 40113
```

Get Source Accounts with all their attributes. Defaults to False. Using the switch -attributes sets return all attributes to True.
**Note:** Each account is a separate API call. Large sources will take time to return all accounts with attributes.

Example

```powershell
Get-IdentityNowSourceAccounts -sourceID 40113 -attributes 
```

### Create / Update / Remove IdentityNow Source Account (Flat File / Delimited Sources) ###

Create an account on an indirect IdentityNow Source
[Reference post](https://blog.darrenjrobinson.com/authoring-identities-in-sailpoint-identitynow-via-the-api-and-powershell/)

Example

```powershell
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

```powershell
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

```powershell
$user = Search-IdentityNowUsers -query "@accounts(accountId:darrenjrobinson)"
$userIndirectAccounts = $user.accounts | select-object | where-object { ($_.source.type.contains("DelimitedFile")) }
$account = $userIndirectAccounts.id 

Remove-IdentityNowUserSourceAccount -account $account 
```

### Create / Update IdentityNow Source Entitlements (Flat File / Delimited Sources) ###

Create / Update IdentityNow Source Entitlements on Flat File Sources

**IMPORTANT: If you are looking to just update an Entitlement you must upload all Entitlements including the changed entitlement. Otherwise only the entitlements you upload will be present and any others will be removed.**

The input is PSObject of all the Entitlements for the Source.

```powershell
    $sourceEntitlements

    id           : 43367
    name         : Finance
    displayName  : Finance Data
    created      :
    description  : Access to Finance Group data
    modified     :
    entitlements : Finance
    groups       : Finance
    permissions  : Read

    ......

    id           : 45318
    name         : Marketing
    displayName  : Marketing Data
    created      :
    description  : Access to Marketing Group data
    modified     :
    entitlements : Marketing
    groups       : Marketing
    permissions  : Read
```

Example: Create / Update Entitlements on a Flat File Source

```powershell
New-IdentityNowSourceEntitlements -source 12345 -entitlements $sourceEntitlements
```

### Join IdentityNow Account ###

Join an IdentityNow User Account to an Identity

Example: Join a single account

```powershell
Join-IdentityNowAccount -source 12345 -identity jsmith -account jsmith123
```

Example: Join multiple accounts

```powershell
$joins=@()
$joins+=[pscustomobject]@{
        account = $account.nativeIdentity
        displayName = $account.nativeIdentity
        userName = $identity.name
        type = $null
    }
$joins | Join-IdentityNowAccount -org $org -source $source.id
```

### Get / Complete IdentityNow Tasks ###

Get IdentityNow Tasks
[Reference post](https://blog.darrenjrobinson.com/managing-sailpoint-identitynow-tasks-with-powershell/)

Example

```powershell
Get-IdentityNowTask
```

Get a specific IdentityNow Task
Example

```powershell
Get-IdentityNowTask -taskID 2c918084691120d0016926a6a94251d6
```

Mark and IdentityNow Task as complete
Example

```powershell
Complete-IdentityNowTask -taskID 2c918084691120d0016926a6a94251d6
```

### Get IdentityNow Virtual Appliances & Clusters ###

Get IdentityNow Virtual Appliance Clusters
[Reference post](https://blog.darrenjrobinson.com/querying-sailpoint-identitynow-virtual-appliance-clusters-with-powershell/)

Example

```powershell
Get-IdentityNowVACluster
```

Get IdentityNow Virtual Appliances from a cluster

Example

```powershell
$clusters = Get-IdentityNowVACluster
foreach($va in $clusters){
    "Cluster: $($va.description) VA ID: $($va.clients.id) VA Description: $($va.client.description)"
}
```

### Get / Update IdentityNow Applications ###

Get IdentityNow Customer Created and Managed Applications
[Reference post](https://blog.darrenjrobinson.com/managing-sailpoint-identitynow-applications-via-api-with-powershell/)

Example

```powershell
Get-IdentityNowApplication
```

Get IdentityNow Customer default configured SailPoint Applications

Example

```powershell
Get-IdentityNowApplication -org $true
```

Get a specific IdentityNow Application

Example

```powershell
Get-IdentityNowApplication -appID 32128
```

Update an IdentityNow Application

Example

```powershell
$appBody = @{ 
    "launchpadEnabled"        = $false   
    "provisionRequestEnabled" = $false
    "appCenterEnabled"        = $false
} 
Update-IdentityNowApplication -appID 24188 -update ($appBody | ConvertTo-Json) 
```

### Get IdentityNow Authentication Headers / Token ####

Get IdentityNow API Authentication Headers or v3 JWT.

Parameters: authentication header/token to return (defaults to V3JWT)

* V2Header Digest Auth
* V3Header oAuth Access Token Bearer Header
* V3JWT is oAuth JWT Token

Return default JWT

Example

```powershell
Get-IdentityNowAuth
```

Return v2 Digest Auth Header

Example

```powershell
Get-IdentityNowAuth -return V2Header
```

Return v3 oAuth Access Token Bearer Header

Example

```powershell
Get-IdentityNowAuth -return V3Header
```
### Initiate Entitlement Aggregation of an IdentityNow Source ###

Initiate Entitlement Aggregation of an IdentityNow Source.

Example

```powershell
Invoke-IdentityNowAggregateEntitlement -sourceID 12345
```

### Initiate Aggregation of an IdentityNow Source ###

Aggregate an IdentityNow Source
[Reference post](https://blog.darrenjrobinson.com/aggregating-sailpoint-identitynow-sources-via-api-with-powershell/)

Example

```powershell
Invoke-IdentityNowAggregateSource -sourceID 12345
```

Aggregate an IdentityNow Source without optimization
[Reference post](https://blog.darrenjrobinson.com/aggregating-sailpoint-identitynow-sources-via-api-with-powershell/)

Example

```powershell
Invoke-IdentityNowAggregateSource -sourceID 12345 -disableOptimization 
```

### Create / Get / Update / Remove IdentityNow Transforms ###

Get IdentityNow Transforms

Example

```powershell
Get-IdentityNowTransform
```

Get an IdentityNow Transform

Example

```powershell
Get-IdentityNowTransform -ID ToUpper
```

**OPTION:** Return transform(s) as JSON. Useful when you have transforms that don't convert to PowerShell objects due to PowerShell's inability to handle case sensitivity in JSON keys.

Examples

```powershell
Get-IdentityNowTransform -ID ToUpper -json
Get-IdentityNowTransform -json
```

Update an IdentityNow Transform

Example

```powershell
$attributes = @{value = '$firstName.$lastname@$company.com.au'}
$transform = @{type = "static"; attributes = $attributes}
Update-IdentityNowTransform -transform ($transform | convertto-json) -ID "Firstname.LastName"
```

Create an IdentityNow Transform
[SailPoint Transforms Reference](https://community.sailpoint.com/t5/IdentityNow-Wiki/Transformations-in-IdentityNow-Using-Seaspray/ta-p/72176)

Example

```powershell
$attributes = @{value = '$firstName.$lastname'}
$transform = @{type = "static"; id = "FirstName.LastName"; attributes = $attributes}
New-IdentityNowTransform -transform ($transform | convertto-json) 
```

Delete an IdentityNow Transform

Example

```powershell
Remove-IdentityNowTransform -ID "Firstname.LastName"
```

### Identity Transforms Lookup ###

Create or update a dynamic reference transform based on external data.
Set-IdentityNowTransformLookup will look to see if the transform exists. If it does it will be updated with the mappings provided. Otherwise it will be created with the mappings provided.

Example

```powershell
$mappings = @{"US"="+1";"UK"="+44";"AU"="+61"}
Set-IdentityNowTransformLookup -Name "iso3166 2char to e164 prefix" -Mappings $mappings
```

### Get IdentityNow Rules ###

Get IdentityNow Rules

Example

```powershell
Get-IdentityNowRule
```

Get an IdentityNow Rule

Example

```powershell
Get-IdentityNowRule -ID 2c9170826219ab41014275b47fc40b0a
```

### Get / Update Email Templates ###

Get Email Templates

Example

```powershell
Get-IdentityNowEmailTemplate
```

Get an Email Template

Example

```powershell
Get-IdentityNowEmailTemplate -ID 2c91601362431b32016275b4241b08f0
```

Update Email Template

Example

```powershell
$templateChanges = @{}
$templateChanges.add("id","2c91601362431b32016275b4241b08f0")
$templateChanges.add("subject",'Access Request requires completion of Work Item ID : $workItemName')

Update-IdentityNowEmailTemplate -template ($templateChanges | ConvertTo-Json)
```

### Get IdentityNow Personal Access Token(s) ###

List IdentityNow Personal Access Token(s).

Example

```powershell
Get-IdentityNowPersonalAccessToken
```

Limit number of Personal Access Tokens to return

Example

```powershell
Get-IdentityNowPersonalAccessToken -limit 10
```

### Create an IdentityNow Personal Access Token(s) ###

Create an IdentityNow Personal Access Token.

Example

```powershell
New-IdentityNowPersonalAccessToken -name "Sean's Sailpoint IdentityNow module"
```

*Optional:* If a personal access token needs to be made for an account not saved in this module you can pull the access token from <https://{org}.identitynow.com/ui/session?refresh=true> after pulling up the admin section
[See Compass article:]( https://community.sailpoint.com/t5/IdentityNow-Wiki/IdentityNow-REST-API-Create-Personal-Access-Token/ta-p/150462 )

Example

```powershell
New-IdentityNowPersonalAccessToken -name "Sean's Sailpoint IdentityNow module" -accessToken baa2c01cb5674636b8c0f063f3f13db3
```

### Remove an IdentityNow Personal Access Token ###

Delete an IdentityNow Personal Access Token

Example

```powershell
Remove-IdentityNowPersonalAccessToken -id 36480043060f4562af28123456
```

### Get IdentityNow Identity Profiles ###

Get IdentityNow Identity Profiles

Example

```powershell
Get-IdentityNowProfile
```

Get an IdentityNow Profile

Example

```powershell
Get-IdentityNowProfile -ID 1033
```

### Create an IdentityNow Identity Profile ###

Create an IdentityNow Identity Profile. Requires the name for the Identity Profile and the ID of the IdentityNow Source to associated with the IdentityNow Profile

Example

```powershell
New-IdentityNowProfile -Name Contractors -SourceID 116329
```

### Refresh an IdentityNow Identity Profile ###

Trigger a user refresh for an IdentityNow Identity Profile.

Example

```powershell
Start-IdentityNowProfileUserRefresh -ID 116329
```

### Remove IdentityNow Identity Profile(s) ###

Remove a single or multiple IdentityNow Identity Profiles.

Example -  Remove a single IdentityNow Identity Profile

```powershell
Remove-IdentityNowProfile -profileIDs 1234
```

Example - Remove multiple IdentityNow Profiles

```powershell
Remove-IdentityNowProfile -profileIDs 1234,1235,1236
```

### Get / Update IdentityNow Identity Profiles Order ###

Get IdentityNow Identity Profiles Order

Example

```powershell
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

Update IdentityNow Identity Profile Order

Example

```powershell
Update-IdentityNowProfileOrder -id 1285 -priority 20
```

### Get / Update Identity Attributes ###

List Identity Attributes that can be used for correlation rules from Sources.
[Reference Post](Get-IdentityNowIdentityAttribute )

List all Identity Attributes that are configured

Example

```powershell
Get-IdentityNowIdentityAttribute 
```

Get a specific Identity Attribute.

Example

```powershell
Get-IdentityNowIdentityAttribute -attribute firstname
```

Add an attribute into the Identity Attributes List that can be used in Correlation Rules
This makes the attribute searchable and available for correlation rules.
This requires the attribute has first been added to an Identity Profile (under Mapping => Add Attribute)
**NOTE:** the attribute name is case sensitive. It must match what is in IdentityNow.  

Example

```powershell
Update-IdentityNowIdentityAttribute -attribute adsid
```

### Get Identity Attribute Preview ###

Get an IdentityNow Identity Attribute Mapping Preview. See the before and after attribute values on a person object for a single attribute.

-IDP Identity Profile; (Required) the name or ID of the Identity Profile

Get a preview of changes for user darren.robinson and the 'country' attribute using the Employees Identity Profile.

Example

```powershell
Get-IdentityNowIdentityAttributePreview -IDP "Employees" -attribute country -uid darren.robinson
```

Get a preview of the differences for user darren.robinson and the 'c' and 'division' attributes using the Employees Identity Profile.

Example

```powershell
Get-IdentityNowIdentityAttributePreview -uid darren.robinson -IDP "Employees" -attributes @('division','c') -differencesOnly
```

### Create / Get / Remove API Management Clients (Legacy v2) ###

Get all v2 API Clients (listed as Legacy in the IdentityNow portal under API Management )

Example

```powershell
Get-IdentityNowAPIClient
```

Get a single v2 API Client

Example

```powershell
Get-IdentityNowAPIClient -ID 123
```

Create a v2 API Client for VA Cluster 123

Example

```powershell
New-IdentityNowAPIClient -clusterId 123
```

Remove a v2 API Client

Example

```powershell
Remove-IdentityNowAPIClient -ID 123
```

### Create / Get / Remove oAuth API Clients ###

Get oAuth API (v3) Clients

Example

```powershell
Get-IdentityNowOAuthAPIClient 
```

Get an oAuth API (v3) Client

Example

```powershell
Get-IdentityNowOAuthAPIClient -ID '8432e57d-5f8f-dead-beef-a7bf123456a1'
```

Create an oAuth API Client (v3)

Example

```powershell
New-IdentityNowOAuthAPIClient -description 'oAuth Client' -grantTypes 'AUTHORIZATION_CODE,CLIENT_CREDENTIALS,REFRESH_TOKEN,PASSWORD' -redirectUris 'https://localhost,https://myapp.com.au'
```

Remove an oAuth API Client (v3)

Example

```powershell
Remove-IdentityNowOAuthAPIClient -ID '9e23deaf-48aa-dead-beef-ab6821a12ab2'
```

### Search Events - Elasticsearch ###

Search IdentityNow Events using the new IdentityNow Search (Elasticsearch)
Results defaults to 2500. If you want more or less use the -searchLimit option
[Search Event Names](https://community.sailpoint.com/t5/IdentityNow-Forum/Audit-Events-and-Search-Equivalents/m-p/148204#feedback-success)

Example

```powershell
$query = @{query = 'technicalName:USER_AUTHENTICATION_STEP_UP_SETUP_*'; type = 'USER_MANAGEMENT'}
$queryFilter = @{query = $query}
Search-IdentityNowEvents -filter ($queryFilter | convertto-json)
```

Use -searchLimit option to return more (or less) than 2500 results.

Example

```powershell
$query = @{query = 'technicalName:USER_AUTHENTICATION_*'; type = 'USER_MANAGEMENT'}
$queryFilter = @{query = $query}
Search-IdentityNowEvents -filter ($queryFilter | convertto-json) -searchLimit 5500
```

### List Account Activities ###

Get Account Activities by Type, Requested By and Requested For,

Get Account Activities by Type

Example

```powershell
Get-IdentityNowAccountActivities -type appRequest -searchLimit 1000
```

Get Account Activities request for an Identity

Example

```powershell
$user = Search-IdentityNowUsers -query "@accounts(accountId:darren.robinson)"    
Get-IdentityNowAccountActivities -requestedFor $user.id
```

Get Account Activities requested for an Identity by a specific Identity

Example

```powershell
$user = Search-IdentityNowUsers -query "@accounts(accountId:darren.robinson)"
$mgr = Search-IdentityNowUsers -query "@accounts(accountId:rick.sanchez)"
Get-IdentityNowAccountActivities -requestedFor $user.id -requestedBy $mgr.id 
```

### Get Account Activity ###

Get an Account Activity item.

Incomplete AppRequests submitted today

Example

```powershell
$appRequestsIncompleteToday = $today | Where-Object { $_.type -eq 'appRequest' -and $_.completionStatus -eq 'INCOMPLETE' -and $_.created -like "*2019-02-25*" } | Select-Object id 
$appRequestsIncompleteToday | ForEach-Object $_.id | Get-IdentityNowAccountActivity
```

### Reset an IdentityNow Source ###

Clear IdentityNow of data loaded from a source. Delete the specified source data from a source, while keeping all the configuration intact.

Example

```powershell
Invoke-IdentityNowSourceReset -sourceID 12345
```

Don't reset Accounts or Entitlements using the -skip option

Don't reset Entitlements
Example

```powershell
Invoke-IdentityNowSourceReset -sourceID 12345 -skip Entitlements
```

Don't reset Accounts
Example

```powershell
Invoke-IdentityNowSourceReset -sourceID 12345 -skip Accounts
```

### ... and the ultimate flexible cmdlet Invoke-IdentityNowRequest ###

The cmdlet that lets you do your thing, with a little help.
This cmdlet has options for v2 and v3 authentication and will provide the web request headers (with and without content-type = application/json / application/json-patch+json set).

(URI) You supply the URI for the request, the method (POST, GET, DELETE, PATCH) and the request will be sent, and the results sent back.
or
(API Version and Path) You supply the API version and the path for the API request along with the method (POST, GET, DELETE, PATCH) and the request will be sent, and the results sent back.

* *Hint* Get-IdentityNowOrg will show you the API Version to Path mappings

```powershell
Get-IdentityNowOrg  

Name                           Value                                                                                                                                     
----                           -----                                                                                                                                     
Organisation Name              customer-sb
Organisation URI               https://customer-sb.identitynow.com
v1 Base API URI                https://customer-sb.identitynow.com/api
v2 Base API URI                https://customer-sb.api.identitynow.com/v2
v3 Base API URI                https://customer-sb.api.identitynow.com/v3
Private Base API URI           https://customer-sb.api.identitynow.com/cc/api
Beta                           https://customer-sb.api.identitynow.com/beta
```

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
* Headersv3_JSON-Patch - Headersv3_JSON is JWT oAuth with Content-Type set for application/json-patch+json

**OPTION:** -json switch to return request result as JSON.

Example 1 - URI

Get the Schema of a Source
[Reference post](https://blog.darrenjrobinson.com/creating-sailpoint-identitynow-source-configuration-backups-and-html-reports-with-powershell/)

```powershell
$orgName = "customer-sb"
$sourceID = "12345"
Invoke-IdentityNowRequest -Method Get -Uri "https://$($orgName).api.identitynow.com/cc/api/source/getAccountSchema/$($sourceID)" -headers HeadersV3                
```

Example 1 - API & Path

```powershell
$sourceID = "12345"
Invoke-IdentityNowRequest -API Private -path "source/getAccountSchema/$($sourceID)" -method Get -headers Headersv3               
```

Example 2 - URI

List Identity Profiles
[Reference post](https://blog.darrenjrobinson.com/changing-sailpoint-identitynow-identity-profiles-priorities-using-powershell/)

```powershell
$orgName = "customer-sb"
Invoke-IdentityNowRequest -Method Get -Uri "https://$($orgName).identitynow.com/api/profile/list" -headers Headersv2_JSON 
```

Example 2 - API & Path

```powershell
Invoke-IdentityNowRequest -API V1 -Method Get -path "profile/list" -headers Headersv2_JSON  
```

Example 3 - URI

Get IdentityNow Identity Attributes
[Reference post](https://blog.darrenjrobinson.com/indexing-a-sailpoint-identitynow-attribute-in-an-identity-cube-for-use-in-correlation-rules/)

```powershell
$orgName = "customer-sb"
Invoke-IdentityNowRequest -Method Get -Uri "https://$($orgName).api.identitynow.com/cc/api/identityAttribute/list" -headers HeadersV3 
```

Example 3 - API & Path

```powershell
Invoke-IdentityNowRequest -API Private -path "identityAttribute/list" -method Get -headers HeadersV3
```

## Disclaimer - Fine Print ##

I am not a SailPoint employee. I wrote this for our needs and am sharing it with the community.

**** Please use with caution. These cmdlets come with full functionality. Use this power responsibly AND AT YOUR OWN RISK.****

## How can I contribute to the project? ##

* Found an issue and want us to fix it? [Log it](https://github.com/darrenjrobinson/powershell_module_identitynow/issues)
* Want to fix an issue yourself or add functionality? Clone the project and submit a pull request.
* Any and all contributions are more than welcome and appreciated.

## More information on managing SailPoint IdentityNow via API ##

I've written extensive posts on many of these functions. Details are in this section [on my blog](https://blog.darrenjrobinson.com/sailpoint-identitynow/)

## Keep up to date ##

* [Visit my blog](https://blog.darrenjrobinson.com)
* [Follow darrenjrobinson on Twitter](https://twitter.com/darrenjrobinson)![](http://twitter.com/favicon.ico)
