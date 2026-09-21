[CmdletBinding()]
param(
    [string]$ScriptPath,
    [string]$TaskName = 'Helium Windows Spotlight'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($ScriptPath)) {
    $ScriptPath = Join-Path $PSScriptRoot 'Update-HeliumWallpapers.ps1'
}
$ScriptPath = [IO.Path]::GetFullPath($ScriptPath)
if (-not (Test-Path -LiteralPath $ScriptPath -PathType Leaf)) {
    throw "Updater not found: $ScriptPath"
}

$powershell = (Get-Command powershell.exe).Source
$arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`" -MaxWaitSeconds 120 -RetryIntervalSeconds 10"
$action = New-ScheduledTaskAction -Execute $powershell -Argument $arguments
$userId = "$env:USERDOMAIN\$env:USERNAME"
$principal = New-ScheduledTaskPrincipal `
    -UserId $userId `
    -LogonType Interactive `
    -RunLevel Limited
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $userId
$settings = New-ScheduledTaskSettingsSet `
    -StartWhenAvailable `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 15) `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries

Register-ScheduledTask `
    -TaskName $TaskName `
    -Action $action `
    -Trigger $trigger `
    -Settings $settings `
    -Principal $principal `
    -Description 'Copies the current Windows Spotlight image for Helium.' `
    -Force | Out-Null

Write-Output "Scheduled task installed: $TaskName"
