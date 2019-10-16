$IdentityNowConfiguration = @{    
    orgName = $null 
    v2  = $null
    v3  = $null
    AdminCredential = $null
}

$IdentityNowConfigurationFile = Join-Path $env:LOCALAPPDATA IdentityNowConfiguration.clixml
if (Test-Path $IdentityNowConfigurationFile) {
    $IdentityNowConfiguration = Import-Clixml $IdentityNowConfigurationFile
}

if (-not(Get-Module -ListAvailable -Name pscx)) {Install-Module -Name Pscx -RequiredVersion 3.3.2 -Force -AllowClobber}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Get-ChildItem "$PSScriptRoot/scripts/*.ps1" | ForEach-Object { . $_ }
