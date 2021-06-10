function Invoke-IdentityNowAccountCorrelation {
<#
    .SYNOPSIS
        find uncorrelated accounts that can be joined

    .DESCRIPTION
        compare identities to a source's uncorrelated accounts to see if there are unjoined which would benefit from an unoptimized aggregation or manual correlation csv upload

    .PARAMETER org
    string, optional, the name of your org if you wish to switch, calls set-identitynoworg

    .PARAMETER sourceName
    string, required, the name of the source like "Corporate Active Directory", "ServiceNow", "AAD"

    .PARAMETER identityAttribute
    string, required, the system name of the identity attribute which will be tested for a match against accountAttribute

    .PARAMETER accountAttribute
    string, required, the account attribute that should equal the value of identityAttribute, it could be userprincipalname, employeeid, or any other unique value

    .PARAMETER missingAccountQuery
    string, optional, the search query used to identify identities that are missing an account
    the default will be "NOT @accounts(source.name:`"$sourcename`")"
    in large environments, providing stricter criteria like, we also expect an account in AAD, or certain attributes should have a value, or only for this identity profile, can speed up the search query
    IDN has a limit of 10,000 on their search, you may need to break up the identity results if necessary.

    .PARAMETER limit
    integer, batch size for fetching identities and accounts for IDN API, default is 250
    
    .PARAMETER triggerJoin
    switch, after outputting joins will upload csv to IDN to manually correlate identities to accounts

    .EXAMPLE
        Invoke-IdentityNowAccountCorrelation -sourceName "Prod AAD" -identityAttribute calculatedImmuteableID -accountAttribute immuteableId

    .EXAMPLE
        Invoke-IdentityNowAccountCorrelation -sourceName "HR" -identityAttribute identificationNumber -accountAttribute EmployeeID -triggerJoin -limit 500

    .LINK
        http://darrenjrobinson.com/sailpoint-identitynow

    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$org,
        [Parameter(Mandatory = $true)]
        [string]$sourceName,
        [Parameter(Mandatory = $true)]
        [string]$identityAttribute,
        [Parameter(Mandatory = $true)]
        [string]$accountAttribute,
        [string]$missingAccountQuery="NOT @accounts(source.name:`"$sourcename`") AND attributes.$($identityAttribute):*",
        [ValidateRange(0, 250)]
        [int]$limit=250,
        [switch]$triggerJoin
    )
    if ($org){set-identitynoworg $org}
    try{
        $org=(get-identitynoworg).'Organisation Name'
    }catch{
        throw "possibly missing sailpointidentitynow module:$_"
    }
    
    $searchBody=[pscustomobject]@{
        indices = @("identities")
        query = [pscustomobject]@{
            query = $missingAccountQuery
            fields = @("name","description")
        }
    }
    $source=Get-IdentityNowSource
    $source=$source.where{$_.name -eq $sourcename}[0]
    $auth=Get-IdentityNowAuth
    $i=0
    $accounts=@()
    write-output "getting from beta accounts API 'sourceId eq `"$($source.externalId)`" and uncorrelated eq true'"
    do{
        $url="https://$org.api.identitynow.com/beta/accounts?count=true&limit=$limit&offset=$($limit*$i)&filters=sourceId eq `"$($source.externalId)`" and uncorrelated eq true"
        try{
            $temp=Invoke-RestMethod -UseBasicParsing -Uri $url -Headers @{"Authorization"="Bearer $($auth.access_token)"} -Method Get
        }catch{
            switch($_.Exception.Response.StatusCode){
                'GatewayTimeout'{Write-Error "$($_.Exception.Response.StatusCode):$_"}
                default{"$($_.Exception.Response.StatusCode):$_"}
            }
        }
        if ($temp.count -eq 1){$temp=ConvertFrom-Json ($temp -creplace '\"ImmutableId\"\:(null|\"[\w\d\\\+\-\@\.\/]{1,}\"),','')}
        $accounts+=$temp
        $i++
        write-progress -activity 'get accounts' -status $accounts.Count
    }until($temp.count -lt $limit)
    write-output "retrieved $($accounts.count)"
    $auth=Get-IdentityNowAuth
    $i=0
    $missingaccount=@()
    write-output "getting from identities from v3 search API:$missingAccountQuery"
    do{
        $url="https://$org.api.identitynow.com/v3/search?count=true&limit=$limit&offset=$($limit*$i)"
        $temp=$null
        $temp=Invoke-RestMethod -UseBasicParsing -Uri $url -Headers @{"Authorization"="Bearer $($auth.access_token)"} -Method Post -Body ($searchBody | ConvertTo-Json) -ContentType 'application/json'
        if ($temp.count -ge 1){$missingaccount+=$temp}
        if ($temp.Count -eq $limit){$i++}
        write-progress -activity 'get identities' -status $missingaccount.Count
    }until($temp.count -lt $limit)
    write-output "retrieved $($missingAccount.count) identities"
    $i=0
    $joins=@()
    foreach($user in $missingaccount){
        $i++
        if ($user.attributes.$identityAttribute -in $accounts.attributes.$accountAttribute){
            $joins+=[pscustomobject]@{
                account = $accounts.where{$_.attributes.$accountAttribute -eq $user.attributes.$identityAttribute}.nativeIdentity
                displayName = $accounts.where{$_.attributes.$accountAttribute -eq $user.attributes.$identityAttribute}.nativeIdentity
                userName = $user.name
                type = $null
            }
            write-output $joins[-1] | ConvertTo-Json
        }
    }
function Join-IdentityNowAccount {
    <#
        .SYNOPSIS
            Join an IdentityNow User Account to an Identity.

        .DESCRIPTION
            Manually correlate an IdentityNow User Account with an identity account.

        .PARAMETER source
            provide the source ID containing the accounts we wish to join
            SailPoint IdentityNow Source ID
            e.g 12345

        .PARAMETER Identity
            Identity UID

        .PARAMETER Account
            Account ID

        .PARAMETER org
        Specifies the identitynow org

        .PARAMETER joins
        provide a powershell object or array of objects with the property 'identity' and 'account'

        .EXAMPLE
            Join-IdentityNowAccount -source 12345 -identity jsmith -account 012345

        .EXAMPLE
            $joins=@()
            $joins+=[pscustomobject]@{
                    account = $account.nativeIdentity
                    displayName = $account.nativeIdentity
                    userName = $identity.name
                    type = $null
                }
            $joins | join-IdentityNowAccount -org $org -source $source.id
            
        .LINK
            http://darrenjrobinson.com/sailpoint-identitynow

    #>

    [cmdletbinding(DefaultParameterSetName = 'SingleAccount')]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = 'SingleAccount')]    
        [Parameter(Mandatory = $false, ParameterSetName = 'MultipleAccounts')]
        [string]$org,    
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'SingleAccount')]
        [Parameter(Mandatory = $true, ParameterSetName = 'MultipleAccounts')]
        [string]$source,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'SingleAccount')]
        [string]$account,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'SingleAccount')]
        [string]$Identity,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'MultipleAccounts')]
        [pscustomobject[]]$joins
    )
    begin{
        if ($org){set-identitynoworg $org}
        try{
            $org=(get-identitynoworg).'Organisation Name'
        }catch{
            throw "possibly missing sailpointidentitynow module:$_"
        }
        $csv = @()
        $csv = $csv + 'account,displayName,userName,type'
        
    }
    process{
        if ($account){
            $csv = $csv + "$account,$account,$identity,"
        }elseif($_){
            $csv = $csv + "$($_.account),$($_.displayName),$($_.userName),$($_.type)"
        }
    }
    end{
        $v3Token = Get-IdentityNowAuth
        if ($v3Token.access_token) {
            try {
                $result = Invoke-restmethod -Uri "https://$org.api.identitynow.com/cc/api/source/loadUncorrelatedAccounts/$source" `
                    -Method "POST" `
                    -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "Accept-Encoding" = "gzip, deflate, br"} `
                    -ContentType "multipart/form-data; boundary=----WebKitFormBoundaryU1hSZTy7cff3WW27" `
                    -Body ([System.Text.Encoding]::UTF8.GetBytes("------WebKitFormBoundaryU1hSZTy7cff3WW27$([char]13)$([char]10)Content-Disposition: form-data; name=`"file`"; filename=`"temp.csv`"$([char]13)$([char]10)Content-Type: application/vnd.ms-excel$([char]13)$([char]10)$([char]13)$([char]10)$($csv | out-string)$([char]13)$([char]10)------WebKitFormBoundaryU1hSZTy7cff3WW27--$([char]13)$([char]10)")) `
                    -UseBasicParsing
                return $result           
            }
            catch {
                Write-Error "Account couldn't be joined. $($_)" 
            }
        }
        else {
            Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
            return $v3Token
        } 
    }
}

    if ($triggerJoin -and $joins.count -ge 1){
        $joins | Join-IdentityNowAccount -org $org -source $source.id
    }

}
# SIG # Begin signature block
# MIINSwYJKoZIhvcNAQcCoIINPDCCDTgCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUXLlCE3muqplNfMZ6/hqDePN5
# hhigggqNMIIFMDCCBBigAwIBAgIQBAkYG1/Vu2Z1U0O1b5VQCDANBgkqhkiG9w0B
# AQsFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVk
# IElEIFJvb3QgQ0EwHhcNMTMxMDIyMTIwMDAwWhcNMjgxMDIyMTIwMDAwWjByMQsw
# CQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cu
# ZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFzc3VyZWQgSUQg
# Q29kZSBTaWduaW5nIENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
# +NOzHH8OEa9ndwfTCzFJGc/Q+0WZsTrbRPV/5aid2zLXcep2nQUut4/6kkPApfmJ
# 1DcZ17aq8JyGpdglrA55KDp+6dFn08b7KSfH03sjlOSRI5aQd4L5oYQjZhJUM1B0
# sSgmuyRpwsJS8hRniolF1C2ho+mILCCVrhxKhwjfDPXiTWAYvqrEsq5wMWYzcT6s
# cKKrzn/pfMuSoeU7MRzP6vIK5Fe7SrXpdOYr/mzLfnQ5Ng2Q7+S1TqSp6moKq4Tz
# rGdOtcT3jNEgJSPrCGQ+UpbB8g8S9MWOD8Gi6CxR93O8vYWxYoNzQYIH5DiLanMg
# 0A9kczyen6Yzqf0Z3yWT0QIDAQABo4IBzTCCAckwEgYDVR0TAQH/BAgwBgEB/wIB
# ADAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAwwCgYIKwYBBQUHAwMweQYIKwYBBQUH
# AQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wQwYI
# KwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFz
# c3VyZWRJRFJvb3RDQS5jcnQwgYEGA1UdHwR6MHgwOqA4oDaGNGh0dHA6Ly9jcmw0
# LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwOqA4oDaG
# NGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RD
# QS5jcmwwTwYDVR0gBEgwRjA4BgpghkgBhv1sAAIEMCowKAYIKwYBBQUHAgEWHGh0
# dHBzOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwCgYIYIZIAYb9bAMwHQYDVR0OBBYE
# FFrEuXsqCqOl6nEDwGD5LfZldQ5YMB8GA1UdIwQYMBaAFEXroq/0ksuCMS1Ri6en
# IZ3zbcgPMA0GCSqGSIb3DQEBCwUAA4IBAQA+7A1aJLPzItEVyCx8JSl2qB1dHC06
# GsTvMGHXfgtg/cM9D8Svi/3vKt8gVTew4fbRknUPUbRupY5a4l4kgU4QpO4/cY5j
# DhNLrddfRHnzNhQGivecRk5c/5CxGwcOkRX7uq+1UcKNJK4kxscnKqEpKBo6cSgC
# PC6Ro8AlEeKcFEehemhor5unXCBc2XGxDI+7qPjFEmifz0DLQESlE/DmZAwlCEIy
# sjaKJAL+L3J+HNdJRZboWR3p+nRka7LrZkPas7CM1ekN3fYBIM6ZMWM9CBoYs4Gb
# T8aTEAb8B4H6i9r5gkn3Ym6hU/oSlBiFLpKR6mhsRDKyZqHnGKSaZFHvMIIFVTCC
# BD2gAwIBAgIQDOzRdXezgbkTF+1Qo8ZgrzANBgkqhkiG9w0BAQsFADByMQswCQYD
# VQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGln
# aWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFzc3VyZWQgSUQgQ29k
# ZSBTaWduaW5nIENBMB4XDTIwMDYxNDAwMDAwMFoXDTIzMDYxOTEyMDAwMFowgZEx
# CzAJBgNVBAYTAkFVMRgwFgYDVQQIEw9OZXcgU291dGggV2FsZXMxFDASBgNVBAcT
# C0NoZXJyeWJyb29rMRowGAYDVQQKExFEYXJyZW4gSiBSb2JpbnNvbjEaMBgGA1UE
# CxMRRGFycmVuIEogUm9iaW5zb24xGjAYBgNVBAMTEURhcnJlbiBKIFJvYmluc29u
# MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwj7PLmjkknFA0MIbRPwc
# T1JwU/xUZ6UFMy6AUyltGEigMVGxFEXoVybjQXwI9hhpzDh2gdxL3W8V5dTXyzqN
# 8LUXa6NODjIzh+egJf/fkXOgzWOPD5fToL7mm4JWofuaAwv2DmI2UtgvQGwRhkUx
# Y3hh0+MNDSyz28cqExf8H6mTTcuafgu/Nt4A0ddjr1hYBHU4g51ZJ96YcRsvMZSu
# 8qycBUNEp8/EZJxBUmqCp7mKi72jojkhu+6ujOPi2xgG8IWE6GqlmuMVhRSUvF7F
# 9PreiwPtGim92RG9Rsn8kg1tkxX/1dUYbjOIgXOmE1FAo/QU6nKVioJMNpNsVEBz
# /QIDAQABo4IBxTCCAcEwHwYDVR0jBBgwFoAUWsS5eyoKo6XqcQPAYPkt9mV1Dlgw
# HQYDVR0OBBYEFOh6QLkkiXXHi1nqeGozeiSEHADoMA4GA1UdDwEB/wQEAwIHgDAT
# BgNVHSUEDDAKBggrBgEFBQcDAzB3BgNVHR8EcDBuMDWgM6Axhi9odHRwOi8vY3Js
# My5kaWdpY2VydC5jb20vc2hhMi1hc3N1cmVkLWNzLWcxLmNybDA1oDOgMYYvaHR0
# cDovL2NybDQuZGlnaWNlcnQuY29tL3NoYTItYXNzdXJlZC1jcy1nMS5jcmwwTAYD
# VR0gBEUwQzA3BglghkgBhv1sAwEwKjAoBggrBgEFBQcCARYcaHR0cHM6Ly93d3cu
# ZGlnaWNlcnQuY29tL0NQUzAIBgZngQwBBAEwgYQGCCsGAQUFBwEBBHgwdjAkBggr
# BgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tME4GCCsGAQUFBzAChkJo
# dHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRTSEEyQXNzdXJlZElE
# Q29kZVNpZ25pbmdDQS5jcnQwDAYDVR0TAQH/BAIwADANBgkqhkiG9w0BAQsFAAOC
# AQEANWoHDjN7Hg9QrOaZx0V8MK4c4nkYBeFDCYAyP/SqwYeAtKPA7F72mvmJV6E3
# YZnilv8b+YvZpFTZrw98GtwCnuQjcIj3OZMfepQuwV1n3S6GO3o30xpKGu6h0d4L
# rJkIbmVvi3RZr7U8ruHqnI4TgbYaCWKdwfLb/CUffaUsRX7BOguFRnYShwJmZAzI
# mgBx2r2vWcZePlKH/k7kupUAWSY8PF8O+lvdwzVPSVDW+PoTqfI4q9au/0U77UN0
# Fq/ohMyQ/CUX731xeC6Rb5TjlmDhdthFP3Iho1FX0GIu55Py5x84qW+Ou+OytQcA
# FZx22DA8dAUbS3P7OIPamcU68TGCAigwggIkAgEBMIGGMHIxCzAJBgNVBAYTAlVT
# MRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5j
# b20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBDb2RlIFNpZ25p
# bmcgQ0ECEAzs0XV3s4G5ExftUKPGYK8wCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcC
# AQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYB
# BAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFFZKwgcbJj/x
# AAq7XQMBqTkUtSR1MA0GCSqGSIb3DQEBAQUABIIBAAMaDRDo/j9OK5krjtDh481d
# oJAo5oVcXSk82gXltoLAY/nZH3DIiehgmC55i40E0FOSoJXi0NC++25vWwXzTfl7
# mWU20iYzHGRfzJcBb5h1/pKxSiOYByqHDUtQZMnZo1MRyXeHgMmuO/yyol/MgMQ5
# xBoSiR5ux3RKh7YAEVx9ckwDg4jWgwYJnwr07gYTxRb4x5VOTh195bzhmgRdBWCt
# rFJpsKW7IvXxXcxMvVatWgU1fvJ1kCOsi2y44vldMwaNnoC8j0hx/OD7HB0C73mm
# dViUGFxB7/eFhnjv4E6VP+neO8uv9xbEqBEbahNlNJj/Arj/2YPzEcM5hVS3FkM=
# SIG # End signature block
