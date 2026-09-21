# Helium Windows Spotlight

An independent Windows companion utility for [Helium](https://github.com/imputnet/helium). At user logon it copies the desktop image currently displayed by Windows Spotlight into a stable JPEG path that Helium can use as its custom background.

The project does not modify Helium source code, download images from the Internet, or contain personal files.

## How it works

1. The updater reads the wallpaper path currently set in the user's Windows profile.
2. If Spotlight is not ready at logon, it waits for up to two minutes.
3. As a fallback, it selects the newest valid landscape image from the local Spotlight cache.
4. It atomically writes the result to `%USERPROFILE%\Pictures\Helium Wallpapers\helium-current.jpg`.

## Setup

Run the following commands from PowerShell in the project directory:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Test-HeliumWallpapers.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Update-HeliumWallpapers.ps1 -DryRun
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Install-HeliumWallpaperTask.ps1
```

Then select `helium-current.jpg` once as Helium's custom background. By default the file is stored at:

`%USERPROFILE%\Pictures\Helium Wallpapers\helium-current.jpg`

The `Helium Windows Spotlight` task runs at every interactive Windows logon. It does not require administrator privileges.

## Requirements

- Windows PowerShell 5.1 or later
- Windows Spotlight enabled as the desktop background
- Helium with support for a local custom background

## Relationship to Helium

This is an unofficial companion utility and does not modify the Helium source tree. Platform-specific integration belongs in the [Helium for Windows repository](https://github.com/imputnet/helium-windows).

## License

The standalone utility is released under the MIT License.
