param(
  [string]$Destination = (Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'My Games\Sid Meier''s Civilization VI\Mods\MapTackBlueprints')
)

$ErrorActionPreference = 'Stop'
$sourceRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

New-Item -ItemType Directory -Path $Destination -Force | Out-Null
foreach ($item in @('MapTackBlueprints.modinfo', 'blueprints', 'text', 'ui')) {
  Copy-Item -LiteralPath (Join-Path $sourceRoot $item) -Destination $Destination -Recurse -Force
}

Write-Host "Installed Map Tack Blueprints to: $Destination"
Write-Host 'Enable the mod under Additional Content, then load or start a game.'
