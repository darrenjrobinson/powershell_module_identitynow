function Get-IdentityNowAggregationStatus {
    <#
    .SYNOPSIS
    Get Status of an IdentityNow Aggregation.
    
    .DESCRIPTION
    Get Status of an IdentityNow Aggregation. 
    
    .PARAMETER id
    (required) ID of the Aggregation to get the status of (e.g. 2c91808477a6b0c60177a81146b8110b)
    
    .EXAMPLE
    Get-IdentityNowAggregationStatus -id 2c91808477a6b0c60177a81146b8110b
    
    .LINK
    http://darrenjrobinson.com/sailpoint-identitynow
    
    #>
    
    
    [cmdletbinding()]
    param( 
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$id 
    )
    
    $v3Token = Get-IdentityNowAuth
    
    if ($v3Token.access_token) {
        try {    
            $aggStatus = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/beta/account-aggregations/$($id)/status" -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" ; "Content-Type" = "application/json" }
            return $aggStatus
        }
        catch {
            Write-Error "$($_)"
        }
    }
    else {
        Write-Error "Authentication Failed. Check your v3/PAT API credentials. $($_)"
        return $_
    } 
}
    
    