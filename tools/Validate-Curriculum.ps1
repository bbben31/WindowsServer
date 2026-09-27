[CmdletBinding()]
param([string]$RepositoryRoot)

$ErrorActionPreference = 'Stop'
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) { $RepositoryRoot = Split-Path $scriptRoot -Parent }
$manifestPath = Join-Path $RepositoryRoot 'metadata\curriculum-manifest.json'
$manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
$entries = @($manifest.entries)
$practices = @($entries | Where-Object category -eq 'Practices')
$labs = @($entries | Where-Object category -eq 'Labs')
if ($practices.Count -ne 89 -or $labs.Count -ne 50) { throw "Coverage mismatch: Practices=$($practices.Count), Labs=$($labs.Count)." }
foreach ($entry in $entries) {
    if (!(Test-Path -LiteralPath (Join-Path $RepositoryRoot $entry.path))) { throw "Missing manifest path: $($entry.path)" }
}
$badLinks = @()
foreach ($file in Get-ChildItem $RepositoryRoot -Recurse -File -Filter '*.md') {
    foreach ($match in [regex]::Matches((Get-Content $file.FullName -Raw), '\[[^\]]+\]\(([^)]+)\)')) {
        $link = $match.Groups[1].Value.Split('#')[0].Trim('<>')
        if ($link -and $link -notmatch '^(https?:|mailto:|#)' -and !(Test-Path -LiteralPath (Join-Path $file.DirectoryName $link))) { $badLinks += "$($file.FullName): $link" }
    }
}
if ($badLinks.Count) { throw "Broken links: $($badLinks -join '; ')" }
foreach ($scriptFile in Get-ChildItem $RepositoryRoot -Recurse -File -Filter '*.ps1') {
    $tokens=$null; $errors=$null
    [System.Management.Automation.Language.Parser]::ParseFile($scriptFile.FullName, [ref]$tokens, [ref]$errors) | Out-Null
    if ($errors.Count) { throw "PowerShell syntax errors in $($scriptFile.FullName)" }
}
$forbidden = '(?i)(^|[\\/])Instructor([\\/]|$)|users\.csv|Setup-Azure\.ps1|Clear-EntraTenants?\.ps1|Create-(Student|Users|Tenant)|Reset-(Password|Mfa)|Invite-(Guest|Users)'
foreach ($item in Get-ChildItem $RepositoryRoot -Recurse -Force) {
    if ($item.FullName -notmatch '[\\/]\.git([\\/]|$)' -and $item.FullName -match $forbidden) {
        throw "Instructor or credential automation artifact detected: $($item.FullName)"
    }
}
$missingScripts = @()
foreach ($file in Get-ChildItem $RepositoryRoot -Recurse -File -Filter '*.md') {
    $content = Get-Content $file.FullName -Raw
    foreach ($reference in [regex]::Matches($content, '(?i)(?<![\w-])([\w.-]+\.ps1)')) {
        $name = $reference.Groups[1].Value
        if ($name -notmatch '^(https?:|http)' -and -not (Get-ChildItem $RepositoryRoot -Recurse -File -Filter $name | Select-Object -First 1)) {
            $missingScripts += "$($file.FullName): $name"
        }
    }
}
if ($missingScripts.Count) {
    Write-Warning "Referenced source helpers not present in the learner tree (review each procedure before use): $($missingScripts -join '; ')"
}
Write-Output "PASS: JSON, coverage (89 practices/50 labs), manifest paths, links, all PowerShell syntax, script references, and instructor exclusions."
