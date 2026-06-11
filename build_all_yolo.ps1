param(
    [string]$GameBasePath = "C:\Games\007 First Light",
    [switch]$LaunchGame
)

$ErrorActionPreference = "Stop"

Set-StrictMode -Version Latest

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$buildScriptPath = Join-Path $projectRoot "build_all.ps1"
$releasePatchPath = Join-Path $projectRoot "release\chunk0patch272.rpkg"
$runtimePatchPath = Join-Path $GameBasePath "Runtime\chunk0patch272.rpkg"
$gameExePath = Join-Path $GameBasePath "Retail\007FirstLight.exe"

function Write-Step {
    param([string]$Message)

    Write-Host ""
    Write-Host "==> $Message"
}

if (-not (Test-Path -LiteralPath $buildScriptPath)) {
    throw "Build script not found: '$buildScriptPath'."
}

if (-not (Test-Path -LiteralPath $GameBasePath)) {
    throw "Game base path not found: '$GameBasePath'."
}

if (-not (Test-Path -LiteralPath (Split-Path -Parent $runtimePatchPath))) {
    throw "Game Runtime directory not found: '$(Split-Path -Parent $runtimePatchPath)'."
}

if (-not (Test-Path -LiteralPath $gameExePath)) {
    throw "Game executable not found: '$gameExePath'."
}

Write-Step "Removing deployed patch from Runtime"
if (Test-Path -LiteralPath $runtimePatchPath) {
    Remove-Item -LiteralPath $runtimePatchPath -Force
    Write-Host ("Deleted {0}" -f $runtimePatchPath)
}
else {
    Write-Host ("No existing runtime patch at {0}" -f $runtimePatchPath)
}

Write-Step "Running build_all.ps1"
& $buildScriptPath

if ($LASTEXITCODE -ne 0) {
    throw "build_all.ps1 failed with exit code $LASTEXITCODE."
}

if (-not (Test-Path -LiteralPath $releasePatchPath)) {
    throw "Expected built patch not found: '$releasePatchPath'."
}

Write-Step "Deploying patch to Runtime"
Copy-Item -LiteralPath $releasePatchPath -Destination $runtimePatchPath -Force
Write-Host ("Copied {0} -> {1}" -f $releasePatchPath, $runtimePatchPath)

if ($LaunchGame) {
    Write-Step "Launching game"
    Start-Process -FilePath $gameExePath
}
else {
    Write-Host ""
    Write-Host "Build and deploy complete. Skipping game launch."
}
