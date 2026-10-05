function Test-CurriculumDependencyCycles {
    param($CurriculumEntries)
    $graph = @{}; $states = @{}; $stack = [System.Collections.Generic.List[string]]::new()
    foreach ($item in $CurriculumEntries) { $graph[$item.path] = @($item.dependencies) }
    $visit = {
        param([string]$node)
        if ($states[$node] -eq 'active') { throw ('Dependency cycle: ' + (($stack.ToArray() + $node) -join ' -> ')) }
        if ($states[$node] -eq 'done') { return }
        $states[$node] = 'active'; $stack.Add($node)
        foreach ($next in $graph[$node]) { if ($graph.ContainsKey($next)) { & $visit $next } }
        $stack.RemoveAt($stack.Count - 1); $states[$node] = 'done'
    }
    foreach ($node in $graph.Keys) { & $visit $node }
}

function Test-CurriculumRules {
    param($Entries, [string]$RepositoryRoot)
    $failures = [System.Collections.Generic.List[string]]::new()
    $profileEntries = $Entries
    $sourceFile = Join-Path $RepositoryRoot 'metadata/curriculum-source.json'
    if (Test-Path -LiteralPath $sourceFile) { $profileEntries = ([IO.File]::ReadAllText($sourceFile) | ConvertFrom-Json).entries }
    $profiles = @{}; foreach ($item in $profileEntries) { $profiles[$item.path] = $item }
    foreach ($item in $Entries) { $profiles[$item.path] = $item }
    foreach ($entry in $Entries) {
        $path = Join-Path $RepositoryRoot $entry.path
        $content = [IO.File]::ReadAllText($path).Replace("`r`n", "`n")
        $procedure = [regex]::Replace($content, '(?s)<!-- BEGIN GENERATED COMPLETION CONTRACT -->.*?<!-- END GENERATED COMPLETION CONTRACT -->', '')
        $label = $entry.path
        $title = [regex]::Match($content.TrimStart([char]0xFEFF), '(?m)^# [^\n]+')
        if (!$title.Success) { $failures.Add("${label}: curriculum document has no H1 title") }
        elseif ($content.IndexOf('<!-- BEGIN GENERATED COMPLETION CONTRACT -->') -lt $title.Index) { $failures.Add("${label}: completion contract precedes H1 title") }
        if ($label -match '(?i)DHCP' -and $procedure -match '\b10\.1\.\d+\.(?:\d+|\*)' -and $entry.networkProfile -ne 'enterprise') {
            $failures.Add("${label}: enterprise DHCP addresses require enterprise metadata profile")
        }
        if ($label -eq 'Instructions/Practices/Authorize-DHCP-server-and-activate-scope.md') {
            if ($procedure -match '\b10\.10\.30\.0\b') { $failures.Add("${label}: obsolete core DHCP activation scope") }
            $creatorPath = 'Instructions/Practices/Add-a-DHCP-scope.md'
            $creator = [IO.File]::ReadAllText((Join-Path $RepositoryRoot $creatorPath))
            $creator = [regex]::Replace($creator, '(?s)<!-- BEGIN GENERATED COMPLETION CONTRACT -->.*?<!-- END GENERATED COMPLETION CONTRACT -->', '')
            $range = [regex]::Match($creator, '(?i)Start IP address[^\r\n]*?\b(\d+\.\d+\.\d+)\.\d+')
            $prefix = [regex]::Match($creator, '(?i)In \*\*Length\*\*, type \*\*24\*\*')
            $createdScope = $range.Groups[1].Value + '.0'
            $activatedScopes = @([regex]::Matches($procedure, '(?i)Scope \[(\d+\.\d+\.\d+\.\d+)\]|\$scopeId\s*=\s*[\x27\x22](\d+\.\d+\.\d+\.\d+)[\x27\x22]') | ForEach-Object { if ($_.Groups[1].Success) { $_.Groups[1].Value } else { $_.Groups[2].Value } })
            if ($creatorPath -notin $entry.dependencies -or !$range.Success -or !$prefix.Success -or $activatedScopes.Count -lt 3 -or @($activatedScopes | Where-Object { $_ -ne $createdScope }).Count) {
                $failures.Add("${label}: prerequisite-created DHCP scope does not match GUI/PowerShell activation")
            }
        }
        foreach ($field in @('vmTopology','alternativeVmGroups','referencedVms','prerequisiteState','verification','outbound','networkProfile','hyperVTeaching','profileTransitions')) {
            if (!$entry.PSObject.Properties[$field]) { $failures.Add("${label}: missing authoritative field $field") }
        }
        if (!$entry.azure.required -and $entry.cleanup -match '(?i)delete.+Azure|deallocate.+Azure|verify.+resource group.+empty') {
            $failures.Add("${label}: non-Azure entry has Azure-only cleanup")
        }
        if ($entry.azure.required -and ($entry.riskCost.cost -notmatch '(?i)cost|charge|budget|GBP|safety' -or $entry.cleanup -notmatch '(?i)delete|remove' -or $entry.cleanup -notmatch '(?i)verif')) {
            $failures.Add("${label}: Azure entry lacks cost and cleanup guidance")
        }
        if ($entry.riskCost.costClass -notin @('local-only','conceptual','optional-azure','cost-gated') -or $entry.riskCost.risk -notin @('low','medium','high') -or $entry.networkProfile -notin @('core','enterprise','alternate-forest')) {
            $failures.Add("${label}: invalid manifest filter value")
        }
        if ($entry.azure.required -isnot [bool] -or $entry.compatibility.optional -isnot [bool] -or $entry.outbound.required -isnot [bool] -or $entry.hyperVTeaching -isnot [bool]) { $failures.Add("${label}: filter flags must be JSON booleans") }
        if ($entry.azure.required -and $entry.riskCost.costClass -ne 'cost-gated') { $failures.Add("${label}: Azure exercise must be cost-gated") }
        if (!$entry.compatibility.optional -and $entry.compatibility.notes -match '(?i)Verify current support for optional products') { $failures.Add("${label}: non-optional entry has generic optional-product compatibility warning") }
        $contract = [regex]::Match($content, '(?s)<!-- BEGIN GENERATED COMPLETION CONTRACT -->.*?<!-- END GENERATED COMPLETION CONTRACT -->').Value
        if ($contract -match '\S[ \t]{2,}\S') { $failures.Add("${label}: doubled topology separator spaces in generated contract") }
        if ($contract -match '(?<!\.)\.\.(?!\.)') { $failures.Add("${label}: doubled punctuation in generated contract") }
        if ($contract -match '(?i);\s*(local-only|conceptual|optional-azure|cost-gated); optional=(?:true|false)\.\s*\1\b') { $failures.Add("${label}: duplicated cost-class wording in generated contract") }
        if (!@($entry.verification).Count -or !@($entry.permissions).Count -or !@($entry.dependencies).Count -or [string]::IsNullOrWhiteSpace($entry.cleanup)) {
            $failures.Add("${label}: incomplete completion contract")
        }
        foreach ($dependency in $entry.dependencies) {
            if ($dependency -eq $entry.path -or !(Test-Path -LiteralPath (Join-Path $RepositoryRoot $dependency) -PathType Leaf)) { $failures.Add("${label}: invalid prerequisite $dependency") }
            if ($entry.networkProfile -eq 'core' -and $profiles.ContainsKey($dependency) -and $profiles[$dependency].networkProfile -ne 'core') {
                $justified = @($entry.profileTransitions | Where-Object { $_.dependency -eq $dependency -and ![string]::IsNullOrWhiteSpace($_.reason) })
                if ($justified.Count -ne 1) { $failures.Add("${label}: unexplained profile downgrade from $dependency") }
            }
        }
        foreach ($transition in $entry.profileTransitions) {
            if ($transition.dependency -notin $entry.dependencies -or !$profiles.ContainsKey($transition.dependency) -or [string]::IsNullOrWhiteSpace($transition.reason)) { $failures.Add("${label}: invalid profile transition justification") }
        }
        foreach ($vm in $entry.vmTopology | Where-Object phase -eq 'conditional') {
            if ([string]::IsNullOrWhiteSpace($vm.retirementReason)) { $failures.Add("${label}: conditional VM lacks retirement explanation") }
        }
        $names = @($entry.vmTopology | ForEach-Object guestHostname)
        if (@($names | Group-Object | Where-Object Count -gt 1).Count) { $failures.Add("${label}: duplicate manifest VM") }
        if ((@($names | Sort-Object) -join '|') -ne (@($entry.requiredVmsOrTopology | Sort-Object) -join '|')) { $failures.Add("${label}: required VM topology disagrees with manifest names") }
        foreach ($vm in $entry.vmTopology) {
            if (($vm.layer -eq 'outer-vmware' -and !$vm.vmwareDisplayName) -or ($vm.layer -eq 'inner-hyper-v' -and !$vm.hyperVName) -or $vm.layer -notin @('outer-vmware','inner-hyper-v') -or $vm.phase -notin @('existing','existing-inner','created','conditional')) { $failures.Add("${label}: incomplete display/hostname/layer mapping") }
        }
        foreach ($reference in $entry.referencedVms) { if ([string]::IsNullOrWhiteSpace($reference.reason)) { $failures.Add("${label}: unexplained reference-only VM") } }
        $requiredSection = [regex]::Match($procedure, '(?ms)^## Required VMs\s*\n(.*?)(?=^## |\z)').Groups[1].Value
        # Parse the initial list as mandatory machines plus explicit one-of groups.
        $initial = [regex]::Match($requiredSection.TrimStart(), '(?m)\A(?:(?:\* |VN[123]-|CL\d)[^\n]*\n?)+').Value
        $declared = @([regex]::Matches($initial, '(?m)^(?:\* )?((?!One\b)[A-Z][A-Z0-9-]+)\b') | ForEach-Object { $_.Groups[1].Value.ToUpperInvariant() })
        if (@($declared | Group-Object | Where-Object Count -gt 1).Count) { $failures.Add("${label}: duplicate Required VMs") }
        $alternativeNames = @($entry.alternativeVmGroups | ForEach-Object { $_.names })
        $mandatoryNames = @($entry.vmTopology | Where-Object { $_.phase -in @('existing','existing-inner') -and $_.guestHostname -notin $alternativeNames } | ForEach-Object guestHostname)
        if ((@($declared | Sort-Object -Unique) -join '|') -ne (@($mandatoryNames | Sort-Object -Unique) -join '|')) { $failures.Add("${label}: Required VMs disagree with mandatory authoritative topology") }
        if (@($declared | Where-Object { $_ -in $alternativeNames }).Count) { $failures.Add("${label}: alternatives rendered as unconditional requirements") }
        $documentGroups = @([regex]::Matches($initial, '(?m)^\* One active domain controller: ([A-Z0-9-]+(?: or [A-Z0-9-]+)+)\s*$') | ForEach-Object { ($_.Groups[1].Value -split ' or ' | Sort-Object) -join '|' })
        $metadataGroups = @($entry.alternativeVmGroups | ForEach-Object { if ($_.minimum -ne 1) { $failures.Add("${label}: Required VMs one-of syntax requires minimum=1") }; ($_.names | Sort-Object) -join '|' })
        if ((($documentGroups | Sort-Object) -join ';') -cne (($metadataGroups | Sort-Object) -join ';')) { $failures.Add("${label}: Required VMs alternative groups disagree with authoritative metadata") }
        foreach ($kind in @(@{prefix='Conditional until retired';phase='conditional'},@{prefix='Created during exercise';phase='created'})) {
            $documentNames = @([regex]::Matches($initial, '(?m)^\* ' + $kind.prefix + ': ([A-Z0-9-]+)\s*$') | ForEach-Object { $_.Groups[1].Value })
            $phaseNames = @($entry.vmTopology | Where-Object phase -eq $kind.phase | ForEach-Object guestHostname)
            if ((($documentNames | Sort-Object) -join '|') -cne (($phaseNames | Sort-Object) -join '|')) { $failures.Add("${label}: Required VMs $($kind.phase) lifecycle disagrees with metadata") }
        }
        $used = @([regex]::Matches($procedure, '(?i)\b(?:VN[123]-SRV\d+|PM-SRV\d+|CL\d+)\b') | ForEach-Object { $_.Value.ToUpperInvariant() } | Sort-Object -Unique)
        $allowed = @($names) + @($entry.referencedVms | ForEach-Object name)
        foreach ($name in $used) { if ($name -notin $allowed) { $failures.Add("${label}: task/setup VM absent from Required VMs: $name") } }
        # A reference exemption cannot excuse an actual execution/connection target.
        $operationalPattern = '(?i)(?:Perform (?:this task|these steps|these tasks) on|Connected to|On)\s+\*{0,2}(?:WIN-)?(VN[123]-SRV\d+|PM-SRV\d+|CL\d+)\b|-(?:ComputerName|VMName)\s+[\x27\x22]?(?:WIN-)?(VN[123]-SRV\d+|PM-SRV\d+|CL\d+)\b'
        foreach ($target in [regex]::Matches($procedure, $operationalPattern)) {
            $targetName = if ($target.Groups[1].Success) { $target.Groups[1].Value } else { $target.Groups[2].Value }
            if ($targetName -notin $names) { $failures.Add("${label}: operational task/setup VM absent from Required VMs: $targetName") }
        }
        if (!$entry.hyperVTeaching -and $procedure -match '(?im)^\s*(?:[\w$]+\s*\|\s*)?(?:Get-VM(?:NetworkAdapter|HardDiskDrive)?|Set-VM(?:Processor|NetworkAdapter)?|Stop-VM|Start-VM|Suspend-VM|Resume-VM|Connect-VMNetworkAdapter)\b|^\s*1\. (?:Open|Switch to) \*\*Hyper-V[ -]Manager') {
            $failures.Add("${label}: outer Hyper-V management in non-Hyper-V exercise")
        }
        if (!$entry.hyperVTeaching) {
            $codeText = ([regex]::Matches($procedure, '(?ms)^\s*(?:`{3,}|~{3,})powershell\s*\n(.*?)^\s*(?:`{3,}|~{3,})\s*$') | ForEach-Object { $_.Groups[1].Value }) -join "`n"
            if ($codeText -match '(?i)\b[A-Za-z]+-(?:VM\w*|VHD\w*)\b') { $failures.Add("${label}: Hyper-V VM/VHD cmdlet outside nested teaching") }
            $operationalLines = ($procedure -split "`n" | Where-Object { $_ -match '^\s*(?:\d+\.|In the instance|Perform|Switch to)' -and $_ -notmatch '(?i)not used|do not|never|not required' }) -join "`n"
            if ($operationalLines -match '(?i)Hyper-V Manager|Virtual Machine Connection|Connection to virtual (?:computer|machine)|Enhanced Session|\bMedia\b.+\bDVD Drive\b|menu on the virtual machine connection') { $failures.Add("${label}: Hyper-V console operation outside nested teaching") }
        }
        foreach ($block in [regex]::Matches($procedure, '(?ms)^\s*(?:`{3,}|~{3,})powershell\s*\n(.*?)^\s*(?:`{3,}|~{3,})\s*$')) {
            $code = $block.Groups[1].Value
            if ($code -match '(?i)\b(?:Stop-VM|Start-VM|Set-VMProcessor|Get-VMNetworkAdapter)\b') {
                foreach ($vm in $entry.vmTopology | Where-Object layer -eq 'outer-vmware') {
                    foreach ($display in @($vm.vmwareDisplayName) + @($vm.displayNameAliases)) {
                        if ($display -and $code -match ('(?i)[\x27\x22]' + [regex]::Escape($display) + '[\x27\x22]')) { $failures.Add("${label}: outer VMware VM targeted by Hyper-V management: $display") }
                    }
                }
            }
        }
        if ($entry.hyperVTeaching -and (@($entry.prerequisiteState) -join ' ') -notmatch '(?i)nested|inner') { $failures.Add("${label}: Hyper-V teaching lacks nested execution boundary") }
        $plain = $procedure.Replace('**','').Replace('`','')
        foreach ($match in [regex]::Matches($plain, '(?im)In Windows Admin Center, (?:on the connections page, )?click ([\w.-]+)\.[ \t]*\n1\. Connected to ([\w.-]+),')) {
            if ($match.Groups[1].Value -ine $match.Groups[2].Value) { $failures.Add("${label}: adjacent Windows Admin Center targets mismatch") }
        }
        if ($procedure -match '(?i)comicrosoft\.com|smart\.etc|smpt\.ad\.lab\.test|clients\.ad\.contoso\.com|ad\.clients\.lab\.test') { $failures.Add("${label}: known invalid domain") }
        if ((@($entry.outbound.endpoints) -join ' ') -match 'onlyOfficial') { $failures.Add("${label}: malformed combined outbound endpoint") }
        $adminPattern = '(?im)^\s*(?:Install-WindowsFeature|Enable-ADOptionalFeature|New-NetLbfoTeam|Set-NetIPInterface|Add-DhcpServer\w*|Set-DhcpServer\w*|Set-VMProcessor|Install-ADDS\w*|Set-ADForest|Set-ADDomain|Set-ItemProperty|Set-OSConfigDesiredConfiguration)\b'
        if ($procedure -match $adminPattern -and (@($entry.permissions) -join ' ') -notmatch '(?i)Administrator|Admin\b|delegated|authorization|Schema') { $failures.Add("${label}: administrative commands paired only with standard-user permissions") }
        $downloadPattern = '(?im)^\s*(?:Install-Module|Find-Module|Update-Module|Update-Help|Invoke-WebRequest|Add-WindowsCapability|git\s+(?:clone|pull)|winget\s+(?:install|upgrade))\b|^\s*1\. [^\n]*(?:download and install|Microsoft Store|Download .* from|download .*installer|Download .*<https?://)|docker image pull|wsl --install'
        $downloadPattern += '|Install-RemoteServerAdministrationTools\.ps1|install the optional feature \*\*RSAT|install (?:the )?(?:Active Directory )?extension'
        if ($procedure -match $downloadPattern -and !$entry.outbound.required) { $failures.Add("${label}: download/install without declared outbound access") }
        $networkCleanupPattern = '(?i)\b(?:remove|disconnect|detach|disable|restore)\b[^.\r\n]*(?:VMnet8|\bNAT\b|(?:temporary )?outbound(?: access| connectivity)?)|(?:VMnet8|\bNAT\b|outbound access)[^.\r\n]*\b(?:remove(?:d)?|disconnect(?:ed)?|detach(?:ed)?|disable(?:d)?|restore(?:d)?)\b'
        if ($entry.outbound.mode -notin @('none','guest-vmnet8','host-browser') -or ($entry.outbound.required -and $entry.outbound.mode -eq 'none') -or (!$entry.outbound.required -and $entry.outbound.mode -ne 'none')) { $failures.Add("${label}: invalid outbound access mode") }
        if ($entry.outbound.required -and (!@($entry.outbound.endpoints | Where-Object { ![string]::IsNullOrWhiteSpace($_) }).Count -or [string]::IsNullOrWhiteSpace($entry.outbound.method))) { $failures.Add("${label}: incomplete outbound purpose/endpoints") }
        if ($entry.outbound.required -and $entry.outbound.mode -eq 'guest-vmnet8' -and ((@($entry.networks) -join ' ') -notmatch 'VMnet8' -or $entry.cleanup -notmatch $networkCleanupPattern)) { $failures.Add("${label}: incomplete outbound access/cleanup contract") }
        if ($entry.outbound.mode -eq 'host-browser' -and (@($entry.vmTopology).Count -or $entry.cleanup -match $networkCleanupPattern -or (@($entry.networks) -join ' ') -notmatch '(?i)host.browser')) { $failures.Add("${label}: host-browser access must not require guest networking/cleanup") }
        if (!$entry.outbound.required) {
            $cleanupText = $entry.cleanup + "`n" + (([regex]::Matches($procedure, '(?ms)^## (?:Rollback[^\n]*|Cleanup[^\n]*)\n(.*?)(?=^## |\z)') | ForEach-Object { $_.Groups[1].Value }) -join "`n")
            foreach ($sentence in [regex]::Split($cleanupText, '(?<=[.!?])\s+|\r?\n')) {
                if ($sentence -notmatch $networkCleanupPattern) { continue }
                $conditional = $sentence -match '(?i)^\s*If temporary VMnet8 access was attached\b'
                $documentedOptional = $procedure -match '(?i)(?:attach|connect)[^.\r\n]*VMnet8[^.\r\n]*(?:only when|optional|if)|(?:optional|if)[^.\r\n]*(?:attach|connect)[^.\r\n]*VMnet8'
                if (!$conditional -or !$documentedOptional) { $failures.Add("${label}: non-required outbound access has unconditional or undocumented network cleanup") }
            }
        }
        foreach ($issue in [regex]::Matches($procedure, '(?im)^.*https://github\.com/[^/\s)]+/[^/\s)]+/issues/\d+.*$')) {
            if ($issue.Value.Length -lt 180) { $failures.Add("${label}: external known issue lacks local adapted explanation") }
        }
    }
    return $failures.ToArray()
}
