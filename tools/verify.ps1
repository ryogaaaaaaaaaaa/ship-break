#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$GodotBin = if ($env:GODOT_BIN) { $env:GODOT_BIN } else { "godot" }

function Invoke-LoggedCommand {
    param(
        [string]$LogPath,
        [string[]]$Arguments
    )

    & $GodotBin @Arguments *> $LogPath
    return $LASTEXITCODE
}

try {
    $GodotVersion = & $GodotBin --version
} catch {
    Write-Host "SHIP//BREAK VERIFY: FAIL"
    Write-Host "Godot executable was not found. Set GODOT_BIN or install Godot."
    exit 1
}

$TempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("ship-break-verify-" + [System.Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $TempDir | Out-Null
$ProjectLog = Join-Path $TempDir "project.log"
$TestLog = Join-Path $TempDir "tests.log"
$ProjectGodotLog = Join-Path $TempDir "project-godot.log"
$TestGodotLog = Join-Path $TempDir "tests-godot.log"

Write-Host "SHIP//BREAK VERIFY"
Write-Host ("Godot: " + $GodotVersion)

$ProjectExit = Invoke-LoggedCommand -LogPath $ProjectLog -Arguments @("--headless", "--log-file", $ProjectGodotLog, "--path", $ProjectRoot, "--script", "res://tools/launch_check.gd")
$TestExit = Invoke-LoggedCommand -LogPath $TestLog -Arguments @("--headless", "--log-file", $TestGodotLog, "--path", $ProjectRoot, "--script", "res://tests/test_runner.gd")

$ProjectStatus = if ($ProjectExit -eq 0) { "PASS" } else { "FAIL" }
$TestStatus = if ($TestExit -eq 0) { "PASS" } else { "FAIL" }
$ErrorPattern = "SCRIPT ERROR|Parse Error|Compile Error|Invalid call|Invalid access|Node not found"
if (Select-String -Path $ProjectLog -Pattern $ErrorPattern -Quiet) {
    $ProjectStatus = "FAIL"
}
if (Select-String -Path $TestLog -Pattern $ErrorPattern -Quiet) {
    $TestStatus = "FAIL"
}
$TestSummary = Select-String -Path $TestLog -Pattern "Assertions:" | Select-Object -First 1

if ($ProjectStatus -eq "PASS" -and $TestStatus -eq "PASS") {
    Write-Host ""
    Write-Host "SHIP//BREAK VERIFY: PASS"
    Write-Host "Project startup:    PASS"
    if ($null -ne $TestSummary) {
        Write-Host ("Automated tests:    PASS (" + $TestSummary.Line + ")")
    } else {
        Write-Host "Automated tests:    PASS"
    }
    Write-Host "Content validation: NOT YET APPLICABLE"
    Write-Host "Simulation:         NOT YET APPLICABLE"
    Write-Host "Errors:             0"
    Remove-Item -Recurse -Force $TempDir
    exit 0
}

Write-Host ""
Write-Host "SHIP//BREAK VERIFY: FAIL"
Write-Host ("Project startup:    " + $ProjectStatus)
Write-Host ("Automated tests:    " + $TestStatus)
Write-Host ""
Write-Host "--- Project startup output ---"
Get-Content $ProjectLog
Write-Host ""
Write-Host "--- Test output ---"
Get-Content $TestLog
Remove-Item -Recurse -Force $TempDir
exit 1
