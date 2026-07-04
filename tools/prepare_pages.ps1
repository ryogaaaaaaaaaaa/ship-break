#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$WebDir = Join-Path $ProjectRoot "build/web"
$PagesDir = Join-Path $ProjectRoot "build/pages"

& (Join-Path $ProjectRoot "tools/export_web.ps1")
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

New-Item -ItemType Directory -Force -Path $PagesDir | Out-Null
$Names = @(
    "index.html",
    "index.js",
    "index.wasm",
    "index.pck",
    "index.png",
    "index.icon.png",
    "index.apple-touch-icon.png",
    "index.audio.worklet.js",
    "index.audio.position.worklet.js",
    ".nojekyll"
)

foreach ($Name in $Names) {
    $Source = Join-Path $WebDir $Name
    if (Test-Path $Source) {
        Copy-Item -Force $Source (Join-Path $PagesDir $Name)
    }
}

Write-Host ("Pages package written to " + $PagesDir)
