$ErrorActionPreference = "Stop"

Set-StrictMode -Version Latest

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$rpkgToolRoot = Join-Path $projectRoot "RPKGTool"
$rebuildSourceRoot = Join-Path $projectRoot "rebuild"
$rebuildOutputRoot = Join-Path $projectRoot "rebuild_output"
$rebuildGfxfTargetRoot = Join-Path $rebuildSourceRoot "chunk0\GFXF"
$finalPatchPath = Join-Path $projectRoot "chunk0patch272.rpkg"

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

    $rebuiltFiles = Get-ChildItem -LiteralPath $gfxfRoot -Recurse -File -Filter "GFXF.rebuilt"
    if (-not $rebuiltFiles) {
        throw "No GFXF.rebuilt files were found under '$gfxfRoot'."
    }

    return $rebuiltFiles
}

function Move-RebuiltGfxfFiles {
    param(
        [System.IO.FileInfo[]]$RebuiltFiles,
        [string]$DestinationRoot
    )

    if (-not (Test-Path -LiteralPath $DestinationRoot)) {
        throw "Destination GFXF directory not found: '$DestinationRoot'."
    }

    Get-ChildItem -LiteralPath $DestinationRoot -File -Filter "*.GFXF" |
        ForEach-Object {
            Remove-Item -LiteralPath $_.FullName -Force
        }

    foreach ($rebuiltFile in $RebuiltFiles) {
        $hashFolderName = Split-Path -Leaf (Split-Path -Parent $rebuiltFile.FullName)
        if (-not $hashFolderName.EndsWith(".GFXF")) {
            throw "Unexpected rebuilt GFXF folder name '$hashFolderName'."
        }

        $destinationPath = Join-Path $DestinationRoot $hashFolderName
        Move-Item -LiteralPath $rebuiltFile.FullName -Destination $destinationPath -Force
        Write-Host ("Moved {0} -> {1}" -f $rebuiltFile.FullName, $destinationPath)
    }
}

$rpkgCliPath = Get-RpkgCliPath -ToolRoot $rpkgToolRoot

$swfRoots = @(
    (Join-Path $projectRoot "src\hud.swf"),
    (Join-Path $projectRoot "src\menu.swf")
)

Write-Step "Rebuilding GFXF resources"
foreach ($swfRoot in $swfRoots) {
    $gfxSourceRoot = Join-Path $swfRoot "gfx"
    if (-not (Test-Path -LiteralPath $gfxSourceRoot)) {
        throw "Expected GFX source directory not found: '$gfxSourceRoot'."
    }

    Invoke-RpkgCli -CliPath $rpkgCliPath -Arguments @(
        "-rebuild_gfxf_in",
        $gfxSourceRoot
    )
}

Write-Step "Refreshing rebuild\chunk0\GFXF"
$rebuiltOutputs = @()
foreach ($swfRoot in $swfRoots) {
    $rebuiltOutputs += Get-RebuiltGfxfOutputs -SwfRoot $swfRoot
}
Move-RebuiltGfxfFiles -RebuiltFiles $rebuiltOutputs -DestinationRoot $rebuildGfxfTargetRoot

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
if (Test-Path -LiteralPath $finalPatchPath) {
    Remove-Item -LiteralPath $finalPatchPath -Force
}

Move-Item -LiteralPath $generatedRpkgPath -Destination $finalPatchPath -Force

Write-Host ""
Write-Host "Build complete:"
Write-Host "  $finalPatchPath"
