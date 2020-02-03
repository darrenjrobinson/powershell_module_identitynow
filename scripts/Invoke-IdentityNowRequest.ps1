function Invoke-IdentityNowRequest {
    <#
.SYNOPSIS
Submit an IdentityNow API Request.

.DESCRIPTION
Submit an IdentityNow API Request.

.PARAMETER uri
(required) API URI

.PARAMETER method
(required) API Method
e.g Post, Get, Patch, Delete

.PARAMETER headers
(required) Headers for the request
Headersv2 Digest Auth with no Content-Type set 
Headersv2_JSON is Digest Auth with Content-Type set for application/json
Headersv3 is JWT oAuth with no Content-Type set 
Headersv3_JSON is JWT oAuth with Content-Type set for application/json

.PARAMETER body
(optional - JSON) Payload for a webrequest

.EXAMPLE
Invoke-IdentityNowRequest -method Get -headers Headersv2 -uri "https://YOURORG.api.identitynow.com/v2/accounts?sourceId=12345&limit=20&org=YOURORG"

.EXAMPLE
Invoke-IdentityNowRequest -method Get -headers Headersv3 -uri "https://YOURORG.api.identitynow.com/cc/api/integration/listSimIntegrations"

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$uri,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string][ValidateSet("Get", "Put", "Patch", "Delete", "Post")]$method,
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string][ValidateSet("HeadersV2", "HeadersV3", "Headersv2_JSON", "Headersv3_JSON", "Headersv3_JSON-Patch")]$headers,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$body
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
    $v3Token = Invoke-RestMethod -Method Post -Uri "$($oAuthURI)?grant_type=password&username=$($adminUSR)&password=$($adminPWD)" -Headers $Headersv3 

    # v2 Auth
    $clientSecretv2 = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($IdentityNowConfiguration.v2.Password))
    $Bytes = [System.Text.Encoding]::utf8.GetBytes("$($IdentityNowConfiguration.v2.UserName):$($clientSecretv2)") 
    $encodedAuth = [Convert]::ToBase64String($Bytes)     

    switch ($headers) {
        HeadersV2 { 
            $requestHeaders = @{Authorization = "Basic $($encodedAuth)" }
            Write-Verbose "Authorization = Basic $($encodedAuth)"
        }
        HeadersV3 { 
            $requestHeaders = @{Authorization = "Bearer $($v3Token.access_token)" }
            Write-Verbose "Authorization = Bearer $($v3Token.access_token)"
        }
        Headersv2_JSON { 
            $requestHeaders = @{Authorization = "Basic $($encodedAuth)"; "Content-Type" = "application/json" }
            Write-Verbose "Authorization = 'Basic $($encodedAuth)' ; 'Content-Type' = 'application/json' "
        }
        Headersv3_JSON { 
            $requestHeaders = @{Authorization = "Bearer $($v3Token.access_token)"; "Content-Type" = "application/json" }
            Write-Verbose "Authorization = 'Bearer $($v3Token.access_token)' ; 'Content-Type' = 'application/json'"
            Write-verbose ($v3Token | convertTo-json)
        }
        Headersv3_JSON-Patch { 
            $requestHeaders = @{Authorization = "Bearer $($v3Token.access_token)"; "Content-Type" = "application/json-patch+json" }
            Write-Verbose "Authorization = 'Bearer $($v3Token.access_token)'; 'Content-Type' = 'application/json-patch+json'"
            Write-verbose ($v3Token | convertTo-json)
        }
        default { 
            $requestHeaders = $headers 
        } 
    }
    
    Write-Verbose $requestHeaders
    
    if ($requestHeaders) {
        try {
            if ($body) {
                $result = Invoke-RestMethod -Method $method -Uri $uri -Headers $requestHeaders -Body $body 
            }
            else {            
                $result = Invoke-RestMethod -Method $method -Uri $uri -Headers $requestHeaders        
            }
            return $result
        }
        catch {
            Write-Error "Request Failed. Check your request parameters. $($_)" 
        }
    }
    else {
        Write-Error "No Request Headers computed. Check your request `$headers parameter. $($_)"
        return $v3Token
    } 
}
