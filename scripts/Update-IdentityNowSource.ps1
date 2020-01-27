function Update-IdentityNowSource {
    <#
.SYNOPSIS
Update the configuration of an IdentityNow Source.

.DESCRIPTION
Update the configuration of an IdentityNow Source

.PARAMETER sourceID
(required) Id of the IdentityNow Source. e.g 12345

.PARAMETER update
(required) Sources change(s) to update 
e.g  name=SyntheticAttributes&description=Attributes for Provisioning Logic

.PARAMETER accountProfile
used to update the source account profile, pass the entire profile with updates

.EXAMPLE
Update-IdentityNowSource -id 12345 -update 'name=SyntheticAttributes&description=Attributes for Provisioning Logic'

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$sourceID,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        $update,
        [switch]$accountProfile
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

    if ($v3Token.access_token) {
        try {                         
            if ($accountProfile){
                $body=$update | ConvertTo-Json -Depth 100
                $updateSource = Invoke-RestMethod -Method Post -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/api/accountProfile/bulkUpdate/$($sourceID)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "Content-Type" = "application/json"} -Body $body
                return $updateSource
            }else{
                Write-Verbose "update ===> $($update)"
                $updateSource = Invoke-RestMethod -Method Post -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/source/update/$($sourceID)?$($update)" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "Content-Type" = "application/json"}            
                return $updateSource
            }           
        }
        catch {
            Write-Error "Update failed. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}