# build_libraw.ps1 - Build LibRaw as a static library for Windows (MSVC, x64, static CRT).
# zlib (deflate DNG) and libjpeg-turbo (lossy DNG) are built too and merged into the same libraw.lib.
#
# Prerequisites: Visual Studio with the MSVC 14.44 toolset (MSVC v143), and CMake.
#
# Usage: .\build_libraw.ps1          # release
#        .\build_libraw.ps1 debug    # /Od + /Z7 for LibRaw and zlib (libjpeg-turbo stays Release)
#        .\build_libraw.ps1 clean    # remove build\ and the built library

param([string]$Mode = "release")

$ErrorActionPreference = "Stop"
$root        = $PSScriptRoot
$version     = "0.22.2"
$zlibVersion = "1.3.2"
$jpegVersion = "3.2.0"
$toolset     = "14.44" # the oldest MSVC that links the library, see README.md
$buildDir    = "$root\build"
$sourceDir   = "$buildDir\LibRaw-$version"
$zlibDir     = "$buildDir\zlib-$zlibVersion"
$jpegDir     = "$buildDir\libjpeg-turbo-$jpegVersion"
$jpegBuild   = "$buildDir\libjpeg-turbo-build"
$objectDir   = "$buildDir\object-$Mode"
$zlibObjects = "$buildDir\zlib-object-$Mode"
$outputDir   = "$root\output"
$archives    = @("LibRaw-$version.tar.gz", "zlib-$zlibVersion.tar.gz", "libjpeg-turbo-$jpegVersion.tar.gz")

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

# --- Verify the source archives against SHA256SUMS.txt, then extract them ---
New-Item -ItemType Directory -Force $buildDir | Out-Null
foreach ($name in $archives) {
    $archive  = "$root\source\$name"
    $expected = (Get-Content "$root\source\SHA256SUMS.txt" | Where-Object { $_ -match [regex]::Escape($name) }) -split '\s+' | Select-Object -First 1
    $actual   = (Get-FileHash $archive -Algorithm SHA256).Hash.ToLower()
    if ($actual -ne $expected) { Write-Error "SHA256 mismatch for $archive`n  expected $expected`n  actual   $actual"; exit 1 }

    if (-not (Test-Path "$buildDir\$($name -replace '\.tar\.gz$', '')")) {
        Write-Host "Extracting $name..."
        & "$env:SystemRoot\System32\tar.exe" -xzf $archive -C $buildDir
        if ($LASTEXITCODE -ne 0) { Write-Error "tar failed"; exit 1 }
    }
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
Write-Host "Compiling zlib $zlibVersion, libjpeg-turbo $jpegVersion and $($sources.Count) LibRaw files ($Mode)..."

Remove-Item $objectDir, $zlibObjects -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force $objectDir, $zlibObjects, $outputDir | Out-Null

$responseFile = "$buildDir\sources-$Mode.rsp"
$sources | ForEach-Object { "`"$($_.FullName)`"" } | Set-Content $responseFile -Encoding ascii

$compileZlib   = "cl /nologo /c /MP /MT /W0 $optimizeFlags /Fo`"$zlibObjects\\`" `"$zlibDir\*.c`""

# Only the static libjpeg library. No SIMD, because its x86 code needs NASM, and lossy DNG is rare.
# libjpeg-turbo's CMake uses the static CRT (/MT) unless WITH_CRT_DLL is set.
$configureJpeg = "cmake -S `"$jpegDir`" -B `"$jpegBuild`" -G `"NMake Makefiles`" -DCMAKE_BUILD_TYPE=Release -DENABLE_SHARED=OFF -DENABLE_STATIC=ON -DWITH_SIMD=OFF -DWITH_TURBOJPEG=OFF -DWITH_TOOLS=OFF -DWITH_TESTS=OFF"
$buildJpeg     = "cmake --build `"$jpegBuild`" --target jpeg-static"

# Flags follow Makefile.msvc, except /MT (static CRT, the same as Hydra and Odin's vendor libs)
# and no /openmp, so the library needs no OpenMP runtime. USE_ZLIB and USE_JPEG enable deflate and lossy DNG.
$compile = "cl /nologo /c /MP /MT /EHsc /W0 $optimizeFlags /DWIN32 /DLIBRAW_NODLL /DLIBRAW_BUILDLIB /DUSE_ZLIB /DUSE_JPEG /I`"$sourceDir`" /I`"$zlibDir`" /I`"$jpegDir\src`" /I`"$jpegBuild`" /Fo`"$objectDir\\`" @`"$responseFile`""
$archiveLib = "lib /nologo /out:`"$outputDir\libraw.lib`" `"$objectDir\*.obj`" `"$zlibObjects\*.obj`" `"$jpegBuild\jpeg-static.lib`""

cmd /c "call $vcvars >nul && $compileZlib && $configureJpeg && $buildJpeg && $compile && $archiveLib"
if ($LASTEXITCODE -ne 0) { Write-Error "LibRaw build failed"; exit 1 }

# --- License files next to the library ---
Copy-Item "$sourceDir\LICENSE.CDDL" "$outputDir\"                          -Force
Copy-Item "$sourceDir\COPYRIGHT"    "$outputDir\"                          -Force
Copy-Item "$zlibDir\LICENSE"        "$outputDir\LICENSE.zlib"              -Force
Copy-Item "$jpegDir\LICENSE.md"     "$outputDir\LICENSE.libjpeg-turbo.md"  -Force
Copy-Item "$jpegDir\README.ijg"     "$outputDir\README.ijg"                -Force

Write-Host "`n=== Done! $outputDir\libraw.lib ==="
