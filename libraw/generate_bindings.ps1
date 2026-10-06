# generate_bindings.ps1 - Generate Odin bindings for LibRaw using odin-c-bindgen.
#
# Prerequisites: build_libraw.ps1 has run (it extracts the headers), Odin on PATH,
# LLVM/Clang 16+ (libclang.lib + libclang.dll in ..\odin-c-bindgen\).

$ErrorActionPreference = "Stop"
$root       = $PSScriptRoot
$version    = "0.22.2"
$outputDir  = "$root\output"
$headersDir = "$root\build\LibRaw-$version\libraw"
$bindgenDir = "$root\..\odin-c-bindgen"
$bindgen    = "$bindgenDir\bindgen.exe"

# --- Build bindgen if needed ---
if (-not (Test-Path $bindgen)) {
    Write-Host "Building bindgen..."
    Push-Location $bindgenDir
    odin build src -out:bindgen.exe -o:speed
    Pop-Location
    if (-not (Test-Path $bindgen)) { Write-Error "Failed to build bindgen.exe"; exit 1 }
}

if (-not (Test-Path $headersDir)) {
    Write-Error "LibRaw headers not found at $headersDir. Run build_libraw.ps1 first."
    exit 1
}

# --- Run bindgen ---
Write-Host "Running bindgen..."
New-Item -ItemType Directory -Force $outputDir | Out-Null
Get-ChildItem "$outputDir\*.odin" -ErrorAction SilentlyContinue | Remove-Item -Force

Push-Location $root
& $bindgen "$root\bindgen-config"
$bindgenExit = $LASTEXITCODE
Pop-Location
if ($bindgenExit -ne 0) { Write-Error "bindgen failed with exit code $bindgenExit"; exit 1 }

# --- Post-process: foreign import and license header ---
# The static library sits next to the bindings: libraw.lib on Windows, libraw.a on macOS.
# LibRaw is C++, so macOS also links libc++. On Windows the MSVC objects pull in the C++ runtime themselves.
$placeholderPattern = 'foreign import lib "__PLACEHOLDER__\.lib"\r?\n_ :: lib'
$replacement = "when ODIN_OS == .Windows {`r`n    foreign import lib `"libraw.lib`"`r`n} else when ODIN_OS == .Darwin {`r`n    foreign import lib { `"libraw.a`", `"system:c++`" }`r`n}"

$header = @"
// Odin bindings for LibRaw $version, generated from the LibRaw headers by
// generate_bindings.ps1 (https://github.com/Dihedron-Software/ffpackage, libraw/).
//
// LibRaw: Copyright (C) 2008-2025 LibRaw LLC (http://www.libraw.org, info@libraw.org)
// Generated bindings: Dihedron Software GmbH
//
// This file is distributed under the COMMON DEVELOPMENT AND DISTRIBUTION LICENSE (CDDL)
// Version 1.0, which is one of the two licenses LibRaw offers. See LICENSE.CDDL and COPYRIGHT.

"@

Write-Host "`nPost-processing..."
foreach ($odinFile in Get-ChildItem "$outputDir\*.odin") {
    $content = Get-Content $odinFile.FullName -Raw
    $content = $content -replace $placeholderPattern, $replacement
    Set-Content $odinFile.FullName -Value ($header + $content) -NoNewline
    Write-Host "  $($odinFile.Name)"
}

# --- License files next to the bindings ---
Copy-Item "$root\build\LibRaw-$version\LICENSE.CDDL" "$outputDir\" -Force
Copy-Item "$root\build\LibRaw-$version\COPYRIGHT"    "$outputDir\" -Force

Write-Host "`n=== Done! Bindings in $outputDir\ ==="
