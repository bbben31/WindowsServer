[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$NssmPath = 'C:\WindowsServerLab\Resources\nssm.exe',
    [string]$ServiceScript = 'C:\WindowsServerLab\Resources\service.ps1',
    [string]$ServiceName = 'PSService'
)

$ErrorActionPreference = 'Stop'

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]::new($identity)
if (!$principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Run this script from an elevated PowerShell session.'
}
if (!(Test-Path -LiteralPath $NssmPath -PathType Leaf)) {
    throw "NSSM was not found at $NssmPath. Obtain it from the official project, verify its SHA-256 hash, and place the reviewed binary at this path."
}
if (!(Test-Path -LiteralPath $ServiceScript -PathType Leaf)) {
    throw "Service script was not found at $ServiceScript. Copy the repository Resources directory first."
}

$existing = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if ($existing) {
    Write-Output "$ServiceName already exists. No installation change was made."
    return
}

$powerShellPath = (Get-Command powershell.exe -ErrorAction Stop).Source
$arguments = "-NoProfile -ExecutionPolicy RemoteSigned -File `"$ServiceScript`""
if ($PSCmdlet.ShouldProcess($ServiceName, 'Install and start sample Windows service through reviewed NSSM binary')) {
    & $NssmPath install $ServiceName $powerShellPath $arguments
    if ($LASTEXITCODE) { throw "NSSM service installation failed with exit code $LASTEXITCODE." }
    & $NssmPath set $ServiceName Start SERVICE_AUTO_START
    if ($LASTEXITCODE) { throw "NSSM startup configuration failed with exit code $LASTEXITCODE." }
    Start-Service -Name $ServiceName
}

Get-CimInstance Win32_Service -Filter "Name='$ServiceName'" |
    Select-Object Name, State, StartMode, StartName, PathName
