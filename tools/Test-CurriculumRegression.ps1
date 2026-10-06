[CmdletBinding()]
param([string]$RepositoryRoot)
$ErrorActionPreference = 'Stop'
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
if (!$RepositoryRoot) { $RepositoryRoot = Split-Path $scriptRoot -Parent }
$RepositoryRoot = (Resolve-Path -LiteralPath $RepositoryRoot).ProviderPath
if ($RepositoryRoot.Length -gt [IO.Path]::GetPathRoot($RepositoryRoot).Length) { $RepositoryRoot = $RepositoryRoot.TrimEnd([char[]]'\/') }
. (Join-Path $scriptRoot 'Test-CurriculumRules.ps1')
$manifest = [IO.File]::ReadAllText((Join-Path $RepositoryRoot 'metadata\curriculum-manifest.json')) | ConvertFrom-Json
$baselineErrors = @(Test-CurriculumRules $manifest.entries $RepositoryRoot)
if ($baselineErrors.Count) { throw "Baseline rules failed: $($baselineErrors -join '; ')" }
& (Join-Path $scriptRoot 'Test-MarkdownValidationRegression.ps1') -RepositoryRoot $RepositoryRoot
$tempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
$fixtureRoot = Join-Path $tempRoot ('WindowsServer-curriculum-test-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $fixtureRoot | Out-Null
$utf8 = New-Object Text.UTF8Encoding($false)
$passed = 0
try {
    Copy-Item -LiteralPath (Join-Path $RepositoryRoot 'Instructions') -Destination $fixtureRoot -Recurse
    New-Item -ItemType Directory -Path (Join-Path $fixtureRoot 'metadata') | Out-Null
    Copy-Item -LiteralPath (Join-Path $RepositoryRoot 'metadata/curriculum-source.json') -Destination (Join-Path $fixtureRoot 'metadata/curriculum-source.json')
    $entry = $manifest.entries | Where-Object path -eq 'Instructions/Labs/BranchCache.md'
    $entryJson = $entry | ConvertTo-Json -Depth 24
    $documentPath = Join-Path $fixtureRoot $entry.path
    $original = [IO.File]::ReadAllText($documentPath).Replace("`r`n","`n")
    $cases = @(
        @{ Name='invalid Windows VMnet metadata'; Expect='VMnet identifier outside Windows Workstation range'; Edit={param($e) $e.networks+= 'VMnet20 for server workloads'} },
        @{ Name='invalid Windows VMnet procedure'; Expect='VMnet identifier outside Windows Workstation range'; Append="`nAttach the workload NIC to VMnet30.`n" },
        @{ Name='local Azure cleanup'; Expect='non-Azure entry has Azure-only cleanup'; Edit={param($e) $e.cleanup='Deallocate/delete disposable Azure resources and verify the lab resource group is empty.'} },
        @{ Name='Azure guidance'; Expect='Azure entry lacks cost and cleanup guidance'; Edit={param($e) $e.azure.required=$true; $e.riskCost.cost='free'; $e.cleanup=''} },
        @{ Name='duplicate Required VMs'; Expect='duplicate Required VMs'; Text={param($t) $t.Replace("* CL3`n","* CL3`n* CL3`n")} },
        @{ Name='missing task VM'; Expect='task/setup VM absent from Required VMs'; Append="`nPerform this task on VN1-SRV99.`n" },
        @{ Name='reference exemption target'; Expect='operational task/setup VM absent from Required VMs'; Edit={param($e) $e.referencedVms+= [pscustomobject]@{name='VN1-SRV99';reason='Example output only'}}; Append="`nPerform this task on VN1-SRV99.`n" },
        @{ Name='outer Hyper-V'; Expect='outer Hyper-V management'; Append="`n````powershell`nStop-VM -Name WIN-CL3`n`````n" },
        @{ Name='Hyper-V lab outer target'; Expect='outer VMware VM targeted by Hyper-V management'; Edit={param($e) $e.hyperVTeaching=$true; $e.prerequisiteState+= 'Commands must run in a nested host.'}; Append="`n~~~powershell`nStop-VM -Name 'WIN-CL3'`n~~~`n" },
        @{ Name='WAC target'; Expect='adjacent Windows Admin Center targets mismatch'; Append="`n1. In Windows Admin Center, on the connections page, click **vn1-srv10.ad.lab.test**.`n1. Connected to vn1-srv4.ad.lab.test, under **Tools**, click **Roles & features**.`n" },
        @{ Name='invalid domain'; Expect='known invalid domain'; Append="`n<!-- https://admincenter.smart.etc -->`n" },
        @{ Name='wrong child domain'; Expect='known invalid domain'; Append="`nConnect to clients.ad.contoso.com.`n" },
        @{ Name='reversed child domain'; Expect='known invalid domain'; Append="`nConnect to ad.clients.lab.test.`n" },
        @{ Name='merged endpoint'; Expect='malformed combined outbound endpoint'; Edit={param($e) $e.outbound.endpoints=@('public name resolution onlyOfficial Microsoft ADMT download')} },
        @{ Name='admin permissions'; Expect='administrative commands paired only with standard-user permissions'; Edit={param($e) $e.permissions=@('Standard lab user')}; Append="`nNew-NetLbfoTeam -Name Test -TeamMembers Ethernet1,Ethernet2`n" },
        @{ Name='outbound omission'; Expect='download/install without declared outbound access'; Append="`nInstall-Module Microsoft.Graph.Authentication -Scope CurrentUser`n" },
        @{ Name='shared RSAT download omission'; Expect='download/install without declared outbound access'; Append="`nRun C:\WindowsServerLab\Resources\Solutions\Install-RemoteServerAdministrationTools.ps1 during setup.`n" },
        @{ Name='required outbound missing cleanup'; Expect='incomplete outbound access/cleanup contract'; Edit={param($e) $e.outbound.required=$true; $e.outbound.mode='guest-vmnet8'; $e.outbound.endpoints=@('https://www.powershellgallery.com'); $e.networks+= 'Temporary VMnet8 NAT for PowerShell Gallery'; $e.cleanup='Restore guest settings. VMnet8 was used for downloads.'} },
        @{ Name='non-required outbound cleanup'; Expect='non-required outbound access has unconditional or undocumented network cleanup'; Edit={param($e) $e.cleanup='Remove temporary VMnet8 access and restore recorded DNS.'} },
        @{ Name='non-required procedure cleanup'; Expect='non-required outbound access has unconditional or undocumented network cleanup'; Append="`n## Cleanup`nDisconnect temporary NAT access.`n" },
        @{ Name='undocumented conditional cleanup'; Expect='non-required outbound access has unconditional or undocumented network cleanup'; Edit={param($e) $e.cleanup='If temporary VMnet8 access was attached, disconnect it.'} },
        @{ Name='non-optional generic warning'; Expect='non-optional entry has generic optional-product compatibility warning'; Edit={param($e) $e.compatibility.optional=$false; $e.compatibility.notes='Verify current support for optional products before execution.'} },
        @{ Name='doubled topology separator'; Expect='doubled topology separator spaces'; Text={param($t) $t.Replace('**Machines and network profile:** ', '**Machines and network profile:** A.  ')} },
        @{ Name='doubled punctuation'; Expect='doubled punctuation in generated contract'; Text={param($t) $t.Replace('**Machines and network profile:** ', '**Machines and network profile:** Reference.. ')} },
        @{ Name='duplicate cost wording'; Expect='duplicated cost-class wording in generated contract'; Text={param($t) [regex]::Replace($t, '(?m)^\*\*Risk, cost and optional status:\*\*.*$', '**Risk, cost and optional status:** low; local-only; optional=false. local-only')} },
        @{ Name='invalid outbound mode'; Expect='invalid outbound access mode'; Edit={param($e) $e.outbound.mode='unknown'} },
        @{ Name='filter vocabulary'; Expect='invalid manifest filter value'; Edit={param($e) $e.riskCost.costClass='unrecognized'} },
        @{ Name='boolean flags'; Expect='filter flags must be JSON booleans'; Edit={param($e) $e.compatibility.optional='true'} },
        @{ Name='external workaround'; Expect='external known issue lacks local adapted explanation'; Append="`n<https://github.com/EnterpriseTrainingCenter/WindowsServer/issues/201>`n" }
    )
    foreach ($case in $cases) {
        $candidate = $entryJson | ConvertFrom-Json
        $text = $original
        if ($case.Text) { $text = & $case.Text $text }
        if ($case.Append) { $text += $case.Append }
        if ($case.Edit) { & $case.Edit $candidate }
        [IO.File]::WriteAllText($documentPath, $text, $utf8)
        $errors = @(Test-CurriculumRules @($candidate) $fixtureRoot)
        if (!@($errors | Where-Object { $_ -like ('*' + $case.Expect + '*') }).Count) { throw "Mutation escaped its intended detector: $($case.Name). Actual errors: $($errors -join '; ')" }
        $passed++
    }
    [IO.File]::WriteAllText($documentPath, $original, $utf8)
    foreach ($punctuation in @('.', ',', ';', ':')) {
        foreach ($ticks in @('`', '``')) {
            $good = 'Navigate to ' + $ticks + '\\server\share' + $ticks + $punctuation
            $bad = 'Navigate to ' + $ticks + '\\server\share' + $punctuation + $ticks
            if (@(Test-CurriculumSemantics $entry $good).Count) { throw 'Valid UNC punctuation rejected' }
            if (!@(Test-CurriculumSemantics $entry $bad | Where-Object { $_ -like '*sentence punctuation inside inline UNC path*' }).Count) { throw 'UNC punctuation mutation escaped' }
            $passed += 2
        }
    }
    $semanticCases = @(
        @{Path='Instructions/Labs/Multi-domain-environments.md';Name='child promotion prose target';From='Install a child domain **clients** with the parent domain **ad.lab.test** on VN1-SRV7.';To='Install a child domain **clients** with the parent domain **ad.lab.test** on PM-SRV1.';Expected='domain promotion prose/command/subsection target conflict'},
        @{Path='Instructions/Labs/Multi-domain-environments.md';Name='tree promotion prose target';From='Install a new tree **extranet.lab.test** with the parent domain **ad.lab.test** on PM-SRV1.';To='Install a new tree **extranet.lab.test** with the parent domain **ad.lab.test** on VN1-SRV7.';Expected='domain promotion prose/command/subsection target conflict'},
        @{Path='Instructions/Labs/Multi-domain-environments.md';Name='child promotion command target';From='-ComputerName VN1-SRV7.ad.lab.test';To='-ComputerName PM-SRV1.ad.lab.test';Expected='domain deployment identity disagrees with metadata'},
        @{Path='Instructions/Labs/Multi-domain-environments.md';Name='child promotion GUI target';From='Configuration required for Active Directory Domain Services at VN1-SRV7';To='Configuration required for Active Directory Domain Services at PM-SRV1';Expected='domain promotion prose/command/subsection target conflict'},
        @{Path='Instructions/Labs/Multi-domain-environments.md';Name='child domain name';From='-NewDomainName clients';To='-NewDomainName extranet.lab.test';Expected='domain deployment identity disagrees with metadata'},
        @{Path='Instructions/Labs/Multi-domain-environments.md';Name='wrong parent domain';From='-ParentDomainName ad.lab.test';To='-ParentDomainName clients.ad.lab.test';Expected='domain deployment identity disagrees with metadata'},
        @{Path='Instructions/Labs/Multi-domain-environments.md';Name='child/tree domain type swap';From='-DomainType ChildDomain';To='-DomainType TreeDomain';Expected='domain deployment identity disagrees with metadata'},
        @{Path='Instructions/Labs/Multi-domain-environments.md';Name='child/tree server swap';From='VN1-SRV7';To='PM-SRV1';Expected='domain deployment identity disagrees with metadata'},
        @{Path='Instructions/Labs/Multi-domain-environments.md';Name='tree/child server swap';From='PM-SRV1';To='VN1-SRV7';Expected='domain deployment identity disagrees with metadata'},
        @{Path='Instructions/Labs/Multi-domain-environments.md';Name='Marketing share punctuation';From='`\\VN1-SRV10\Marketing`.';To='`\\VN1-SRV10\Marketing.`';Expected='sentence punctuation inside inline UNC path'},
        @{Path='Instructions/Labs/Multi-domain-environments.md';Name='UNC hostname punctuation';From='`\\VN1-SRV10.ad.lab.test`.';To='`\\VN1-SRV10.ad.lab.test.`';Expected='sentence punctuation inside inline UNC path'},
        @{Path='Instructions/Labs/Managing-hybrid-servers-using-Azure-Arc.md';Name='Arc portal target';From='VN1-SRV8';To='VN1-SRV5';Expected='undeclared operational or unscoped VM VN1-SRV5'},
        @{Path='Instructions/Labs/Deploying-domain-controllers.md';Name='old DNS machine label';From='10.1.2.8 (VN2-SRV1)';To='10.1.2.8 (VN1-SRV2)';Expected='incorrect machine/address association'},
        @{Path='Instructions/Labs/Deploying-domain-controllers.md';Name='wrong declared DNS machine';From='10.1.2.8 (VN2-SRV1)';To='10.1.2.8 (VN1-SRV4)';Expected='incorrect machine/address association'},
        @{Path='Instructions/Labs/Storage-Replica-and-stretched-cluster.md';Name='wrong site node';From='**VN3-SRV1** to the site **Secondary**';To='**VN3-SRV2** to the site **Secondary**';Expected='undeclared operational or unscoped VM VN3-SRV2'},
        @{Path='Instructions/Labs/Storage-Replica-and-stretched-cluster.md';Name='three-octet cluster address';From='IP addresses 10.1.2.9 and 10.1.3.9';To='IP addresses 10.1.2.9 and 10.3.9';Expected='malformed IPv4 address in address context'},
        @{Path='Instructions/Labs/Storage-Replica-and-stretched-cluster.md';Name='wrong cluster name in prose';From='name **VN2-VN3-CLST1**';To='name **VN2-VN3-CLST**';Expected='cluster name in prose disagrees'},
        @{Path='Instructions/Labs/Storage-Replica-and-stretched-cluster.md';Name='wrong complete cluster address';From='-StaticAddress 10.1.2.9, 10.1.3.9';To='-StaticAddress 10.1.2.9, 10.1.2.10';Expected='cluster creation identity disagrees'},
        @{Path='Instructions/Labs/Storage-Replica-and-stretched-cluster.md';Name='wrong declared site node';From='Set-ClusterFaultDomain -Name VN3-SRV1 -Parent Secondary';To='Set-ClusterFaultDomain -Name VN1-SRV5 -Parent Secondary';Expected='cluster site assignment disagrees'},
        @{Path='Instructions/Labs/Storage-Replica-and-stretched-cluster.md';Name='wrong site subnet';From='VN3-SRV1 to Secondary (10.1.3.0/24)';To='VN3-SRV1 to Secondary (10.1.2.0/24)';Expected='cluster site subnet disagrees'},
        @{Path='Instructions/Labs/Storage-Replica-and-stretched-cluster.md';Name='wrong preferred site';From=".PreferredSite = 'Primary'";To=".PreferredSite = 'Secondary'";Expected='cluster preferred site disagrees'},
        @{Path='Instructions/Practices/Verify-DHCP-functionality.md';Name='excluded DHCP continuation';From='On **VN1-SRV1**, **VN1-SRV3**, **VN1-SRV4**, **VN1-SRV5**, **VN1-SRV11**, **VN1-SRV12**, and **VN1-SRV13**: After';To='On **VN1-SRV1**, **VN1-SRV3**, **VN1-SRV4**, **VN1-SRV5**, **VN1-SRV11**, **VN1-SRV12**, and **VN1-SRV7**: After';Expected='excluded machine later included'},
        @{Path='Instructions/Practices/Verify-DHCP-functionality.md';Name='missing processed DHCP machine';From='On **VN1-SRV1**, **VN1-SRV3**, **VN1-SRV4**, **VN1-SRV5**, **VN1-SRV11**, **VN1-SRV12**, and **VN1-SRV13**: After';To='On **VN1-SRV3**, **VN1-SRV4**, **VN1-SRV5**, **VN1-SRV11**, **VN1-SRV12**, and **VN1-SRV13**: After';Expected='continuation machines do not match'},
        @{Path='Instructions/Practices/Explore-intra-site-replication.md';Name='unprovisioned replication partner';From='| [live partner] | [selected controller] |';To='| PM-SRV1 | VN1-SRV5 |';Expected='undeclared operational or unscoped VM PM-SRV1'},
        @{Path='Instructions/Practices/Explore-intra-site-replication.md';Name='uncreated child-domain partner';From='| [live partner] | [selected controller] |';To='| VN1-SRV7 | VN1-SRV5 |';Expected='undeclared operational or unscoped VM VN1-SRV7'},
        @{Path='Instructions/Practices/Explore-intra-site-replication.md';Name='uncreated second-site partner';From='| [live partner] | [selected controller] |';To='| VN2-SRV5 | VN1-SRV5 |';Expected='undeclared operational or unscoped VM VN2-SRV5'},
        @{Path='Instructions/Labs/Installing-and-configuring-a-fail-over-cluster.md';Name='existing but wrong task anchor';From='[Create a failover cluster](#task-4-create-a-failover-cluster)';To='[Create a failover cluster](#task-4-create-a-virtual-machine)';Expected='semantically wrong outline anchor'},
        @{Path='Instructions/Labs/Active-Directory-Rights-Management-Service.md';Name='repeated RMS role target';From='on **VN2-SRV1** and **VN2-SRV2**';To='on **VN2-SRV1** and **VN2-SRV1**';Expected='repeated machine where distinct targets'},
        @{Path='Instructions/Labs/Active-Directory-Rights-Management-Service.md';Name='self-pointing RMS database record';From='for **rmsdb.ad.lab.test** pointing to **10.1.1.24 (VN1-SRV3)**';To='for **rmsdb.ad.lab.test** pointing to **rmsdb.ad.lab.test**';Expected='DNS record described as pointing to itself'}
    )
    foreach ($case in $semanticCases) {
        $candidate = $manifest.entries | Where-Object path -eq $case.Path
        $file = Join-Path $fixtureRoot $case.Path
        $before = [IO.File]::ReadAllText($file)
        if (!$before.Contains($case.From)) { throw "Semantic mutation did not alter its intended fixture: $($case.Name)" }
        try {
            [IO.File]::WriteAllText($file, $before.Replace($case.From, $case.To), $utf8)
            $errors = @(Test-CurriculumRules @($candidate) $fixtureRoot)
            if (!@($errors | Where-Object { $_ -like ('*' + $case.Expected + '*') }).Count) { throw "Semantic mutation escaped: $($case.Name). $($errors -join '; ')" }
            $passed++
        } finally { [IO.File]::WriteAllText($file, $before, $utf8) }
    }
    $domainEntry = $manifest.entries | Where-Object path -eq 'Instructions/Labs/Multi-domain-environments.md'
    $domainText = [IO.File]::ReadAllText((Join-Path $fixtureRoot $domainEntry.path)).Replace("`r`n","`n")
    $swapped = $domainText.Replace('VN1-SRV7','SWAP-TARGET').Replace('PM-SRV1','VN1-SRV7').Replace('SWAP-TARGET','PM-SRV1')
    if (!@(Test-CurriculumSemantics $domainEntry $swapped | Where-Object { $_ -like '*domain deployment identity disagrees with metadata*' }).Count) { throw 'Reciprocal child/tree server swap escaped' }
    $passed++
    $noDeployment = ($domainEntry | ConvertTo-Json -Depth 24) | ConvertFrom-Json
    $noDeployment.domainDeployments = @()
    if (!@(Test-CurriculumSemantics $noDeployment $domainText | Where-Object { $_ -like '*commands require matching deployment identities*' }).Count) { throw 'Missing deployment identities escaped' }
    $passed++
    $dnsEntry = $manifest.entries | Where-Object path -eq 'Instructions/Labs/Managing-DNS.md'
    $candidate = ($manifest.entries | Where-Object path -eq 'Instructions/Practices/Explore-intra-site-replication.md' | ConvertTo-Json -Depth 24) | ConvertFrom-Json
    $candidate.vmTopology = @($candidate.vmTopology | Where-Object guestHostname -ne 'VN2-SRV1')
    $candidate.requiredVmsOrTopology = @($candidate.requiredVmsOrTopology | Where-Object { $_ -ne 'VN2-SRV1' })
    if (!@(Test-CurriculumRules @($candidate) $fixtureRoot | Where-Object { $_ -match 'undeclared operational or unscoped VM VN2-SRV1' }).Count) { throw 'Required prerequisite-created replication partner was allowed to disappear from topology.' }
    $passed++
    $dnsFile = Join-Path $fixtureRoot $dnsEntry.path
    $dnsOriginal = [IO.File]::ReadAllText($dnsFile)
    if (@(Test-CurriculumRules @($dnsEntry) $fixtureRoot).Count) { throw 'Intentional scoped DNS-record data was rejected.' }
    $passed++
    foreach ($operation in @(
        '1. In VN1-SRV2, under Settings, click Windows Admin Center.',
        '1. In the portal search, type **VN4-SRV99** and click it.',
        '$computerNames = @("VN2-SRV2"); Invoke-Command -ComputerName $computerNames { Get-Service }'
    )) {
        [IO.File]::WriteAllText($dnsFile, ($dnsOriginal + "`n" + $operation + "`n"), $utf8)
        if (!@(Test-CurriculumRules @($dnsEntry) $fixtureRoot | Where-Object { $_ -match 'undeclared operational or unscoped VM' }).Count) { throw "Scoped reference leaked into operation: $operation" }
        $passed++
    }
    [IO.File]::WriteAllText($dnsFile, $dnsOriginal, $utf8)
    $candidate = ($dnsEntry | ConvertTo-Json -Depth 24) | ConvertFrom-Json
    $candidate.referencedVms[0].PSObject.Properties.Remove('contexts')
    if (!@(Test-CurriculumRules @($candidate) $fixtureRoot | Where-Object { $_ -match 'invalid scoped reference-only VM' }).Count) { throw 'Reason-only reference exemption was accepted.' }
    $passed++
    $operation = '1. In VN1-SRV2, under Settings, click Windows Admin Center.'
    $candidate = ($dnsEntry | ConvertTo-Json -Depth 24) | ConvertFrom-Json
    ($candidate.referencedVms | Where-Object name -eq 'VN1-SRV2').contexts += $operation
    [IO.File]::WriteAllText($dnsFile, ($dnsOriginal + "`n" + $operation + "`n"), $utf8)
    if (!@(Test-CurriculumRules @($candidate) $fixtureRoot | Where-Object { $_ -match 'reference-only context authorizes operational use' }).Count) { throw 'An operational GUI target was approved as reference-only data.' }
    $passed++
    [IO.File]::WriteAllText($dnsFile, $dnsOriginal, $utf8)
    foreach ($referenceCase in @(
        @{Kind='dns-record-data';Line='| record data | PM-SRV99 |'},
        @{Kind='illustrative-example';Line='> Illustrative example only: PM-SRV99 is not provisioned.'},
        @{Kind='deferred-inner';Line='> Reference only: PM-SRV99 is created in a later, separate nested exercise.'}
    )) {
        $candidate = $entryJson | ConvertFrom-Json
        $candidate.referencedVms += [pscustomobject]@{name='PM-SRV99';kind=$referenceCase.Kind;reason='Fixture reference data only, not an execution target.';contexts=@($referenceCase.Line)}
        [IO.File]::WriteAllText($documentPath, ($original + "`n" + $referenceCase.Line + "`n"), $utf8)
        if (@(Test-CurriculumRules @($candidate) $fixtureRoot).Count) { throw "Explicit reference context rejected: $($referenceCase.Kind)" }
        $passed++
        [IO.File]::WriteAllText($documentPath, ($original + "`n" + $referenceCase.Line + "`n1. Connect to PM-SRV99 in the portal.`n"), $utf8)
        if (!@(Test-CurriculumRules @($candidate) $fixtureRoot | Where-Object { $_ -match 'undeclared operational or unscoped VM' }).Count) { throw 'Reference data escaped its exact declared context.' }
        $passed++
    }
    [IO.File]::WriteAllText($documentPath, $original, $utf8)
    foreach ($cmdlet in @('New-VHD','Add-VMHardDiskDrive','Get-VMFirmware')) {
        $text = $original + "`n1. Run the host command:`n`n````````powershell`n$cmdlet -VMName 'WIN-VN1-SRV10'`n`````````n"
        [IO.File]::WriteAllText($documentPath, $text, $utf8)
        if (!@(Test-CurriculumRules @($entry) $fixtureRoot | Where-Object { $_ -match 'Hyper-V VM/VHD cmdlet outside nested teaching' }).Count) { throw "Missed Hyper-V cmdlet: $cmdlet" }
        $passed++
    }
    foreach ($operation in @('Open Hyper-V Manager.','Open Virtual Machine Connection.','Activate Enhanced Session.','On the Media menu, click DVD Drive.','In the menu on the virtual machine connection, click Ctrl+Alt+Delete.')) {
        [IO.File]::WriteAllText($documentPath, ($original + "`n1. $operation`n"), $utf8)
        if (!@(Test-CurriculumRules @($entry) $fixtureRoot | Where-Object { $_ -match 'Hyper-V console operation outside nested teaching' }).Count) { throw "Missed Hyper-V console operation: $operation" }
        $passed++
    }
    [IO.File]::WriteAllText($documentPath, ($original + "`nHyper-V Manager, Virtual Machine Connection and New-VHD are not used for this outer VMware scenario.`n"), $utf8)
    if (@(Test-CurriculumRules @($entry) $fixtureRoot).Count) { throw 'Explanatory Hyper-V boundary note produced a false positive.' }
    $passed++
    [IO.File]::WriteAllText($documentPath, $original, $utf8)
    foreach ($lifecycleEntry in $manifest.entries | Where-Object { @($_.vmTopology | Where-Object { $_.phase -in @('conditional','created') }).Count }) {
        $lifecycleFile = Join-Path $fixtureRoot $lifecycleEntry.path
        $lifecycleText = [IO.File]::ReadAllText($lifecycleFile).Replace("`r`n","`n")
        foreach ($vm in $lifecycleEntry.vmTopology | Where-Object { $_.phase -in @('conditional','created') }) {
            $prefix = if ($vm.phase -eq 'conditional') { 'Conditional until retired' } else { 'Created during exercise' }
            foreach ($replacement in @('', ('* ' + $vm.guestHostname), ('* ' + $prefix + ': VN1-SRV99'))) {
                [IO.File]::WriteAllText($lifecycleFile, $lifecycleText.Replace(('* ' + $prefix + ': ' + $vm.guestHostname), $replacement), $utf8)
                if (!@(Test-CurriculumRules @($lifecycleEntry) $fixtureRoot | Where-Object { $_ -like ('*Required VMs ' + $vm.phase + ' lifecycle disagrees*') }).Count) { throw "Lifecycle mutation escaped: $($lifecycleEntry.path) $($vm.guestHostname)" }
                $passed++
            }
            [IO.File]::WriteAllText($lifecycleFile, $lifecycleText, $utf8)
        }
    }
    $profileCandidate = ($manifest.entries | Where-Object path -eq 'Instructions/Practices/Explore-intra-site-replication.md' | ConvertTo-Json -Depth 24) | ConvertFrom-Json
    $profileCandidate.networkProfile = 'core'
    if (!@(Test-CurriculumRules @($profileCandidate) $fixtureRoot | Where-Object { $_ -match 'unexplained profile downgrade' }).Count) { throw 'Unexplained profile downgrade escaped validation.' }
    $passed++
    $profileCandidate.profileTransitions = @([pscustomobject]@{dependency='Instructions/Labs/Deploying-domain-controllers.md';reason='Fixture explicitly records a separate isolated core forest.'})
    if (@(Test-CurriculumRules @($profileCandidate) $fixtureRoot | Where-Object { $_ -match 'profile downgrade|invalid profile transition' }).Count) { throw 'Explicit profile transition was rejected.' }
    $passed++
    Test-CurriculumDependencyCycles $manifest.entries
    $passed++
    foreach ($graph in @(
        @([pscustomobject]@{path='a';dependencies=@('b')},[pscustomobject]@{path='b';dependencies=@('a')}),
        @([pscustomobject]@{path='a';dependencies=@('a')})
    )) {
        $rejected = $false
        try { Test-CurriculumDependencyCycles $graph } catch { if ($_.Exception.Message -match 'Dependency cycle:') { $rejected = $true } else { throw } }
        if (!$rejected) { throw 'Dependency cycle escaped validation.' }
        $passed++
    }
    $activationEntry = $manifest.entries | Where-Object path -eq 'Instructions/Practices/Authorize-DHCP-server-and-activate-scope.md'
    $activationFile = Join-Path $fixtureRoot $activationEntry.path
    $activationOriginal = [IO.File]::ReadAllText($activationFile)
    $creatorFile = Join-Path $fixtureRoot 'Instructions/Practices/Add-a-DHCP-scope.md'
    $creatorOriginal = [IO.File]::ReadAllText($creatorFile)
    foreach ($scopeCase in @(
        @{ Name='old core activation scope'; Expected='obsolete core DHCP activation scope'; Activation='10.10.30.0' },
        @{ Name='different activated scope'; Expected='prerequisite-created DHCP scope does not match'; Activation='10.1.2.0' },
        @{ Name='different prerequisite scope'; Expected='prerequisite-created DHCP scope does not match'; Creator=$true }
    )) {
        if ($scopeCase.Activation) { [IO.File]::WriteAllText($activationFile, $activationOriginal.Replace('10.1.1.0', $scopeCase.Activation), $utf8) }
        if ($scopeCase.Creator) { [IO.File]::WriteAllText($creatorFile, $creatorOriginal.Replace('10.1.1.2', '10.1.2.2'), $utf8) }
        $errors = @(Test-CurriculumRules @($activationEntry) $fixtureRoot)
        if (!@($errors | Where-Object { $_ -like ('*' + $scopeCase.Expected + '*') }).Count) { throw "DHCP mutation escaped: $($scopeCase.Name)" }
        [IO.File]::WriteAllText($activationFile, $activationOriginal, $utf8)
        [IO.File]::WriteAllText($creatorFile, $creatorOriginal, $utf8)
        $passed++
    }
    foreach ($dhcpPath in @('Instructions/Practices/Authorize-DHCP-server-and-activate-scope.md','Instructions/Practices/Configure-DHCP-server-options.md')) {
        $candidate = ($manifest.entries | Where-Object path -eq $dhcpPath | ConvertTo-Json -Depth 24) | ConvertFrom-Json
        $candidate.networkProfile = 'core'
        $errors = @(Test-CurriculumRules @($candidate) $fixtureRoot)
        if (!@($errors | Where-Object { $_ -like '*enterprise DHCP addresses require enterprise metadata profile*' }).Count) { throw "Core DHCP profile escaped: $dhcpPath" }
        $passed++
    }
    $conditionalEntry = $manifest.entries | Where-Object path -eq 'Instructions/Practices/Configure-a-guest-operating-system.md'
    foreach ($alternativeEntry in $manifest.entries | Where-Object { $_.alternativeVmGroups.Count }) {
        $alternativeFile = Join-Path $fixtureRoot $alternativeEntry.path
        # Exercise Windows-checkout CRLF input, then normalize before exact-line mutations.
        $windowsFixture = [IO.File]::ReadAllText($alternativeFile).Replace("`r`n", "`n").Replace("`n", "`r`n")
        [IO.File]::WriteAllText($alternativeFile, $windowsFixture, $utf8)
        $alternativeOriginal = [IO.File]::ReadAllText($alternativeFile).Replace("`r`n", "`n")
        $group = $alternativeEntry.alternativeVmGroups[0]
        $groupLine = '* One active domain controller: ' + ($group.names -join ' or ')
        $ordinaryName = @($alternativeEntry.requiredVmsOrTopology | Where-Object { $_ -notin $group.names })[0]
        foreach ($alternativeCase in @(
            @{ Expected='alternative groups disagree'; Text=$alternativeOriginal.Replace($groupLine + "`n", '') },
            @{ Expected='alternative groups disagree'; Text=$alternativeOriginal.Replace($groupLine, '* One active domain controller: VN1-SRV1 or VN1-SRV99') },
            @{ Expected='alternatives rendered as unconditional'; Text=$alternativeOriginal.Replace($groupLine, ('* ' + ($group.names -join "`n* "))) },
            @{ Expected='mandatory authoritative topology'; Text=$alternativeOriginal.Replace('* ' + $ordinaryName + "`n", '') }
        )) {
            [IO.File]::WriteAllText($alternativeFile, $alternativeCase.Text, $utf8)
            $errors = @(Test-CurriculumRules @($alternativeEntry) $fixtureRoot)
            if (!@($errors | Where-Object { $_ -like ('*' + $alternativeCase.Expected + '*') }).Count) { throw "Alternative mutation escaped for $($alternativeEntry.path): $($alternativeCase.Expected)" }
            $passed++
        }
        [IO.File]::WriteAllText($alternativeFile, $alternativeOriginal, $utf8)
    }
    if (@(Test-CurriculumRules @($conditionalEntry) $fixtureRoot).Count) { throw 'Documented optional VMnet8 cleanup was rejected.' }
    $passed++
    . (Join-Path $scriptRoot 'Curriculum-Contract.ps1')
    foreach ($prefix in @("`n`n", ([string][char]0xFEFF + "`n`n"))) {
        $fixtureText = $prefix + "# Fixture title`n`n## Required VMs`n`n* CL1`n"
        $renderedFixture = Set-CurriculumContractText $fixtureText $entry
        if ($renderedFixture -notmatch '\A# Fixture title\n\n<!-- BEGIN GENERATED COMPLETION CONTRACT -->' -or $renderedFixture.IndexOf('## Required VMs') -lt $renderedFixture.IndexOf('<!-- END GENERATED COMPLETION CONTRACT -->')) { throw 'Leading blanks/BOM put the contract before H1.' }
        if ((Set-CurriculumContractText $renderedFixture $entry) -cne $renderedFixture) { throw 'Title-based insertion is not idempotent.' }
        $passed++
    }
    [IO.File]::WriteAllText($documentPath, [regex]::Replace($original, '(?m)^# ', '## '), $utf8)
    if (!@(Test-CurriculumRules @($entry) $fixtureRoot | Where-Object { $_ -match 'no H1 title' }).Count) { throw 'Missing H1 escaped validation.' }
    [IO.File]::WriteAllText($documentPath, $original, $utf8)
    $passed++
    $renderEntry = $entryJson | ConvertFrom-Json
    $renderEntry.alternativeVmGroups = @($null)
    $renderEntry.networks = @('', '  Isolated lab.  ', $null)
    $renderEntry.vmTopology[0].displayNameAliases = @('', '  WIN-CL1  ', $null)
    $rendered = Get-CurriculumContract $renderEntry
    if ($rendered -match '\S[ \t]{2,}\S' -or $rendered -notmatch 'accepted display aliases: WIN-CL1;' -or $rendered -notmatch '\. Isolated lab\.') { throw 'Empty topology parts or whitespace aliases broke contract rendering.' }
    $passed++
    $preflight = Join-Path $scriptRoot 'Preflight-LearnerLab.ps1'
    $tokens = $null; $parseErrors = $null
    $ast = [Management.Automation.Language.Parser]::ParseInput([IO.File]::ReadAllText($preflight), [ref]$tokens, [ref]$parseErrors)
    $forbiddenCalls = @($ast.FindAll({param($node) $node -is [Management.Automation.Language.CommandAst] -and $node.GetCommandName() -match '^(?:Connect-|New-|Remove-|Start-|Stop-|Install-|Uninstall-|Update-|Invoke-|Get-AD|az$)'}, $true))
    if ($forbiddenCalls.Count -or $parseErrors.Count) { throw 'Preflight contains an authentication/mutation command or parse error.' }
    $passed++
    $engine = if ($PSVersionTable.PSEdition -eq 'Desktop') { Join-Path $PSHOME 'powershell.exe' } else { Join-Path $PSHOME 'pwsh.exe' }
    $matrixManifest = Join-Path $fixtureRoot 'metadata/path-matrix.json'
    [IO.File]::WriteAllText($matrixManifest, ($manifest | ConvertTo-Json -Depth 24), $utf8)
    [IO.File]::WriteAllText((Join-Path $fixtureRoot 'metadata/invalid-matrix.json'), '{ invalid JSON', $utf8)
    [IO.File]::WriteAllText((Join-Path $fixtureRoot 'metadata/empty-matrix.json'), '{}', $utf8)
    $pathRunner = Join-Path $fixtureRoot 'path-preflight.ps1'
    [IO.File]::WriteAllText($pathRunner, @'
param($Preflight, $WorkingDirectory, $ManifestPath, $CurriculumPath)
Set-Location -LiteralPath $WorkingDirectory
if ($CurriculumPath -eq '__INVALID_NUL_PATH__') { $CurriculumPath = 'D:\invalid' + [char]0 + '\BranchCache.md' }
& $Preflight -SkipHostChecks -AsJson -ManifestPath $ManifestPath -CurriculumPath $CurriculumPath
exit $LASTEXITCODE
'@, $utf8)
    foreach ($form in @('bare','nested','absolute')) {
        foreach ($curriculumForm in @('relative','absolute')) {
            foreach ($state in @('valid','missing','invalid','empty')) {
                $fileName = switch ($state) { 'valid' {'path-matrix.json'}; 'missing' {'missing-matrix.json'}; 'invalid' {'invalid-matrix.json'}; 'empty' {'empty-matrix.json'} }
                $workingDirectory = if ($form -eq 'bare') { Join-Path $fixtureRoot 'metadata' } else { $fixtureRoot }
                $manifestArgument = switch ($form) { 'bare' {$fileName}; 'nested' {'metadata/' + $fileName}; 'absolute' {Join-Path $fixtureRoot ('metadata/' + $fileName)} }
                $curriculumArgument = if ($curriculumForm -eq 'absolute') { Join-Path $fixtureRoot 'Instructions/Labs/BranchCache.md' } else { 'Instructions/Labs/BranchCache.md' }
                $output = & $engine -NoProfile -ExecutionPolicy Bypass -File $pathRunner $preflight $workingDirectory $manifestArgument $curriculumArgument 2>&1
                $expectedExit = if ($state -eq 'valid') { 0 } else { 1 }
                if ($LASTEXITCODE -ne $expectedExit) { throw "Manifest path matrix exit failed: $form/$curriculumForm/$state. $output" }
                $checks = $output -join "`n" | ConvertFrom-Json
                $manifestStatus = if ($state -eq 'valid') { 'Pass' } else { 'Error' }
                $selectionStatus = if ($state -eq 'valid') { 'Pass' } else { 'Skipped' }
                if (!@($checks | Where-Object { $_.Name -eq 'Manifest' -and $_.Status -eq $manifestStatus }).Count -or !@($checks | Where-Object { $_.Name -eq 'Curriculum selection' -and $_.Status -eq $selectionStatus }).Count) { throw "Manifest path matrix checks failed: $form/$curriculumForm/$state" }
                $passed++
            }
        }
    }
    foreach ($pathCase in @(
        @{Path='Instructions/Practices/../Labs/BranchCache.md';Exit=0},
        @{Path='../Instructions/Labs/BranchCache.md';Exit=1},
        @{Path='__INVALID_NUL_PATH__';Exit=1},
        @{Path=(Split-Path -Qualifier $fixtureRoot) + 'Instructions/Labs/BranchCache.md';Exit=0}
    )) {
        $output = & $engine -NoProfile -ExecutionPolicy Bypass -File $pathRunner $preflight $fixtureRoot (Join-Path $fixtureRoot 'metadata/path-matrix.json') $pathCase.Path 2>&1
        if ($LASTEXITCODE -ne $pathCase.Exit) { throw "Curriculum normalization exit failed: $($pathCase.Path). $output" }
        $checks = $output -join "`n" | ConvertFrom-Json
        $status = if ($pathCase.Exit) { 'Error' } else { 'Pass' }
        if (!@($checks | Where-Object { $_.Name -eq 'Curriculum selection' -and $_.Status -eq $status }).Count) { throw 'Curriculum normalization did not preserve structured selection results.' }
        $passed++
    }
    foreach ($schemaCase in @('missing-azure','missing-outbound','scalar-dependencies','scalar-topology','invalid-phase','invalid-aliases','old-schema','scalar-entries','numeric-vm-name','blank-alias','numeric-alias','null-vm','duplicate-alternative','alias-collision','invalid-endpoint','invalid-azure-service','numeric-cleanup','array-azure','empty-transition','duplicate-transition','transition-alias-collision')) {
        $candidate = $entryJson | ConvertFrom-Json
        $fixture = [pscustomobject]@{schemaVersion=3;entries=@($candidate)}
        switch ($schemaCase) {
            'missing-azure' { $candidate.PSObject.Properties.Remove('azure') }
            'missing-outbound' { $candidate.PSObject.Properties.Remove('outbound') }
            'scalar-dependencies' { $candidate.dependencies=$candidate.dependencies[0] }
            'scalar-topology' { $candidate.vmTopology=$candidate.vmTopology[0] }
            'invalid-phase' { $candidate.vmTopology[0].phase='unknown' }
            'invalid-aliases' { $candidate.vmTopology[0].displayNameAliases='WIN-CL1' }
            'old-schema' { $fixture.schemaVersion=2 }
            'scalar-entries' { $fixture.entries=$candidate }
            'numeric-vm-name' { $candidate.requiredVmsOrTopology[0]=42; $candidate.vmTopology[0].guestHostname=42 }
            'blank-alias' { $candidate.vmTopology[0].displayNameAliases=@('') }
            'numeric-alias' { $candidate.vmTopology[0].displayNameAliases=@(42) }
            'null-vm' { $candidate.vmTopology[0]=$null }
            'duplicate-alternative' { $candidate.alternativeVmGroups=@([pscustomobject]@{names=@('CL1','CL1');minimum=2;reason='Duplicated requirement'}) }
            'alias-collision' { $candidate.vmTopology[0].displayNameAliases=@($candidate.vmTopology[1].guestHostname) }
            'invalid-endpoint' { $candidate.outbound.endpoints=@([pscustomobject]@{url='example.test'}) }
            'invalid-azure-service' { $candidate.azure.services=@(42) }
            'numeric-cleanup' { $candidate.cleanup=42 }
            'array-azure' { $candidate.azure=@($candidate.azure) }
            'empty-transition' { $candidate | Add-Member -NotePropertyName identityTransitions -NotePropertyValue '' -Force }
            { $_ -in @('duplicate-transition','transition-alias-collision') } {
                $reuse = [pscustomobject]@{initialGuestHostname='CL1';laterGuestHostname='REUSED-CL1';vmwareDisplayName=$candidate.vmTopology[0].vmwareDisplayName;simultaneous=$false;trigger='snapshot-reversion-and-pxe-redeployment';snapshot='Before-installation'}
                if ($schemaCase -eq 'transition-alias-collision') { $reuse.laterGuestHostname=$candidate.vmTopology[1].displayNameAliases[0] }
                $transitions = if ($schemaCase -eq 'duplicate-transition') { @($reuse,$reuse) } else { @($reuse) }
                $candidate | Add-Member -NotePropertyName identityTransitions -NotePropertyValue $transitions -Force
            }
        }
        $badManifest = Join-Path $fixtureRoot ('metadata/invalid-contract-' + $schemaCase + '.json')
        [IO.File]::WriteAllText($badManifest, ($fixture | ConvertTo-Json -Depth 24), $utf8)
        $output = & $engine -NoProfile -ExecutionPolicy Bypass -File $preflight -SkipHostChecks -AsJson -ManifestPath $badManifest -CurriculumPath $entry.path 2>&1
        if ($LASTEXITCODE -ne 1) { throw "Invalid selected contract accepted: $schemaCase" }
        $checks = $output -join "`n" | ConvertFrom-Json
        if (!@($checks | Where-Object Status -eq 'Error').Count -or @($checks | Where-Object Name -eq 'Required VMs').Count) { throw "Invalid selected contract was interpreted: $schemaCase" }
        $passed++
    }
    $probeRunner = Join-Path $fixtureRoot 'probe-preflight.ps1'
    [IO.File]::WriteAllText($probeRunner, @'
param($Preflight, $ManifestPath, $Mode, $ReportPath)
function Get-CimInstance { [CmdletBinding()] param([string]$ClassName) }
function Resolve-DnsName { [CmdletBinding()] param([string]$Name, [string]$Server) }
function Test-NetConnection { [CmdletBinding()] param([string]$ComputerName, [int]$Port, [string]$InformationLevel); throw 'TCP probe unavailable' }
function Test-Connection { [CmdletBinding()] param([string]$ComputerName, [int]$Count, [switch]$Quiet); return $true }
function Get-NetIPAddress { [CmdletBinding()] param([string]$AddressFamily); [pscustomobject]@{IPAddress='10.10.10.1'} }
$path = if ($Mode -in @('reuse','missing-probes')) { 'Instructions/Labs/Microsoft-Deployment-Toolkit.md' } else { 'Instructions/Practices/Create-an-Azure-Subscription.md' }
$entry = ([IO.File]::ReadAllText($ManifestPath) | ConvertFrom-Json).entries | Where-Object path -eq $path
$parameters = @{CurriculumPath=$path;ManifestPath=$ManifestPath;AsJson=$true;OutboundAvailable=$true;CompletedPrerequisite=@($entry.dependencies)}
if ($ReportPath) { $parameters.ReportPath=$ReportPath }
switch ($Mode) {
    'dns-failure' { $parameters.ExpectedDnsServer='10.10.10.10' }
    'bad-octet' { $parameters.ExpectedSubnet='999.10.10.0/24' }
    'bad-prefix' { $parameters.ExpectedSubnet='10.10.10.0/99' }
    'reuse' { $parameters.VmName=@('VN1-SRV21') }
    'missing-probes' {
        function Get-Command { [CmdletBinding()] param([string]$Name); if ($Name -notin @('Test-Connection','Test-NetConnection')) { Microsoft.PowerShell.Core\Get-Command @PSBoundParameters } }
        $parameters.VmName=@('VN1-SRV21'); $parameters.ExpectedDnsServer='10.10.10.10'
    }
    'absolute-evidence' { $parameters.SkipHostChecks=$true; $parameters.FailOnWarning=$true; $parameters.CompletedPrerequisite=@($entry.dependencies | ForEach-Object { Join-Path (Split-Path (Split-Path $ManifestPath -Parent) -Parent) $_ }) }
    'escaped-evidence' { $parameters.SkipHostChecks=$true; $parameters.CompletedPrerequisite=@('../Instructions/General/Learner-Setup.md') }
}
& $Preflight @parameters
exit $LASTEXITCODE
'@, $utf8)
    foreach ($probeCase in @(
        @{Mode='dns-failure';Exit=0;Name='DNS port 53';Status='Warning'},
        @{Mode='bad-octet';Exit=1;Name='Expected subnet';Status='Error'},
        @{Mode='bad-prefix';Exit=1;Name='Expected subnet';Status='Error'},
        @{Mode='reuse';Exit=0;Name='VM reachability: VN1-SRV21';Status='Pass'},
        @{Mode='missing-probes';Exit=0;Name='DNS port 53';Status='Warning'},
        @{Mode='absolute-evidence';Exit=0;Name='Prerequisite evidence';Status='Pass'},
        @{Mode='escaped-evidence';Exit=1;Name='Prerequisite evidence';Status='Error'}
    )) {
        $probeReport = Join-Path $fixtureRoot ('probe-' + $probeCase.Mode + '.json')
        $output = & $engine -NoProfile -ExecutionPolicy Bypass -File $probeRunner $preflight (Join-Path $RepositoryRoot 'metadata/curriculum-manifest.json') $probeCase.Mode $probeReport 2>&1
        if ($LASTEXITCODE -ne $probeCase.Exit) { throw "Probe/evidence exit failed: $($probeCase.Mode). $output" }
        $checks = $output -join "`n" | ConvertFrom-Json
        if (!@($checks | Where-Object { $_.Name -eq $probeCase.Name -and $_.Status -eq $probeCase.Status }).Count) { throw "Probe/evidence result failed: $($probeCase.Mode)" }
        if ($probeCase.Mode -eq 'reuse' -and @($checks | Where-Object Name -eq 'VM reachability: VN1-SRV20').Count) { throw 'Reused guest was probed using its retired hostname.' }
        if ($probeCase.Mode -eq 'missing-probes' -and !@($checks | Where-Object { $_.Name -eq 'VM reachability: VN1-SRV21' -and $_.Status -eq 'Warning' -and $_.Detail -match 'unavailable' }).Count) { throw 'Unavailable ICMP probe was silently omitted.' }
        $reportChecks = [IO.File]::ReadAllText($probeReport) | ConvertFrom-Json
        if (($checks | ConvertTo-Json -Depth 6 -Compress) -cne ($reportChecks | ConvertTo-Json -Depth 6 -Compress)) { throw 'Probe/evidence JSON report differs from stdout.' }
        $passed++
    }
    $inputManifest = Join-Path $fixtureRoot 'metadata/path-matrix.json'
    $malformedManifest = Join-Path $fixtureRoot 'metadata/malformed-protected.json'
    [IO.File]::WriteAllText($malformedManifest, '{ invalid JSON', $utf8)
    $preflightCopy = Join-Path $fixtureRoot 'protected-preflight.ps1'
    Copy-Item -LiteralPath $preflight -Destination $preflightCopy
    foreach ($protectedInput in @(
        @{Script=$preflight;Manifest=$malformedManifest;Target=$malformedManifest},
        @{Script=$preflight;Manifest=$inputManifest;Target=(Join-Path $fixtureRoot $entry.path)},
        @{Script=$preflightCopy;Manifest=$inputManifest;Target=$preflightCopy}
    )) {
        $protectedBefore = [IO.File]::ReadAllText($protectedInput.Target)
        $output = & $engine -NoProfile -ExecutionPolicy Bypass -File $protectedInput.Script -SkipHostChecks -AsJson -ManifestPath $protectedInput.Manifest -CurriculumPath $entry.path -ReportPath $protectedInput.Target 2>&1
        if ($LASTEXITCODE -ne 1) { throw 'Protected report destination did not produce exit 1.' }
        $checks = $output -join "`n" | ConvertFrom-Json
        if (!@($checks | Where-Object { $_.Name -eq 'Report output' -and $_.Status -eq 'Error' }).Count) { throw 'Protected report failure did not remain structured JSON.' }
        if ([IO.File]::ReadAllText($protectedInput.Target) -cne $protectedBefore) { throw 'Report output overwrote an input or its preflight source.' }
        $passed++
    }
    $inputBefore = [IO.File]::ReadAllText($inputManifest)
    foreach ($reportDestination in @((Join-Path $fixtureRoot 'missing-directory/report.json'), $inputManifest)) {
        $output = & $engine -NoProfile -ExecutionPolicy Bypass -File $preflight -SkipHostChecks -AsJson -ManifestPath $inputManifest -CurriculumPath $entry.path -ReportPath $reportDestination 2>&1
        if ($LASTEXITCODE -ne 1) { throw 'Report failure did not produce exit 1.' }
        $checks = $output -join "`n" | ConvertFrom-Json
        if (!@($checks | Where-Object { $_.Name -eq 'Report output' -and $_.Status -eq 'Error' }).Count) { throw 'Report failure did not remain structured JSON.' }
        if ([IO.File]::ReadAllText($inputManifest) -cne $inputBefore) { throw 'Report output overwrote its input manifest.' }
        $passed++
    }
    $mdt = $manifest.entries | Where-Object path -eq 'Instructions/Labs/Microsoft-Deployment-Toolkit.md'
    $s2d = $manifest.entries | Where-Object path -eq 'Instructions/Labs/Configuring-and-managing-Storage-Spaces-Direct-and-hyper-converged-virtualization.md'
    $existingInner = $s2d.vmTopology | Where-Object guestHostname -eq 'VN1-SRV23'
    if ($existingInner.phase -ne 'existing-inner' -or !$existingInner.prerequisiteCreator -or (Get-CurriculumRequiredVmLines $s2d) -notmatch '(?m)^\* VN1-SRV23$' -or @($s2d.vmTopology | Where-Object phase -eq 'created').Count -ne 1) { throw 'S2D prerequisite-created VM counted as a newly created target' }
    $passed++
    $candidate = ($s2d | ConvertTo-Json -Depth 24) | ConvertFrom-Json
    ($candidate.vmTopology | Where-Object guestHostname -eq 'VN1-SRV23').phase='created'
    if (!@(Test-CurriculumRules @($candidate) $fixtureRoot | Where-Object { $_ -like '*prerequisite-created VM must remain an existing target*' }).Count) { throw 'Prerequisite-created VM lifecycle mutation escaped' }
    $passed++
    $s2dText = [IO.File]::ReadAllText((Join-Path $fixtureRoot $s2d.path)).Replace("`r`n","`n")
    $wrongConsole = $s2dText.Replace('In VN1-SRV24 on VN1-SRV6 - Virtual Machine Connection','In VN1-SRV23 on VN1-SRV4 - Virtual Machine Connection')
    if ($wrongConsole -ceq $s2dText -or !@(Test-CurriculumSemantics $s2d $wrongConsole | Where-Object { $_ -like '*connected VM and console identity disagree*' }).Count) { throw 'S2D stale console identity escaped' }
    $passed++
    $mdtText = [IO.File]::ReadAllText((Join-Path $fixtureRoot $mdt.path)).Replace("`r`n","`n")
    $created = @($mdt.vmTopology | Where-Object phase -eq 'created')
    if ($created.Count -ne 1 -or $created[0].guestHostname -ne 'VN1-SRV20' -or $created[0].layer -ne 'outer-vmware' -or $created[0].vmwareDisplayName -ne 'WIN-VN1-SRV20') { throw 'MDT must create exactly one outer VMware target' }
    $passed++
    $required = Get-CurriculumRequiredVmLines $mdt
    $contract = Get-CurriculumContract $mdt
    if ($required -notmatch 'Created during exercise: VN1-SRV20' -or $required -match 'VN1-SRV21' -or $contract -notmatch 'Machine reuse' -or $contract -notmatch 'no simultaneous second VM' -or $contract -notmatch 'VN1-SRV20' -or $contract -notmatch 'VN1-SRV21') { throw 'MDT reuse contract/Required VMs regressed' }
    $passed++
    foreach ($mutation in @('second-created','wrong-target','simultaneous','wrong-snapshot','missing-transition','unscoped-context','missing-initial','wrong-redeployment')) {
        $candidate = ($mdt | ConvertTo-Json -Depth 24) | ConvertFrom-Json
        $text = $mdtText
        $expected = switch ($mutation) {
            'second-created' {
                $second = ($created[0] | ConvertTo-Json -Depth 8) | ConvertFrom-Json
                $second.guestHostname='VN1-SRV21'; $second.vmwareDisplayName='WIN-VN1-SRV21'; $second.displayNameAliases=@('VN1-SRV21')
                $candidate.vmTopology += $second; $candidate.requiredVmsOrTopology += 'VN1-SRV21'
                'reused guest identity must not be another topology VM'
            }
            'wrong-target' { $candidate.identityTransitions[0].vmwareDisplayName='WIN-VN1-SRV21'; 'invalid reused VMware target identity' }
            'simultaneous' { $candidate.identityTransitions[0].simultaneous=$true; 'invalid reused VMware target identity' }
            'wrong-snapshot' { $candidate.identityTransitions[0].snapshot='Other-snapshot'; 'reuse procedure disagrees' }
            'missing-transition' { $candidate.identityTransitions=@(); 'VM reuse requires an identity transition' }
            'unscoped-context' { $candidate.identityTransitions[0].laterGuestContexts=@('Perform this task on VN1-SRV21.'); 'invalid reused guest context' }
            'missing-initial' { $text=$text.Replace('type **VN1-SRV20**','type **VN1-SRV99**'); 'initial reused guest hostname is not documented' }
            'wrong-redeployment' { $text=$text.Replace('type **VN1-SRV21**','type **VN1-SRV20**'); 'reuse procedure disagrees' }
        }
        if (!@(Test-CurriculumIdentityTransitions $candidate $text | Where-Object { $_ -like ('*' + $expected + '*') }).Count) { throw "MDT identity mutation escaped: $mutation" }
        $passed++
    }
    $wds = $manifest.entries | Where-Object path -eq 'Instructions/Labs/Windows-Deployment-Services.md'
    $wdsCreated = @($wds.vmTopology | Where-Object phase -eq 'created')
    if ($wdsCreated.Count -ne 1 -or $wdsCreated[0].guestHostname -ne 'VN1-SRV21' -or $wdsCreated[0].layer -ne 'outer-vmware' -or @($wds.identityTransitions | Where-Object { $_ }).Count -or (Get-CurriculumRequiredVmLines $wds) -notmatch 'Created during exercise: VN1-SRV21') { throw 'Independent WDS created target regressed' }
    $passed++
    foreach ($identityPath in @($mdt.path,$wds.path)) {
        $output = & $engine -NoProfile -ExecutionPolicy Bypass -File $preflight -SkipHostChecks -AsJson -CurriculumPath $identityPath
        if ($LASTEXITCODE -ne 0) { throw 'Created target preflight failed' }
        $checks = $output -join "`n" | ConvertFrom-Json
        $createdChecks = @($checks | Where-Object Name -eq 'Created VM')
        $expectedGuest = if ($identityPath -eq $mdt.path) { 'VN1-SRV20' } else { 'VN1-SRV21' }
        if ($createdChecks.Count -ne 1 -or $createdChecks[0].Detail -notmatch $expectedGuest) { throw 'Preflight counted an incorrect number of created targets' }
        if ($identityPath -eq $mdt.path -and ($createdChecks[0].Detail -match 'VN1-SRV21' -or !@($checks | Where-Object { $_.Name -eq 'Machine reuse' -and $_.Detail -match 'one VMware target' -and $_.Detail -match 'VN1-SRV21' }).Count -or @($checks | Where-Object { $_.Name -eq 'Required VMs' -and $_.Detail -match 'VN1-SRV21' }).Count)) { throw 'Preflight treated the reused identity as a separate VM' }
        $passed++
    }
    $output = & $engine -NoProfile -ExecutionPolicy Bypass -File $preflight -SkipHostChecks -AsJson -CurriculumPath $mdt.path -VmName 'VN1-SRV21'
    if ($LASTEXITCODE -ne 0 -or @(($output -join "`n" | ConvertFrom-Json) | Where-Object Name -eq 'Supplied VM comparison').Count) { throw 'Later guest identity did not map to the reused VMware target' }
    $passed++
    $lifecycleRunner = Join-Path $fixtureRoot 'lifecycle-preflight.ps1'
    [IO.File]::WriteAllText($lifecycleRunner, @'
param($Preflight, $ManifestPath, $CurriculumPath, $Mode)
$entry = ([IO.File]::ReadAllText($ManifestPath) | ConvertFrom-Json).entries | Where-Object path -eq $CurriculumPath
$argsForCheck = @{CurriculumPath=$CurriculumPath; ManifestPath=$ManifestPath; SkipHostChecks=$true; AsJson=$true; FailOnWarning=$true; OutboundAvailable=$true; AzureSubscriptionId="<AZURE_SUBSCRIPTION_ID>"; AzureRegion="<AZURE_REGION>"; AzureResourceGroup="<AZURE_RESOURCE_GROUP>"; AzureBudgetName="<AZURE_BUDGET_NAME>"; CompletedPrerequisite=@($entry.dependencies); VmName=@($entry.vmTopology | Where-Object phase -in @('existing','existing-inner') | ForEach-Object guestHostname)}
switch ($Mode) {
    'present' { $argsForCheck.VmName += @($entry.vmTopology | Where-Object phase -eq 'conditional' | ForEach-Object guestHostname) }
    'retired' { $argsForCheck.RetiredVmName = @($entry.vmTopology | Where-Object phase -eq 'conditional' | ForEach-Object guestHostname) }
    'conflict' { $argsForCheck.VmName += 'VN1-SRV1'; $argsForCheck.RetiredVmName = @('VN1-SRV1') }
    'mandatory' { $argsForCheck.RetiredVmName = @('CL1') }
    'created-retired' { $argsForCheck.RetiredVmName = @($entry.vmTopology | Where-Object phase -eq 'created' | ForEach-Object guestHostname) }
}
& $Preflight @argsForCheck
exit $LASTEXITCODE
'@, $utf8)
    foreach ($lifecycleCase in @(
        @{Path='Instructions/Practices/Configure-a-fine-grained-password-policy.md';Mode='present';Exit=0;Name='Conditional VM';Status='Pass'},
        @{Path='Instructions/Practices/Configure-a-fine-grained-password-policy.md';Mode='retired';Exit=0;Name='Conditional VM';Status='Skipped'},
        @{Path='Instructions/Practices/Configure-a-fine-grained-password-policy.md';Mode='absent';Exit=1;Name='Conditional VM';Status='Warning'},
        @{Path='Instructions/Practices/Configure-a-fine-grained-password-policy.md';Mode='conflict';Exit=1;Status='Error'},
        @{Path='Instructions/Practices/Configure-a-fine-grained-password-policy.md';Mode='mandatory';Exit=1;Status='Error'},
        @{Path='Instructions/Practices/Create-and-install-a-virtual-machine.md';Mode='absent';Exit=0;Name='Created VM';Status='Skipped'},
        @{Path='Instructions/Practices/Create-and-install-a-virtual-machine.md';Mode='created-retired';Exit=1;Status='Error'}
    )) {
        $output = & $engine -NoProfile -ExecutionPolicy Bypass -File $lifecycleRunner $preflight (Join-Path $RepositoryRoot 'metadata/curriculum-manifest.json') $lifecycleCase.Path $lifecycleCase.Mode
        if ($LASTEXITCODE -ne $lifecycleCase.Exit) { throw "Lifecycle preflight exit failed: $($lifecycleCase.Mode). $output" }
        $checks = $output -join "`n" | ConvertFrom-Json
        if (!@($checks | Where-Object { $_.Status -eq $lifecycleCase.Status -and (!$lifecycleCase.Name -or $_.Name -eq $lifecycleCase.Name) }).Count) { throw "Lifecycle preflight status failed: $($lifecycleCase.Mode)" }
        $passed++
    }
    foreach ($lifecycleEntry in $manifest.entries) {
        $hasConditional = @($lifecycleEntry.vmTopology | Where-Object phase -eq 'conditional').Count -gt 0
        $hasCreated = @($lifecycleEntry.vmTopology | Where-Object phase -eq 'created').Count -gt 0
        $modes = @()
        if ($hasConditional) { $modes += @('present','retired','absent') }
        if ($hasCreated) { $modes += 'created' }
        foreach ($mode in $modes) {
            $output = & $engine -NoProfile -ExecutionPolicy Bypass -File $lifecycleRunner $preflight (Join-Path $RepositoryRoot 'metadata/curriculum-manifest.json') $lifecycleEntry.path $mode
            $expectedExit = if ($mode -eq 'absent') { 1 } else { 0 }
            if ($LASTEXITCODE -ne $expectedExit) { throw "Whole-curriculum lifecycle preflight failed: $($lifecycleEntry.path) $mode. $output" }
            $checks = $output -join "`n" | ConvertFrom-Json
            $expectedName = if ($mode -eq 'created') { 'Created VM' } else { 'Conditional VM' }
            $expectedStatus = switch ($mode) { 'present' {'Pass'}; 'absent' {'Warning'}; default {'Skipped'} }
            if (!@($checks | Where-Object { $_.Name -eq $expectedName -and $_.Status -eq $expectedStatus }).Count) { throw "Whole-curriculum lifecycle status failed: $($lifecycleEntry.path) $mode" }
            $passed++
        }
    }
    foreach ($jsonCase in @(
        @{ Arguments=@('-CurriculumPath','Instructions/Labs/BranchCache.md'); Exit=0 },
        @{ Arguments=@('-CurriculumPath','Instructions/Labs/does-not-exist.md'); Exit=1 },
        @{ Arguments=@(); Exit=1 }
    )) {
        $reportFile = Join-Path $fixtureRoot ('preflight-' + $passed + '.json')
        $jsonArguments = $jsonCase.Arguments
        $jsonOutput = & $engine -NoProfile -ExecutionPolicy Bypass -File $preflight -SkipHostChecks -AsJson -ReportPath $reportFile @jsonArguments
        if ($LASTEXITCODE -ne $jsonCase.Exit) { throw 'JSON/report mode changed the exit code.' }
        $stdoutChecks = $jsonOutput -join "`n" | ConvertFrom-Json
        $fileChecks = [IO.File]::ReadAllText($reportFile) | ConvertFrom-Json
        if (($stdoutChecks | ConvertTo-Json -Depth 6 -Compress) -cne ($fileChecks | ConvertTo-Json -Depth 6 -Compress)) { throw 'JSON report/stdout differs or stdout was contaminated.' }
        $passed++
    }
    $output = & $engine -NoProfile -ExecutionPolicy Bypass -File $preflight -SkipHostChecks -AsJson
    if ($LASTEXITCODE -ne 1 -or !@(($output -join "`n" | ConvertFrom-Json) | Where-Object { $_.Name -eq 'Curriculum selection' -and $_.Status -eq 'Error' -and $_.Detail -match 'Supply -CurriculumPath' }).Count) { throw 'Missing curriculum selection did not produce a clear error and exit 1.' }
    $passed++
    foreach ($portalPath in @('Instructions/Practices/Create-an-Azure-Subscription.md','Instructions/Practices/Create-an-Entra-ID-tenant.md')) {
        $portalEntry = $manifest.entries | Where-Object path -eq $portalPath
        if (@(Test-CurriculumRules @($portalEntry) $fixtureRoot).Count) { throw 'Valid host-browser contract was rejected.' }
        $output = & $engine -NoProfile -ExecutionPolicy Bypass -File $preflight -SkipHostChecks -AsJson -CurriculumPath $portalPath
        if ($LASTEXITCODE -ne 0) { throw 'Host-browser conceptual path failed without guest/Azure parameters.' }
        $checks = $output -join "`n" | ConvertFrom-Json
        if (!@($checks | Where-Object { $_.Name -eq 'Required outbound access' -and $_.Status -eq 'Warning' }).Count) { throw 'Host-browser Internet requirement did not warn.' }
        $portalEntry.cleanup = 'Disconnect temporary VMnet8.'
        if (!@(Test-CurriculumRules @($portalEntry) $fixtureRoot | Where-Object { $_ -match 'host-browser access must not require guest' }).Count) { throw 'Host-browser guest cleanup contradiction escaped validation.' }
        $portalEntry.cleanup = 'Sign out and close the portal browser; retain only private conceptual notes.'
        $passed++
    }
    $output = & $engine -NoProfile -ExecutionPolicy Bypass -File $preflight -SkipHostChecks -AsJson -CurriculumPath 'Instructions/Labs/BranchCache.md' -VmName 'WIN-CL1'
    if ($LASTEXITCODE -ne 0) { throw 'Local exercise unexpectedly required Azure parameters.' }
    $checks = $output -join "`n" | ConvertFrom-Json
    if (!@($checks | Where-Object { $_.Name -eq 'Required VMs' -and $_.Status -eq 'Warning' }).Count) { throw 'Missing VM comparison did not warn.' }
    if (@($checks | Where-Object { $_.Name -eq 'Supplied VM comparison' }).Count) { throw 'Known VMware display alias was not mapped to the guest hostname.' }
    $passed++
    $output = & $engine -NoProfile -ExecutionPolicy Bypass -File $preflight -SkipHostChecks -AsJson -CurriculumPath 'Instructions/Practices/Create-a-Log-Analytics-Workspace.md' -AzureSubscriptionId '<AZURE_SUBSCRIPTION_ID>' -AzureRegion '<AZURE_REGION>' -AzureResourceGroup '<AZURE_RESOURCE_GROUP>' -AzureBudgetName '<AZURE_BUDGET_NAME>'
    if ($LASTEXITCODE -ne 0) { throw 'Azure placeholders were treated as real identifiers or missing values.' }
    $checks = $output -join "`n" | ConvertFrom-Json
    if (@($checks | Where-Object { $_.Name -in @('Azure Subscription','Azure Region','Azure ResourceGroup','Azure Budget') -and $_.Status -eq 'Skipped' }).Count -ne 4) { throw 'Not all Azure placeholders were skipped.' }
    if (!@($checks | Where-Object { $_.Name -eq 'Required outbound access' -and $_.Status -eq 'Warning' }).Count) { throw 'Required outbound access did not warn.' }
    $passed++
    $null = & $engine -NoProfile -ExecutionPolicy Bypass -File $preflight -SkipHostChecks -AsJson -CurriculumPath 'Instructions/Practices/Create-a-Log-Analytics-Workspace.md'
    if ($LASTEXITCODE -ne 1) { throw 'Azure-required exercise accepted absent explicit Azure parameters.' }
    $passed++
    $null = & $engine -NoProfile -ExecutionPolicy Bypass -File $preflight -SkipHostChecks -AsJson -CurriculumPath 'Instructions/Labs/does-not-exist.md'
    if ($LASTEXITCODE -ne 1) { throw 'Unknown curriculum path was accepted.' }
    $passed++
    $manifest.entries += $entry
    $fixtureManifest = Join-Path $fixtureRoot 'metadata\curriculum-manifest.json'
    [IO.File]::WriteAllText($fixtureManifest, ($manifest | ConvertTo-Json -Depth 24), $utf8)
    $output = & $engine -NoProfile -ExecutionPolicy Bypass -File $preflight -SkipHostChecks -AsJson -ManifestPath $fixtureManifest -CurriculumPath $entry.path
    if ($LASTEXITCODE -ne 1) { throw 'Ambiguous curriculum selection was accepted.' }
    $passed++
} finally {
    $resolvedFixture = [IO.Path]::GetFullPath($fixtureRoot)
    if (!$resolvedFixture.StartsWith($tempRoot, [StringComparison]::OrdinalIgnoreCase) -or [IO.Path]::GetFileName($resolvedFixture) -notlike 'WindowsServer-curriculum-test-*') { throw 'Refusing cleanup outside the dedicated temporary fixture.' }
    Remove-Item -LiteralPath $resolvedFixture -Recurse -Force
}
Write-Output "PASS: $passed mutation/preflight regression cases plus real-curriculum baseline under $($PSVersionTable.PSVersion)."
