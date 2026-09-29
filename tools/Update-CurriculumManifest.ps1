[CmdletBinding(SupportsShouldProcess)]
param([string]$RepositoryRoot)

$ErrorActionPreference = 'Stop'
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) { $RepositoryRoot = Split-Path $scriptRoot -Parent }
$RepositoryRoot = (Resolve-Path -LiteralPath $RepositoryRoot).Path
$manifestPath = Join-Path $RepositoryRoot 'metadata\curriculum-manifest.json'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false, $true)

function Read-Utf8Text([string]$Path) {
    return [System.IO.File]::ReadAllText($Path, $utf8NoBom)
}

function Format-Json([string]$Json) {
    $builder = New-Object System.Text.StringBuilder
    $indent = 0
    $inString = $false
    $escaped = $false

    for ($index = 0; $index -lt $Json.Length; $index++) {
        $character = $Json[$index]
        if ($inString) {
            [void]$builder.Append($character)
            if ($escaped) { $escaped = $false }
            elseif ($character -eq '\') { $escaped = $true }
            elseif ($character -eq '"') { $inString = $false }
            continue
        }

        if ($character -eq '"') {
            $inString = $true
            [void]$builder.Append($character)
        }
        elseif ($character -eq '{' -or $character -eq '[') {
            $closingCharacter = if ($character -eq '{') { '}' } else { ']' }
            if ($index + 1 -lt $Json.Length -and $Json[$index + 1] -eq $closingCharacter) {
                [void]$builder.Append($character).Append($closingCharacter)
                $index++
            }
            else {
                $indent++
                [void]$builder.Append($character).Append("`n").Append('  ' * $indent)
            }
        }
        elseif ($character -eq '}' -or $character -eq ']') {
            $indent--
            [void]$builder.Append("`n").Append('  ' * $indent).Append($character)
        }
        elseif ($character -eq ',') {
            [void]$builder.Append($character).Append("`n").Append('  ' * $indent)
        }
        elseif ($character -eq ':') {
            [void]$builder.Append(': ')
        }
        elseif (![char]::IsWhiteSpace($character)) {
            [void]$builder.Append($character)
        }
    }

    return $builder.ToString()
}

$manifest = Read-Utf8Text $manifestPath | ConvertFrom-Json

$azureServices = @{
    'Instructions/Practices/Add-server-to-Azure-Arc.md' = @('Azure Arc-enabled servers')
    'Instructions/Practices/Create-a-Log-Analytics-Workspace.md' = @('Azure Monitor', 'Log Analytics')
    'Instructions/Practices/Create-an-Automation-account.md' = @('Azure Automation')
    'Instructions/Practices/Register-Windows-Admin-Center-with-Azure.md' = @('Windows Admin Center Azure integration', 'Microsoft Entra ID')
    'Instructions/Labs/Deploying-a-hybrid-cloud-model.md' = @('Microsoft Entra Connect', 'Microsoft Entra ID')
    'Instructions/Labs/Distributed-File-System-and-Azure-File-Sync.md' = @('Azure File Sync', 'Azure Storage')
    'Instructions/Labs/Managing-hybrid-servers-using-Azure-Arc.md' = @('Azure Arc', 'Azure Monitor', 'Azure Policy', 'Azure Update Manager')
}

$azurePermission = @{
    'Instructions/Practices/Add-server-to-Azure-Arc.md' = 'Azure Connected Machine onboarding role at disposable resource-group scope'
    'Instructions/Practices/Create-a-Log-Analytics-Workspace.md' = 'Log Analytics Contributor at disposable resource-group scope'
    'Instructions/Practices/Create-an-Automation-account.md' = 'Automation Contributor at disposable resource-group scope'
    'Instructions/Practices/Register-Windows-Admin-Center-with-Azure.md' = 'Windows Admin Center gateway administrator plus authority to create or approve the required Entra application permissions'
    'Instructions/Labs/Deploying-a-hybrid-cloud-model.md' = 'Hybrid Identity Administrator assigned directly; temporary AD DS Enterprise Admin only for connector setup'
    'Instructions/Labs/Distributed-File-System-and-Azure-File-Sync.md' = 'Permission to create Storage and Storage Sync resources and register the server at disposable resource-group scope'
    'Instructions/Labs/Managing-hybrid-servers-using-Azure-Arc.md' = 'Azure Arc resource permissions plus the narrowest Azure Policy, Monitor, and Update Manager roles required by each exercise'
}

foreach ($entry in $manifest.entries) {
    $documentPath = Join-Path $RepositoryRoot $entry.path
    $content = Read-Utf8Text $documentPath

    $requiredVms = @(
        [regex]::Matches($content, '(?i)\b(?:VN[123]-SRV\d+|PM-SRV\d+|CL\d+|WIN-[A-Z0-9-]+)\b') |
            ForEach-Object { $_.Value.ToUpperInvariant() } |
            Sort-Object -Unique
    )
    if ($requiredVms.Count) {
        $entry.requiredVmsOrTopology = $requiredVms
    }
    else {
        $entry.requiredVmsOrTopology = @('No dedicated VM beyond the environment-profile prerequisites named in the procedure')
    }

    $networks = [System.Collections.Generic.List[string]]::new()
    if ($content -match '\b10\.1\.(?:1|2|3|128|144|160|200|201)\.') {
        $networks.Add('Enterprise expansion profile: isolated source 10.1.x.0/24 segments mapped to dedicated VMware custom VMnets')
    }
    if ($content -match '\b10\.10\.(?:10|20|30)\.') {
        $networks.Add('Core learner profile: VMnet10 10.10.10.0/24, VMnet20 10.10.20.0/24, and/or VMnet30 10.10.30.0/24 as named by the procedure')
    }
    if (!$networks.Count -and $content -match '(?i)\bVNet[123]\b') {
        $networks.Add('Enterprise expansion profile: map each named source VNet to an isolated VMware custom VMnet')
    }
    if ($azureServices.ContainsKey($entry.path)) {
        $networks.Add('Temporary VMware NAT (VMnet8) for approved outbound Azure access; disconnect after the exercise')
    }
    if (!$networks.Count) {
        $networks.Add('Existing selected environment-profile connectivity; no additional segment declared by this procedure')
    }
    $entry.networks = @($networks)

    $permissions = [System.Collections.Generic.List[string]]::new()
    if ($content -match '(?i)ad\\+Administrator|Administrator@ad\.lab\.test') {
        $permissions.Add('Lab Domain Administrator for the named AD DS configuration steps')
    }
    if ($content -match '(?i)\.\\+Administrator|local administrator|run .* as administrator|terminal \(admin') {
        $permissions.Add('Local Administrator on the named disposable lab machines')
    }
    if ($azurePermission.ContainsKey($entry.path)) {
        $permissions.Add($azurePermission[$entry.path])
    }
    if (!$permissions.Count) {
        $permissions.Add('Standard lab user; elevate only when an individual step explicitly requires administrative rights')
    }
    $entry.permissions = @($permissions | Select-Object -Unique)

    $dependencies = [System.Collections.Generic.List[string]]::new()
    foreach ($match in [regex]::Matches($content, '(?!!)\[[^\]]+\]\(([^)#]+\.md)(?:#[^)]+)?\)')) {
        $target = [uri]::UnescapeDataString($match.Groups[1].Value)
        $absoluteTarget = [IO.Path]::GetFullPath((Join-Path (Split-Path -Parent $documentPath) $target))
        if ($absoluteTarget.StartsWith($RepositoryRoot, [StringComparison]::OrdinalIgnoreCase) -and
            (Test-Path -LiteralPath $absoluteTarget -PathType Leaf)) {
            $relativeTarget = $absoluteTarget.Substring($RepositoryRoot.Length + 1).Replace('\', '/')
            if ($relativeTarget -ne $entry.path) { $dependencies.Add($relativeTarget) }
        }
    }
    if (!$dependencies.Count) {
        $dependencies.Add('Instructions/General/Learner-Setup.md')
        $dependencies.Add('Instructions/General/Environment-Profiles.md')
    }
    $entry.dependencies = @($dependencies | Select-Object -Unique)

    if ($content -match '(?i)Windows 10') {
        $entry.windowsVersionAssumptions = 'Windows Server 2025 and Windows 11 baseline; adapt historical Windows 10 UI labels unless the exercise explicitly tests legacy behavior.'
    }
    elseif ($content -match '(?i)Windows Server 2022') {
        $entry.windowsVersionAssumptions = 'Windows Server 2025 baseline; Windows Server 2022 is retained only where this procedure explicitly requires it.'
    }
    else {
        $entry.windowsVersionAssumptions = 'Windows Server 2025 and Windows 11 learner baseline; verify optional product-specific support before provisioning.'
    }

    $requiresAzure = $azureServices.ContainsKey($entry.path)
    $entry.azure.required = $requiresAzure
    if ($requiresAzure) {
        $entry.azure.services = @($azureServices[$entry.path])
        $entry.azure.region = 'UK South when supported; verify current regional availability'
        $entry.azure.scope = 'Existing Azure for Students tenant/subscription; disposable per-lab resource group'
        $entry.riskCost.cost = "Azure cost-gated; stop at the $([char]0x00A3)10 monthly safety limit"
    }
    elseif ($entry.path -eq 'Instructions/Practices/Create-an-Azure-Subscription.md' -or
        $entry.path -eq 'Instructions/Practices/Create-an-Entra-ID-tenant.md') {
        $entry.azure.services = @('Conceptual reference only; no Azure resource or tenant creation')
        $entry.azure.region = 'Not applicable'
        $entry.azure.scope = 'Existing tenant/subscription only; no mutation'
        $entry.riskCost.cost = 'no deployment'
    }
    elseif ($entry.path -eq 'Instructions/Labs/Windows-Admin-Center.md') {
        $entry.azure.services = @('Optional Windows Admin Center Azure integration')
        $entry.azure.region = 'UK South when optional integration is selected'
        $entry.azure.scope = 'Local lab by default; existing tenant/subscription for optional integration'
        $entry.riskCost.cost = 'local-only unless optional Azure integration is selected'
    }
    else {
        $entry.azure.services = @('None')
        $entry.azure.region = 'Not applicable'
        $entry.azure.scope = 'Not applicable'
        $entry.riskCost.cost = 'local-only'
    }

    $profileNote = if ($entry.networks -match 'Enterprise expansion') {
        'Enterprise expansion profile; retain the named multi-server roles and isolate all source networks in VMware.'
    }
    else {
        'Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.'
    }
    $entry.compatibility.notes = "$profileNote Verify current support for optional products before execution."
}

$manifest.schemaVersion = 2
$json = $manifest | ConvertTo-Json -Depth 12 -Compress
# Windows PowerShell 5.1 escapes HTML-sensitive characters that PowerShell 7
# leaves readable. Normalize them before applying repository-standard layout.
$json = $json.Replace('\u0026', '&').Replace('\u0027', "'").Replace('\u003c', '<').Replace('\u003e', '>')
$json = Format-Json $json
if ($PSCmdlet.ShouldProcess($manifestPath, 'Write regenerated curriculum metadata')) {
    [System.IO.File]::WriteAllText($manifestPath, $json + "`n", $utf8NoBom)
}

Write-Output "Updated $(@($manifest.entries).Count) manifest entries."
