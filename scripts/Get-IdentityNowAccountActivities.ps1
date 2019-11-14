function Get-IdentityNowAccountActivities {
    <#
.SYNOPSIS
    Get IdentityNow Activities.    

.DESCRIPTION
    Get IdentityNow Activities.
    See https://community.sailpoint.com/t5/IdentityNow-Wiki/IdentityNow-REST-API-List-Account-Activities/ta-p/72189

.PARAMETER requestedFor
    (optional - ID) ID of identity that the activity was requested for

.PARAMETER requestedBy
    (optional - ID) The identity that requested the activity

.PARAMETER type
    (optional) The type of account activity e.g "Identity Refresh", "AccountAttributeUpdate", "CloudPasswordRequest", "appRequest", "AccountStateUpdate"

.PARAMETER searchLimit
    (optional - default 250) number of results to return

.EXAMPLE
    Get-IdentityNowAccountActivities -type appRequest -searchLimit 1000

.EXAMPLE
    $user = Search-IdentityNowUsers -query "@accounts(accountId:darren.robinson)"    
    Get-IdentityNowAccountActivities -requestedFor $user.id

.EXAMPLE
    $user = Search-IdentityNowUsers -query "@accounts(accountId:darren.robinson)"
    $mgr = Search-IdentityNowUsers -query "@accounts(accountId:rick.sanchez)"
    Get-IdentityNowAccountActivities -requestedFor $user.id -requestedBy $mgr.id 

.EXAMPLE
    $user = Search-IdentityNowUsers -query "@accounts(accountId:darren.robinson)"
    Get-IdentityNowAccountActivities -regardingIdentity $user.id 

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$requestedBy,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$requestedFor,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$regardingIdentity,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$type,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [int]$searchLimit = 250
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
            $accountActivities = @()
            if ($searchLimit -gt 250) {
                $iterations = $searchLimit / 250
                $offset = 250
                $limit = 250
                Write-Verbose "Iterations ====> $($iterations)"
            } else { 
                $limit = $searchLimit 
            }
            
            switch ($requestedBy, $requestedFor, $type, $searchLimit, $limit) {
                { $requestedFor } {
                    $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities?requested-for=$($requestedFor)&limit=$($limit)"
                    Write-Verbose "RequestedFor Case - https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities?limit=250"
                }
                { $requestedBy -and $requestedFor } {
                    $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities?requested-for=$($requestedFor)&requested-by=$($requestedBy)&limit=$($limit)"
                    Write-Verbose "RequestedBy and RequestedFor Case - https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities?limit=250"
                }
                { $requestedBy } {
                    $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities?requested-by=$($requestedBy)&limit=$($limit)"
                    Write-Verbose "RequestedBy Case - https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities?limit=250"
                }                        
                { $requestedFor -and $type} {
                    $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities?requested-for=$($requestedFor)&type=$($type)&limit=$($limit)"
                    Write-Verbose "RequestedFor and Type Case - https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities?requested-for=$($requestedFor)&type=$($type)&limit=$($limit)"
                }
                { $requestedBy -and $requestedFor -and $type} {
                    $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities?requested-for=$($requestedFor)&requested-by=$($requestedBy)&type=$($type)&limit=$($limit)"
                    Write-Verbose "RequestedBy and RequestedFor and Type Case - https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities?requested-for=$($requestedFor)&requested-by=$($requestedBy)&type=$($type)&limit=$($limit)"
                }
                { $requestedBy -and $type} {
                    $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities?requested-by=$($requestedBy)&type=$($type)&limit=$($limit)"
                    Write-Verbose "RequestedBy and Type Case - https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities?requested-by=$($requestedBy)&type=$($type)&limit=$($limit)"
                }           
                {$regardingIdentity} {
                    $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities?regarding-identity=$($regardingIdentity)&limit=$($limit)"
                    Write-Verbose "RegardingIdentity Case - https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities?regarding-identity=$($regardingIdentity)&limit=$($limit)"
                }
                {$regardingIdentity -and $type} {
                    $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities?regarding-identity=$($regardingIdentity)&type=$($type)&limit=$($limit)"
                    Write-Verbose "RegardingIdentity and Type Case - https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities?regarding-identity=$($regardingIdentity)&type=$($type)&limit=$($limit)"
                }
                { $type } {
                    $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities?type=$($type)&limit=$($limit)"
                    Write-Verbose "Type Case - https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities?limit=250"
                }
                default {
                    $searchURLBase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities?limit=250"
                    Write-Verbose "Default Case - https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/account-activities?limit=250"
                }
            }

            $loop = 0
            if ($iterations -gt 1) {
                # Get First
                $results = Invoke-RestMethod -Method Get -URI $searchURLBase -Headers @{Authorization = "Bearer $($v3Token.access_token)"; "Content-Type" = "application/json" }
                $loop++
                Write-Verbose "Iteration ===> $($loop)"

                if ($results) {
                    $accountActivities += $results
                }
                # Get Rest 
                do {
                    if (($searchLimit - $offset) -gt 250) {  
                        Write-Verbose "Iteration ===> $($loop)"
                        $results = Invoke-RestMethod -Method Get -Uri "$($searchURLBase)&offset=$($offset)" -Headers @{Authorization = "Bearer $($v3Token.access_token)"; "Content-Type" = "application/json" }  
                        $loop++
                        $offset += $results.count 
                        if ($results) {
                            $accountActivities += $results
                        }
                        else {
                            break 
                        }
                    }
                    else {
                        $limitCount = ($searchLimit - $accountActivities.count)
                        $searchURL = $searchURLBase.Replace("limit=250", "limit=$($limitCount)")
                        $results = Invoke-RestMethod -Method Get -Uri "$($searchURL)&offset=$($offset)" -Headers @{Authorization = "Bearer $($v3Token.access_token)"; "Content-Type" = "application/json" } 
                        if ($results) {
                            $accountActivities += $results
                        }
                        else {
                            break 
                        }
                        Write-Verbose "Iteration ===> $($loop)"
                        $loop++
                    }
                } until (($loop -gt $iterations))
            }
            else {
                # Get full set (<250)
                $results = Invoke-RestMethod -Method Get -Uri $searchURLBase -Headers @{Authorization = "Bearer $($v3Token.access_token)"; "Content-Type" = "application/json" }                                                 
                $loop++
                Write-Verbose "Iteration ===> $($loop)"

                if ($results) {
                    $accountActivities += $results                    
                }
            }
            return $accountActivities
        }
        catch {
            Write-Error "Account Activities not found? $($_)" 
        }
    }
}
