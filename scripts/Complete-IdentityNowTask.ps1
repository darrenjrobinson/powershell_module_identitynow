function Complete-IdentityNowTask {
    <#
.SYNOPSIS
Complete an IdentityNow Task.

.DESCRIPTION
Complete an IdentityNow Task.

.PARAMETER taskID
(required) The ID of IdentityNow task to mark as complete.

.EXAMPLE
Complete-IdentityNowTask -taskID 2c918084691120d0016926a6a94251d6

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$taskID
    )

    $v3Token = Get-IdentityNowAuth

    if ($v3Token.access_token) {
        try {
            $Task = Invoke-RestMethod -Method Post -Uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/task/complete/$($taskID)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }                                                                                     
            return $Task
        }
        catch {
            Write-Error "Task doesn't exist. Check Task ID. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

