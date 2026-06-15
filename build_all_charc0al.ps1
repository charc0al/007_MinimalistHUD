param(
    [switch]$SkipSourceSync
)

$ErrorActionPreference = "Stop"

Set-StrictMode -Version Latest

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$baseBuildScriptPath = Join-Path $projectRoot "build_all.ps1"
$charc0alButtonsRoot = Join-Path $projectRoot "buttons\charc0al"
$srcRoot = Join-Path $projectRoot "src"

function Write-Step {
    param([string]$Message)

    Write-Host ""
    Write-Host "==> $Message"
}

function Copy-PlatformButtonOverrides {
    param(
        [string]$SourceRoot,
        [string]$DestinationRoot
    )

    if (-not (Test-Path -LiteralPath $SourceRoot)) {
        throw "Platform button source root not found: '$SourceRoot'."
    }

    if (-not (Test-Path -LiteralPath $DestinationRoot)) {
        throw "Source asset root not found: '$DestinationRoot'."
    }

    $overrideDirs = @(
        Get-ChildItem -LiteralPath $SourceRoot -Recurse -Directory -Filter "*.GFXF" |
        Sort-Object FullName
    )

    if ($overrideDirs.Count -eq 0) {
        throw "No platform override GFXF directories were found under '$SourceRoot'."
    }

    foreach ($overrideDir in $overrideDirs) {
        $relativeDir = $overrideDir.FullName.Substring($SourceRoot.Length).TrimStart('\')
        $targetDir = Join-Path $DestinationRoot $relativeDir

        if (-not (Test-Path -LiteralPath $targetDir)) {
            throw "Matching source GFXF directory not found: '$targetDir'."
        }

        $overrideFiles = @(
            Get-ChildItem -LiteralPath $overrideDir.FullName -File -Filter "*.dds" |
            Sort-Object Name
        )

        foreach ($overrideFile in $overrideFiles) {
            $destinationPath = Join-Path $targetDir $overrideFile.Name
            Copy-Item -LiteralPath $overrideFile.FullName -Destination $destinationPath -Force
            Write-Host ("Copied {0} -> {1}" -f $overrideFile.FullName, $destinationPath)
        }
    }
}

if (-not (Test-Path -LiteralPath $baseBuildScriptPath)) {
    throw "Base build script not found: '$baseBuildScriptPath'."
}

Write-Step "Copying Switch button overrides into src"
Copy-PlatformButtonOverrides -SourceRoot $charc0alButtonsRoot -DestinationRoot $srcRoot

Write-Step "Running base build"
& $baseBuildScriptPath -IncludeAssetOnlySwfs:$true -SkipSourceSync:$SkipSourceSync

if ($LASTEXITCODE -ne 0) {
    throw "Base build failed with exit code $LASTEXITCODE."
}
