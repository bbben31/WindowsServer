[CmdletBinding()]
param([string]$RepositoryRoot)
$ErrorActionPreference = 'Stop'
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
if (!$RepositoryRoot) { $RepositoryRoot = Split-Path $scriptRoot -Parent }
$RepositoryRoot = (Resolve-Path -LiteralPath $RepositoryRoot).Path
. (Join-Path $scriptRoot 'Test-CurriculumRules.ps1')
$manifest = [IO.File]::ReadAllText((Join-Path $RepositoryRoot 'metadata\curriculum-manifest.json')) | ConvertFrom-Json
$baselineErrors = @(Test-CurriculumRules $manifest.entries $RepositoryRoot)
if ($baselineErrors.Count) { throw "Baseline rules failed: $($baselineErrors -join '; ')" }
$tempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
$fixtureRoot = Join-Path $tempRoot ('WindowsServer-curriculum-test-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $fixtureRoot | Out-Null
$utf8 = New-Object Text.UTF8Encoding($false)
$passed = 0
try {
    Copy-Item -LiteralPath (Join-Path $RepositoryRoot 'Instructions') -Destination $fixtureRoot -Recurse
    New-Item -ItemType Directory -Path (Join-Path $fixtureRoot 'metadata') | Out-Null
    $entry = $manifest.entries | Where-Object path -eq 'Instructions/Labs/BranchCache.md'
    $entryJson = $entry | ConvertTo-Json -Depth 24
    $documentPath = Join-Path $fixtureRoot $entry.path
    $original = [IO.File]::ReadAllText($documentPath).Replace("`r`n","`n")
    $cases = @(
        @{ Name='local Azure cleanup'; Expect='non-Azure entry has Azure-only cleanup'; Edit={param($e) $e.cleanup='Deallocate/delete disposable Azure resources and verify the lab resource group is empty.'} },
        @{ Name='Azure guidance'; Expect='Azure entry lacks cost and cleanup guidance'; Edit={param($e) $e.azure.required=$true; $e.riskCost.cost='free'; $e.cleanup=''} },
        @{ Name='duplicate Required VMs'; Expect='duplicate Required VMs'; Text={param($t) $t.Replace("* CL3`n","* CL3`n* CL3`n")} },
        @{ Name='missing task VM'; Expect='task/setup VM absent from Required VMs'; Append="`nPerform this task on VN1-SRV99.`n" },
        @{ Name='reference exemption target'; Expect='operational task/setup VM absent from Required VMs'; Edit={param($e) $e.referencedVms+= [pscustomobject]@{name='VN1-SRV99';reason='Example output only'}}; Append="`nPerform this task on VN1-SRV99.`n" },
        @{ Name='outer Hyper-V'; Expect='outer Hyper-V management'; Append="`n````powershell`nStop-VM -Name WIN-CL3`n`````n" },
        @{ Name='Hyper-V lab outer target'; Expect='outer VMware VM targeted by Hyper-V management'; Edit={param($e) $e.hyperVTeaching=$true; $e.prerequisiteState+= 'Commands must run in a nested host.'}; Append="`n~~~powershell`nStop-VM -Name 'WIN-CL3'`n~~~`n" },
        @{ Name='WAC target'; Expect='adjacent Windows Admin Center targets mismatch'; Append="`n1. In Windows Admin Center, on the connections page, click **vn1-srv10.ad.lab.test**.`n1. Connected to vn1-srv4.ad.lab.test, under **Tools**, click **Roles & features**.`n" },
        @{ Name='invalid domain'; Expect='known invalid domain'; Append="`n<!-- https://admincenter.smart.etc -->`n" },
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
