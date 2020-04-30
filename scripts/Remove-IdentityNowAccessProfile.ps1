function Remove-IdentityNowAccessProfile {
    <#
.SYNOPSIS
Delete an IdentityNow Access Profile.

.DESCRIPTION
Delete an IdentityNow Access Profile.

.PARAMETER profileID
(required) The profile ID of the IdentityNow Access Profile to delete.

.EXAMPLE
Remove-IdentityNowAccessProfile -profileID 2c9180886cd58059016d18a52bd50951

.EXAMPLE
$ExistingAPs = Get-IdentityNowAccessProfile
$myAP = $ExistingAPs | Select-Object | Where-Object {$_.name -like "*My Access Profile*"}
Remove-IdentityNowAccessProfile -profileID $myAP.id

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$profileID
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
            # The IdentityNow Access Profile Delete call takes an Array. This cmdlet is designed for a single Access Profile deletion function
            # Don't judge me. This is Day2 and I'm 26 cmdlets deep.
            $profID = "[`"$($profileID)`"]"
            $IDNDeleteAP = Invoke-RestMethod -Method Post -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/access-profiles/bulk-delete" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" ; "Content-Type" = "application/json" } -Body $profID
            return $IDNDeleteAP
        }
        catch {
            Write-Error "Deletion of Access Profile failed. Check Access Profile ID and format (JSON). $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

