[CmdletBinding()]
param([string]$RepositoryRoot)

$ErrorActionPreference = 'Stop'
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path $scriptRoot -Parent
}
$RepositoryRoot = (Resolve-Path -LiteralPath $RepositoryRoot).Path
$utf8NoBom = New-Object System.Text.UTF8Encoding($false, $true)

function Read-Utf8Text([string]$Path) {
    return [System.IO.File]::ReadAllText($Path, $utf8NoBom)
}

function Read-Utf8Lines([string]$Path) {
    return [System.IO.File]::ReadAllLines($Path, $utf8NoBom)
}

function Get-MarkdownSlug([string]$Heading) {
    $slug = $Heading.Trim().ToLowerInvariant()
    $slug = [regex]::Replace($slug, '<[^>]+>', '')
    $slug = [regex]::Replace($slug, '[^\p{L}\p{N}\p{M}\p{Pc}\- ]', '')
    return ($slug -replace ' ', '-')
}

$headingCache = @{}
function Get-MarkdownHeadings([string]$Path) {
    if ($headingCache.ContainsKey($Path)) { return $headingCache[$Path] }
    $counts = @{}
    $headings = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($line in Read-Utf8Lines $Path) {
        if ($line -match '^#{1,6}\s+(.+?)\s*#*\s*$') {
            $base = Get-MarkdownSlug $Matches[1]
            if (!$counts.ContainsKey($base)) {
                $counts[$base] = 0
                $slug = $base
            }
            else {
                $counts[$base]++
                $slug = "$base-$($counts[$base])"
            }
            [void]$headings.Add($slug)
        }
    }
    $headingCache[$Path] = $headings
    return $headings
}

$manifestPath = Join-Path $RepositoryRoot 'metadata\curriculum-manifest.json'
$manifest = Read-Utf8Text $manifestPath | ConvertFrom-Json
if ($manifest.schemaVersion -ne 3) { throw 'Expected explicit curriculum schema version 3.' }
$entries = @($manifest.entries)
$practices = @($entries | Where-Object category -eq 'Practices')
$labs = @($entries | Where-Object category -eq 'Labs')
if ($practices.Count -ne 89 -or $labs.Count -ne 50) {
    throw "Coverage mismatch: Practices=$($practices.Count), Labs=$($labs.Count)."
}

$curriculumFiles = @(Get-ChildItem -LiteralPath (Join-Path $RepositoryRoot 'Instructions\Practices'), (Join-Path $RepositoryRoot 'Instructions\Labs') -File -Filter '*.md')
$curriculumPaths = @($curriculumFiles | ForEach-Object { $_.FullName.Substring($RepositoryRoot.Length + 1).Replace('\', '/') })
$declaredPaths = @($entries | ForEach-Object path)
. (Join-Path $scriptRoot 'Test-CurriculumRules.ps1')
Test-CurriculumDependencyCycles $entries
$missingManifestEntries = @($curriculumPaths | Where-Object { $_ -notin $declaredPaths })
$unexpectedManifestEntries = @($declaredPaths | Where-Object { $_ -notin $curriculumPaths })
if ($missingManifestEntries.Count -or $unexpectedManifestEntries.Count) {
    throw "Manifest/file coverage mismatch. Missing entries: $($missingManifestEntries -join ', '); unexpected entries: $($unexpectedManifestEntries -join ', ')."
}

$manifestPaths = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
foreach ($entry in $entries) {
    if (!$manifestPaths.Add($entry.path)) { throw "Duplicate manifest path: $($entry.path)" }
    $entryPath = Join-Path $RepositoryRoot $entry.path
    if (!(Test-Path -LiteralPath $entryPath -PathType Leaf)) {
        throw "Missing manifest path: $($entry.path)"
    }
    $heading = Read-Utf8Lines $entryPath | Where-Object { $_ -match '^#\s+' } | Select-Object -First 1
    if ($heading -notmatch '^#\s+(.+)$' -or $Matches[1] -ne $entry.title) {
        throw "Manifest title does not match first heading: $($entry.path)"
    }
    $metadataText = (@($entry.networks) + @($entry.permissions) + @($entry.dependencies) + @($entry.windowsVersionAssumptions)) -join ' '
    if ($metadataText -match '(?i)\bTBD\b') { throw "Unresolved manifest metadata: $($entry.path)" }
    if ($entry.azure.required -and (@($entry.azure.services) -join ' ') -match '(?i)^None(?: identified)?$') {
        throw "Azure-required entry has no Azure service: $($entry.path)"
    }
    $content = Read-Utf8Text $entryPath

}

. (Join-Path $scriptRoot 'Test-CurriculumRules.ps1')
$policyErrors = @(Test-CurriculumRules -Entries $entries -RepositoryRoot $RepositoryRoot)
if ($policyErrors.Count) { throw "Curriculum consistency errors:`n$($policyErrors -join "`n")" }
& (Join-Path $scriptRoot 'Update-CurriculumManifest.ps1') -RepositoryRoot $RepositoryRoot -Check
$markdownFiles = @(Get-ChildItem -LiteralPath $RepositoryRoot -Recurse -File -Filter '*.md' |
    Where-Object FullName -NotMatch '[\\/]\.git[\\/]')
foreach ($instruction in $markdownFiles | Where-Object FullName -Match '[\\/]Instructions[\\/]') {
    if ((Read-Utf8Text $instruction.FullName) -match '(?i)comicrosoft\.com|smart\.etc|smpt\.ad\.lab\.test') {
        throw "Known invalid domain in instruction document: $($instruction.FullName)"
    }
}
$roadmap = Read-Utf8Text (Join-Path $RepositoryRoot 'Instructions\General\Staged-Lab-Roadmap.md')
if ($roadmap -notmatch 'riskCost\.costClass=cost-gated' -or $roadmap -match 'riskCost\.cost=cost-gated') {
    throw 'Stage H must filter the normalized riskCost.costClass field.'
}
$linkErrors = [System.Collections.Generic.List[string]]::new()
foreach ($file in $markdownFiles) {
    $lineNumber = 0
    $insideComment = $false
    foreach ($line in Read-Utf8Lines $file.FullName) {
        $lineNumber++
        $scanLine = $line
        if ($insideComment) {
            if ($scanLine -match '-->') {
                $scanLine = $scanLine.Substring($scanLine.IndexOf('-->') + 3)
                $insideComment = $false
            }
            else { continue }
        }
        while ($scanLine -match '<!--') {
            $commentStart = $scanLine.IndexOf('<!--')
            $commentEnd = $scanLine.IndexOf('-->', $commentStart + 4)
            if ($commentEnd -ge 0) {
                $scanLine = $scanLine.Remove($commentStart, $commentEnd + 3 - $commentStart)
            }
            else {
                $scanLine = $scanLine.Substring(0, $commentStart)
                $insideComment = $true
                break
            }
        }
        foreach ($match in [regex]::Matches($scanLine, '!?\[[^\]]*\]\(([^)]+)\)')) {
            $target = $match.Groups[1].Value.Trim('<>')
            if ($target -match '^(https?:|mailto:)') { continue }
            $parts = $target -split '#', 2
            $relativePath = [uri]::UnescapeDataString($parts[0])
            $targetPath = if ([string]::IsNullOrWhiteSpace($relativePath)) { $file.FullName } else { Join-Path $file.DirectoryName $relativePath }
            if (!(Test-Path -LiteralPath $targetPath -PathType Leaf)) {
                $linkErrors.Add("$($file.FullName):$lineNumber missing target '$target'")
                continue
            }
            if ($parts.Count -eq 2 -and ![string]::IsNullOrWhiteSpace($parts[1])) {
                $fragment = [uri]::UnescapeDataString($parts[1]).ToLowerInvariant()
                if (!(Get-MarkdownHeadings $targetPath).Contains($fragment)) {
                    $linkErrors.Add("$($file.FullName):$lineNumber missing anchor '$target'")
                }
            }
        }
    }
}
if ($linkErrors.Count) { throw "Broken Markdown links:`n$($linkErrors -join "`n")" }

$fenceErrors = [System.Collections.Generic.List[string]]::new()
foreach ($file in $markdownFiles) {
    $markerCharacter = $null
    $markerLength = 0
    $openingLine = 0
    $lineNumber = 0
    foreach ($line in Read-Utf8Lines $file.FullName) {
        $lineNumber++
        if ($null -eq $markerCharacter) {
            $opening = [regex]::Match($line, '^\s*(`{3,}|~{3,}).*$')
            if ($opening.Success) {
                $markerCharacter = $opening.Groups[1].Value[0]
                $markerLength = $opening.Groups[1].Value.Length
                $openingLine = $lineNumber
            }
            continue
        }
        $closingPattern = '^\s*' + [regex]::Escape([string]$markerCharacter) + '{' + $markerLength + ',}\s*$'
        if ($line -match $closingPattern) {
            $markerCharacter = $null
            $markerLength = 0
            $openingLine = 0
        }
    }
    if ($null -ne $markerCharacter) {
        $fenceErrors.Add("$($file.FullName):$openingLine unclosed Markdown code fence")
    }
}
if ($fenceErrors.Count) { throw "Unclosed Markdown code fences:`n$($fenceErrors -join "`n")" }

$powerShellErrors = [System.Collections.Generic.List[string]]::new()
foreach ($scriptFile in Get-ChildItem -LiteralPath $RepositoryRoot -Recurse -File -Filter '*.ps1' |
    Where-Object FullName -NotMatch '[\\/]\.git[\\/]') {
    $tokens = $null
    $parseErrors = $null
    [System.Management.Automation.Language.Parser]::ParseInput((Read-Utf8Text $scriptFile.FullName), [ref]$tokens, [ref]$parseErrors) | Out-Null
    foreach ($parseError in $parseErrors) {
        $powerShellErrors.Add("$($scriptFile.FullName):$($parseError.Extent.StartLineNumber) $($parseError.Message)")
    }
}

foreach ($file in $markdownFiles) {
    $lines = @(Read-Utf8Lines $file.FullName)
    for ($index = 0; $index -lt $lines.Count; $index++) {
        $open = [regex]::Match($lines[$index], '^\s*(`{3,})\s*(powershell|ps1)\s*$', 'IgnoreCase')
        if (!$open.Success) { continue }
        $fenceLength = $open.Groups[1].Value.Length
        $startLine = $index + 2
        $codeLines = [System.Collections.Generic.List[string]]::new()
        $closed = $false
        for ($cursor = $index + 1; $cursor -lt $lines.Count; $cursor++) {
            $close = [regex]::Match($lines[$cursor], '^\s*(`{3,})\s*$')
            if ($close.Success -and $close.Groups[1].Value.Length -ge $fenceLength) {
                $closed = $true
                $index = $cursor
                break
            }
            $codeLines.Add($lines[$cursor])
        }
        if (!$closed) {
            $powerShellErrors.Add("$($file.FullName):$startLine unclosed PowerShell fence")
            continue
        }
        $tokens = $null
        $parseErrors = $null
        [System.Management.Automation.Language.Parser]::ParseInput(($codeLines -join "`n"), [ref]$tokens, [ref]$parseErrors) | Out-Null
        foreach ($parseError in $parseErrors) {
            $errorLine = $startLine + $parseError.Extent.StartLineNumber - 1
            $powerShellErrors.Add("$($file.FullName):$errorLine $($parseError.Message)")
        }
    }
}
if ($powerShellErrors.Count) { throw "PowerShell syntax errors:`n$($powerShellErrors -join "`n")" }

$availableScripts = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
foreach ($scriptFile in Get-ChildItem -LiteralPath $RepositoryRoot -Recurse -File -Filter '*.ps1') {
    [void]$availableScripts.Add($scriptFile.Name)
}
$missingScripts = [System.Collections.Generic.List[string]]::new()
foreach ($file in $markdownFiles) {
    $content = Read-Utf8Text $file.FullName
    foreach ($reference in [regex]::Matches($content, '(?i)(?<![\w-])([\w.-]+\.ps1)')) {
        $name = $reference.Groups[1].Value
        if ($availableScripts.Contains($name)) { continue }
        $relative = $file.FullName.Substring($RepositoryRoot.Length + 1).Replace('\', '/')
        $isGeneratedHardLink = $name -ieq 'SetupScript.ps1' -and
            $relative -eq 'Instructions/Labs/Manage-local-storage.md' -and
            $content -match "(?i)\`$name\s*=\s*'SetupScript\.ps1'" -and
            $content -match 'New-Item\s+-ItemType\s+HardLink'
        $isPinnedDownload = $name -ieq 'install-docker-ce.ps1' -and
            $relative -eq 'Instructions/Labs/Windows-containers.md' -and
            $content -match 'raw\.githubusercontent\.com/microsoft/Windows-Containers/[0-9a-f]{40}/' -and
            $content -match 'Get-FileHash.+SHA256' -and
            $content -match "expectedHash\s*=\s*'[0-9A-Fa-f]{64}'"
        if (!$isGeneratedHardLink -and !$isPinnedDownload) { $missingScripts.Add("${relative}: $name") }
    }
}
if ($missingScripts.Count) { throw "Missing script dependencies:`n$($missingScripts -join "`n")" }

$unsafeText = [System.Collections.Generic.List[string]]::new()
foreach ($file in $markdownFiles | Where-Object FullName -Match '[\\/]Instructions[\\/](Labs|Practices)[\\/]') {
    $content = Read-Utf8Text $file.FullName
    foreach ($pattern in @(
        '(?i)ask (the |your )?instructor',
        '(?i)your instructor will',
        '(?i)instructor will help',
        '(?i)other students in the class',
        '(?i)dc\s*=\s*ad\s*,\s*dc\s*=\s*adatum\s*,\s*dc\s*=\s*com',
        '(?i)adatum\.onmicrosoft\.com',
        '(?i)SecureStringToBSTR|PtrToStringAuto',
        '(?is)ConvertTo-SecureString.{0,160}-AsPlainText',
        '(?i)C:\\+LabResources?',
        '(?i)c\$\\+LabResources?',
        '(?i)C:\\+Labs\\+',
        '(?i)consume\.exe'
    )) {
        if ($content -match $pattern) { $unsafeText.Add("$($file.FullName): forbidden source assumption '$pattern'") }
    }
}
if ($unsafeText.Count) { throw "Unadapted classroom or identity assumptions:`n$($unsafeText -join "`n")" }

$azureSafetyAllowed = @(
    'Deploying-a-hybrid-cloud-model.md',
    'Distributed-File-System-and-Azure-File-Sync.md',
    'Managing-hybrid-servers-using-Azure-Arc.md'
)
foreach ($file in $markdownFiles | Where-Object FullName -Match '[\\/]Instructions[\\/]Labs[\\/]') {
    $content = Read-Utf8Text $file.FullName
    if ($content -match '> \*\*Azure safety:' -and $file.Name -notin $azureSafetyAllowed) {
        throw "Local-only lab contains an Azure safety classification: $($file.FullName)"
    }
}

$encodingErrors = @($markdownFiles | Where-Object {
    (Read-Utf8Text $_.FullName) -match '[\u00C2\u00C3\uFFFD]|\u00E2\u20AC'
})
if ($encodingErrors.Count) {
    throw "Possible mojibake in Markdown files:`n$($encodingErrors.FullName -join "`n")"
}

$unfinishedMarkers = @($markdownFiles | Where-Object {
    (Read-Utf8Text $_.FullName) -match '(?i)\b(?:TBD|TODO|FIXME)\b'
})
if ($unfinishedMarkers.Count) {
    throw "Unresolved documentation markers:`n$($unfinishedMarkers.FullName -join "`n")"
}

$containerLab = Read-Utf8Text (Join-Path $RepositoryRoot 'Instructions\Labs\Windows-containers.md')
if ($containerLab -notmatch 'raw\.githubusercontent\.com/microsoft/Windows-Containers/[0-9a-f]{40}/' -or
    $containerLab -notmatch "expectedHash\s*=\s*'[0-9A-Fa-f]{64}'" -or
    $containerLab -notmatch 'Get-FileHash') {
    throw 'Windows container installer must use a pinned commit and verify SHA-256 before execution.'
}

$mdtLab = Read-Utf8Text (Join-Path $RepositoryRoot 'Instructions\Labs\Microsoft-Deployment-Toolkit.md')
if ($mdtLab -match '(?i)Hyper-V Manager|Virtual Machine Connection|New-PSSession\s+-VMName|Stop-VM|Get-VMHardDiskDrive|New-VHD') {
    throw 'The MDT lab must use VMware consistently for outer VM lifecycle operations.'
}

$multiDomainLab = Read-Utf8Text (Join-Path $RepositoryRoot 'Instructions\Labs\Multi-domain-environments.md')
if ($multiDomainLab -notmatch '#task-4-add-the-contoso-upn-suffix' -or
    $multiDomainLab -notmatch '(?is)Task 4: Add the Contoso UPN suffix.{0,1200}Set-ADForest.{0,300}ad\.contoso\.com.{0,300}contoso\.com' -or
    $multiDomainLab -notmatch '(?is)Task 5: Create a new user.{0,1800}Wil@contoso\.com.{0,1000}CN=Users,DC=ad,DC=contoso,DC=com') {
    throw 'The multi-domain lab must configure the Contoso UPN suffix and create Wil in ad.contoso.com.'
}

Write-Output 'PASS: explicit metadata and generated contracts for 139 exercises; VM declarations and role layers; Azure cost/cleanup; outbound access; permissions; normalized filters; local workarounds; adjacent WAC targets; instruction domains; links/fences; PowerShell syntax; script dependencies; pinned installer; VMware MDT and Contoso scenario integrity.'
