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