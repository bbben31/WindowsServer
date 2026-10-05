# Shared, deterministic rendering. All requirements come from explicit source metadata.
function Get-CurriculumContract {
    param($Entry)
    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add('<!-- BEGIN GENERATED COMPLETION CONTRACT -->')
    $lines.Add('## Self-learner completion contract')
    $lines.Add('')
    $lines.Add('Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.')
    $lines.Add('')
    $lines.Add('**Prerequisites (in order):** ' + (@($Entry.dependencies) -join '; ') + '. ' + (@($Entry.prerequisiteState) -join ' '))
    $machines = @($Entry.vmTopology | ForEach-Object {
        $aliasNames = @($_.displayNameAliases | Where-Object { ![string]::IsNullOrWhiteSpace($_) } | ForEach-Object { $_.Trim() })
        $aliases = if ($aliasNames.Count) { 'accepted display aliases: ' + ($aliasNames -join ', ') } else { '' }
        $display = if ($_.layer -eq 'inner-hyper-v') { 'Hyper-V name: ' + $_.hyperVName } else { 'VMware display: ' + $_.vmwareDisplayName }
        $phaseText = switch ($_.phase) { 'created' { 'created in the designated task; not a preflight prerequisite' }; 'conditional' { 'conditional until retired; supply the guest or explicitly confirm retirement with -RetiredVmName' }; default { $_ } }
        $details = @($display, $aliases, $phaseText) | Where-Object { ![string]::IsNullOrWhiteSpace($_) } | ForEach-Object { $_.Trim() }
        $_.guestHostname.Trim() + ' (' + ($details -join '; ') + ')'
    })
    $machineText = if ($machines.Count) { $machines -join '; ' } else { 'No dedicated guest; use the host/browser or existing tenant context specified by this reference' }
    $alternatives = @($Entry.alternativeVmGroups | Where-Object { $_ } | ForEach-Object {
        $alternativeNames = @($_.names | Where-Object { ![string]::IsNullOrWhiteSpace($_) } | ForEach-Object { $_.Trim() })
        if ($alternativeNames.Count) {
            $alternativeParts = @('At least ' + $_.minimum + ' of [' + ($alternativeNames -join ', ') + ']:', $_.reason)
            (@($alternativeParts | Where-Object { ![string]::IsNullOrWhiteSpace($_) } | ForEach-Object { $_.Trim() }) -join ' ')
        }
    })
    $lines.Add('')
    $machineParts = @($machineText + '.') + @($alternatives) + @($Entry.networks)
    $machineParts = @($machineParts | Where-Object { ![string]::IsNullOrWhiteSpace($_) } | ForEach-Object { $_.Trim() })
    $lines.Add('**Machines and network profile:** ' + ($machineParts -join ' '))
    $lines.Add('')
    $lines.Add('**Permissions:** ' + (@($Entry.permissions) -join ' '))
    $lines.Add('')
    $endpoints = @($Entry.outbound.endpoints | Where-Object { ![string]::IsNullOrWhiteSpace($_) })
    $endpointText = if ($endpoints.Count) { ' Endpoints: ' + ($endpoints -join '; ') + '.' } else { '' }
    $lines.Add('**Outbound access:** ' + $Entry.outbound.method + $endpointText)
    $lines.Add('')
    $costText = $Entry.riskCost.cost.Trim()
    if ($costText -ieq $Entry.riskCost.costClass) { $costText = '' }
    if ($costText) { $costText = $costText.Substring(0, 1).ToUpperInvariant() + $costText.Substring(1); if ($costText -notmatch '[.!?]$') { $costText += '.' } }
    $riskParts = @(($Entry.riskCost.risk + '; ' + $Entry.riskCost.costClass + '; optional=' + $Entry.compatibility.optional.ToString().ToLowerInvariant() + '.'), $costText, $Entry.compatibility.notes)
    $lines.Add('**Risk, cost and optional status:** ' + (@($riskParts | Where-Object { ![string]::IsNullOrWhiteSpace($_) } | ForEach-Object { $_.Trim() }) -join ' '))
    $lines.Add('')
    $lines.Add('**Success verification:** ' + (@($Entry.verification) -join ' '))
    $lines.Add('')
    $lines.Add('**Rollback and cleanup:** ' + $Entry.cleanup)
    $lines.Add('')
    $lines.Add('<!-- END GENERATED COMPLETION CONTRACT -->')
    return $lines -join "`n"
}

function Get-CurriculumRequiredVmLines {
    param($Entry)
    $alternativeNames = @($Entry.alternativeVmGroups | ForEach-Object { $_.names })
    $lines = @($Entry.vmTopology | Where-Object { $_.phase -in @('existing','existing-inner') -and $_.guestHostname -notin $alternativeNames } | ForEach-Object { '* ' + $_.guestHostname })
    $lines += @($Entry.alternativeVmGroups | ForEach-Object { '* One active domain controller: ' + ($_.names -join ' or ') })
    $lines += @($Entry.vmTopology | Where-Object phase -eq 'conditional' | ForEach-Object { '* Conditional until retired: ' + $_.guestHostname })
    $lines += @($Entry.vmTopology | Where-Object phase -eq 'created' | ForEach-Object { '* Created during exercise: ' + $_.guestHostname })
    if (!$lines.Count) { return 'None; use the declared host/browser reference context.' }
    return $lines -join "`n"
}

function Set-CurriculumRequiredVmText {
    param([string]$Content, $Entry)
    $Content = $Content.Replace("`r`n", "`n")
    $pattern = '(?m)(^## Required VMs\n\n)(?:(?:\* |VN[123]-|CL\d|None;)[^\n]*\n?)+'
    if (![regex]::IsMatch($Content, $pattern)) { throw "Required VMs list missing: $($Entry.path)" }
    $list = Get-CurriculumRequiredVmLines $Entry
    return [regex]::Replace($Content, $pattern, [Text.RegularExpressions.MatchEvaluator]{ param($match) $match.Groups[1].Value + $list + "`n" })
}

function Set-CurriculumContractText {
    param([string]$Content, $Entry)
    $Content = $Content.TrimStart([char]0xFEFF).Replace("`r`n", "`n").TrimEnd()
    $block = Get-CurriculumContract $Entry
    $pattern = '(?s)<!-- BEGIN GENERATED COMPLETION CONTRACT -->.*?<!-- END GENERATED COMPLETION CONTRACT -->'
    $Content = [regex]::Replace($Content, $pattern, '').TrimStart([char[]]@([char]0xFEFF, [char]10, [char]13))
    $title = [regex]::Match($Content, '(?m)^# [^\n]+')
    if (!$title.Success) { throw "Curriculum document has no H1 title: $($Entry.path)" }
    $titleEnd = $title.Index + $title.Length
    return $Content.Substring(0, $titleEnd) + "`n`n" + $block + "`n`n" + $Content.Substring($titleEnd).TrimStart([char]10).TrimEnd() + "`n"
}

function ConvertTo-CurriculumJson {
    param($Value)
    $json = $Value | ConvertTo-Json -Depth 24 -Compress
    $json = $json.Replace('\u0026', '&').Replace('\u0027', "'").Replace('\u003c', '<').Replace('\u003e', '>')
    return (Format-Json $json) + "`n"
}
