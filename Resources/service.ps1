[CmdletBinding()]
param(
    [string]$LogPath = 'C:\Logs\Policies.log',
    [int]$IntervalSeconds = 30
)

$ErrorActionPreference = 'Stop'
$logDirectory = Split-Path -Parent $LogPath
New-Item -Path $logDirectory -ItemType Directory -Force | Out-Null

while ($true) {
    $timestamp = Get-Date -Format o
    try {
        $domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
        $sysvol = "\\$($domain.Name)\SYSVOL\$($domain.Name)\Policies"
        $policies = @(Get-ChildItem -LiteralPath $sysvol -Directory -ErrorAction Stop | Select-Object -ExpandProperty Name)
        "$timestamp`t$($policies -join ',')" | Add-Content -LiteralPath $LogPath -Encoding UTF8
    }
    catch {
        "$timestamp`tERROR`t$($_.Exception.Message)" | Add-Content -LiteralPath $LogPath -Encoding UTF8
    }
    Start-Sleep -Seconds $IntervalSeconds
}
