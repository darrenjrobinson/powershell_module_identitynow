function Search-IdentityNowAuditEvents {
    <#
.SYNOPSIS
    Search IdentityNow Audit Event(s) using the v2 API.

.DESCRIPTION
    Search IdentityNow Audit Event(s) using the v2 API

.PARAMETER action
    (optional) Audit Action Event 
    AddEntitlement,AddEntitlementFailure,APP_LAUNCH_SAML,APP_ADD,APP_CREATE,APP_DELETE,APP_EXPORT,APP_IMPORT,APP_REMOVE,APP_UPDATE,AUTHENTICATION-103,AUTHENTICATION-201,AUTHENTICATION-240,AUTHENTICATION-241,AUTHENTICATION-243,AUTHENTICATION-245,AUTHENTICATION-247,AUTHENTICATION-303,CREATE_ACCESS_PROFILE,CreateAccount,CreateAccountFailure,DELETE_ACCESS_PROFILE,DisableAccount,DisableAccountFailure,EnableAccount,EnableAccountFailure,IDENTITY_PROFILE_CREATE,IDENTITY_PROFILE_DELETE,IDENTITY_PROFILE_REFRESH,IDENTITY_PROFILE_UPDATE,IdentityStateChange,ModifyAccount,ModifyAccountFailure,RequestApp,RequestAppFailure,SAML_FORCE_AUTHN,SAML2-36,SAML2-37,SAML2-149,SAML2-156,SESSION-1,SESSION-2,SESSION-3,SESSION-4,SESSION-6,SOURCE_ACCOUNTS_EXPORT,SOURCE_ACTIVITY_EXPORT,SOURCE_EXTERNAL_PASSWORD_CHANGE,SOURCE_EXTERNAL_PASSWORD_CHANGE_ACTIVITY_EXPORT,SOURCE_RESET,USER_ACTIVATE,USER_ACTIVITY_EXPORT,USER_KBA_ANSWER_UPDATE,USER_PASSWORD_UPDATE,USER_STEP_UP_AUTH

.PARAMETER type
    (optional) type (the audit category. Valid values are “AUTH”, “SSO”, “PROVISIONING”, “PASSWORD_CHANGE” or “SOURCE” Ex: type=AUTH)

.PARAMETER user
    (optional) Case insensitive exact match of the UID of an identity contained in either “source” or “target” properties in the logs where source indicates the person who took the action and target indicates the person who was affected by the action. Ex: user=guybrush.threepwood

.PARAMETER application
    (optional) Case insensitive name of the source you're querying for

.PARAMETER days
    (optional) days (Only return results whose timestamp is within this previous number of days; defaults to 7.)

.PARAMETER since
    (optional) since (Returns only results from days since the entered date, or date and time combination, in ISO-8601 format.)
    e.g yyyy-mm-ddThh:mm:ss

.PARAMETER searchLimit
    (optional - default 2500) Max results to return

.EXAMPLE
    Search-Search-IdentityNowAuditEvents 

.EXAMPLE
    Search-Search-IdentityNowAuditEvents -action USER_STEP_UP_AUTH

.EXAMPLE
    Search-IdentityNowAuditEvents -since '2019-09-30T12:30:50.450Z'
    Search-IdentityNowAuditEvents -since '2019-09-30T12:30:50.450Z' -searchLimit 10  
    Search-IdentityNowAuditEvents -since '2019-09-30T12:30:50.450Z' -searchLimit 2501 

.EXAMPLE
    Search-IdentityNowAuditEvents -days 1 
    Search-IdentityNowAuditEvents -days 1 -searchLimit 5000 
    Search-IdentityNowAuditEvents -days 1 -action 'AUTHENTICATION-103'

.EXAMPLE
    Search-IdentityNowAuditEvents -type AUTH
    Search-IdentityNowAuditEvents -type AUTH -days 1 
    Search-IdentityNowAuditEvents -type AUTH -days 1 -searchLimit 5000
    Search-IdentityNowAuditEvents -type AUTH -days 1 -action 'AUTHENTICATION-103'

.EXAMPLE
    Search-IdentityNowAuditEvents -user 'customer_admin'
    Search-IdentityNowAuditEvents -user 'customer_admin' -searchLimit 10
    Search-IdentityNowAuditEvents -user 'customer_admin' -since '2019-10-30T12:30:50.450Z'
    Search-IdentityNowAuditEvents -user 'customer_admin' -days 1 
    Search-IdentityNowAuditEvents -user 'customer_admin' -days 1 -searchLimit 2510
    Search-IdentityNowAuditEvents -user 'customer_admin' -action 'AUTHENTICATION-103'
    Search-IdentityNowAuditEvents -user 'customer_admin' -type 'AUTH'
    Search-IdentityNowAuditEvents -user 'customer_admin' -days 1 -action 'AUTHENTICATION-103'
    Search-IdentityNowAuditEvents -user 'customer_admin' -days 1 -type 'AUTH'
    Search-IdentityNowAuditEvents -user 'customer_admin' -days 1 -type 'AUTH' -action 'AUTHENTICATION-103' 
    Search-IdentityNowAuditEvents -user 'customer_admin' -days 1 -type 'AUTH' -action 'AUTHENTICATION-103' -searchLimit 50
    Search-IdentityNowAuditEvents -user 'customer_admin' -since '2019-10-30T12:30:50.450Z' -action 'AUTHENTICATION-103' 
    Search-IdentityNowAuditEvents -user 'customer_admin' -since '2019-10-30T12:30:50.450Z'  -type 'AUTH' -action 'AUTHENTICATION-103' 

.EXAMPLE
    Search-IdentityNowAuditEvents -application 'Workday (Dev)'
    Search-IdentityNowAuditEvents -application 'Workday (Dev)' -days 2
    Search-IdentityNowAuditEvents -application 'Workday (Dev)' -action 'SOURCE_ACCOUNT_AGGREGATION'
    Search-IdentityNowAuditEvents -application 'Workday (Dev)' -action 'SOURCE_ACCOUNT_AGGREGATION' -days 2
    Search-IdentityNowAuditEvents -application 'Workday (Dev)' -type 'PROVISIONING'

.EXAMPLE
    Search-IdentityNowAuditEvents -application 'Workday (Dev)' -since '2019-10-30T12:30:50.450Z'
    Search-IdentityNowAuditEvents -application 'Workday (Dev)' -since '2019-10-30T12:30:50.450Z' -action 'SOURCE_ACCOUNT_AGGREGATION'
    Search-IdentityNowAuditEvents -application 'Workday (Dev)' -since '2019-10-30T12:30:50.450Z' -action 'SOURCE_ACCOUNT_AGGREGATION' -type 'PROVISIONING'

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [ValidateSet("AddEntitlement", "AddEntitlementFailure", "APP_LAUNCH_SAML", "APP_ADD", "APP_CREATE", "APP_DELETE,APP_EXPORT", "APP_IMPORT", "APP_PURGED", "APP_REMOVE", "APP_UPDATE", "AUTHENTICATION-103", "AUTHENTICATION-201", "AUTHENTICATION-240", "AUTHENTICATION-241", "AUTHENTICATION-243", "AUTHENTICATION-245", "AUTHENTICATION-247", "AUTHENTICATION-303", "CampaignFilterCreate", "certificationsPhased", "CLIENT_MANUAL_VA_JOB", "CLIENT_REQUEST_CREDENTIALS", "CLIENT_TOKEN_ISSUE", "CREATE_ACCESS_PROFILE", "create", "CreateAccount", "CreateAccountFailure", "delete", "DELETE_ACCESS_PROFILE", "DisableAccount", "DisableAccountFailure", "emailSent", "EnableAccount", "EnableAccountFailure", "IDENTITY_PROFILE_CREATE", "IDENTITY_PROFILE_DELETE", "IDENTITY_PROFILE_REFRESH", "IDENTITY_PROFILE_UPDATE", "IdentityStateChange", "ModifyAccount", "ModifyAccountFailure", "PasswordChange", "PasswordChangeSuccess", "reassign", "remediate", "RemoveEntitlement", "RequestApp", "RequestAppFailure", "SAML_FORCE_AUTHN", "SAML2-36", "SAML2-37", "SAML2-149", "SAML2-156", "SESSION-1", "SESSION-2", "SESSION-3", "SESSION-4", "SESSION-6", "SetEntitlement", "signoff", "SOURCE_ACCOUNT_AGGREGATION", "SOURCE_ACCOUNTS_EXPORT", "SOURCE_ENTITLEMENT_AGGREGATION", "SOURCE_ACCOUNTS_EXPORT,SOURCE_ACTIVITY_EXPORT", "SOURCE_EXTERNAL_PASSWORD_CHANGE", "SOURCE_EXTERNAL_PASSWORD_CHANGE_ACTIVITY_EXPORT", "SOURCE_RESET", "SOURCE_UPDATE", "taskResultsPruned", "update", "USER_ACTIVATE", "USER_ACTIVITY_EXPORT", "USER_CERT_ADMIN_GRANT", "USER_DELETE", "USER_HELPDESK_GRANT", "USER_INVITE", "USER_KBA_ANSWERS", "USER_KBA_ANSWER_UPDATE", "USER_PASSWORD_UPDATE", "USER_PASSWORD_UPDATE_PASSED", "USER_REGISTRATION", "USER_REGISTRATION_LINK", "USER_STEP_UP_AUTH", "USER_STEP_UP_AUTH_FAILURE")]
        [string]$action,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [ValidateSet("AUTH", "SSO", "PROVISIONING", "PASSWORD_CHANGE", "SOURCE")]
        [string]$type,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$user,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$application,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [ValidateRange(1,365)]
        [int]$days,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$since,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [int]$searchLimit = 2500
    )

    $Headersv2 = Get-IdentityNowAuth -Return V2Header
    $Headersv2."Content-Type" = "application/json" 
        
    try {
        $sourceObjects = @()   
        if ($searchLimit -gt 2500) {
            $iterations = $searchLimit / 2500
            $offset = 2500
        }
        
        if ($searchLimit -gt 2500) { $limit = 2500 } else { $limit = $searchLimit }
        switch ($action, $type, $user, $days, $since) {            
            { $since } {                 
                $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/audit/auditEvents?limit=$($limit)&since=$($since)" 
            }
            { $since -and $action } { 
                $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/audit/auditEvents?limit=$($limit)&since=$($since)&actn=$($action)" 
            }
            { $days } {
                $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/audit/auditEvents?limit=$($limit)&days=$($days)" 
            }
            { $days -and $action} {
                $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/audit/auditEvents?limit=$($limit)&days=$($days)&actn=$($action)" 
            }
            { $type } {
                $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/audit/auditEvents?limit=$($limit)&type=$($type)" 
            }
            { $type -and $days} {
                $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/audit/auditEvents?limit=$($limit)&type=$($type)&days=$($days)" 
            }
            { $type -and $since} {
                $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/audit/auditEvents?limit=$($limit)&type=$($type)&since=$($since)" 
            }
            { $type -and $days -and $action} {
                $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/audit/auditEvents?limit=$($limit)&type=$($type)&days=$($days)&actn=$($action)" 
            }
            { $type -and $since -and $action} {
                $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/audit/auditEvents?limit=$($limit)&type=$($type)&since=$($since)&actn=$($action)" 
            }
            { $user } {
                $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/audit/auditEvents?limit=$($limit)&user=$($user)" 
            }
            { $user -and $since } {
                $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/audit/auditEvents?limit=$($limit)&user=$($user)&since=$($since)" 
            }
            { $user -and $days } {
                $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/audit/auditEvents?limit=$($limit)&user=$($user)&days=$($days)" 
            }
            { $user -and $action } {
                $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/audit/auditEvents?limit=$($limit)&user=$($user)&actn=$($action)" 
            }
            { $user -and $type } {
                $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/audit/auditEvents?limit=$($limit)&user=$($user)&type=$($type)" 
            }
            { $user -and $days -and $action}{
                $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/audit/auditEvents?limit=$($limit)&user=$($user)&days=$($days)&actn=$($action)" 
            }
            { $user -and $days -and $type}{
                $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/audit/auditEvents?limit=$($limit)&user=$($user)&days=$($days)&type=$($type)" 
            }
            { $user -and $days -and $type -and $action}{
                $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/audit/auditEvents?limit=$($limit)&user=$($user)&days=$($days)&type=$($type)&actn=$($action)" 
            }
            { $user -and $since -and $action}{
                $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/audit/auditEvents?limit=$($limit)&user=$($user)&since=$($since)&actn=$($action)" 
            }
            { $user -and $since -and $type}{
                $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/audit/auditEvents?limit=$($limit)&user=$($user)&since=$($since)&type=$($type)" 
            }
            { $user -and $since -and $type -and $action}{
                $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/audit/auditEvents?limit=$($limit)&user=$($user)&since=$($since)&type=$($type)&actn=$($action)" 
            }
            { $application } {
                Add-Type -AssemblyName System.Web
                $applicationEncoded = [System.Web.HttpUtility]::UrlEncode($application)                
                $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/audit/auditEvents?limit=$($limit)&application=$($applicationEncoded)" 
            }
            { $application -and $days } {
                Add-Type -AssemblyName System.Web
                $applicationEncoded = [System.Web.HttpUtility]::UrlEncode($application)                
                $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/audit/auditEvents?limit=$($limit)&application=$($applicationEncoded)&days=$($days)" 
            }
            { $application -and $action } {
                Add-Type -AssemblyName System.Web
                $applicationEncoded = [System.Web.HttpUtility]::UrlEncode($application)                
                $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/audit/auditEvents?limit=$($limit)&application=$($applicationEncoded)&actn=$($action)" 
            }
            { $application -and $type } {
                Add-Type -AssemblyName System.Web
                $applicationEncoded = [System.Web.HttpUtility]::UrlEncode($application)                
                $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/audit/auditEvents?limit=$($limit)&application=$($applicationEncoded)&type=$($type)" 
            }
            { $application -and $days -and $action} {
                Add-Type -AssemblyName System.Web
                $applicationEncoded = [System.Web.HttpUtility]::UrlEncode($application)                
                $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/audit/auditEvents?limit=$($limit)&application=$($applicationEncoded)&days=$($days)&actn=$($action)" 
            }
            { $application -and $days -and $action -and $type} {
                Add-Type -AssemblyName System.Web
                $applicationEncoded = [System.Web.HttpUtility]::UrlEncode($application)                
                $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/audit/auditEvents?limit=$($limit)&application=$($applicationEncoded)&days=$($days)&actn=$($action)&type=$($type)" 
            }
            { $application -and $since } {
                Add-Type -AssemblyName System.Web
                $applicationEncoded = [System.Web.HttpUtility]::UrlEncode($application)                
                $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/audit/auditEvents?limit=$($limit)&application=$($application)&since=$($since)" 
            }
            { $application -and $since -and $action} {
                Add-Type -AssemblyName System.Web
                $applicationEncoded = [System.Web.HttpUtility]::UrlEncode($application)                
                $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/audit/auditEvents?limit=$($limit)&application=$($applicationEncoded)&since=$($since)&actn=$($action)" 
            }
            { $application -and $since -and $action -and $type} {
                Add-Type -AssemblyName System.Web
                $applicationEncoded = [System.Web.HttpUtility]::UrlEncode($application)                
                $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/audit/auditEvents?limit=$($limit)&application=$($applicationEncoded)&since=$($since)&actn=$($action)&type=$($type)" 
            }
            Default {$searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/audit/auditEvents?limit=$($limit)" }
        }

        $loop = 0
        if ($iterations -gt 1) {
            # Get First
            $results = Invoke-RestMethod -Method Get -Uri $searchURLBase -Headers $Headersv2                                        
            $loop++

            if ($results) {
                $sourceObjects += $results
            }

            # Get Rest 
            do {
                if (($searchLimit - $offset) -gt 2500) {  
                    $results = Invoke-RestMethod -Method Get -Uri "$($searchURLBase)&start=$($offset)" -Headers $Headersv2
                    $loop++
                    $offset += $results.items.count 
                    if ($results) {
                        $sourceObjects += $results
                    }
                    else {
                        break 
                    }
                }
                else {
                    $limitCount = ($searchLimit - $sourceObjects.items.count)
                    $searchURL = $searchURLBase.Replace("limit=2500", "limit=$($limitCount)")
                    $results = Invoke-RestMethod -Method Get -Uri "$($searchURL)&start=$($offset)" -Headers $Headersv2
                    if ($results) {
                        $sourceObjects += $results
                    }
                    else {
                        break 
                    }
                    $loop++
                }
            } until (($loop -gt $iterations))
        }
        else {
            # Get full set (<2500)
            $results = Invoke-RestMethod -Method Get -Uri $searchURLBase -Headers $Headersv2                                        
            $loop++

            if ($results) {
                $sourceObjects += $results
            }
        }
        return $sourceObjects.items 
    }
    catch {
        Write-Error "Audit Event(s) not found? Check search criteria. $($_)" 
    }
}
