#!/bin/bash
# Build FFmpeg 8.0 as LGPL 2.1+ shared DLLs using MSYS2/MinGW64.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FFMPEG_SRC="$SCRIPT_DIR/ffmpeg"
INSTALL_DIR="$SCRIPT_DIR/ffmpeg-install"
OUTPUT_DIR="$SCRIPT_DIR/output"

echo "=== FFmpeg LGPL 2.1+ Shared Build ==="
echo "Source:  $FFMPEG_SRC"
echo "Install: $INSTALL_DIR"
echo "Output:  $OUTPUT_DIR"
echo ""

echo ">>> Installing prerequisites..."
pacman -S --needed --noconfirm \
    mingw-w64-x86_64-gcc \
    mingw-w64-x86_64-nasm \
    mingw-w64-x86_64-tools-git \
    make \
    pkg-config \
    diffutils

for tool in gcc nasm make pkg-config gendef dlltool; do
    if ! command -v $tool &>/dev/null; then
        echo "ERROR: $tool not found. Check your MSYS2 environment."
        exit 1
    fi
done

cd "$FFMPEG_SRC"

if [ "$1" = "clean" ]; then
    echo ">>> Cleaning previous build..."
    make distclean 2>/dev/null || true
    rm -rf "$INSTALL_DIR" "$OUTPUT_DIR"
fi

if [ ! -f "config.mak" ]; then
    echo ">>> Configuring FFmpeg (this takes a long time on MSYS2)..."
    ./configure \
        --prefix="$INSTALL_DIR" \
        --enable-shared \
        --disable-static \
        --disable-programs \
        --disable-doc \
        --enable-runtime-cpudetect \
        --extra-cflags="-O2" \
        --extra-ldflags="-static-libgcc" \
        --extra-libs="-static -lz -liconv"
    echo ">>> Configure done."
else
    echo ">>> Skipping configure (already configured). Use 'clean' to reconfigure."
fi

JOBS=$(nproc)
if [ "$JOBS" -gt 8 ]; then JOBS=8; fi
echo ">>> Building FFmpeg ($JOBS threads)..."
make -j$JOBS || { echo "ERROR: Build failed."; exit 1; }
echo ">>> Build done."

echo ">>> Installing..."
make install -k 2>&1 | grep -v "cannot stat.*\.lib"

echo ">>> Collecting outputs..."
mkdir -p "$OUTPUT_DIR/dll" "$OUTPUT_DIR/lib"
cp "$INSTALL_DIR/bin/"*.dll "$OUTPUT_DIR/dll/" 2>/dev/null || true

cd "$OUTPUT_DIR/dll"
for dll in *.dll; do
    basename="${dll%.dll}"
    libname=$(echo "$basename" | sed 's/-[0-9]*$//')
    echo "  $dll -> $libname.lib"
    gendef "$dll"
    if [ -f "${basename}.def" ]; then
        dlltool -d "${basename}.def" -l "../lib/${libname}.lib" -D "$dll"
        rm -f "${basename}.def"
    fi
done

echo ""
echo "=== Build complete ==="
echo "DLLs:    $(ls -1 "$OUTPUT_DIR/dll/"*.dll 2>/dev/null | wc -l) files in $OUTPUT_DIR/dll/"
echo "Libs:    $(ls -1 "$OUTPUT_DIR/lib/"*.lib 2>/dev/null | wc -l) files in $OUTPUT_DIR/lib/"
echo "Headers: $INSTALL_DIR/include/"
echo ""
echo "Next: run generate_bindings.ps1"
