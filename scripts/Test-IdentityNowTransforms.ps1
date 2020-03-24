function Test-IdentityNowTransforms {
    <#
.SYNOPSIS
Test IdentityNow transforms to detect common problems

.DESCRIPTION
Test IdentityNow transforms to detect common problems

.EXAMPLE
Test-IdentityNowTransforms

.EXAMPLE
Test-IdentityNowTransforms -verbose

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

.NOTES
written by Sean McGovern 1/27/2020 (twitter @410sean) for the sailpointidentitynow powershell module
https://github.com/darrenjrobinson/powershell_module_identitynow

#>
    [cmdletbinding()]
    $transforms = Get-IdentityNowTransform
    $sources = Get-IdentityNowSource
    $i = 0
    foreach ($s in $sources) {
        Write-Progress -Activity 'getting sources' -PercentComplete ($i/$sources.count*100)
        $i++
        $url = (Get-IdentityNowOrg).'v3 / Private Base API URI' + '/source/getAccountSchema/' + $s.id                
        $target = Invoke-IdentityNowRequest -headers Headersv3 -method Get -uri $url
        $s | Add-Member -NotePropertyName schema -NotePropertyValue $target.attributes -Force
    }
    $identity = Get-IdentityNowIdentityAttribute
    $rule = Get-IdentityNowRule
    function check-recurse {        
        param(
            $next, $transformname, $path
        )

        write-verbose "TF:$path\$($next.type)"
        if ($null -ne $next.attributes.input) { check-recurse -next $next.attributes.input -transformname $transformname -path "$path\$($next.type)\input" }
        switch ($next.type) {
            
            'accountAttribute' {
                $target = $sources.where{ $_.name -eq $next.attributes.sourceName }
                if (-not $target) {
                    Write-host -Message "TF:$path\$($next.type) - references missing source name '$($next.attributes.sourcename)'"  -ForegroundColor yellow
                }
                elseif ($target.schema.name -notcontains $next.attributes.attributeName) {
                    Write-host -Message "TF:$path\$($next.type) - references missing source attribute '$($next.attributes.sourcename):$($next.attributes.attributeName)'" -ForegroundColor yellow
                }
                else {
                    Write-Verbose -message "TF:$path\$($next.type) - references valid source attribute '$($next.attributes.sourcename):$($next.attributes.attributeName)'"
                }
            }
            
            'identityAttribute' {
                if ($next.attributes.name -notin $identity.name) {
                    write-host -Message "TF:$path\$($next.type) - references missing identity attribute '$($next.attributes.name)'" -ForegroundColor yellow
                }
                else {
                    Write-Verbose -Message "TF:$path\$($next.type) - references valid identity attribute '$($next.attributes.name)'" 
                }
            }
            
            'firstValid' { $next.attributes.values | ForEach-Object { check-recurse -next $_ -transformname $transformname -path "$path\$($next.type)" } }
            'lookup'{ (($next.attributes.table | Get-Member -MemberType NoteProperty)).name | ForEach-Object { check-recurse -next $next.attributes.table.$_ -transformname $transformname -path "$path\$($next.type)" } }
            'reference' {
                if ($next.attributes.id -notin $transforms.id) {
                    Write-host -Message "TF:$path\$($next.type) - references missing transform name '$($next.attributes.id)'" -ForegroundColor yellow
                }
                else {
                    Write-Verbose -Message "TF:$path\$($next.type) - references valid transform name '$($next.attributes.id)'"
                }
            }
            
            'rule' {
                if ($next.attributes.name -notin $rule.name) {
                    Write-host -Message "TF:$path\$($next.type) - references missing rule name '$($next.attributes.name)'" -ForegroundColor yellow
                }
                else {
                    Write-Verbose -Message "TF:$path\$($next.type) - references valid rule name '$($next.attributes.name)'"
                }
            }
            
            'concat' { $next.attributes.values | ForEach-Object { check-recurse -next $_ -transformname $transformname -path "$path\$($next.type)" } }
            default { if ($null -ne $next.attribute) { check-recurse -next $next.attributes -transformname $transformname -path "$path\$($next.type)" } }
        }
        return
        $next | ConvertTo-Json -Depth 100
    }
    $i = 0
    foreach ($t in $transforms) {
        Write-Progress -Activity "checking $($t.id)" -PercentComplete ($i/$transforms.count*100)
        check-recurse -next $t -transformname $t.id -path "\\$((Get-IdentityNowOrg).'Organisation Name')\$($t.id)"
        $i++
    }
}
