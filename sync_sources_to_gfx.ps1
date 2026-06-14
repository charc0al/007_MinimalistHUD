param(
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

function Get-SwfTargets {
    param([string]$SourceRoot)

    $targets = @()
    $swfRoots = Get-ChildItem -LiteralPath $SourceRoot -Directory -Filter "*.swf" | Sort-Object Name
    foreach ($swfRoot in $swfRoots) {
        $gfxRoot = Join-Path $swfRoot.FullName "gfx\GFXF\chunk0.rpkg"
        $scriptsRoot = Join-Path $swfRoot.FullName "scripts"
        $hasGfx = Test-Path -LiteralPath $gfxRoot
        $hasScripts = Test-Path -LiteralPath $scriptsRoot
        if (-not $hasGfx -or -not $hasScripts) {
            continue
        }

        $gfxFile = Get-ChildItem -LiteralPath $gfxRoot -Recurse -File -Filter "*.GFX" | Select-Object -First 1
        if ($null -eq $gfxFile) {
            continue
        }

        $targets += @{
            Name = [System.IO.Path]::GetFileNameWithoutExtension($swfRoot.Name)
            SwfName = $swfRoot.Name
            GfxPath = $gfxFile.FullName
            ScriptsPath = $scriptsRoot
        }
    }

    if ($targets.Count -eq 0) {
        throw "No SWF targets with both scripts and GFX payloads were found under '$SourceRoot'."
    }

    return $targets
}

$ffdecCliPath = Get-FfdecCliPath -Root $projectRoot

$targets = @(Get-SwfTargets -SourceRoot (Join-Path $projectRoot "src"))

if ($Target -ne "all") {
    $targets = @($targets | Where-Object { $_.Name -eq $Target -or $_.SwfName -eq $Target -or $_.SwfName -eq ($Target + ".swf") })
    if ($targets.Count -eq 0) {
        throw "Unknown sync target '$Target'. Available targets: $((Get-SwfTargets -SourceRoot (Join-Path $projectRoot "src") | ForEach-Object { $_.Name }) -join ', ')"
    }
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
