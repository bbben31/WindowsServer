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
    $preflight = Join-Path $scriptRoot 'Preflight-LearnerLab.ps1'
    $tokens = $null; $parseErrors = $null
    $ast = [Management.Automation.Language.Parser]::ParseInput([IO.File]::ReadAllText($preflight), [ref]$tokens, [ref]$parseErrors)
    $forbiddenCalls = @($ast.FindAll({param($node) $node -is [Management.Automation.Language.CommandAst] -and $node.GetCommandName() -match '^(?:Connect-|New-|Remove-|Start-|Stop-|Install-|Uninstall-|Update-|Invoke-|Get-AD|az$)'}, $true))
    if ($forbiddenCalls.Count -or $parseErrors.Count) { throw 'Preflight contains an authentication/mutation command or parse error.' }
    $passed++
    $engine = if ($PSVersionTable.PSEdition -eq 'Desktop') { Join-Path $PSHOME 'powershell.exe' } else { Join-Path $PSHOME 'pwsh.exe' }
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
