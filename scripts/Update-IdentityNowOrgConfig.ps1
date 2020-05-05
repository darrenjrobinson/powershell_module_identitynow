function Update-IdentityNowOrgConfig {
    <#
.SYNOPSIS
    Update IdentityNow Org Global Reminders and Escalation Policies Configuration.

.DESCRIPTION
    Update IdentityNow Org Global Reminders and Escalation Policies Configuration

.PARAMETER update
    (required - JSON) Configuration settings to update

.EXAMPLE
    Update-IdentityNowOrgConfig -update "{"approvalConfig":  {"daysBetweenReminders":  2,"daysTillEscalation":  7,"fallbackApprover":  "darrenjrobinson","maxReminders":  12}}"

.EXAMPLE
    $orgConfig = Get-IdentityNowOrgConfig
    $approvalConfig = $orgConfig.approvalConfig
    # global reminders and escalation policies for access request approvals
    $daysBetweenReminders = 2
    $daysTillEscalation = 7
    $maxReminders = 12
    # SailPoint user name of the identity 
    $fallbackApprover = "darrenjrobinson"

    # Set Config options to update
    $approvalConfig.daysBetweenReminders = $daysBetweenReminders
    $approvalConfig.daysTillEscalation = $daysTillEscalation
    $approvalConfig.maxReminders = $maxReminders
    $approvalConfig.fallbackApprover = $fallbackApprover
    $approvalConfigBody = @{"approvalConfig" = $approvalConfig}

    Update-IdentityNowOrgConfig -update ($approvalConfigBody | Convertto-json)

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$update
    )

    $v3Token = Get-IdentityNowAuth

    if ($v3Token.access_token) {
        try {
            $IDNOrgConfig = Invoke-RestMethod -Method Patch -Uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/v2/org" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "Content-Type" = "application/json"  } -body $update
            return $IDNOrgConfig
        }
        catch {
            Write-Error "$($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

