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
    param ( )
    try{    
        $lowusersource=(Get-IdentityNowSource | Where-Object {$_.usercount -ne 0} | Sort-Object usercount)[0]
    }
    catch{
        write-warning "testing APIv3 credentials failed for $($IdentityNowConfiguration.orgName), unable to continue"
        return $null
    }
    "able to use APIv3"
    try{
        $accounts=Get-IdentityNowSourceAccounts -sourceID $lowusersource.id
    }
    catch{
        write-warning "testing APIv2 credentials failed for $($IdentityNowConfiguration.orgName)"
        return $null
    }
    "able to use APIv2"
    return "credentials APIv2 and APIv3 are working for $($IdentityNowConfiguration.orgName)"
}