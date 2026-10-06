[CmdletBinding()]
param([string]$RepositoryRoot)

$ErrorActionPreference = 'Stop'
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) { $RepositoryRoot = Split-Path $scriptRoot -Parent }
$RepositoryRoot = (Resolve-Path -LiteralPath $RepositoryRoot).ProviderPath
$engine = if ($PSVersionTable.PSEdition -eq 'Desktop') { Join-Path $PSHOME 'powershell.exe' } else { Join-Path $PSHOME 'pwsh.exe' }
$tempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
$fixtureRoot = Join-Path $tempRoot ('WindowsServer-markdown-test-' + [guid]::NewGuid().ToString('N'))
$utf8 = New-Object Text.UTF8Encoding($false)
$passed = 0
New-Item -ItemType Directory -Path $fixtureRoot | Out-Null
try {
    foreach ($directory in @('Instructions', 'metadata', 'Resources', 'tools', 'images')) {
        Copy-Item -LiteralPath (Join-Path $RepositoryRoot $directory) -Destination $fixtureRoot -Recurse
    }
    Copy-Item -LiteralPath (Join-Path $RepositoryRoot 'README.md') -Destination $fixtureRoot
    $document = Join-Path $fixtureRoot 'markdown-validation-fixture.md'
    $cases = @(
        @{Name='Windows VMnet range in general documentation';Text='Attach a guest to VMnet20.';Exit=1;Expected='VMnet identifier outside Windows Workstation range'},
        @{Name='PowerShell cast in code fence';Text=@'
```powershell
$policyId = [guid](Read-Host 'Policy ID')
```
'@;Exit=0},
        @{Name='tilde fence lengths and literal comments';Text=@'
~~~~text
[not a link](missing-code-file.md)
<!-- a literal code comment opener
~~~
````
[still code](missing-code-file.md)
~~~~~
[valid prose](README.md)
'@;Exit=0},
        @{Name='inline delimiter lengths';Text=@'
`[cast](missing-inline-file.md)` and ``one ` tick [code](missing-inline-file.md)``.
`<!-- literal code -->` [valid prose](README.md).
'@;Exit=0},
        @{Name='multiline inline span';Text=@'
An inline span starts `code
[not a link](missing-inline-file.md)
<!-- still code --> ends` with [valid prose](README.md).
'@;Exit=0},
        @{Name='comments cannot open fences';Text=@'
<!--
````text
[hidden](missing-comment-file.md)
-->
[valid prose](README.md)
<!-- [hidden](missing-comment-file.md) --> [valid prose](README.md)
'@;Exit=0},
        @{Name='real broken link outside code';Text='[broken](missing-real-file.md)';Exit=1;Expected='Broken Markdown links'},
        @{Name='comment opener in inline code stays literal';Text='`<!--` [broken](missing-real-file.md)';Exit=1;Expected='Broken Markdown links'},
        @{Name='comment opener in fenced code stays literal';Text=@'
```text
<!-- literal code
```
[broken](missing-real-file.md)
'@;Exit=1;Expected='Broken Markdown links'},
        @{Name='unmatched inline delimiter stays prose';Text='` [broken](missing-real-file.md)';Exit=1;Expected='Broken Markdown links'},
        @{Name='heading interrupts inline span';Text=@'
An unmatched tick starts `here
# [broken](missing-real-file.md)
Closing-looking tick ` is a new paragraph.
'@;Exit=1;Expected='Broken Markdown links'},
        @{Name='fenced heading cannot supply an anchor';Text=@'
```text
# Phantom anchor
```
[broken](#phantom-anchor)
'@;Exit=1;Expected='missing anchor'},
        @{Name='comment heading cannot supply an anchor';Text=@'
<!--
# Phantom anchor
-->
[broken](#phantom-anchor)
'@;Exit=1;Expected='missing anchor'},
        @{Name='hidden duplicate cannot supply a suffixed anchor';Text=@'
# Visible title
```text
# Visible title
```
[broken](#visible-title-1)
'@;Exit=1;Expected='missing anchor'},
        @{Name='hidden heading does not consume a real slug';Text=@'
```text
# Visible title
```
# Visible title
[valid](#visible-title)
'@;Exit=0},
        @{Name='inline-code heading retains its title slug';Text=@'
# `Inline title`
[valid](#inline-title)
'@;Exit=0},
        @{Name='short fence cannot close longer fence';Text=@'
````text
[code](missing-code-file.md)
```
'@;Exit=1;Expected='Unclosed Markdown code fences'}
    )
    foreach ($case in $cases) {
        [IO.File]::WriteAllText($document, ($case.Text + "`n"), $utf8)
        $previousPreference = $ErrorActionPreference
        try {
            # Windows PowerShell wraps expected native stderr in non-terminating error records.
            $ErrorActionPreference = 'Continue'
            $output = & $engine -NoProfile -ExecutionPolicy Bypass -File (Join-Path $fixtureRoot 'tools/Validate-Curriculum.ps1') -RepositoryRoot $fixtureRoot 2>&1
            $actualExit = $LASTEXITCODE
        } finally { $ErrorActionPreference = $previousPreference }
        if ($actualExit -ne $case.Exit -or ($case.Expected -and ($output -join "`n") -notmatch [regex]::Escape($case.Expected))) {
            throw "Markdown validator regression failed: $($case.Name). Exit=$actualExit. $output"
        }
        $passed++
    }
} finally {
    $resolvedFixture = [IO.Path]::GetFullPath($fixtureRoot)
    if (!$resolvedFixture.StartsWith($tempRoot, [StringComparison]::OrdinalIgnoreCase) -or [IO.Path]::GetFileName($resolvedFixture) -notlike 'WindowsServer-markdown-test-*') { throw 'Refusing cleanup outside the dedicated Markdown fixture.' }
    Remove-Item -LiteralPath $resolvedFixture -Recurse -Force
}
Write-Output "PASS: $passed actual-validator Markdown regression cases under $($PSVersionTable.PSVersion)."
