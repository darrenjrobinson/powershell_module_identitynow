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

    # IdentityNow Admin User
    $adminUSR = [string]$IdentityNowConfiguration.AdminCredential.UserName.ToLower()
    $adminPWDClear = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($IdentityNowConfiguration.AdminCredential.Password))

    # Generate the password hash
    # Requires Get-Hash from PowerShell Community Extensions (PSCX) Module 
    # https://www.powershellgallery.com/packages/Pscx/3.2.2
    $passwordHash = Get-Hash -Algorithm SHA256 -StringEncoding utf8 -InputObject ($($adminPWDClear) + (Get-Hash -Algorithm SHA256 -StringEncoding utf8 -InputObject ($adminUSR)).HashString.ToLower())
    $adminPWD = $passwordHash.ToString().ToLower() 

    # Qantas-SB   
    $clientSecretv3 = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($IdentityNowConfiguration.v3.Password))
    # Basic Auth
    $Bytesv3 = [System.Text.Encoding]::utf8.GetBytes("$($IdentityNowConfiguration.v3.UserName):$($clientSecretv3)")
    $encodedAuthv3 = [Convert]::ToBase64String($Bytesv3)
    $Headersv3 = @{Authorization = "Basic $($encodedAuthv3)" }

    # Get v3 oAuth Token
    # oAuth URI
    $oAuthURI = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/oauth/token"
    $v3Token = Invoke-RestMethod -Method Post -Uri "$($oAuthURI)?grant_type=password&username=$($adminUSR)&password=$($adminPWD)" -Headers $Headersv3 -SessionVariable IDNv3

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

