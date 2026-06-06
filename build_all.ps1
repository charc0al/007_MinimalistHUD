$ErrorActionPreference = "Stop"

Set-StrictMode -Version Latest

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$rpkgToolRoot = Join-Path $projectRoot "RPKGTool"
$rebuildSourceRoot = Join-Path $projectRoot "rebuild"
$rebuildOutputRoot = Join-Path $projectRoot "rebuild_output"
$rebuildGfxfTargetRoot = Join-Path $rebuildSourceRoot "chunk0\GFXF"
$releaseRoot = Join-Path $projectRoot "release"
$finalPatchPath = Join-Path $releaseRoot "chunk0patch272.rpkg"
$postRebuildDelaySeconds = 5
$rebuiltWaitTimeoutSeconds = 120

function Write-Step {
    param([string]$Message)

    Write-Host ""
    Write-Host "==> $Message"
}

function Get-RpkgCliPath {
    param([string]$ToolRoot)

    $candidates = @(
        (Join-Path $ToolRoot "rpkg-cli.exe"),
        (Join-Path $ToolRoot "bin\rpkg-cli.exe"),
        (Join-Path $ToolRoot "Release\rpkg-cli.exe"),
        (Join-Path $ToolRoot "x64\Release\rpkg-cli.exe"),
        (Join-Path $ToolRoot "publish\rpkg-cli.exe")
    )

    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }

    $discovered = Get-ChildItem -LiteralPath $ToolRoot -Recurse -File -Filter "rpkg-cli.exe" |
        Select-Object -First 1 -ExpandProperty FullName

    if ($discovered) {
        return $discovered
    }

    throw "Could not find rpkg-cli.exe under '$ToolRoot'."
}

function Invoke-RpkgCli {
    param(
        [string]$CliPath,
        [string[]]$Arguments
    )

    Write-Host ("Running: {0} {1}" -f (Split-Path -Leaf $CliPath), ($Arguments -join " "))
    & $CliPath @Arguments

    if ($LASTEXITCODE -ne 0) {
        throw "RPKG CLI failed with exit code $LASTEXITCODE."
    }
}

function Get-RebuiltGfxfOutputs {
    param([string]$SwfRoot)

    $gfxfRoot = Join-Path $SwfRoot "gfx\GFXF\chunk0.rpkg"
    if (-not (Test-Path -LiteralPath $gfxfRoot)) {
        throw "Expected rebuilt GFXF root not found: '$gfxfRoot'."
    }

    $rebuiltFiles = @(
        Get-ChildItem -LiteralPath $gfxfRoot -Directory -Filter "*.GFXF" |
        ForEach-Object {
            $rebuiltPath = Join-Path $_.FullName "GFXF.rebuilt"
            if (Test-Path -LiteralPath $rebuiltPath) {
                Get-Item -LiteralPath $rebuiltPath -Force
            }
        }
    )

    return $rebuiltFiles
}

function Get-ExpectedRebuiltGfxfPaths {
    param([string]$SwfRoot)

    $gfxfRoot = Join-Path $SwfRoot "gfx\GFXF\chunk0.rpkg"
    if (-not (Test-Path -LiteralPath $gfxfRoot)) {
        throw "Expected rebuilt GFXF root not found: '$gfxfRoot'."
    }

    $expectedPaths = @(
        Get-ChildItem -LiteralPath $gfxfRoot -Directory -Filter "*.GFXF" |
        ForEach-Object {
            Join-Path $_.FullName "GFXF.rebuilt"
        }
    )

    if ($expectedPaths.Count -eq 0) {
        throw "No *.GFXF directories were found under '$gfxfRoot'."
    }

    return $expectedPaths
}

function Wait-ForRebuiltGfxfOutputs {
    param(
        [string]$SwfRoot,
        [int]$DelaySeconds,
        [int]$TimeoutSeconds
    )

    $expectedPaths = @(Get-ExpectedRebuiltGfxfPaths -SwfRoot $SwfRoot)
    Start-Sleep -Seconds $DelaySeconds

    Write-Host "Waiting for rebuilt GFXF output:"
    foreach ($expectedPath in $expectedPaths) {
        Write-Host ("  {0}" -f $expectedPath)
    }

    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    $secondsWaited = 0
    while ((Get-Date) -lt $deadline) {
        $rebuiltFiles = @(Get-RebuiltGfxfOutputs -SwfRoot $SwfRoot)
        if ($rebuiltFiles.Count -gt 0) {
            return $rebuiltFiles
        }

        $secondsWaited++
        Write-Host ("  still waiting... {0}s" -f $secondsWaited)
        Start-Sleep -Seconds 1
    }

    throw "No GFXF.rebuilt files were found at the expected paths after waiting $DelaySeconds seconds plus $TimeoutSeconds seconds of polling."
}

function Move-RebuiltGfxfFiles {
    param(
        [System.IO.DirectoryInfo[]]$RebuiltFiles,
        [string]$DestinationRoot
    )

    if (-not (Test-Path -LiteralPath $DestinationRoot)) {
        throw "Destination GFXF directory not found: '$DestinationRoot'."
    }

    foreach ($rebuiltFile in $RebuiltFiles) {
        $hashFolderName = Split-Path -Leaf (Split-Path -Parent $rebuiltFile.FullName)
        if (-not $hashFolderName.EndsWith(".GFXF")) {
            throw "Unexpected rebuilt GFXF folder name '$hashFolderName'."
        }

        $destinationPath = Join-Path $DestinationRoot $hashFolderName
        $rebuiltPayload = @(Get-ChildItem -LiteralPath $rebuiltFile.FullName -Force)
        if ($rebuiltPayload.Count -ne 1) {
            throw "Expected exactly one rebuilt payload inside '$($rebuiltFile.FullName)', found $($rebuiltPayload.Count)."
        }

        $payload = $rebuiltPayload[0]
        if ($payload.PSIsContainer) {
            throw "Expected rebuilt payload to be a file inside '$($rebuiltFile.FullName)', but found directory '$($payload.FullName)'."
        }

        Move-Item -LiteralPath $payload.FullName -Destination $destinationPath -Force
        Write-Host ("Moved {0} -> {1}" -f $payload.FullName, $destinationPath)
    }
}

function Clear-TargetGfxfFiles {
    param([string]$DestinationRoot)

    if (-not (Test-Path -LiteralPath $DestinationRoot)) {
        throw "Destination GFXF directory not found: '$DestinationRoot'."
    }

    Get-ChildItem -LiteralPath $DestinationRoot -File -Filter "*.GFXF" |
        ForEach-Object {
            Remove-Item -LiteralPath $_.FullName -Force
        }
}

$rpkgCliPath = Get-RpkgCliPath -ToolRoot $rpkgToolRoot

$swfRoots = @(
    (Join-Path $projectRoot "src\hud.swf"),
    (Join-Path $projectRoot "src\menu.swf")
)

if (-not (Test-Path -LiteralPath $releaseRoot)) {
    New-Item -ItemType Directory -Path $releaseRoot | Out-Null
}

if (Test-Path -LiteralPath $finalPatchPath) {
    Remove-Item -LiteralPath $finalPatchPath -Force
}

Write-Step "Rebuilding GFXF resources"
Write-Step "Refreshing rebuild\chunk0\GFXF"
Clear-TargetGfxfFiles -DestinationRoot $rebuildGfxfTargetRoot

foreach ($swfRoot in $swfRoots) {
    $gfxSourceRoot = Join-Path $swfRoot "gfx"
    if (-not (Test-Path -LiteralPath $gfxSourceRoot)) {
        throw "Expected GFX source directory not found: '$gfxSourceRoot'."
    }

    Invoke-RpkgCli -CliPath $rpkgCliPath -Arguments @(
        "-rebuild_gfxf_in",
        $gfxSourceRoot
    )

    $rebuiltFiles = @(Wait-ForRebuiltGfxfOutputs -SwfRoot $swfRoot -DelaySeconds $postRebuildDelaySeconds -TimeoutSeconds $rebuiltWaitTimeoutSeconds)
    Write-Host ("Found {0} rebuilt file(s) under {1}" -f $rebuiltFiles.Count, $swfRoot)
    Move-RebuiltGfxfFiles -RebuiltFiles $rebuiltFiles -DestinationRoot $rebuildGfxfTargetRoot
}

Write-Step "Generating rebuild.rpkg"
if (-not (Test-Path -LiteralPath $rebuildSourceRoot)) {
    throw "Rebuild source directory not found: '$rebuildSourceRoot'."
}

if (-not (Test-Path -LiteralPath $rebuildOutputRoot)) {
    New-Item -ItemType Directory -Path $rebuildOutputRoot | Out-Null
}

$generatedRpkgPath = Join-Path $rebuildOutputRoot "rebuild.rpkg"
if (Test-Path -LiteralPath $generatedRpkgPath) {
    Remove-Item -LiteralPath $generatedRpkgPath -Force
}

Invoke-RpkgCli -CliPath $rpkgCliPath -Arguments @(
    "-generate_rpkg_from",
    $rebuildSourceRoot,
    "-output_path",
    $rebuildOutputRoot
)

if (-not (Test-Path -LiteralPath $generatedRpkgPath)) {
    throw "Expected generated RPKG not found: '$generatedRpkgPath'."
}

Write-Step "Promoting final patch file"
Move-Item -LiteralPath $generatedRpkgPath -Destination $finalPatchPath -Force

Write-Host ""
Write-Host "Build complete:"
Write-Host "  $finalPatchPath"
