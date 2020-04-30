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

    # IdentityNow Admin User
    $adminUSR = [string]$IdentityNowConfiguration.AdminCredential.UserName.ToLower()
    $adminPWDClear = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($IdentityNowConfiguration.AdminCredential.Password))

    # Generate the account hash
    $hashUser = Get-HashString $adminUSR.ToLower() 
    $adminPWD = Get-HashString "$($adminPWDClear)$($hashUser)"  

    $clientSecretv3 = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($IdentityNowConfiguration.v3.Password))
    # Basic Auth
    $Bytesv3 = [System.Text.Encoding]::utf8.GetBytes("$($IdentityNowConfiguration.v3.UserName):$($clientSecretv3)")
    $encodedAuthv3 = [Convert]::ToBase64String($Bytesv3)
    $Headersv3 = @{Authorization = "Basic $($encodedAuthv3)" }

    # Get v3 oAuth Token
    # oAuth URI
    $oAuthURI = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/oauth/token"
    $oAuthTokenBody = @{
        grant_type = "password"
        username = $adminUSR
        password = $adminPWD
    }
    $v3Token = Invoke-RestMethod -Uri $oAuthURI -Method Post -Body $oAuthTokenBody -Headers $Headersv3 
    
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

