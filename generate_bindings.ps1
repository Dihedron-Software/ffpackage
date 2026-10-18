# generate_bindings.ps1 - Generate Odin bindings for FFmpeg using odin-c-bindgen.
#
# Prerequisites: Odin on PATH, LLVM/Clang 16+ (libclang.lib + libclang.dll in odin-c-bindgen/)

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$outputDir = "$root\output"
$headersDir = "$root\ffmpeg-install\include"
$bindgen = "$root\odin-c-bindgen\bindgen.exe"

# --- Build bindgen if needed ---
if (-not (Test-Path $bindgen)) {
    Write-Host "Building bindgen..."
    Push-Location "$root\odin-c-bindgen"
    odin build src -out:bindgen.exe -o:speed
    Pop-Location
    if (-not (Test-Path $bindgen)) { Write-Error "Failed to build bindgen.exe"; exit 1 }
}

if (-not (Test-Path $headersDir)) {
    Write-Error "FFmpeg headers not found at $headersDir. Run build_ffmpeg.sh first."
    exit 1
}

# --- Pre-process: temporarily remove forward declarations that cause empty structs ---
Write-Host "`nPre-processing headers..."
$headersToFix = @(
    @{ File = "$headersDir\libavformat\avformat.h"; Patterns = @('struct AVFormatContext;', 'struct AVFrame;') },
    @{ File = "$headersDir\libavcodec\avcodec.h";   Patterns = @('struct AVCodecParameters;') }
)

$backups = @()
foreach ($entry in $headersToFix) {
    $file = $entry.File
    if (Test-Path $file) {
        $backup = "$file.bak"
        Copy-Item $file $backup -Force
        $backups += @{ Original = $file; Backup = $backup }
        $content = Get-Content $file -Raw
        foreach ($pattern in $entry.Patterns) {
            $content = $content.Replace($pattern, "// $pattern")
        }
        Set-Content $file -Value $content -NoNewline
        Write-Host "  Patched $([System.IO.Path]::GetFileName($file))"
    }
}

# --- Run bindgen ---
Write-Host "`nRunning bindgen..."
& $bindgen "$root\bindgen-config"
$bindgenExit = $LASTEXITCODE

Write-Host "Restoring headers..."
foreach ($b in $backups) { Move-Item $b.Backup $b.Original -Force }

if ($bindgenExit -ne 0) { Write-Error "bindgen failed with exit code $bindgenExit"; exit 1 }

# --- Post-process: fix foreign imports per library ---
Write-Host "`nPatching foreign imports..."

$headerToLib = @{
    "avutil"         = "avutil"
    "buffer"         = "avutil"
    "channel_layout" = "avutil"
    "dict"           = "avutil"
    "display"        = "avutil"
    "frame"          = "avutil"
    "hwcontext"      = "avutil"
    "imgutils"       = "avutil"
    "log"            = "avutil"
    "mathematics"    = "avutil"
    "pixdesc"        = "avutil"
    "pixfmt"         = "avutil"
    "rational"       = "avutil"
    "samplefmt"      = "avutil"
    "avcodec"        = "avcodec"
    "codec"          = "avcodec"
    "codec_desc"     = "avcodec"
    "codec_id"       = "avcodec"
    "codec_par"      = "avcodec"
    "defs"           = "avcodec"
    "packet"         = "avcodec"
    "avformat"       = "avformat"
    "avio"           = "avformat"
    "avdevice"       = "avdevice"
    "swresample"     = "swresample"
    "swscale"        = "swscale"
}

$placeholderPattern = 'foreign import lib "__PLACEHOLDER__\.lib"\r?\n_ :: lib'

# The macOS and Linux libraries are named after their major version (libavcodec.62.dylib, libavcodec.so.62), the names
# the products ship them under, so read it from the headers this build installed.
$libMajor = @{}
foreach ($libName in ($headerToLib.Values | Sort-Object -Unique)) {
    $define = "LIB$($libName.ToUpper())_VERSION_MAJOR"
    foreach ($header in @("$headersDir\lib$libName\version_major.h", "$headersDir\lib$libName\version.h")) {
        if ((Test-Path $header) -and ((Get-Content $header -Raw) -match "#define\s+$define\s+(\d+)")) {
            $libMajor[$libName] = $Matches[1]
            break
        }
    }
    if (-not $libMajor.ContainsKey($libName)) { Write-Error "Could not find $define in the lib$libName headers"; exit 1 }
}

foreach ($odinFile in Get-ChildItem "$outputDir\*.odin" -ErrorAction SilentlyContinue) {
    $stem = $odinFile.BaseName
    if (-not $headerToLib.ContainsKey($stem)) { continue }
    $libName = $headerToLib[$stem]
    $major = $libMajor[$libName]

    # Windows: the import library next to the bindings. macOS and Linux: the shared library in macos/ or linux/, where
    # the product's build extracts its FFmpeg zip, named after its install name or soname.
    $replacement = "when ODIN_OS == .Windows {`r`n    foreign import lib `"lib/$libName.lib`"`r`n} else when ODIN_OS == .Darwin {`r`n    foreign import lib `"macos/lib$libName.$major.dylib`"`r`n} else when ODIN_OS == .Linux {`r`n    foreign import lib `"linux/lib$libName.so.$major`"`r`n}"

    $content = Get-Content $odinFile.FullName -Raw
    $newContent = $content -replace $placeholderPattern, $replacement
    if ($newContent -ne $content) {
        Set-Content $odinFile.FullName -Value $newContent -NoNewline
        Write-Host "  $($odinFile.Name) -> $libName"
    }
}

# --- Remove duplicate empty struct declarations ---
Write-Host "`nStripping duplicate empty structs..."

$fullStructs = @{}
$emptyStructs = @()

foreach ($odinFile in Get-ChildItem "$outputDir\*.odin" -ErrorAction SilentlyContinue) {
    $lines = Get-Content $odinFile.FullName
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if ($line -match '^\s*(\w+)\s*::\s*struct\s*\{\}\s*$') {
            $emptyStructs += ,@($odinFile, $Matches[1], $i)
        } elseif ($line -match '^\s*(\w+)\s*::\s*struct.*\{$') {
            $fullStructs[$Matches[1]] = $odinFile.Name
        }
    }
}

$keptEmpty = @{}
foreach ($entry in $emptyStructs) {
    $file = $entry[0]; $typeName = $entry[1]; $lineIdx = $entry[2]
    $remove = $false

    if ($fullStructs.ContainsKey($typeName) -and $fullStructs[$typeName] -ne $file.Name) {
        $remove = $true
    } elseif (-not $fullStructs.ContainsKey($typeName) -and $keptEmpty.ContainsKey($typeName)) {
        $remove = $true
    }

    if ($remove) {
        $lines = Get-Content $file.FullName
        $lines[$lineIdx] = "// $typeName :: struct {} // removed duplicate"
        Set-Content $file.FullName -Value $lines
        Write-Host "  Removed $typeName from $($file.Name)"
    } else {
        $keptEmpty[$typeName] = $file.Name
    }
}

# --- Copy hand-written files ---
Write-Host "`nCopying hand-written files..."
foreach ($f in Get-ChildItem "$root\hand-written\*.odin" -ErrorAction SilentlyContinue) {
    Copy-Item $f.FullName "$outputDir\" -Force
    Write-Host "  $($f.Name)"
}

Write-Host "`n=== Done! Bindings in $outputDir\ ==="
