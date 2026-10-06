# build_libraw.ps1 - Build LibRaw as a static library for Windows (MSVC, x64, static CRT).
#
# Prerequisites: Visual Studio with the MSVC 14.44 toolset (MSVC v143).
#
# Usage: .\build_libraw.ps1          # release
#        .\build_libraw.ps1 debug    # /Od + /Z7
#        .\build_libraw.ps1 clean    # remove build\ and the built library

param([string]$Mode = "release")

$ErrorActionPreference = "Stop"
$root      = $PSScriptRoot
$version   = "0.22.2"
$toolset   = "14.44" # the oldest MSVC that links Dihedron products, see README.md
$archive   = "$root\source\LibRaw-$version.tar.gz"
$buildDir  = "$root\build"
$sourceDir = "$buildDir\LibRaw-$version"
$objectDir = "$buildDir\object-$Mode"
$outputDir = "$root\output"

if ($Mode -eq "clean") {
    Remove-Item $buildDir -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$outputDir\libraw.lib" -Force -ErrorAction SilentlyContinue
    Write-Host "Cleaned."
    exit 0
}

$optimizeFlags = switch ($Mode) {
    "release" { "/O2" }
    "debug"   { "/Od /Z7" }
    default   { Write-Error "Unknown mode '$Mode' (release, debug, clean)"; exit 1 }
}

# --- Verify the source archive against SHA256SUMS.txt ---
Write-Host "Verifying source archive..."
$expected = (Get-Content "$root\source\SHA256SUMS.txt" | Where-Object { $_ -match "LibRaw-$version\.tar\.gz" }) -split '\s+' | Select-Object -First 1
$actual   = (Get-FileHash $archive -Algorithm SHA256).Hash.ToLower()
if ($actual -ne $expected) { Write-Error "SHA256 mismatch for $archive`n  expected $expected`n  actual   $actual"; exit 1 }

# --- Extract ---
if (-not (Test-Path $sourceDir)) {
    New-Item -ItemType Directory -Force $buildDir | Out-Null
    Write-Host "Extracting LibRaw $version..."
    & "$env:SystemRoot\System32\tar.exe" -xzf $archive -C $buildDir
    if ($LASTEXITCODE -ne 0) { Write-Error "tar failed"; exit 1 }
}

# --- Locate MSVC ---
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
if (-not (Test-Path $vswhere)) { Write-Error "vswhere.exe not found. Install Visual Studio with the C++ toolset."; exit 1 }
$vsPath = & $vswhere -all -products * -property installationPath | Where-Object { Test-Path "$_\VC\Tools\MSVC\$toolset.*" } | Select-Object -First 1
if (-not $vsPath) { Write-Error "No Visual Studio has the MSVC $toolset toolset. Add the 'MSVC v143 - VS 2022 C++ x64/x86 build tools' component in the Visual Studio Installer."; exit 1 }
$vcvars = "`"$vsPath\VC\Auxiliary\Build\vcvars64.bat`" -vcvars_ver=$toolset"
Write-Host "Using MSVC $toolset from $vsPath"

# --- Compile ---
# The same source list as LibRaw's Makefile.msvc: every src\**\*.cpp except the *_ph.cpp
# placeholders, which stub out postprocessing for builds that do not want it.
$sources = Get-ChildItem "$sourceDir\src" -Recurse -Filter *.cpp | Where-Object { $_.Name -notlike "*_ph.cpp" }
Write-Host "Compiling $($sources.Count) files ($Mode)..."

Remove-Item $objectDir -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force $objectDir | Out-Null
New-Item -ItemType Directory -Force $outputDir | Out-Null

$responseFile = "$buildDir\sources-$Mode.rsp"
$sources | ForEach-Object { "`"$($_.FullName)`"" } | Set-Content $responseFile -Encoding ascii

# Flags follow Makefile.msvc, except /MT (static CRT, the same as Hydra and Odin's vendor libs)
# and no /openmp, so the library needs no OpenMP runtime.
$compile = "cl /nologo /c /MP /MT /EHsc /W0 $optimizeFlags /DWIN32 /DLIBRAW_NODLL /DLIBRAW_BUILDLIB /I`"$sourceDir`" /Fo`"$objectDir\\`" @`"$responseFile`""
$archiveLib = "lib /nologo /out:`"$outputDir\libraw.lib`" `"$objectDir\*.obj`""

cmd /c "call $vcvars >nul && $compile && $archiveLib"
if ($LASTEXITCODE -ne 0) { Write-Error "LibRaw build failed"; exit 1 }

# --- License files next to the library ---
Copy-Item "$sourceDir\LICENSE.CDDL" "$outputDir\" -Force
Copy-Item "$sourceDir\COPYRIGHT"    "$outputDir\" -Force

Write-Host "`n=== Done! $outputDir\libraw.lib ==="
