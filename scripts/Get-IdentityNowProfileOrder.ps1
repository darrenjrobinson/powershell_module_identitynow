function Get-IdentityNowProfileOrder {
    <#
.SYNOPSIS
Get IdentityNow Profiles Order.

.DESCRIPTION
Get IdentityNow Profiles Order.

.EXAMPLE
Get-IdentityNowProfileOrder 

ProfileName           Priority   ID
-----------           --------   --
IdentityNow Admins          10 1066
Cloud Identities            30 1285
Guest Identities            40 1286
Special Identities          60 1372
Non Employee Identities     70 1380
Employee Identities         80 1387

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param()

    $v3Token = Get-IdentityNowAuth
    
    if ($v3Token.access_token) {
        try {
            $IDNProfile = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/profile/list" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
            $identityProfileOrderSelect = $IDNProfile | Select-Object -Property name, id, priority | Sort-Object -Property priority 

            $iProfiles = @()      
            [int]$order = 0  
            foreach ($profile in $identityProfileOrderSelect) {
                $iProfileName = New-Object -TypeName PSObject
                $iProfileName | Add-Member -Type NoteProperty -Name ProfileName -Value $profile.name  
                $iProfileName | Add-Member -Type NoteProperty -Name Priority -Value $profile.priority
                $iProfileName | Add-Member -Type NoteProperty -Name ID -Value $profile.id
                $iProfiles += $iProfileName 
                $order++
            }
            return $iProfiles
        }
        catch {
            Write-Error "Profile doesn't exist? $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

