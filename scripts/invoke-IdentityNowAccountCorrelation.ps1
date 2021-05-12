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
        [string]$missingAccountQuery="NOT @accounts(source.name:`"$sourcename`")",
        [integer]$limit=250,
        [switch]$triggerJoin
    )
    if ($org){set-identitynoworg $org}
    $org=(get-identitynoworg).'Organisation Name'
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
    do{
        $url="https://$org.api.identitynow.com/beta/accounts?count=true&limit=$limit&offset=$($limit*$i)&filters=sourceId eq `"$($source.externalId)`" and uncorrelated eq true"
        $temp=Invoke-RestMethod -UseBasicParsing -Uri $url -Headers @{"Authorization"="Bearer $($auth.access_token)"} -Method Get
        $accounts+=$temp
        $i++
        write-progress -activity 'get accounts' -status $accounts.Count
    }until($temp.count -lt $limit)

    $auth=Get-IdentityNowAuth
    $i=0
    $missingaccount=@()
    do{
        $url="https://$org.api.identitynow.com/v3/search?count=true&limit=$limit&offset=$($limit*$i)"
        $temp=$null
        $temp=Invoke-RestMethod -UseBasicParsing -Uri $url -Headers @{"Authorization"="Bearer $($auth.access_token)"} -Method Post -Body ($searchBody | ConvertTo-Json) -ContentType 'application/json'
        if ($temp.count -ge 1){$missingaccount+=$temp}
        if ($temp.Count -eq $limit){$i++}
        write-progress -activity 'get identities' -status $missingaccount.Count
    }until($temp.count -lt $limit)
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
            $joins[-1]
        }
    }
    if ($triggerJoin){
        $joins | Join-IdentityNowAccount -org $org -source $source.id
    }
}