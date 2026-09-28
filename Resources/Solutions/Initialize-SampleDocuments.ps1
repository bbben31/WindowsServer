[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$DestinationRoot = 'C:\WindowsServerLab\Resources\Sample Documents',
    [ValidateRange(101, 2048)]
    [int]$TravelPackageTotalMB = 120
)

$ErrorActionPreference = 'Stop'
$departments = @('Finance', 'IT', 'Marketing', 'Travel Packages')
foreach ($department in $departments) {
    $path = Join-Path $DestinationRoot $department
    if (!(Test-Path -LiteralPath $path -PathType Container) -and
        $PSCmdlet.ShouldProcess($path, 'Create sample-document directory')) {
        New-Item -Path $path -ItemType Directory -Force | Out-Null
    }
}

$textFiles = @{
    'Finance\Budget-notes.txt' = 'Disposable finance sample for file-sharing and storage labs.'
    'IT\Operations-notes.txt' = 'Disposable IT sample for file-sharing and storage labs.'
    'Marketing\Campaign-notes.txt' = 'Disposable marketing sample for file-sharing and storage labs.'
}
foreach ($relativePath in $textFiles.Keys) {
    $path = Join-Path $DestinationRoot $relativePath
    if (!(Test-Path -LiteralPath $path -PathType Leaf) -and
        $PSCmdlet.ShouldProcess($path, 'Create sample text file')) {
        Set-Content -LiteralPath $path -Value $textFiles[$relativePath] -Encoding utf8
    }
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
