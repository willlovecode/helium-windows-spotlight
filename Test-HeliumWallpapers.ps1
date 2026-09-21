[CmdletBinding()]
param()

. (Join-Path $PSScriptRoot 'HeliumWallpaperTools.ps1')
$ErrorActionPreference = 'Stop'

function Assert-Equal {
    param(
        [Parameter(Mandatory)] [object]$Expected,
        [Parameter(Mandatory)] [object]$Actual,
        [Parameter(Mandatory)] [string]$Message
    )

    if ($Expected -ne $Actual) {
        throw "$Message. Erwartet: '$Expected'; erhalten: '$Actual'."
    }
}

function Assert-True {
    param(
        [Parameter(Mandatory)] [bool]$Condition,
        [Parameter(Mandatory)] [string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

$testRoot = Join-Path ([IO.Path]::GetTempPath()) "helium-spotlight-test-$PID"
New-Item -ItemType Directory -Path $testRoot -Force | Out-Null

try {
    Add-Type -AssemblyName System.Drawing
    $fixturePath = Join-Path $testRoot 'fixture.jpg'
    $bitmap = New-Object Drawing.Bitmap 8, 4
    try {
        $bitmap.Save($fixturePath, [Drawing.Imaging.ImageFormat]::Jpeg)
    } finally {
        $bitmap.Dispose()
    }

    $directPath = Join-Path $testRoot 'current-without-extension'
    Copy-Item -LiteralPath $fixturePath -Destination $directPath
    $resolvedDirect = Resolve-SpotlightWallpaperPath `
        -RegistryWallpaperPath $directPath `
        -AssetDirectory $testRoot `
        -MinimumBytes 1
    Assert-Equal -Expected $directPath -Actual $resolvedDirect -Message 'Direkter Windows-Wallpaper-Pfad wurde nicht bevorzugt'

    $assetDirectory = Join-Path $testRoot 'assets'
    New-Item -ItemType Directory -Path $assetDirectory -Force | Out-Null
    $landscapePath = Join-Path $assetDirectory 'landscape-cache-entry'
    Copy-Item -LiteralPath $fixturePath -Destination $landscapePath
    $portraitPath = Join-Path $assetDirectory 'portrait-cache-entry'
    $portrait = New-Object Drawing.Bitmap 4, 8
    try {
        $portrait.Save($portraitPath, [Drawing.Imaging.ImageFormat]::Jpeg)
    } finally {
        $portrait.Dispose()
    }
    $resolvedFallback = Resolve-SpotlightWallpaperPath `
        -RegistryWallpaperPath (Join-Path $testRoot 'missing-wallpaper') `
        -AssetDirectory $assetDirectory `
        -MinimumBytes 1
    Assert-Equal -Expected $landscapePath -Actual $resolvedFallback -Message 'Spotlight-Fallback findet kein Landschaftsbild'

    $info = Get-ImageInfo -Path $resolvedFallback
    Assert-Equal -Expected 8 -Actual $info.Width -Message 'Bildbreite wurde nicht erkannt'
    Assert-Equal -Expected 4 -Actual $info.Height -Message 'Bildhöhe wurde nicht erkannt'
    Assert-True -Condition $info.IsLandscape -Message 'Landschaftsbild wurde fälschlich als Hochformat erkannt'
} finally {
    Remove-Item -LiteralPath $testRoot -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Output 'Helium-Spotlight-Selbsttest: OK'
