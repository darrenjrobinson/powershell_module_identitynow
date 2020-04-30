function Get-IdentityNowGovernanceGroup {
        <#
.SYNOPSIS
    Get an IdentityNow Governance Group.

.DESCRIPTION
    Get an IdentityNow Governance Group.

.PARAMETER group
    (optional) The Name of an IdentityNow Governance Group.

.EXAMPLE
    Get-IdentityNowGovernanceGroup 

.EXAMPLE
    Get-IdentityNowGovernanceGroup -group 6289788a-c73c-426b-9170-12340aaa6789

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$group
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
            if ($group) {
                $IDNGroups = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/workgroups/$($group)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
                return $IDNGroups
            }
            else {
                $IDNGroups = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/workgroups?org=$($IdentityNowConfiguration.orgName)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
                return $IDNGroups
            }
        }
        catch {
            Write-Error "Group doesn't exist. Check group ID. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

