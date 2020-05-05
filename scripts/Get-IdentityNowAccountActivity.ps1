function Get-IdentityNowAccountActivity {
    <#
.SYNOPSIS
    Get IdentityNow Activity for an account.

.DESCRIPTION
    Get IdentityNow Activity for an account.

.PARAMETER id
    (required)
    ID of the Activity to retrieve    
    See https://community.sailpoint.com/t5/Admin-Help/How-do-I-use-Search-in-IdentityNow/ta-p/76960#toc-hId--14014548

.EXAMPLE
    #Incomplete AppRequests submitted today
    $appRequestsIncompleteToday = $today | Where-Object { $_.type -eq 'appRequest' -and $_.completionStatus -eq 'INCOMPLETE' -and $_.created -like "*2019-02-25*" } | Select-Object id 
    $appRequestsIncompleteToday | ForEach-Object $_.id | Get-IdentityNowAccountActivity 

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$id
    )

    $v3Token = Get-IdentityNowAuth
    
    if ($v3Token.access_token) {        
        try {   
            $accountActivites = Invoke-RestMethod -Method Get -URI "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities/$($id)" -Headers @{Authorization = "Bearer $($v3Token.access_token)"; "Content-Type" = "application/json" }
            return $accountActivites
        }
        catch {
            Write-Error "Activities with ID $($id) not found? Check your ID. $($_)" 
        }
    }
}
