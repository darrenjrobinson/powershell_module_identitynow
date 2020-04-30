function Get-IdentityNowRole {
    <#
.SYNOPSIS
Get an IdentityNow Role(s).

.DESCRIPTION
Get an IdentityNow Role(s).

.PARAMETER roleID
(optional) The ID of an IdentityNow Role.

.EXAMPLE
Get-IdentityNowRole 

.EXAMPLE
Get-IdentityNowRole -roleID 2c918084691653af01695182a78b05ec

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$roleID
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
            if ($roleID) {
                $utime = [int][double]::Parse((Get-Date -UFormat %s))
                $IDNRoles = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/role/get?_dc=$($utime)&id=$($roleID)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
                return $IDNRoles
            }
            else {
                Write-Verbose "Getting All Roles"
                # Get Roles Based on Query because the LIST Roles API is just random chaos when returning multiple pages of results
                $sourceObjects = @() 
                $limit = "2500"
                $results = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/search/roles?offset=0&limit=2500&query=name%20-eq%20*&org=$($IdentityNowConfiguration.orgName)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }                

                if ($results) {
                    $sourceObjects += $results
                }
                $offset = 0
                do { 
                    if ($results.Count -eq $limit) {
                        # Get Next Page
                        [int]$offset = $offset + $limit 
                        $results = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/search/roles?offset=$($offset)&limit=$($limit)&query=name%20-eq%20*" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }                
                        if ($results) {
                            $sourceObjects += $results
                        }
                    }
                } until ($results.Count -lt $limit)
                return $sourceObjects
            }
        }
        catch {
            Write-Error "Role doesn't exist. Check Role ID. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

