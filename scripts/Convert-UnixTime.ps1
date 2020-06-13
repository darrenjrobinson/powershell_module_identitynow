function Convert-UnixTime {
    <#
.SYNOPSIS
Convert UnixTime to PowerShell DateTime 

.DESCRIPTION
Convert UnixTime to PowerShell DateTime 

.PARAMETER unixDate
(required) The unix time integer

.EXAMPLE
Convert-UnixTime 1592001868

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)][int32]$unixDate
    )

    $orig = (Get-Date -Year 1970 -Month 1 -Day 1 -hour 0 -Minute 0 -Second 0 -Millisecond 0)        
    $timeZone = Get-TimeZone
    $utcTime = $orig.AddSeconds($unixDate)
    $localTime = $utcTime.AddMinutes($timeZone.BaseUtcOffset.TotalMinutes)
    # Return local time
    return $localTime
}