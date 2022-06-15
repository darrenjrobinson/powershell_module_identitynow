function Get-IdentityNowEvent {
    <#
.SYNOPSIS
Get IdentityNow Events.

.DESCRIPTION
Get IdentityNow system activity Events.

.PARAMETER Filter
(optional) The filter of IdentityNow events.

.PARAMETER Limit
(optional) default 200

.EXAMPLE
Get-IdentityNowEvent

.EXAMPLE

Get-IdentityNowEvent -Filter '[{"property":"type","value":"CLOUD_ACCOUNT_AGGREGATION"},{"property":"objectType","value":"source"},{"property":"objectId","value":"133327"}]'

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$Filter='[{"property":"type","value":"CLOUD_ACCOUNT_AGGREGATION"}]',
        [int]$Limit=200,
        [string]$sort='[{"property":"timestamp","direction":"DESC"}]'
    )
    $result=$null
    $page=1
    $start=0
    do{
         if ($limit-$result.items.count -lt 200){
            $thislimit=$limit-$result.items.count
        }else{
            $thislimit=200
        }
        if ($result){
            if ($filter){
                $uri=(get-identitynoworg).'Private Base API URI' + "/event/list?page=$page&start=$start&limit=$thislimit&sort=$sort&filter=$filter"
            }else{
                $uri=(get-identitynoworg).'Private Base API URI' + "/event/list?page=$page&start=$start&limit=$thislimit&sort=$sort"
            }
            $temp=Invoke-IdentityNowRequest -uri $uri -method get -headers Headersv3
            $result.items+=$temp.Items
        }else{
            if ($filter){
                $uri=(get-identitynoworg).'Private Base API URI' + "/event/list?page=1&start=0&limit=$thislimit&sort=$sort&filter=$filter"
            }else{
                $uri=(get-identitynoworg).'Private Base API URI' + "/event/list?page=1&start=0&limit=$thislimit&sort=$sort"
            }
            $result=Invoke-IdentityNowRequest -uri $uri -method get -headers Headersv3
        }
        $start=$start+$thislimit
    }until($result.items.count -ge $limit)
    return $result
}
