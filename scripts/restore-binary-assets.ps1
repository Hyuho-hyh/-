$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$bundlePath = Join-Path $PSScriptRoot 'windows-assets.zip.b64'
if (-not (Test-Path -LiteralPath $bundlePath)) { return }
$temporaryArchive = Join-Path ([System.IO.Path]::GetTempPath()) ('hghub-assets-' + [guid]::NewGuid().ToString('N') + '.zip')
try {
    [System.IO.File]::WriteAllBytes($temporaryArchive, [System.Convert]::FromBase64String([System.IO.File]::ReadAllText($bundlePath)))
    Expand-Archive -LiteralPath $temporaryArchive -DestinationPath $projectRoot -Force
    Write-Output 'Restored application icons and binary resources.'
} finally {
    if (Test-Path -LiteralPath $temporaryArchive) { Remove-Item -LiteralPath $temporaryArchive }
}
