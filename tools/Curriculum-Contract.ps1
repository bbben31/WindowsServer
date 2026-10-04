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
        $details = @($display, $aliases, $_.phase) | Where-Object { ![string]::IsNullOrWhiteSpace($_) } | ForEach-Object { $_.Trim() }
        $_.guestHostname.Trim() + ' (' + ($details -join '; ') + ')'
    })
    $machineText = if ($machines.Count) { $machines -join '; ' } else { 'No dedicated guest; use the host/browser or existing tenant context specified by this reference.' }
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
    $lines.Add('**Risk, cost and optional status:** ' + $Entry.riskCost.risk + '; ' + $Entry.riskCost.costClass + '; optional=' + $Entry.compatibility.optional.ToString().ToLowerInvariant() + '. ' + $Entry.riskCost.cost + ' ' + $Entry.compatibility.notes)
    $lines.Add('')
    $lines.Add('**Success verification:** ' + (@($Entry.verification) -join ' '))
    $lines.Add('')
    $lines.Add('**Rollback and cleanup:** ' + $Entry.cleanup)
    $lines.Add('')
    $lines.Add('<!-- END GENERATED COMPLETION CONTRACT -->')
    return $lines -join "`n"
}

function Set-CurriculumContractText {
    param([string]$Content, $Entry)
    $Content = $Content.Replace("`r`n", "`n").TrimEnd()
    $block = Get-CurriculumContract $Entry
    $pattern = '(?s)<!-- BEGIN GENERATED COMPLETION CONTRACT -->.*?<!-- END GENERATED COMPLETION CONTRACT -->'
    if ([regex]::IsMatch($Content, $pattern)) {
        return [regex]::Replace($Content, $pattern, [Text.RegularExpressions.MatchEvaluator]{ param($match) $block }) + "`n"
    }
    $firstNewline = $Content.IndexOf("`n")
    return $Content.Substring(0, $firstNewline) + "`n`n" + $block + "`n" + $Content.Substring($firstNewline) + "`n"
}

function ConvertTo-CurriculumJson {
    param($Value)
    $json = $Value | ConvertTo-Json -Depth 24 -Compress
    $json = $json.Replace('\u0026', '&').Replace('\u0027', "'").Replace('\u003c', '<').Replace('\u003e', '>')
    return (Format-Json $json) + "`n"
}
