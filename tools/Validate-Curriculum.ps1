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
foreach ($script in @('tools\Preflight-LearnerLab.ps1','tools\Validate-Curriculum.ps1')) {
    $tokens=$null; $errors=$null
    [System.Management.Automation.Language.Parser]::ParseFile((Join-Path $RepositoryRoot $script), [ref]$tokens, [ref]$errors) | Out-Null
    if ($errors.Count) { throw "PowerShell syntax errors in $script" }
}
if (Get-ChildItem $RepositoryRoot -Recurse -Force | Where-Object Name -in @('Instructor','users.csv','Setup-Azure.ps1','Clear-EntraTentants.ps1')) { throw 'Instructor artifact detected.' }
Write-Output "PASS: JSON, coverage (89 practices/50 labs), manifest paths, links, PowerShell syntax, and instructor exclusions."
