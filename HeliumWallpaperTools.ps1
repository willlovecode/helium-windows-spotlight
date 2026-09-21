Set-StrictMode -Version Latest

function Get-ImageInfo {
    param(
        [Parameter(Mandatory)] [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return $null
    }

    try {
        Add-Type -AssemblyName System.Drawing
        $file = Get-Item -LiteralPath $Path
        $image = [Drawing.Image]::FromFile($file.FullName)
        try {
            [pscustomobject]@{
                Path = $file.FullName
                Width = $image.Width
                Height = $image.Height
                IsLandscape = ($image.Width -ge $image.Height)
            }
        } finally {
            $image.Dispose()
        }
    } catch {
        return $null
    }
}

function Resolve-SpotlightWallpaperPath {
    param(
        [string]$RegistryWallpaperPath,
        [Parameter(Mandatory)] [string]$AssetDirectory,
        [int]$MinimumBytes = 10000
    )

    if (-not [string]::IsNullOrWhiteSpace($RegistryWallpaperPath) -and
        (Test-Path -LiteralPath $RegistryWallpaperPath -PathType Leaf)) {
        $directInfo = Get-ImageInfo -Path $RegistryWallpaperPath
        $directFile = Get-Item -LiteralPath $RegistryWallpaperPath
        if ($directInfo -and $directFile.Length -ge $MinimumBytes) {
            return $directInfo.Path
        }
    }

    if (-not (Test-Path -LiteralPath $AssetDirectory -PathType Container)) {
        return $null
    }

    foreach ($file in @(Get-ChildItem -LiteralPath $AssetDirectory -File | Sort-Object LastWriteTime -Descending)) {
        if ($file.Length -lt $MinimumBytes) {
            continue
        }

        $info = Get-ImageInfo -Path $file.FullName
        if ($info -and $info.IsLandscape) {
            return $info.Path
        }
    }

    return $null
}

function Get-WindowsWallpaperPath {
    $wallpaper = (Get-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name WallPaper -ErrorAction SilentlyContinue).WallPaper
    if ([string]::IsNullOrWhiteSpace([string]$wallpaper)) {
        return $null
    }

    [Environment]::ExpandEnvironmentVariables(([string]$wallpaper).Trim())
}

function ConvertTo-Jpeg {
    param(
        [Parameter(Mandatory)] [string]$SourcePath,
        [Parameter(Mandatory)] [string]$DestinationPath
    )

    Add-Type -AssemblyName System.Drawing
    $image = [Drawing.Image]::FromFile($SourcePath)
    try {
        $image.Save($DestinationPath, [Drawing.Imaging.ImageFormat]::Jpeg)
    } finally {
        $image.Dispose()
    }
}
