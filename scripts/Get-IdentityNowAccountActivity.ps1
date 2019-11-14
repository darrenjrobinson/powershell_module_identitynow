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

    # IdentityNow Admin User
    $adminUSR = [string]$IdentityNowConfiguration.AdminCredential.UserName.ToLower()
    $adminPWDClear = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($IdentityNowConfiguration.AdminCredential.Password))
    # Generate the password hash
    # Requires Get-Hash from PowerShell Community Extensions (PSCX) Module 
    # https://www.powershellgallery.com/packages/Pscx/3.2.2
    $passwordHash = Get-Hash -Algorithm SHA256 -StringEncoding utf8 -InputObject ($($adminPWDClear) + (Get-Hash -Algorithm SHA256 -StringEncoding utf8 -InputObject ($adminUSR)).HashString.ToLower())
    $adminPWD = $passwordHash.ToString().ToLower() 
    $clientSecretv3 = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($IdentityNowConfiguration.v3.Password))
    # Basic Auth
    $Bytesv3 = [System.Text.Encoding]::utf8.GetBytes("$($IdentityNowConfiguration.v3.UserName):$($clientSecretv3)")
    $encodedAuthv3 = [Convert]::ToBase64String($Bytesv3)
    $Headersv3 = @{Authorization = "Basic $($encodedAuthv3)" }

    # Get v3 oAuth Token
    # oAuth URI
    $oAuthURI = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/oauth/token"
    $v3Token = Invoke-RestMethod -Method Post -Uri "$($oAuthURI)?grant_type=password&username=$($adminUSR)&password=$($adminPWD)" -Headers $Headersv3 
    
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
