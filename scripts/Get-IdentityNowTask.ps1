function Get-IdentityNowTask {
    <#
.SYNOPSIS
Get an IdentityNow Task(s).

.DESCRIPTION
Get an IdentityNow Task(s).

.PARAMETER taskID
(optional) The ID of an IdentityNow task.

.EXAMPLE
Get-IdentityNowTask 

.EXAMPLE
Get-IdentityNowTask -taskID 2c918084691120d0016926a6a94251d6

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
            if ($taskID) {
                $Task = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/task/get/$($taskID)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }                                                                                     
                return $Task
            }
            else {
                $tasksList = Invoke-RestMethod -method Get -uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/task/listAll" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
                return $tasksList.items
            }
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

