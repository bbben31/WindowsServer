function Test-CurriculumRules {
    param($Entries, [string]$RepositoryRoot)
    $failures = [System.Collections.Generic.List[string]]::new()
    foreach ($entry in $Entries) {
        $path = Join-Path $RepositoryRoot $entry.path
        $content = [IO.File]::ReadAllText($path).Replace("`r`n", "`n")
        $procedure = [regex]::Replace($content, '(?s)<!-- BEGIN GENERATED COMPLETION CONTRACT -->.*?<!-- END GENERATED COMPLETION CONTRACT -->', '')
        $label = $entry.path
        foreach ($field in @('vmTopology','alternativeVmGroups','referencedVms','prerequisiteState','verification','outbound','networkProfile','hyperVTeaching')) {
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
        if (!@($entry.verification).Count -or !@($entry.permissions).Count -or !@($entry.dependencies).Count -or [string]::IsNullOrWhiteSpace($entry.cleanup)) {
            $failures.Add("${label}: incomplete completion contract")
        }
        foreach ($dependency in $entry.dependencies) {
            if ($dependency -eq $entry.path -or !(Test-Path -LiteralPath (Join-Path $RepositoryRoot $dependency) -PathType Leaf)) { $failures.Add("${label}: invalid prerequisite $dependency") }
        }
        $names = @($entry.vmTopology | ForEach-Object guestHostname)
        if (@($names | Group-Object | Where-Object Count -gt 1).Count) { $failures.Add("${label}: duplicate manifest VM") }
        if ((@($names | Sort-Object) -join '|') -ne (@($entry.requiredVmsOrTopology | Sort-Object) -join '|')) { $failures.Add("${label}: required VM topology disagrees with manifest names") }
        foreach ($vm in $entry.vmTopology) {
            if (($vm.layer -eq 'outer-vmware' -and !$vm.vmwareDisplayName) -or ($vm.layer -eq 'inner-hyper-v' -and !$vm.hyperVName) -or $vm.layer -notin @('outer-vmware','inner-hyper-v') -or $vm.phase -notin @('existing','existing-inner','created','conditional')) { $failures.Add("${label}: incomplete display/hostname/layer mapping") }
        }
        foreach ($reference in $entry.referencedVms) { if ([string]::IsNullOrWhiteSpace($reference.reason)) { $failures.Add("${label}: unexplained reference-only VM") } }
        $requiredSection = [regex]::Match($procedure, '(?ms)^## Required VMs\s*\n(.*?)(?=^## |\z)').Groups[1].Value
        # Only the initial list is authoritative; alternatives and phased notes below it are not duplicate declarations.
        $initial = [regex]::Match($requiredSection.TrimStart(), '(?m)\A(?:(?:\* |VN[123]-|CL\d)[^\n]*\n?)+').Value
        $declared = @([regex]::Matches($initial, '(?m)^(?:\* )?([A-Z][A-Z0-9-]+)\b') | ForEach-Object { $_.Groups[1].Value.ToUpperInvariant() })
        if (@($declared | Group-Object | Where-Object Count -gt 1).Count) { $failures.Add("${label}: duplicate Required VMs") }
        if ((@($declared | Sort-Object -Unique) -join '|') -ne (@($names | Sort-Object -Unique) -join '|')) { $failures.Add("${label}: Required VMs disagree with authoritative topology") }
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
        if ($procedure -match '(?i)comicrosoft\.com|smart\.etc|smpt\.ad\.lab\.test') { $failures.Add("${label}: known invalid domain") }
        $adminPattern = '(?im)^\s*(?:Install-WindowsFeature|Enable-ADOptionalFeature|New-NetLbfoTeam|Set-NetIPInterface|Add-DhcpServer\w*|Set-DhcpServer\w*|Set-VMProcessor|Install-ADDS\w*|Set-ADForest|Set-ADDomain|Set-ItemProperty|Set-OSConfigDesiredConfiguration)\b'
        if ($procedure -match $adminPattern -and (@($entry.permissions) -join ' ') -notmatch '(?i)Administrator|Admin\b|delegated|authorization|Schema') { $failures.Add("${label}: administrative commands paired only with standard-user permissions") }
        $downloadPattern = '(?im)^\s*(?:Install-Module|Find-Module|Update-Module|Update-Help|Invoke-WebRequest|Add-WindowsCapability|git\s+(?:clone|pull)|winget\s+(?:install|upgrade))\b|^\s*1\. [^\n]*(?:download and install|Microsoft Store|Download .* from|download .*installer|Download .*<https?://)|docker image pull|wsl --install'
        if ($procedure -match $downloadPattern -and !$entry.outbound.required) { $failures.Add("${label}: download/install without declared outbound access") }
        if ($entry.outbound.required -and ((@($entry.networks) -join ' ') -notmatch 'VMnet8' -or !@($entry.outbound.endpoints).Count -or $entry.cleanup -notmatch '(?i)VMnet8|NAT|outbound')) { $failures.Add("${label}: incomplete outbound access/cleanup contract") }
        foreach ($issue in [regex]::Matches($procedure, '(?im)^.*https://github\.com/[^/\s)]+/[^/\s)]+/issues/\d+.*$')) {
            if ($issue.Value.Length -lt 180) { $failures.Add("${label}: external known issue lacks local adapted explanation") }
        }
    }
    return $failures.ToArray()
}
