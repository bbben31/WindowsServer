[CmdletBinding()]
param(
    [string]$ManifestPath,
    [string]$ServerIsoPath,
    [string]$Windows10IsoPath,
    [string[]]$VmName,
    [string]$ExpectedDnsServer,
    [string]$ExpectedSubnet,
    [string]$AzureSubscriptionId,
    [string]$AzureRegion,
    [string]$AzureResourceGroup,
    [string]$AzureBudgetName,
    [string]$ReportPath,
    [switch]$FailOnWarning
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrWhiteSpace($ManifestPath)) { $ManifestPath = Join-Path $scriptRoot '..\metadata\curriculum-manifest.json' }
$results = [System.Collections.Generic.List[object]]::new()
function Add-Check {
    param([string]$Name, [ValidateSet('Pass','Warning','Error','Skipped')] [string]$Status, [string]$Detail)
    $results.Add([pscustomobject]@{ Name = $Name; Status = $Status; Detail = $Detail })
}

function Test-PathParameter {
    param([string]$Name, [string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path)) {
        Add-Check $Name 'Skipped' 'No path supplied; use an explicit local placeholder when running this check.'
    } elseif ($Path -match '^<.+>$') {
        Add-Check $Name 'Skipped' "Placeholder supplied: $Path"
    } elseif (Test-Path -LiteralPath $Path) {
        Add-Check $Name 'Pass' $Path
    } else {
        Add-Check $Name 'Warning' "Path was not found: $Path"
    }
}

if (Test-Path -LiteralPath $ManifestPath) {
    try {
        $manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
        Add-Check 'Manifest' 'Pass' "$($manifest.entries.Count) curriculum entries loaded."
    } catch {
        Add-Check 'Manifest' 'Error' 'Manifest could not be parsed as JSON.'
    }
} else {
    Add-Check 'Manifest' 'Error' "Manifest was not found: $ManifestPath"
}

$os = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
if ($os) { Add-Check 'Host OS' 'Pass' "$($os.Caption) $($os.Version)" } else { Add-Check 'Host OS' 'Warning' 'CIM OS information is unavailable.' }
$computer = Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue
if ($computer) { Add-Check 'Host virtualization' 'Pass' "Hypervisor-present=$($computer.HypervisorPresent); model=$($computer.Model)" } else { Add-Check 'Host virtualization' 'Warning' 'Computer-system information is unavailable.' }

$vmwareCommands = @('vmrun','vmware.exe','vmnetcfg.exe') | ForEach-Object {
    $command = Get-Command $_ -ErrorAction SilentlyContinue
    if ($command) { $_ }
}
if ($vmwareCommands) { Add-Check 'VMware visibility' 'Pass' ("Visible commands: " + ($vmwareCommands -join ', ')) } else { Add-Check 'VMware visibility' 'Warning' 'VMware CLI/config tools are not on PATH; inspect Virtual Network Editor manually.' }
Test-PathParameter 'Windows Server ISO' $ServerIsoPath
Test-PathParameter 'Windows 10 ISO' $Windows10IsoPath

if ($VmName) {
    foreach ($name in $VmName) {
        if (Get-Command Test-Connection -ErrorAction SilentlyContinue) {
            if (Test-Connection -ComputerName $name -Count 1 -Quiet -ErrorAction SilentlyContinue) { Add-Check "VM reachability: $name" 'Pass' 'Responded to ICMP.' }
            else { Add-Check "VM reachability: $name" 'Warning' 'No ICMP response; the VM may be off or ICMP may be blocked.' }
        }
    }
} else { Add-Check 'VM reachability' 'Skipped' 'No VM names supplied.' }

if ($ExpectedDnsServer) {
    if (Get-Command Resolve-DnsName -ErrorAction SilentlyContinue) {
        try { Resolve-DnsName -Name 'ad.lab.test' -Server $ExpectedDnsServer -ErrorAction Stop | Out-Null; Add-Check 'AD DNS resolution' 'Pass' "ad.lab.test resolved through $ExpectedDnsServer." }
        catch { Add-Check 'AD DNS resolution' 'Warning' "ad.lab.test did not resolve through $ExpectedDnsServer." }
    } else { Add-Check 'AD DNS resolution' 'Warning' 'Resolve-DnsName is unavailable.' }
    if (Get-Command Test-NetConnection -ErrorAction SilentlyContinue) {
        $dnsPort = Test-NetConnection -ComputerName $ExpectedDnsServer -Port 53 -InformationLevel Quiet -WarningAction SilentlyContinue
        Add-Check 'DNS port 53' $(if ($dnsPort) {'Pass'} else {'Warning'}) "$ExpectedDnsServer TCP/53 reachable=$dnsPort"
    }
} else { Add-Check 'AD/DNS checks' 'Skipped' 'Supply -ExpectedDnsServer to test ad.lab.test and DNS port 53.' }

if ($ExpectedSubnet) {
    $addresses = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object IPAddress -like "$($ExpectedSubnet -replace '/.*$','').*"
    Add-Check 'Expected subnet' $(if ($addresses) {'Pass'} else {'Warning'}) "Found $($addresses.Count) local IPv4 address(es) matching the supplied prefix."
} else { Add-Check 'IP/subnet checks' 'Skipped' 'Supply -ExpectedSubnet as a prefix such as 10.10.10.' }

if ($ExpectedDnsServer -and (Get-Command Get-ADDomain -ErrorAction SilentlyContinue)) {
    try { $domain = Get-ADDomain -ErrorAction Stop; Add-Check 'AD domain health' 'Pass' "Connected to $($domain.DNSRoot)." } catch { Add-Check 'AD domain health' 'Warning' 'Active Directory query failed.' }
} else { Add-Check 'AD domain health' 'Skipped' 'Active Directory module or DNS server parameter is unavailable.' }

if ($AzureSubscriptionId -or $AzureRegion -or $AzureResourceGroup -or $AzureBudgetName) {
    $az = Get-Command az -ErrorAction SilentlyContinue
    if (!$az) {
        Add-Check 'Azure CLI' 'Warning' 'Azure parameters were supplied but az.exe is unavailable; no Azure checks ran.'
    } else {
        Add-Check 'Azure CLI' 'Pass' 'Azure CLI is available. No login or mutating command was executed.'
        if ($AzureSubscriptionId) {
            $account = & $az.Source account show --subscription $AzureSubscriptionId --query '{id:id,name:name,user:user.name}' -o json 2>$null
            if ($LASTEXITCODE -eq 0) { Add-Check 'Azure subscription access' 'Pass' 'Subscription metadata was readable; credentials and tokens were not printed.' }
            else { Add-Check 'Azure subscription access' 'Warning' 'Subscription metadata was not readable with the current non-interactive context.' }
        }
        if ($AzureRegion) { Add-Check 'Azure region' 'Pass' "Requested region recorded as $AzureRegion; availability was not changed or assumed." }
        if ($AzureResourceGroup) { Add-Check 'Azure resource group' 'Pass' "Resource group scope recorded as $AzureResourceGroup; no resource changes were made." }
        if ($AzureBudgetName) { Add-Check 'Azure budget' 'Pass' "Budget name recorded as $AzureBudgetName; no budget was created or changed." }
    }
} else { Add-Check 'Azure checks' 'Skipped' 'Supply explicit Azure parameters to run read-only CLI checks; this script never logs in.' }

$results | Format-Table -AutoSize | Out-Host
if ($ReportPath) { $results | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $ReportPath -Encoding utf8; Write-Output "Report written to $ReportPath" }
$hasError = @($results | Where-Object Status -eq 'Error').Count -gt 0
$hasWarning = @($results | Where-Object Status -eq 'Warning').Count -gt 0
if ($hasError -or ($FailOnWarning -and $hasWarning)) { exit 1 }
exit 0
