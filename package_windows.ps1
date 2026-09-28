<#
.SYNOPSIS
  Verify -> sign -> zip -> replace the Windows FFmpeg libraries into Blick.

  Runs AFTER build_ffmpeg.sh has produced output/dll/*.dll. Steps:
    1. Assert the build is legally clean (config.h: no GPL/nonfree, excluded encoders gone).
    2. Assert the 7 expected shared libs are present.
    3. Authenticode-sign the DLLs with Azure Artifact Signing.
    4. Verify signatures.
    5. Pack the DLLs flat into ffmpeg_windows.zip.
    6. Back up and replace the monorepo's blick\ffmpeg_windows.zip (Blick and Zeiger ship it).

  Signing note: signtool uses the same Azure dlib and metadata.json in C:\tools\azuresign as
  the monorepo builder. Run `az login` as the signer account first, or pass -SkipSign to
  produce an unsigned zip.

.EXAMPLE
  .\package_windows.ps1                 # full pipeline (sign + replace)
  .\package_windows.ps1 -SkipSign       # zip + replace without signing
  .\package_windows.ps1 -NoReplace      # build the signed zip, don't touch Blick
#>
[CmdletBinding()]
param(
    [string]$SignDlib     = "C:\tools\azuresign\client\bin\x64\Azure.CodeSigning.Dlib.dll",
    [string]$SignMetadata = "C:\tools\azuresign\metadata.json",
    [string]$TimestampUrl = "http://timestamp.acs.microsoft.com",
    [string]$DllDir      = "$PSScriptRoot\output\dll",
    [string]$ConfigH     = "$PSScriptRoot\ffmpeg\config.h",
    [string]$ConfigComponents = "$PSScriptRoot\ffmpeg\config_components.h",
    [string]$TargetZip   = "$PSScriptRoot\..\monorepo\blick\ffmpeg_windows.zip",
    [switch]$SkipSign,
    [switch]$NoReplace
)

$ErrorActionPreference = "Stop"

# The libs Blick links; must match the sonames the Odin bindings expect.
$expected = @(
    "avcodec-62.dll","avdevice-62.dll","avfilter-11.dll","avformat-62.dll",
    "avutil-60.dll","swresample-6.dll","swscale-9.dll"
)

function Fail($msg) { Write-Host "FAIL: $msg" -ForegroundColor Red; exit 1 }
function Ok($msg)   { Write-Host "  OK  $msg" -ForegroundColor Green }

# --- 1. legal verification from config.h ------------------------------------
Write-Host "`n[1/6] Verifying license posture in config.h" -ForegroundColor Cyan
if (-not (Test-Path $ConfigH)) { Fail "config.h not found at $ConfigH - run build_ffmpeg.sh first." }
# FFmpeg 8.0 splits macros: GPL/nonfree/external-libs in config.h, per-codec
# encoder/decoder macros in config_components.h. Parse both.
$cfg = @{}
foreach ($file in @($ConfigH, $ConfigComponents)) {
    if (-not (Test-Path $file)) { Fail "config file not found: $file - run build_ffmpeg.sh first." }
    foreach ($line in Get-Content $file) {
        if ($line -match '^#define\s+(CONFIG_\w+)\s+(\d+)') { $cfg[$Matches[1]] = [int]$Matches[2] }
    }
}
# name -> required value. 0 = must be absent, 1 = must be present.
$mustBe = [ordered]@{
    CONFIG_GPL              = 0;  CONFIG_NONFREE          = 0
    CONFIG_LIBX264          = 0;  CONFIG_LIBX265          = 0;  CONFIG_LIBFDK_AAC = 0
    CONFIG_PRORES_ENCODER   = 0;  CONFIG_PRORES_AW_ENCODER = 0; CONFIG_PRORES_KS_ENCODER = 0
    CONFIG_EAC3_ENCODER     = 0;  CONFIG_TRUEHD_ENCODER   = 0;  CONFIG_MLP_ENCODER = 0
    CONFIG_DCA_ENCODER      = 0
    CONFIG_AAC_ENCODER      = 1;  CONFIG_LIBOPENH264      = 1
}
$bad = $false
foreach ($k in $mustBe.Keys) {
    $have = if ($cfg.ContainsKey($k)) { $cfg[$k] } else { 0 }
    if ($have -ne $mustBe[$k]) {
        Write-Host ("  BAD  {0} = {1} (want {2})" -f $k, $have, $mustBe[$k]) -ForegroundColor Red
        $bad = $true
    }
}
if ($bad) { Fail "config.h does not match the licensed posture. Do NOT ship this build." }
Ok "GPL/nonfree off; x264/x265/fdk-aac and ProRes/Dolby/DTS encoders absent; AAC+openh264 present."

# --- 2. presence check ------------------------------------------------------
Write-Host "`n[2/6] Checking output DLLs" -ForegroundColor Cyan
if (-not (Test-Path $DllDir)) { Fail "DLL dir not found: $DllDir" }
foreach ($name in $expected) {
    if (-not (Test-Path (Join-Path $DllDir $name))) { Fail "missing expected DLL: $name" }
}
$dlls = Get-ChildItem (Join-Path $DllDir "*.dll")
Ok ("{0} DLLs present ({1} expected)." -f $dlls.Count, $expected.Count)

# --- 3. sign ----------------------------------------------------------------
if ($SkipSign) {
    Write-Host "`n[3/6] Signing SKIPPED (-SkipSign)" -ForegroundColor Yellow
} else {
    Write-Host "`n[3/6] Signing with Azure Artifact Signing" -ForegroundColor Cyan
    $signtool = Get-ChildItem "C:\Program Files (x86)\Windows Kits\10\bin\*\x64\signtool.exe" -EA SilentlyContinue |
                Sort-Object FullName -Descending | Select-Object -First 1
    if (-not $signtool) { Fail "signtool.exe not found (install Windows SDK signing tools)." }
    & $signtool.FullName sign /fd SHA256 /tr $TimestampUrl /td SHA256 /dlib $SignDlib /dmdf $SignMetadata /v $dlls.FullName
    if ($LASTEXITCODE -ne 0) {
        Fail "signtool failed (exit $LASTEXITCODE). Run az login as the signer account; the signer also needs $SignDlib and $SignMetadata."
    }
    Ok "Signed $($dlls.Count) DLLs."

    Write-Host "`n[4/6] Verifying signatures" -ForegroundColor Cyan
    foreach ($d in $dlls) {
        $sig = Get-AuthenticodeSignature $d.FullName
        if ($sig.Status -ne "Valid") { Fail "signature invalid for $($d.Name): $($sig.Status)" }
    }
    Ok "All signatures Valid."
}

# --- 5. pack flat zip -------------------------------------------------------
Write-Host "`n[5/6] Packing flat zip" -ForegroundColor Cyan
$stageZip = Join-Path $PSScriptRoot "output\ffmpeg_windows.zip"
if (Test-Path $stageZip) { Remove-Item $stageZip -Force }
Compress-Archive -Path (Join-Path $DllDir "*.dll") -DestinationPath $stageZip -CompressionLevel Optimal
Ok "Wrote $stageZip"

# --- 6. replace Blick's zip -------------------------------------------------
if ($NoReplace) {
    Write-Host "`n[6/6] Replace SKIPPED (-NoReplace). Staged zip: $stageZip" -ForegroundColor Yellow
} else {
    Write-Host "`n[6/6] Replacing Blick zip" -ForegroundColor Cyan
    $target = Resolve-Path -LiteralPath (Split-Path $TargetZip) -EA SilentlyContinue
    if (-not $target) { Fail "Blick dir not found for $TargetZip" }
    if (Test-Path $TargetZip) {
        $backup = "$TargetZip.bak"
        Copy-Item $TargetZip $backup -Force
        Ok "Backed up existing zip -> $backup"
    }
    Copy-Item $stageZip $TargetZip -Force
    Ok "Replaced $TargetZip"
}

Write-Host "`nDone." -ForegroundColor Cyan
