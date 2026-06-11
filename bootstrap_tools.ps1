param(
    [string]$RpkgCliUrl = "",
    [string]$RpkgCliZipPath = "Z:\Code\RPKGTool\downloaded-builds\first-light-d819b38-rpkg-cli.zip",
    [string]$FfdecUrl = "https://github.com/jindrapetrik/jpexs-decompiler/releases/download/version26.2.1/ffdec_26.2.1.zip",
    [switch]$Force
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$toolsRoot = Join-Path $projectRoot "tools"
$rpkgCliTargetRoot = Join-Path $toolsRoot "rpkg-cli"
$ffdecTargetRoot = Join-Path $toolsRoot "ffdec"
$downloadsRoot = Join-Path $toolsRoot "_downloads"
$rpkgCliArchivePath = Join-Path $downloadsRoot "first-light-rpkg-cli.zip"
$ffdecArchivePath = Join-Path $downloadsRoot "ffdec_26.2.1.zip"

function Write-Step {
    param([string]$Message)

    Write-Host ""
    Write-Host "==> $Message"
}

function Reset-Directory {
    param([string]$Path)

    if (Test-Path -LiteralPath $Path) {
        Remove-Item -LiteralPath $Path -Recurse -Force
    }

    New-Item -ItemType Directory -Path $Path | Out-Null
}

function Expand-FlatZip {
    param(
        [string]$ArchivePath,
        [string]$DestinationPath
    )

    $extractRoot = Join-Path $downloadsRoot ([System.IO.Path]::GetFileNameWithoutExtension($ArchivePath) + "-extract")
    Reset-Directory -Path $extractRoot

    try {
        Expand-Archive -LiteralPath $ArchivePath -DestinationPath $extractRoot -Force

        $entries = @(Get-ChildItem -LiteralPath $extractRoot -Force)
        if ($entries.Count -eq 1 -and $entries[0].PSIsContainer) {
            $payloadRoot = $entries[0].FullName
        }
        else {
            $payloadRoot = $extractRoot
        }

        Reset-Directory -Path $DestinationPath
        Get-ChildItem -LiteralPath $payloadRoot -Force | ForEach-Object {
            Move-Item -LiteralPath $_.FullName -Destination $DestinationPath -Force
        }
    }
    finally {
        if (Test-Path -LiteralPath $extractRoot) {
            Remove-Item -LiteralPath $extractRoot -Recurse -Force
        }
    }
}

if (-not (Test-Path -LiteralPath $toolsRoot)) {
    New-Item -ItemType Directory -Path $toolsRoot | Out-Null
}

if (-not (Test-Path -LiteralPath $downloadsRoot)) {
    New-Item -ItemType Directory -Path $downloadsRoot | Out-Null
}

$shouldFetchRpkg = $Force -or -not (Test-Path -LiteralPath (Join-Path $rpkgCliTargetRoot "rpkg-cli.exe"))
$shouldFetchFfdec = $Force -or -not (Test-Path -LiteralPath (Join-Path $ffdecTargetRoot "ffdec-cli.exe"))

if ($shouldFetchRpkg) {
    if ($RpkgCliUrl) {
        Write-Step "Downloading RPKG CLI"
        Invoke-WebRequest -Uri $RpkgCliUrl -OutFile $rpkgCliArchivePath
    }
    elseif (Test-Path -LiteralPath $RpkgCliZipPath) {
        Write-Step "Using local RPKG CLI archive"
        Copy-Item -LiteralPath $RpkgCliZipPath -Destination $rpkgCliArchivePath -Force
    }
    else {
        throw "RPKG CLI archive not found. Provide -RpkgCliUrl or place the archive at '$RpkgCliZipPath'."
    }

    Write-Step "Extracting RPKG CLI to tools\rpkg-cli"
    Expand-FlatZip -ArchivePath $rpkgCliArchivePath -DestinationPath $rpkgCliTargetRoot
}
else {
    Write-Host "RPKG CLI already present at '$rpkgCliTargetRoot'. Use -Force to reinstall."
}

if ($shouldFetchFfdec) {
    Write-Step "Downloading FFDec"
    Invoke-WebRequest -Uri $FfdecUrl -OutFile $ffdecArchivePath

    Write-Step "Extracting FFDec to tools\ffdec"
    Expand-FlatZip -ArchivePath $ffdecArchivePath -DestinationPath $ffdecTargetRoot
}
else {
    Write-Host "FFDec already present at '$ffdecTargetRoot'. Use -Force to reinstall."
}

Write-Host ""
Write-Host "Tool bootstrap complete."
