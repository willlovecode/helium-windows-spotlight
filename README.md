# Helium Windows Spotlight

Unabhängige Windows-Companion-Automation für [Helium](https://github.com/imputnet/helium): Beim Benutzer-Login wird das aktuell von Windows Spotlight angezeigte Desktopbild als feste JPEG-Datei aktualisiert. Helium muss dadurch nur einmal auf diese Datei zeigen.

Das Projekt verändert keinen Helium-Quellcode, lädt keine Bilder aus dem Internet und enthält keine persönlichen Dateien.

## Funktionsweise

1. Der Updater liest den aktuell gesetzten Windows-Wallpaper-Pfad aus dem Benutzerprofil.
2. Wenn Spotlight beim Login noch nicht bereit ist, wird bis zu zwei Minuten gewartet.
3. Als Fallback wird der jüngste gültige Landschaftsbild-Eintrag aus dem lokalen Spotlight-Cache verwendet.
4. Das Ergebnis wird atomar nach `%USERPROFILE%\Pictures\Helium Wallpapers\helium-current.jpg` geschrieben.

## Einrichtung

In PowerShell im Projektordner ausführen:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Test-HeliumWallpapers.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Update-HeliumWallpapers.ps1 -DryRun
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Install-HeliumWallpaperTask.ps1
```

Danach in Helium einmalig `helium-current.jpg` als benutzerdefinierten Hintergrund auswählen. Die Datei liegt standardmäßig unter:

`%USERPROFILE%\Pictures\Helium Wallpapers\helium-current.jpg`

Der Task `Helium Windows Spotlight` startet bei jeder interaktiven Windows-Anmeldung. Er benötigt keine Administratorrechte.

## Anforderungen

- Windows PowerShell 5.1 oder neuer
- Windows Spotlight als Desktop-Hintergrund
- Helium mit Unterstützung für einen lokalen benutzerdefinierten Hintergrund

## Bezug zu Helium

Dieses Repo ist kein offizielles Helium-Repo und kein Submodul. Für eine direkte Integration sollte zuerst ein Issue im passenden [Helium-for-Windows-Repository](https://github.com/imputnet/helium-windows) eröffnet werden. Das offizielle Helium-Projekt verweist für plattformspezifische Features auf die jeweiligen Plattform-Repositories und bittet bei nicht-trivialen Änderungen um Maintainer-Abstimmung.

## Lizenz

Der eigenständige Code steht unter MIT. Eine spätere Übernahme in Helium müsste nach den dort geltenden GPL-3.0-Beitragsbedingungen erfolgen.
