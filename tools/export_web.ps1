#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$GodotBin = if ($env:GODOT_BIN) { $env:GODOT_BIN } else { "godot" }
$OutputDir = Join-Path $ProjectRoot "build/web"
$LogFile = Join-Path ([System.IO.Path]::GetTempPath()) "ship-break-web-export.log"

New-Item -ItemType Directory -Force -Path (Join-Path $ProjectRoot "build") | Out-Null
New-Item -ItemType File -Force -Path (Join-Path $ProjectRoot "build/.gdignore") | Out-Null
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
& $GodotBin --headless --log-file $LogFile --path $ProjectRoot --export-release Web (Join-Path $OutputDir "index.html")
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}
New-Item -ItemType File -Force -Path (Join-Path $OutputDir ".nojekyll") | Out-Null
Write-Host ("Web export written to " + $OutputDir)
