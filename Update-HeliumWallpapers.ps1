[CmdletBinding()]
param(
    [string]$OutputDirectory = (Join-Path $env:USERPROFILE 'Pictures\Helium Wallpapers'),
    [ValidateRange(0, 600)] [int]$MaxWaitSeconds = 120,
    [ValidateRange(1, 60)] [int]$RetryIntervalSeconds = 10,
    [switch]$DryRun
)

Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot 'HeliumWallpaperTools.ps1')

$ErrorActionPreference = 'Stop'
$OutputDirectory = [IO.Path]::GetFullPath($OutputDirectory)
$destinationPath = Join-Path $OutputDirectory 'helium-current.jpg'
$assetDirectory = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\LocalState\Assets'

New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null

$sourcePath = $null
$lastError = $null
$attemptCount = if ($DryRun) { 1 } else { [Math]::Max(1, [Math]::Ceiling($MaxWaitSeconds / $RetryIntervalSeconds) + 1) }

for ($attempt = 1; $attempt -le $attemptCount; $attempt++) {
    try {
        $registryWallpaperPath = Get-WindowsWallpaperPath
        $sourcePath = Resolve-SpotlightWallpaperPath `
            -RegistryWallpaperPath $registryWallpaperPath `
            -AssetDirectory $assetDirectory
        if ($sourcePath) {
            break
        }
        $lastError = 'Windows liefert noch kein gültiges Spotlight-Bild.'
    } catch {
        $lastError = $_.Exception.Message
    }

    if ($attempt -lt $attemptCount) {
        Start-Sleep -Seconds $RetryIntervalSeconds
    }
}

if (-not $sourcePath) {
    throw "Kein aktuelles Windows-Spotlight-Bild gefunden. $lastError"
}

if ($DryRun) {
    Write-Output "Spotlight-Quelle: $sourcePath"
    Write-Output "Ziel: $destinationPath"
    exit 0
}

$temporaryPath = Join-Path $OutputDirectory (".helium-current-$PID-$(Get-Random).jpg")
try {
    $sourceExtension = [IO.Path]::GetExtension($sourcePath)
    if ($sourceExtension -match '^\.jpe?g$') {
        Copy-Item -LiteralPath $sourcePath -Destination $temporaryPath -Force
    } else {
        ConvertTo-Jpeg -SourcePath $sourcePath -DestinationPath $temporaryPath
    }

    Move-Item -LiteralPath $temporaryPath -Destination $destinationPath -Force
    Write-Output "Spotlight synchronisiert: $destinationPath"
    Write-Output "Quelle: $sourcePath"
} finally {
    if (Test-Path -LiteralPath $temporaryPath) {
        Remove-Item -LiteralPath $temporaryPath -Force -ErrorAction SilentlyContinue
    }
}
