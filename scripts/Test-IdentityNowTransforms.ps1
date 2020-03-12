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
        
        param($next, $transformname, $path)
        write-verbose "TF:$path\$($next.type)"
        if ($next.input -ne $null) { check-recurse -next $next.input.attributes -transformname $transformname -path "$path\input" }
        switch ($next.type) {
            'accountAttribute' {
                $target = $sources.where{ $_.name -eq $next.attributes.sourceName }
                if ($target -eq $null) {
                    Write-Warning -Message "TF:$path\$($next.type) - references missing source name '$($next.attributes.sourcename)'" 
                }
                elseif ($target.schema.name.where{ $_ -eq $next.attributes.attributeName } -eq $null) {
                    Write-Warning -Message "TF:$path\$($next.type) - references missing source attribute '$($next.attributes.sourcename):$($next.attributes.attributeName)'"
                }
                else {
                    Write-Verbose -message "TF:$path\$($next.type) - references valid source attribute '$($next.attributes.sourcename):$($next.attributes.attributeName)'"
                }
            }
            'identityAttribute' {
                if ($next.attributes.name -notin $identity.name) {
                    write-warning -Message "TF:$path\$($next.type) - references missing identity attribute '$($next.attributes.name)'" 
                }
                else {
                    Write-Verbose -Message "TF:$path\$($next.type) - references valid identity attribute '$($next.attributes.name)'" 
                }
            }
            'firstValid' { $next.attributes.values | ForEach-Object { check-recurse -next $_ -transformname $transformname -path "$path\$($next.type)" } }
            'reference' {
                if ($next.attributes.id -notin $transforms.id) {
                    Write-Warning -Message "TF:$path\$($next.type) - references missing transform name '$($next.attributes.id)'"
                }
                else {
                    Write-Verbose -Message "TF:$path\$($next.type) - references valid transform name '$($next.attributes.id)'"
                }
            }
            'rule' {
                if ($next.attributes.name -notin $rule.name) {
                    Write-Warning -Message "TF:$path\$($next.type) - references missing rule name '$($next.attributes.name)'"
                }
                else {
                    Write-Verbose -Message "TF:$path\$($next.type) - references valid rule name '$($next.attributes.name)'"
                }
            }
            'concat' { $next.attributes.values | ForEach-Object { check-recurse -next $_ -transformname $transformname -path "$path\$($next.type)" } }
            default { if ($next.attribute -ne $null) { check-recurse -next $next.attributes -transformname $transformname -path "$path\$($next.type)" } }
        }
        return
        $next | ConvertTo-Json -Depth 100
    }
    $i = 0
    foreach ($t in $transforms) {
        Write-Progress -Activity "checking $($t.id)" -PercentComplete ($i/$transforms.count*100)
        check-recurse -next $t -transformname $t.id -path "\\$($t.id)"
        $i++
    }
}