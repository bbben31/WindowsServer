[CmdletBinding(SupportsShouldProcess)]
param([string]$RepositoryRoot, [switch]$Check)

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

. (Join-Path $scriptRoot 'Curriculum-Contract.ps1')
$sourcePath = Join-Path $RepositoryRoot 'metadata\curriculum-source.json'
$manifest = Read-Utf8Text $sourcePath | ConvertFrom-Json
$canonical = ConvertTo-CurriculumJson $manifest
$drift = [System.Collections.Generic.List[string]]::new()
if ((Read-Utf8Text $manifestPath).Replace("`r`n", "`n") -cne $canonical) {
    $drift.Add('metadata/curriculum-manifest.json')
    if (!$Check -and $PSCmdlet.ShouldProcess($manifestPath, 'Regenerate manifest from explicit source')) {
        [IO.File]::WriteAllText($manifestPath, $canonical, $utf8NoBom)
    }
}
foreach ($entry in $manifest.entries) {
    $documentPath = Join-Path $RepositoryRoot $entry.path
    $current = Read-Utf8Text $documentPath
    $expected = Set-CurriculumContractText $current $entry
    if ($current.Replace("`r`n", "`n") -cne $expected) {
        $drift.Add($entry.path)
        if (!$Check -and $PSCmdlet.ShouldProcess($documentPath, 'Regenerate completion contract')) {
            [IO.File]::WriteAllText($documentPath, $expected, $utf8NoBom)
        }
    }
}
if ($Check -and $drift.Count) { throw "Generated curriculum drift: $($drift -join ', ')" }
Write-Output "Verified/regenerated $(@($manifest.entries).Count) explicit manifest entries and completion contracts."
