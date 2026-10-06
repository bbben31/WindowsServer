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
    [string[]]$RetiredVmName,
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
$scriptFile = $MyInvocation.MyCommand.Path
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrWhiteSpace($ManifestPath)) { $ManifestPath = Join-Path $scriptRoot '..\metadata\curriculum-manifest.json' }
$results = [System.Collections.Generic.List[object]]::new()
function Add-Check {
    param([string]$Name, [ValidateSet('Pass','Warning','Error','Skipped')] [string]$Status, [string]$Detail)
    $results.Add([pscustomobject]@{ Name = $Name; Status = $Status; Detail = $Detail })
}

function Resolve-CurriculumRelativePath {
    param([string]$Path, [string]$Root)
    if ([string]::IsNullOrWhiteSpace($Path)) { throw 'A curriculum path must not be blank.' }
    $Path = $Path.Trim()
    if ([IO.Path]::IsPathRooted($Path) -or $Path -match '^[^/\\]+::|^[A-Za-z]:') {
        $absolute = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
    } else {
        $absolute = [IO.Path]::GetFullPath((Join-Path $Root $Path))
    }
    $prefix = $Root.TrimEnd([char[]]'\/') + [IO.Path]::DirectorySeparatorChar
    if (!$absolute.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw 'The curriculum path must remain inside the manifest repository.'
    }
    return $absolute.Substring($prefix.Length).Replace('\', '/')
}

function Test-CurriculumEntryStructure {
    param($Entry)
    $errors = [System.Collections.Generic.List[string]]::new()
    if ($Entry -isnot [pscustomobject]) { return 'Selected curriculum must be a JSON object.' }
    if ($Entry.path -isnot [string] -or [string]::IsNullOrWhiteSpace($Entry.path)) { $errors.Add('path must be a non-empty string.') }
    foreach ($field in @('dependencies','prerequisiteState','networks','permissions','verification','requiredVmsOrTopology','vmTopology','alternativeVmGroups')) {
        if (!$Entry.PSObject.Properties[$field] -or $Entry.$field -isnot [array]) {
            $errors.Add("$field must be a JSON array.")
        }
    }
    foreach ($field in @('dependencies','prerequisiteState','networks','permissions','verification','requiredVmsOrTopology')) {
        if (($field -ne 'requiredVmsOrTopology' -and !@($Entry.$field).Count) -or @($Entry.$field | Where-Object { $_ -isnot [string] -or [string]::IsNullOrWhiteSpace($_) }).Count) {
            $errors.Add("$field must contain non-empty strings.")
        }
    }
    if ($Entry.cleanup -isnot [string] -or [string]::IsNullOrWhiteSpace($Entry.cleanup)) { $errors.Add('cleanup must be a non-empty string.') }
    if ($Entry.azure -isnot [pscustomobject] -or $Entry.azure.required -isnot [bool] -or $Entry.azure.services -isnot [array] -or @($Entry.azure.services | Where-Object { $_ -isnot [string] -or [string]::IsNullOrWhiteSpace($_) }).Count) { $errors.Add('azure requires a boolean required flag and a services array of non-empty strings.') }
    if ($Entry.azure.required -and (!$Entry.azure.services.Count -or $Entry.azure.scope -isnot [string] -or [string]::IsNullOrWhiteSpace($Entry.azure.scope) -or $Entry.azure.region -isnot [string] -or [string]::IsNullOrWhiteSpace($Entry.azure.region))) { $errors.Add('Required Azure access needs services, scope and region.') }
    if ($Entry.outbound -isnot [pscustomobject] -or $Entry.outbound.required -isnot [bool] -or $Entry.outbound.endpoints -isnot [array] -or @($Entry.outbound.endpoints | Where-Object { $_ -isnot [string] -or [string]::IsNullOrWhiteSpace($_) }).Count -or $Entry.outbound.mode -notin @('none','guest-vmnet8','host-browser') -or $Entry.outbound.method -isnot [string] -or [string]::IsNullOrWhiteSpace($Entry.outbound.method)) { $errors.Add('outbound requires a boolean required flag, mode, method and endpoints array of non-empty strings.') }
    if ($Entry.outbound.required -and ($Entry.outbound.mode -eq 'none' -or !@($Entry.outbound.endpoints).Count)) { $errors.Add('Required outbound access needs a mode and endpoints.') }
    if ($Entry.compatibility -isnot [pscustomobject] -or $Entry.compatibility.optional -isnot [bool]) { $errors.Add('compatibility.optional must be a JSON boolean.') }
    if ($Entry.riskCost -isnot [pscustomobject] -or $Entry.riskCost.risk -notin @('low','medium','high') -or $Entry.riskCost.costClass -notin @('local-only','conceptual','optional-azure','cost-gated') -or $Entry.riskCost.cost -isnot [string] -or [string]::IsNullOrWhiteSpace($Entry.riskCost.cost)) { $errors.Add('riskCost requires valid risk, costClass and cost fields.') }
    # Do not interpret malformed collections or member objects after reporting their shape.
    if ($Entry.vmTopology -isnot [array] -or $Entry.requiredVmsOrTopology -isnot [array] -or $Entry.alternativeVmGroups -isnot [array]) { return $errors.ToArray() }
    if (@($Entry.vmTopology | Where-Object { $_ -isnot [pscustomobject] }).Count) { $errors.Add('Each VM must be a JSON object.'); return $errors.ToArray() }
    $names = @($Entry.vmTopology | ForEach-Object guestHostname)
    if (@($names | Group-Object | Where-Object Count -gt 1).Count) { $errors.Add('VM guest hostnames must be unique.') }
    if (($names | Sort-Object) -join '|' -ine (($Entry.requiredVmsOrTopology | Sort-Object) -join '|')) { $errors.Add('requiredVmsOrTopology must match vmTopology guest hostnames.') }
    foreach ($vm in $Entry.vmTopology) {
        if ($vm.guestHostname -isnot [string] -or [string]::IsNullOrWhiteSpace($vm.guestHostname) -or $vm.layer -notin @('outer-vmware','inner-hyper-v') -or $vm.phase -notin @('existing','existing-inner','created','conditional') -or $vm.displayNameAliases -isnot [array] -or @($vm.displayNameAliases | Where-Object { $_ -isnot [string] -or [string]::IsNullOrWhiteSpace($_) }).Count -or ($vm.layer -eq 'outer-vmware' -and ($vm.vmwareDisplayName -isnot [string] -or [string]::IsNullOrWhiteSpace($vm.vmwareDisplayName))) -or ($vm.layer -eq 'inner-hyper-v' -and ($vm.hyperVName -isnot [string] -or [string]::IsNullOrWhiteSpace($vm.hyperVName)))) { $errors.Add('Each VM requires string guest/display names, a valid layer/phase and an aliases array of non-empty strings.') }
        if ($vm.phase -eq 'conditional' -and [string]::IsNullOrWhiteSpace($vm.retirementReason)) { $errors.Add('Conditional VMs require a retirement reason.') }
        foreach ($name in @($vm.guestHostname,$vm.vmwareDisplayName,$vm.hyperVName) + @($vm.displayNameAliases) | Where-Object { $_ }) {
            if (@($Entry.vmTopology | Where-Object { $name -ieq $_.guestHostname -or $name -ieq $_.vmwareDisplayName -or $name -ieq $_.hyperVName -or $name -in $_.displayNameAliases }).Count -ne 1) { $errors.Add("Ambiguous VM display mapping: $name") }
        }
    }
    foreach ($group in $Entry.alternativeVmGroups) {
        if ($group -isnot [pscustomobject] -or $group.names -isnot [array] -or !$group.names.Count -or @($group.names | Where-Object { $_ -isnot [string] -or [string]::IsNullOrWhiteSpace($_) }).Count -or @($group.names | Group-Object | Where-Object Count -gt 1).Count -or ($group.minimum -isnot [int] -and $group.minimum -isnot [long]) -or $group.minimum -lt 1 -or $group.minimum -gt $group.names.Count -or @($group.names | Where-Object { $_ -notin $names }).Count) { $errors.Add('Alternative VM groups require unique valid names and an integer minimum.') }
    }
    if ($Entry.PSObject.Properties['identityTransitions'] -and $Entry.identityTransitions -isnot [array]) { $errors.Add('identityTransitions must be a JSON array when supplied.'); return $errors.ToArray() }
    $laterNames = @($Entry.identityTransitions | ForEach-Object laterGuestHostname)
    if (@($laterNames | Group-Object | Where-Object Count -gt 1).Count) { $errors.Add('Later guest identities must be unique.') }
    foreach ($reuse in $Entry.identityTransitions) {
        $target = @($Entry.vmTopology | Where-Object guestHostname -eq $reuse.initialGuestHostname)
        $identityMappings = @($Entry.vmTopology | Where-Object { $reuse.laterGuestHostname -ieq $_.guestHostname -or $reuse.laterGuestHostname -ieq $_.vmwareDisplayName -or $reuse.laterGuestHostname -ieq $_.hyperVName -or $reuse.laterGuestHostname -in $_.displayNameAliases })
        if ($reuse -isnot [pscustomobject] -or $reuse.initialGuestHostname -isnot [string] -or $reuse.vmwareDisplayName -isnot [string] -or $target.Count -ne 1 -or $target[0].layer -ne 'outer-vmware' -or $target[0].vmwareDisplayName -ine $reuse.vmwareDisplayName -or $reuse.laterGuestHostname -isnot [string] -or [string]::IsNullOrWhiteSpace($reuse.laterGuestHostname) -or $identityMappings.Count -or $reuse.simultaneous -isnot [bool] -or $reuse.simultaneous -or $reuse.trigger -ne 'snapshot-reversion-and-pxe-redeployment' -or $reuse.snapshot -isnot [string] -or [string]::IsNullOrWhiteSpace($reuse.snapshot)) { $errors.Add('Identity transitions must describe one unambiguous sequentially reused outer VMware target.') }
    }
    return $errors.ToArray()
}

function Test-HostProbe {
    param([string]$ProbeName, [scriptblock]$Probe)
    try { & $Probe }
    catch { Add-Check $ProbeName 'Warning' ("Probe unavailable: " + $_.Exception.Message) }
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

$manifest = $null
$manifestReady = $false
$repositoryRoot = $null
$manifestFile = $null
try {
    $manifestFile = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($ManifestPath)
    $repositoryRoot = [IO.Path]::GetFullPath((Join-Path (Split-Path -Parent $manifestFile) '..'))
    if (Test-Path -LiteralPath $ManifestPath -PathType Leaf) {
        $ManifestPath = (Resolve-Path -LiteralPath $ManifestPath).ProviderPath
        $manifest = [IO.File]::ReadAllText($ManifestPath) | ConvertFrom-Json
        if (!$manifest -or ($manifest.schemaVersion -isnot [int] -and $manifest.schemaVersion -isnot [long]) -or $manifest.schemaVersion -ne 3 -or !$manifest.PSObject.Properties['entries'] -or $manifest.entries -isnot [array] -or !$manifest.entries.Count) { throw 'Manifest requires schemaVersion 3 and a non-empty entries array.' }
        $repositoryRoot = [IO.Path]::GetFullPath((Join-Path (Split-Path -Parent $ManifestPath) '..'))
        $manifestReady = $true
        Add-Check 'Manifest' 'Pass' "$($manifest.entries.Count) curriculum entries loaded."
    } else {
        Add-Check 'Manifest' 'Error' "Manifest was not found: $ManifestPath"
    }
} catch {
    Add-Check 'Manifest' 'Error' ("Manifest could not be loaded as curriculum JSON: " + $_.Exception.Message)
}

$selectedEntry = $null
if ([string]::IsNullOrWhiteSpace($CurriculumPath)) {
    Add-Check 'Curriculum selection' 'Error' 'Supply -CurriculumPath with exactly one practice or lab path; curriculum selection is required.'
} elseif (!$manifestReady) {
    Add-Check 'Curriculum selection' 'Skipped' 'Curriculum selection requires a valid manifest.'
} else {
    $normalizedPath = $null
    try { $normalizedPath = Resolve-CurriculumRelativePath $CurriculumPath $repositoryRoot }
    catch { Add-Check 'Curriculum selection' 'Error' ("Invalid curriculum path: " + $_.Exception.Message) }
    $selected = @($manifest.entries | Where-Object { $_.path -ieq $normalizedPath })
    $structureErrors = @()
    if ($selected.Count -eq 1) {
        try { $structureErrors = @(Test-CurriculumEntryStructure $selected[0]) }
        catch { $structureErrors = @('Selected contract validation failed: ' + $_.Exception.Message) }
    }
    if (!$normalizedPath) { }
    elseif ($selected.Count -ne 1) {
        Add-Check 'Curriculum selection' 'Error' "Expected exactly one entry for '$normalizedPath'; found $($selected.Count)."
    } elseif ($structureErrors.Count) {
        Add-Check 'Curriculum selection' 'Error' ("Invalid selected curriculum contract: " + ($structureErrors -join ' '))
    } else {
        $selectedEntry = $selected[0]
        Add-Check 'Curriculum selection' 'Pass' $selectedEntry.path
        $topologyDetail = if (@($selectedEntry.vmTopology).Count) { ($selectedEntry.vmTopology | ForEach-Object { "$($_.guestHostname): VMware display=$($_.vmwareDisplayName); Hyper-V name=$($_.hyperVName); aliases=$($_.displayNameAliases -join ','); layer=$($_.layer); phase=$($_.phase)" }) -join '; ' } else { 'No dedicated guest required; use the declared host/browser/reference context.' }
        Add-Check 'Declared topology' 'Pass' $topologyDetail
        foreach ($reuse in $selectedEntry.identityTransitions) {
            Add-Check 'Machine reuse' 'Pass' "$($reuse.vmwareDisplayName): initial guest=$($reuse.initialGuestHostname); later guest=$($reuse.laterGuestHostname) after snapshot $($reuse.snapshot) and PXE redeployment; one VMware target, no simultaneous second VM."
        }
        Add-Check 'Declared networks' 'Pass' ($selectedEntry.networks -join '; ')
        Add-Check 'Declared permissions' 'Pass' ($selectedEntry.permissions -join '; ')
        Add-Check 'Declared prerequisites' 'Pass' (($selectedEntry.dependencies + $selectedEntry.prerequisiteState) -join '; ')
        Add-Check 'Declared risk/cost' 'Pass' "risk=$($selectedEntry.riskCost.risk); cost=$($selectedEntry.riskCost.costClass); optional=$($selectedEntry.compatibility.optional). $($selectedEntry.riskCost.cost) $($selectedEntry.compatibility.notes)"
        Add-Check 'Declared verification' 'Pass' ($selectedEntry.verification -join '; ')
        Add-Check 'Declared cleanup' 'Pass' $selectedEntry.cleanup
        $completed = @($CompletedPrerequisite | Where-Object { ![string]::IsNullOrWhiteSpace($_) } | ForEach-Object {
            try { Resolve-CurriculumRelativePath $_ $repositoryRoot }
            catch { Add-Check 'Prerequisite evidence' 'Error' ("Invalid completed prerequisite path: " + $_.Exception.Message) }
        })
        $missingDependencies = @($selectedEntry.dependencies | Where-Object { $_ -notin $completed })
        if ($missingDependencies.Count) { Add-Check 'Prerequisite evidence' 'Warning' ("Not confirmed complete: " + ($missingDependencies -join '; ')) }
        else { Add-Check 'Prerequisite evidence' 'Pass' 'All declared prerequisite paths were supplied as completed; role/state requirements still need manual verification.' }
        $suppliedGuestNames = @()
        $probeNames = @{}
        foreach ($name in $VmName) {
            $mapped = @($selectedEntry.vmTopology | Where-Object { $name -ieq $_.guestHostname -or $name -ieq $_.vmwareDisplayName -or $name -ieq $_.hyperVName -or $name -in $_.displayNameAliases })
            $laterIdentities = @($selectedEntry.identityTransitions | Where-Object { $_.laterGuestHostname -ieq $name })
            foreach ($reuse in $laterIdentities) {
                $mapped += @($selectedEntry.vmTopology | Where-Object guestHostname -eq $reuse.initialGuestHostname)
            }
            if ($mapped.Count -eq 1) {
                $guest = $mapped[0].guestHostname
                $suppliedGuestNames += $guest
                if ($laterIdentities.Count) { $probeNames[$guest] = $name }
                elseif (!$probeNames.ContainsKey($guest)) { $probeNames[$guest] = $guest }
            }
            elseif ($mapped.Count -gt 1) { Add-Check 'Supplied VM comparison' 'Error' "Ambiguous display-name mapping: $name" }
            else { Add-Check 'Supplied VM comparison' 'Warning' "VM is not declared for this exercise: $name" }
        }
        $retiredGuests = @()
        foreach ($name in $RetiredVmName) {
            $mapped = @($selectedEntry.vmTopology | Where-Object { $name -ieq $_.guestHostname -or $name -ieq $_.vmwareDisplayName -or $name -ieq $_.hyperVName -or $name -in $_.displayNameAliases })
            if ($mapped.Count -ne 1 -or $mapped[0].phase -ne 'conditional') { Add-Check 'Retirement confirmation' 'Error' "$name is not a declared conditional VM; mandatory and created machines cannot be declared retired."; continue }
            if ($mapped[0].guestHostname -in $suppliedGuestNames) { Add-Check 'Retirement confirmation' 'Error' "$name cannot be supplied and declared retired simultaneously."; continue }
            $retiredGuests += $mapped[0].guestHostname
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
        foreach ($vm in $selectedEntry.vmTopology | Where-Object phase -eq 'conditional') {
            if ($vm.guestHostname -in $suppliedGuestNames) { Add-Check 'Conditional VM' 'Pass' "$($vm.guestHostname) was supplied for the pre-retirement lineage." }
            elseif ($vm.guestHostname -in $retiredGuests) { Add-Check 'Conditional VM' 'Skipped' "$($vm.guestHostname) is explicitly confirmed retired; do not restart it." }
            else { Add-Check 'Conditional VM' 'Warning' "$($vm.guestHostname) is conditional until retired. Supply it or confirm retirement with -RetiredVmName; never restart a retired DC merely to satisfy preflight." }
        }
        foreach ($vm in $selectedEntry.vmTopology | Where-Object phase -eq 'created') { Add-Check 'Created VM' 'Skipped' "$($vm.guestHostname) is created in the designated exercise task, not required to exist during preflight." }
        $VmName = @($suppliedGuestNames | Select-Object -Unique | ForEach-Object { $probeNames[$_] })
        if ($selectedEntry.outbound.required) {
            Add-Check 'Required outbound access' $(if ($OutboundAvailable) { 'Pass' } else { 'Warning' }) ("$($selectedEntry.outbound.method) Endpoints: $($selectedEntry.outbound.endpoints -join '; '). Connectivity is user-reported, not independently verified.")
        } else { Add-Check 'Required outbound access' 'Skipped' 'This exercise declares no online access requirement.' }
    }
}

if (!$SkipHostChecks) {
Test-HostProbe 'Host OS' {
$os = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
if ($os) {
    $hostStatus = if ($os.Caption -match 'Windows 11') { 'Pass' } else { 'Warning' }
    Add-Check 'Host OS' $hostStatus "$($os.Caption) $($os.Version); the supported host baseline is Windows 11."
} else { Add-Check 'Host OS' 'Warning' 'CIM OS information is unavailable.' }
}
Test-HostProbe 'Host virtualization' {
$computer = Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue
$processor = Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue | Select-Object -First 1
if ($computer -and $processor) {
    $virtualizationReady = $processor.VirtualizationFirmwareEnabled -eq $true -and $processor.SecondLevelAddressTranslationExtensions -eq $true
    $virtualizationStatus = if ($virtualizationReady) { 'Pass' } else { 'Warning' }
    Add-Check 'Host virtualization' $virtualizationStatus "Firmware virtualization=$($processor.VirtualizationFirmwareEnabled); SLAT=$($processor.SecondLevelAddressTranslationExtensions); hypervisor-present=$($computer.HypervisorPresent); model=$($computer.Model)."
} else { Add-Check 'Host virtualization' 'Warning' 'Processor or computer-system virtualization information is unavailable.' }
}

Test-HostProbe 'VMware visibility' {
$vmwareCommands = @('vmrun','vmware.exe','vmnetcfg.exe') | ForEach-Object {
    $command = Get-Command $_ -ErrorAction SilentlyContinue
    if ($command) { $_ }
}
if ($vmwareCommands) { Add-Check 'VMware visibility' 'Pass' ("Visible commands: " + ($vmwareCommands -join ', ')) } else { Add-Check 'VMware visibility' 'Warning' 'VMware CLI/config tools are not on PATH; inspect Virtual Network Editor manually.' }
}
Test-HostProbe 'Windows Server ISO' { Test-IsoParameter 'Windows Server ISO' $ServerIsoPath }
Test-HostProbe 'Windows 11 client ISO' { Test-IsoParameter 'Windows 11 client ISO' $ClientIsoPath }

if ($VmName) {
    foreach ($name in $VmName) {
        Test-HostProbe "VM reachability: $name" {
        if (Get-Command Test-Connection -ErrorAction SilentlyContinue) {
            if (Test-Connection -ComputerName $name -Count 1 -Quiet -ErrorAction SilentlyContinue) { Add-Check "VM reachability: $name" 'Pass' 'Responded to ICMP.' }
            else { Add-Check "VM reachability: $name" 'Warning' 'No ICMP response; the VM may be off or ICMP may be blocked.' }
        } else { Add-Check "VM reachability: $name" 'Warning' 'Test-Connection is unavailable.' }
        }
    }
} else { Add-Check 'VM reachability' 'Skipped' 'No VM names supplied.' }

if ($ExpectedDnsServer) {
    if (Get-Command Resolve-DnsName -ErrorAction SilentlyContinue) {
        try { Resolve-DnsName -Name 'ad.lab.test' -Server $ExpectedDnsServer -ErrorAction Stop | Out-Null; Add-Check 'AD DNS resolution' 'Pass' "ad.lab.test resolved through $ExpectedDnsServer." }
        catch { Add-Check 'AD DNS resolution' 'Warning' "ad.lab.test did not resolve through $ExpectedDnsServer." }
    } else { Add-Check 'AD DNS resolution' 'Warning' 'Resolve-DnsName is unavailable.' }
    if (Get-Command Test-NetConnection -ErrorAction SilentlyContinue) {
        Test-HostProbe 'DNS port 53' {
        $dnsPort = Test-NetConnection -ComputerName $ExpectedDnsServer -Port 53 -InformationLevel Quiet -WarningAction SilentlyContinue
        Add-Check 'DNS port 53' $(if ($dnsPort) {'Pass'} else {'Warning'}) "$ExpectedDnsServer TCP/53 reachable=$dnsPort"
        }
    } else { Add-Check 'DNS port 53' 'Warning' 'Test-NetConnection is unavailable.' }
} else { Add-Check 'AD/DNS checks' 'Skipped' 'Supply -ExpectedDnsServer to test ad.lab.test and DNS port 53.' }

if ($ExpectedSubnet) {
    if ($ExpectedSubnet -notmatch '^\d{1,3}(\.\d{1,3}){3}/\d{1,2}$' -or !(Test-IPv4InCidr -Address ($ExpectedSubnet -split '/')[0] -Cidr $ExpectedSubnet)) {
        Add-Check 'Expected subnet' 'Error' 'Use CIDR notation, for example 10.10.10.0/24.'
    }
    else {
        Test-HostProbe 'Expected subnet' {
        $addresses = @(Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
            Where-Object { Test-IPv4InCidr -Address $_.IPAddress -Cidr $ExpectedSubnet })
        Add-Check 'Expected subnet' $(if ($addresses.Count) {'Pass'} else {'Warning'}) "Found $($addresses.Count) local IPv4 address(es) in $ExpectedSubnet."
        }
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

if ($ReportPath) {
    try {
        $reportFile = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($ReportPath)
        if ($reportFile -ieq $manifestFile -or $reportFile -ieq $scriptFile) { throw 'ReportPath must not overwrite the input manifest or preflight script.' }
        if ($CurriculumPath -and $repositoryRoot) {
            $curriculumFile = if ([IO.Path]::IsPathRooted($CurriculumPath) -or $CurriculumPath -match '^[^/\\]+::|^[A-Za-z]:') { $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($CurriculumPath) } else { [IO.Path]::GetFullPath((Join-Path $repositoryRoot $CurriculumPath)) }
            if ($reportFile -ieq $curriculumFile) { throw 'ReportPath must not overwrite the selected curriculum input.' }
        }
        [IO.File]::WriteAllText($reportFile, (ConvertTo-Json -InputObject $results.ToArray() -Depth 6), [Text.UTF8Encoding]::new($false))
        Write-Verbose "Report written to $ReportPath"
    } catch { Add-Check 'Report output' 'Error' ("Report could not be written: " + $_.Exception.Message) }
}
if ($AsJson) { ConvertTo-Json -InputObject $results.ToArray() -Depth 6 }
else { $results | Format-List Name, Status, Detail | Out-Host }
$hasError = @($results | Where-Object Status -eq 'Error').Count -gt 0
$hasWarning = @($results | Where-Object Status -eq 'Warning').Count -gt 0
if ($hasError -or ($FailOnWarning -and $hasWarning)) { exit 1 }
exit 0
