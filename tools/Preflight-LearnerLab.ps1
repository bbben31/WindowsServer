[CmdletBinding()]
param(
    [string]$ManifestPath,
    [string]$CurriculumPath,
    [string[]]$CompletedPrerequisite,
    [switch]$OutboundAvailable,
    [switch]$SkipHostChecks,
    [switch]$AsJson,
    [string]$ServerIsoPath,
    [Alias('Windows10IsoPath')]
    [string]$ClientIsoPath,
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

$ErrorActionPreference = 'Stop'
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

function Test-IsoParameter {
    param([string]$Name, [string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path)) {
        Add-Check $Name 'Skipped' 'No ISO path supplied.'
        return
    }
    if ($Path -match '^<.+>$') {
        Add-Check $Name 'Skipped' "Placeholder supplied: $Path"
        return
    }
    if (!(Test-Path -LiteralPath $Path -PathType Leaf)) {
        Add-Check $Name 'Error' "ISO was not found: $Path"
        return
    }
    $item = Get-Item -LiteralPath $Path
    if ($item.Extension -ine '.iso') {
        Add-Check $Name 'Error' "Expected an .iso file: $Path"
        return
    }
    if ($item.Length -lt 1GB) {
        Add-Check $Name 'Warning' "The file is smaller than 1 GB; verify that it is complete: $Path"
        return
    }
    Add-Check $Name 'Pass' "$Path ($([math]::Round($item.Length / 1GB, 2)) GB). Record its SHA-256 in private lab notes."
}

function Test-IPv4InCidr {
    param([string]$Address, [string]$Cidr)
    if ($Cidr -notmatch '^(.+)/(\d{1,2})$') { return $false }
    $networkAddress = $null
    $candidateAddress = $null
    if (![Net.IPAddress]::TryParse($Matches[1], [ref]$networkAddress) -or
        ![Net.IPAddress]::TryParse($Address, [ref]$candidateAddress)) { return $false }
    $network = $networkAddress.GetAddressBytes()
    $prefixLength = [int]$Matches[2]
    $candidate = $candidateAddress.GetAddressBytes()
    if ($network.Length -ne 4 -or $candidate.Length -ne 4 -or $prefixLength -lt 0 -or $prefixLength -gt 32) { return $false }
    $wholeBytes = [math]::Floor($prefixLength / 8)
    $remainingBits = $prefixLength % 8
    for ($index = 0; $index -lt $wholeBytes; $index++) {
        if ($network[$index] -ne $candidate[$index]) { return $false }
    }
    if ($remainingBits) {
        $mask = [byte](256 - [math]::Pow(2, 8 - $remainingBits))
        if (($network[$wholeBytes] -band $mask) -ne ($candidate[$wholeBytes] -band $mask)) { return $false }
    }
    return $true
}

if (Test-Path -LiteralPath $ManifestPath) {
    try {
        $manifest = [IO.File]::ReadAllText((Resolve-Path -LiteralPath $ManifestPath).Path) | ConvertFrom-Json
        Add-Check 'Manifest' 'Pass' "$($manifest.entries.Count) curriculum entries loaded."
    } catch {
        Add-Check 'Manifest' 'Error' 'Manifest could not be parsed as JSON.'
    }
} else {
    Add-Check 'Manifest' 'Error' "Manifest was not found: $ManifestPath"
}

$selectedEntry = $null
if ([string]::IsNullOrWhiteSpace($CurriculumPath)) {
    Add-Check 'Curriculum selection' 'Error' 'Supply -CurriculumPath with exactly one practice or lab path; curriculum selection is required.'
} else {
    $normalizedPath = $CurriculumPath.Replace('\', '/').TrimStart('.', '/')
    $repositoryRoot = [IO.Path]::GetFullPath((Join-Path (Split-Path -Parent $ManifestPath) '..'))
    if ([IO.Path]::IsPathRooted($CurriculumPath)) {
        $absolute = [IO.Path]::GetFullPath($CurriculumPath)
        if ($absolute.StartsWith($repositoryRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
            $normalizedPath = $absolute.Substring($repositoryRoot.Length + 1).Replace('\','/')
        }
    }
    $selected = @($manifest.entries | Where-Object { $_.path -ieq $normalizedPath })
    if ($selected.Count -ne 1) {
        Add-Check 'Curriculum selection' 'Error' "Expected exactly one entry for '$normalizedPath'; found $($selected.Count)."
    } else {
        $selectedEntry = $selected[0]
        Add-Check 'Curriculum selection' 'Pass' $selectedEntry.path
        $topologyDetail = if (@($selectedEntry.vmTopology).Count) { ($selectedEntry.vmTopology | ForEach-Object { "$($_.guestHostname): VMware display=$($_.vmwareDisplayName); Hyper-V name=$($_.hyperVName); aliases=$($_.displayNameAliases -join ','); layer=$($_.layer); phase=$($_.phase)" }) -join '; ' } else { 'No dedicated guest required; use the declared host/browser/reference context.' }
        Add-Check 'Declared topology' 'Pass' $topologyDetail
        Add-Check 'Declared networks' 'Pass' ($selectedEntry.networks -join '; ')
        Add-Check 'Declared permissions' 'Pass' ($selectedEntry.permissions -join '; ')
        Add-Check 'Declared prerequisites' 'Pass' (($selectedEntry.dependencies + $selectedEntry.prerequisiteState) -join '; ')
        Add-Check 'Declared risk/cost' 'Pass' "risk=$($selectedEntry.riskCost.risk); cost=$($selectedEntry.riskCost.costClass); optional=$($selectedEntry.compatibility.optional). $($selectedEntry.riskCost.cost) $($selectedEntry.compatibility.notes)"
        Add-Check 'Declared verification' 'Pass' ($selectedEntry.verification -join '; ')
        Add-Check 'Declared cleanup' 'Pass' $selectedEntry.cleanup
        $completed = @($CompletedPrerequisite | Where-Object { ![string]::IsNullOrWhiteSpace($_) } | ForEach-Object { $_.Replace('\','/').TrimStart('.', '/') })
        $missingDependencies = @($selectedEntry.dependencies | Where-Object { $_ -notin $completed })
        if ($missingDependencies.Count) { Add-Check 'Prerequisite evidence' 'Warning' ("Not confirmed complete: " + ($missingDependencies -join '; ')) }
        else { Add-Check 'Prerequisite evidence' 'Pass' 'All declared prerequisite paths were supplied as completed; role/state requirements still need manual verification.' }
        $suppliedGuestNames = @()
        foreach ($name in $VmName) {
            $mapped = @($selectedEntry.vmTopology | Where-Object { $name -ieq $_.guestHostname -or $name -ieq $_.vmwareDisplayName -or $name -ieq $_.hyperVName -or $name -in $_.displayNameAliases })
            if ($mapped.Count -eq 1) { $suppliedGuestNames += $mapped[0].guestHostname }
            elseif ($mapped.Count -gt 1) { Add-Check 'Supplied VM comparison' 'Error' "Ambiguous display-name mapping: $name" }
            else { Add-Check 'Supplied VM comparison' 'Warning' "VM is not declared for this exercise: $name" }
        }
        $alternatives = @($selectedEntry.alternativeVmGroups | ForEach-Object { $_.names })
        $requiredNow = @($selectedEntry.vmTopology | Where-Object { $_.phase -notin @('created','conditional') -and $_.guestHostname -notin $alternatives } | ForEach-Object guestHostname)
        $missingNames = @($requiredNow | Where-Object { $_ -notin $suppliedGuestNames })
        if ($missingNames.Count) { Add-Check 'Required VMs' 'Warning' ("Missing supplied guest names: " + ($missingNames -join ', ')) }
        else { Add-Check 'Required VMs' 'Pass' 'Supplied names cover all pre-existing non-alternative machines; this does not verify their installed roles.' }
        foreach ($group in $selectedEntry.alternativeVmGroups) {
            $present = @($group.names | Where-Object { $_ -in $suppliedGuestNames }).Count
            Add-Check 'Alternative VM group' $(if ($present -ge $group.minimum) { 'Pass' } else { 'Warning' }) "Need $($group.minimum) of [$($group.names -join ', ')]; supplied=$present. $($group.reason)"
        }
        foreach ($vm in $selectedEntry.vmTopology | Where-Object { $_.phase -eq 'conditional' -and $_.guestHostname -notin $suppliedGuestNames }) {
            Add-Check 'Conditional VM' 'Warning' "$($vm.guestHostname) is required only in the documented pre-retirement DC lineage. Confirm that it is retired or supply its name; never restart a retired DC merely to satisfy preflight."
        }
        $VmName = @($suppliedGuestNames | Select-Object -Unique)
        if ($selectedEntry.outbound.required) {
            Add-Check 'Required outbound access' $(if ($OutboundAvailable) { 'Pass' } else { 'Warning' }) ("$($selectedEntry.outbound.method) Endpoints: $($selectedEntry.outbound.endpoints -join '; '). Connectivity is user-reported, not independently verified.")
        } else { Add-Check 'Required outbound access' 'Skipped' 'This exercise declares no online access requirement.' }
    }
}

if (!$SkipHostChecks) {
$os = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
if ($os) {
    $hostStatus = if ($os.Caption -match 'Windows 11') { 'Pass' } else { 'Warning' }
    Add-Check 'Host OS' $hostStatus "$($os.Caption) $($os.Version); the supported host baseline is Windows 11."
} else { Add-Check 'Host OS' 'Warning' 'CIM OS information is unavailable.' }
$computer = Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue
$processor = Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue | Select-Object -First 1
if ($computer -and $processor) {
    $virtualizationReady = $processor.VirtualizationFirmwareEnabled -eq $true -and $processor.SecondLevelAddressTranslationExtensions -eq $true
    $virtualizationStatus = if ($virtualizationReady) { 'Pass' } else { 'Warning' }
    Add-Check 'Host virtualization' $virtualizationStatus "Firmware virtualization=$($processor.VirtualizationFirmwareEnabled); SLAT=$($processor.SecondLevelAddressTranslationExtensions); hypervisor-present=$($computer.HypervisorPresent); model=$($computer.Model)."
} else { Add-Check 'Host virtualization' 'Warning' 'Processor or computer-system virtualization information is unavailable.' }

$vmwareCommands = @('vmrun','vmware.exe','vmnetcfg.exe') | ForEach-Object {
    $command = Get-Command $_ -ErrorAction SilentlyContinue
    if ($command) { $_ }
}
if ($vmwareCommands) { Add-Check 'VMware visibility' 'Pass' ("Visible commands: " + ($vmwareCommands -join ', ')) } else { Add-Check 'VMware visibility' 'Warning' 'VMware CLI/config tools are not on PATH; inspect Virtual Network Editor manually.' }
Test-IsoParameter 'Windows Server ISO' $ServerIsoPath
Test-IsoParameter 'Windows 11 client ISO' $ClientIsoPath

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
    if ($ExpectedSubnet -notmatch '^\d{1,3}(\.\d{1,3}){3}/\d{1,2}$') {
        Add-Check 'Expected subnet' 'Error' 'Use CIDR notation, for example 10.10.10.0/24.'
    }
    else {
        $addresses = @(Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
            Where-Object { Test-IPv4InCidr -Address $_.IPAddress -Cidr $ExpectedSubnet })
        Add-Check 'Expected subnet' $(if ($addresses.Count) {'Pass'} else {'Warning'}) "Found $($addresses.Count) local IPv4 address(es) in $ExpectedSubnet."
    }
} else { Add-Check 'IP/subnet checks' 'Skipped' 'Supply -ExpectedSubnet in CIDR notation, for example 10.10.10.0/24.' }

Add-Check 'AD domain health' 'Skipped' 'Authenticated AD queries are outside this preflight. Perform the declared dcdiag/repadmin checks separately in an authorized guest session.'
} else { Add-Check 'Host probes' 'Skipped' 'Host/network probes disabled; curriculum requirements are still reported.' }

if ($selectedEntry -and $selectedEntry.azure.required) {
    Add-Check 'Declared Azure requirements' 'Pass' "$($selectedEntry.azure.services -join '; '); $($selectedEntry.azure.scope); $($selectedEntry.azure.region). No authentication or resource query is performed."
    $azureValues = [ordered]@{ Subscription = $AzureSubscriptionId; Region = $AzureRegion; ResourceGroup = $AzureResourceGroup; Budget = $AzureBudgetName }
    foreach ($item in $azureValues.GetEnumerator()) {
        if ([string]::IsNullOrWhiteSpace($item.Value)) { Add-Check "Azure $($item.Key)" 'Error' 'This Azure-required exercise needs an explicit value or an intentional angle-bracket placeholder.' }
        elseif ($item.Value.Trim() -match '^<[^<>]+>$') { Add-Check "Azure $($item.Key)" 'Skipped' 'Placeholder supplied; no identifier validation, authentication or resource query was attempted.' }
        elseif ($item.Key -eq 'Subscription') {
            $parsedId = [guid]::Empty
            if (![guid]::TryParse($item.Value, [ref]$parsedId) -or $parsedId -eq [guid]::Empty) { Add-Check 'Azure Subscription' 'Error' 'Subscription must be a non-empty GUID or an angle-bracket placeholder.' }
            else { Add-Check 'Azure Subscription' 'Pass' 'Subscription identifier format recorded privately; access was not authenticated or verified.' }
        } else { Add-Check "Azure $($item.Key)" 'Pass' 'Explicit value supplied; existence, permissions and price must be verified separately before execution.' }
    }
} else { Add-Check 'Azure checks' 'Skipped' 'No Azure-required exercise selected. Optional Azure work must use its separate Azure-required practice contract.' }

if ($AsJson) { $results | ConvertTo-Json -Depth 6 }
else { $results | Format-List Name, Status, Detail | Out-Host }
if ($ReportPath) { $results | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $ReportPath -Encoding utf8; Write-Verbose "Report written to $ReportPath" }
$hasError = @($results | Where-Object Status -eq 'Error').Count -gt 0
$hasWarning = @($results | Where-Object Status -eq 'Warning').Count -gt 0
if ($hasError -or ($FailOnWarning -and $hasWarning)) { exit 1 }
exit 0
