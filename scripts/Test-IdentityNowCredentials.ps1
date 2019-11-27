function Test-IdentityNowCredentials {
    <#
.SYNOPSIS
Tests IdentityNow Live credentials.

.DESCRIPTION
Test APIv3 and APIv2 credentials.

.EXAMPLE
Test-IdentityNowCredentials

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

.NOTES
written by Sean McGovern 11/27/2019 (twitter @410sean)

#>
    [cmdletbinding()]
        
    $lowusersource=(Get-IdentityNowSource | where {$_.usercount -ne 0} | sort usercount)[0]
    if ($lowusersource -eq $null){write-warning "testing APIv3 credentials failed, unable to continue";return $null}
    $accounts=Get-IdentityNowSourceAccounts -sourceID $lowusersource
    if ($accounts -eq $null){write-warning "able to use APIv3 but testing APIv2 credentials failed";return $null}
    return "credentials APIv2 and APIv3 are working for $($IdentityNowConfiguration.orgName)"
}