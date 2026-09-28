[CmdletBinding(SupportsShouldProcess)]
param()

$ErrorActionPreference = 'Stop'

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]::new($identity)
if (!$principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Run this script from an elevated PowerShell session.'
}

$capabilities = @(Get-WindowsCapability -Online -Name 'Rsat.*' | Where-Object State -ne 'Installed')
if (!$capabilities.Count) {
    Write-Output 'All available RSAT capabilities are already installed.'
    return
}

foreach ($capability in $capabilities) {
    if ($PSCmdlet.ShouldProcess($capability.Name, 'Install Windows capability')) {
        Add-WindowsCapability -Online -Name $capability.Name | Out-Null
    }
}

Get-WindowsCapability -Online -Name 'Rsat.*' |
    Sort-Object Name |
    Select-Object Name, State
