function Search-IdentityNowEvents {
    <#
.SYNOPSIS
    Search IdentityNow Event(s) using Elasticsearch queries.

.DESCRIPTION
    Search IdentityNow Event(s) using Elasticsearch queries

.PARAMETER filter
    (required - JSON) filter 
    Elasticsearch Query Filter 
    e.g '{"query": {"query": "technicalName:USER_AUTHENTICATION_STEP_UP_SETUP_*","type":"USER_MANAGEMENT"}}'
    See https://community.sailpoint.com/t5/Admin-Help/How-do-I-use-Search-in-IdentityNow/ta-p/76960 

.EXAMPLE
    $query = @{query = 'technicalName:USER_AUTHENTICATION_STEP_UP_SETUP_*'; type = 'USER_MANAGEMENT'}
    $queryFilter = @{query = $query}
    Search-IdentityNowEvents -filter ($queryFilter | convertto-json)

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$filter
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
    $v3Token = Invoke-RestMethod -Method Post -Uri "$($oAuthURI)?grant_type=password&username=$($adminUSR)&password=$($adminPWD)" -Headers $Headersv3 -SessionVariable IDNv3
    
    if ($v3Token.access_token) {        
        try {             
            $getEvents = Invoke-RestMethod -Method POST -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/beta/search/events" -Headers @{Authorization = "Bearer $($v3Token.access_token)"; "Content-Type" = "application/json" } -Body $filter 
            return $getEvents
        }
        catch {
            Write-Error "Event(s) not found? Check your Elasticsearch Query syntax. $($_)" 
        }
    }
}

