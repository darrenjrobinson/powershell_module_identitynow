function Get-HashString {
    <#
.SYNOPSIS
Generate IdentityNow Admin User Password Hash to obtain oAuth Access Token.

.DESCRIPTION
Generate IdentityNow Admin User Password Hash to obtain oAuth Access Token.

.PARAMETER string
(required) The string to hash.

.PARAMETER hashType
(optional) The hash algorithm. e.g MD5,RIPEMD160,SHA1,SHA256,SHA384,SHA512
Defaults to SHA256

.EXAMPLE
Get-HashString -string mystringtohash

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$string,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [ValidateSet("MD5", "RIPEMD160", "SHA1", "SHA256", "SHA384", "SHA512")]
        [string]$hashType = "SHA256"
    )

    $StringBuilder = New-Object System.Text.StringBuilder 
    [System.Security.Cryptography.HashAlgorithm]::Create($hashType).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($string)) | ForEach-Object { 
        [Void]$StringBuilder.Append($_.ToString("x2")) 
    } 
    return $StringBuilder.ToString()  
}
