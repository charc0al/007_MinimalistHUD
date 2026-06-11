param(
    [ValidateSet("all", "hud", "menu")]
    [string]$Target = "all"
)

$ErrorActionPreference = "Stop"

Set-StrictMode -Version Latest

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

function Write-Step {
    param([string]$Message)

    Write-Host ""
    Write-Host "==> $Message"
}

function Get-FfdecCliPath {
    param([string]$Root)

    $candidates = @(
        (Join-Path $Root "tools\ffdec\ffdec-cli.exe"),
        (Join-Path $Root "tools\ffdec\ffdec.bat")
    )

    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }

    $pathCommand = Get-Command ffdec-cli.exe, ffdec.bat -ErrorAction SilentlyContinue |
        Select-Object -First 1

    if ($pathCommand) {
        return $pathCommand.Source
    }

    throw "Could not find FFDec CLI. Expected it under '$Root\tools\ffdec'."
}

function Invoke-FfdecImportScript {
    param(
        [string]$CliPath,
        [string]$InputPath,
        [string]$OutputPath,
        [string]$ScriptsPath
    )

    Write-Host ("Running: {0} -importScript `"{1}`" `"{2}`" `"{3}`"" -f (Split-Path -Leaf $CliPath), $InputPath, $OutputPath, $ScriptsPath)
    & $CliPath -importScript $InputPath $OutputPath $ScriptsPath

    if ($LASTEXITCODE -ne 0) {
        throw "FFDec importScript failed with exit code $LASTEXITCODE."
    }
}

function Sync-ScriptsIntoGfx {
    param(
        [string]$CliPath,
        [string]$Name,
        [string]$GfxPath,
        [string]$ScriptsPath
    )

    if (-not (Test-Path -LiteralPath $GfxPath)) {
        throw "Expected GFX file not found: '$GfxPath'."
    }

    if (-not (Test-Path -LiteralPath $ScriptsPath)) {
        throw "Expected scripts directory not found: '$ScriptsPath'."
    }

    $tempFileName = "{0}-{1}" -f ([System.Guid]::NewGuid().ToString("N")), (Split-Path -Leaf $GfxPath)
    $tempOutputPath = Join-Path ([System.IO.Path]::GetTempPath()) $tempFileName

    try {
        Write-Step ("Importing {0} scripts into {1}" -f $Name, (Split-Path -Leaf $GfxPath))
        Invoke-FfdecImportScript -CliPath $CliPath -InputPath $GfxPath -OutputPath $tempOutputPath -ScriptsPath $ScriptsPath

        if (-not (Test-Path -LiteralPath $tempOutputPath)) {
            throw "FFDec did not produce an output file at '$tempOutputPath'."
        }

        Move-Item -LiteralPath $tempOutputPath -Destination $GfxPath -Force
        Write-Host ("Updated {0}" -f $GfxPath)
    }
    finally {
        if (Test-Path -LiteralPath $tempOutputPath) {
            Remove-Item -LiteralPath $tempOutputPath -Force
        }
    }
}

$ffdecCliPath = Get-FfdecCliPath -Root $projectRoot

$targets = @(
    @{
        Name = "hud"
        GfxPath = Join-Path $projectRoot "src\hud.swf\gfx\GFXF\chunk0.rpkg\01262EED9D687969.GFXF\01262EED9D687969.GFXF.GFX"
        ScriptsPath = Join-Path $projectRoot "src\hud.swf\scripts"
    },
    @{
        Name = "menu"
        GfxPath = Join-Path $projectRoot "src\menu.swf\gfx\GFXF\chunk0.rpkg\01A837AF55107DEC.GFXF\01A837AF55107DEC.GFXF.GFX"
        ScriptsPath = Join-Path $projectRoot "src\menu.swf\scripts"
    }
)

if ($Target -ne "all") {
    $targets = @($targets | Where-Object { $_.Name -eq $Target })
}

foreach ($targetInfo in $targets) {
    Sync-ScriptsIntoGfx `
        -CliPath $ffdecCliPath `
        -Name $targetInfo.Name `
        -GfxPath $targetInfo.GfxPath `
        -ScriptsPath $targetInfo.ScriptsPath
}

Write-Host ""
Write-Host "Source-to-GFX sync complete."
