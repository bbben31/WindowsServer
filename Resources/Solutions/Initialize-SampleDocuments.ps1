[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$DestinationRoot = 'C:\WindowsServerLab\Resources\Sample Documents',
    [ValidateRange(101, 2048)]
    [int]$TravelPackageTotalMB = 120
)

$ErrorActionPreference = 'Stop'
$departments = @('Finance', 'IT', 'IT\Step-by-Step Guides', 'Marketing', 'Travel Packages')
foreach ($department in $departments) {
    $path = Join-Path $DestinationRoot $department
    if (!(Test-Path -LiteralPath $path -PathType Container) -and
        $PSCmdlet.ShouldProcess($path, 'Create sample-document directory')) {
        New-Item -Path $path -ItemType Directory -Force | Out-Null
    }
}

$textFiles = @{
    'Finance\Budget-notes.txt' = 'Disposable finance payroll sample for content classification.'
    'Finance\Expired-notes.txt' = 'Disposable old finance payroll sample for expiration testing.'
    'Finance\Recent-notes.txt' = 'Disposable recent finance payroll sample; retain this in expiration testing.'
    'IT\Operations-notes.txt' = 'Disposable IT tax sample for content classification.'
    'IT\Step-by-Step Guides\Read-me.txt' = 'Disposable offline-files guide; keep this folder available offline.'
    'Marketing\Campaign-notes.txt' = 'Disposable marketing sample: vertraulich.'
}
foreach ($relativePath in $textFiles.Keys) {
    $path = Join-Path $DestinationRoot $relativePath
    if (!(Test-Path -LiteralPath $path -PathType Leaf) -and
        $PSCmdlet.ShouldProcess($path, 'Create sample text file')) {
        Set-Content -LiteralPath $path -Value $textFiles[$relativePath] -Encoding utf8
        if ($relativePath -eq 'Finance\Expired-notes.txt') {
            $oldDate = (Get-Date).AddDays(-367)
            $item = Get-Item -LiteralPath $path
            $item.CreationTime = $oldDate
            $item.LastWriteTime = $oldDate
            $item.LastAccessTime = $oldDate
        }
    }
}

$itQuotaPath = Join-Path $DestinationRoot 'IT\Quota-test.dat'
if (!(Test-Path -LiteralPath $itQuotaPath) -and
    $PSCmdlet.ShouldProcess($itQuotaPath, 'Create 64 MB disposable IT quota-test file')) {
    $stream = [IO.File]::Open($itQuotaPath, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::None)
    try { $stream.SetLength(64MB) }
    finally { $stream.Dispose() }
}

$travelRoot = Join-Path $DestinationRoot 'Travel Packages'
$fileCount = 6
$fileSize = [int64]([math]::Ceiling($TravelPackageTotalMB / $fileCount) * 1MB)
foreach ($number in 1..$fileCount) {
    $path = Join-Path $travelRoot ('Travel-Package-{0:D2}.dat' -f $number)
    $existing = Get-Item -LiteralPath $path -ErrorAction SilentlyContinue
    if ($existing -and $existing.Length -eq $fileSize) { continue }
    if ($PSCmdlet.ShouldProcess($path, "Create or resize disposable quota-test file to $fileSize bytes")) {
        $stream = [IO.File]::Open($path, [IO.FileMode]::OpenOrCreate, [IO.FileAccess]::Write, [IO.FileShare]::None)
        try { $stream.SetLength($fileSize) }
        finally { $stream.Dispose() }
    }
}

if (Test-Path -LiteralPath $DestinationRoot -PathType Container) {
    Get-ChildItem -LiteralPath $DestinationRoot -Recurse -File |
        Select-Object FullName, Length
}

Write-Verbose 'Office fixtures are prepared manually in licensed desktop Office: see Install-prerequisites-for-file-serving.md, Prepare valid Office fixtures. This helper does not create fake XLSX/PPTX files or install Office.'
