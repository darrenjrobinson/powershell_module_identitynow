[CmdletBinding()]
param (
    [string]$InstallPath = (Join-Path $env:ProgramFiles 'WindowsPowerShell\Modules\SailPointIdentityNow'),
    [switch]$Force
)

$sourceFiles = @(
    '.\scripts\',
    '.\SailPointIdentityNow.ps*'
)

if (Test-Path $InstallPath) {
    if ($Force) {
        Remove-Item -Path $InstallPath\* -Recurse
    } else {
        Write-Warning "Module already installed at `"$InstallPath`" use -Force to overwrite installation."
        return
    }
} else {
    New-Item -Path $InstallPath -ItemType Directory | Out-Null
}

Push-Location $PSScriptRoot
Copy-Item -Path $sourceFiles -Destination $InstallPath -Recurse
Pop-Location

Import-Module -Name SailPointIdentityNow 
Get-Command -Module SailPointIdentityNow | Sort-Object Name | Get-Help | Format-Table Name, Synopsis -AutoSize
