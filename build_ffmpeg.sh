#!/bin/bash
# Build FFmpeg 8.0 as LGPL 2.1+ shared DLLs using MSYS2/CLANG64.

# You can clean debug or release-info by writing :
# ./build_ffmpeg.sh clean debug
# ./build_ffmpeg.sh clean release-info

# To build release, no arguments are required otherwise
# ./build_ffmpeg.sh debug
# ./build_ffmpeg.sh release-info
# Debug will allways build with debug info

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
    mingw-w64-clang-x86_64-clang \
    mingw-w64-clang-x86_64-llvm \
    mingw-w64-clang-x86_64-lld \
    mingw-w64-x86_64-nasm \
    mingw-w64-x86_64-tools-git \
    make \
    pkg-config \
    diffutils

for tool in clang nasm make pkg-config ; do
    if ! command -v $tool &>/dev/null; then
        echo "ERROR: $tool not found. Check your MSYS2 environment."
        exit 1
    fi
done

cd "$FFMPEG_SRC"

OPTIMIZATION_FLAGS="-O3"
LIBRARY_FLAGS=""

if [ "$1" = "clean" ]; then
    echo ">>> Cleaning previous build..."
    make distclean 2>/dev/null || true
    rm -rf "$INSTALL_DIR" "$OUTPUT_DIR"
fi

if [ "$1" = "release_info" ]; then
    OPTIMIZATION_FLAGS="-O3 -g -gcodeview"
    LIBRARY_FLAGS="-fuse-ld=lld -Wl,--pdb="
fi

if [ "$1" = "debug" ]; then
    OPTIMIZATION_FLAGS="-O0 -g -gcodeview"
    LIBRARY_FLAGS="-fuse-ld=lld -Wl,--pdb="
fi

if [ "$1" = "clean" ]; then
    echo ">>> Cleaning previous build..."
    make distclean 2>/dev/null || true
    rm -rf "$INSTALL_DIR" "$OUTPUT_DIR"
    exit 0
fi

if [ ! -f "config.mak" ]; then
    echo ">>> Configuring FFmpeg (this takes a long time on MSYS2)..."
    ./configure \
        --prefix="$INSTALL_DIR" \
        --cc=clang \
        --enable-shared \
        --disable-static \
        --disable-programs \
        --disable-doc \
        --enable-runtime-cpudetect \
        --extra-cflags="$OPTIMIZATION_FLAGS" \
        --extra-ldflags="$LIBRARY_FLAGS" \
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
cp "$INSTALL_DIR/bin/"*.lib "$OUTPUT_DIR/lib/" 2>/dev/null || true
cp "$FFMPEG_SRC/libavutil/avutil-"*.pdb "$OUTPUT_DIR/dll/" 2>/dev/null || true
cp "$FFMPEG_SRC/libavcodec/avcodec-"*.pdb "$OUTPUT_DIR/dll/" 2>/dev/null || true
cp "$FFMPEG_SRC/libavdevice/avdevice-"*.pdb "$OUTPUT_DIR/dll/" 2>/dev/null || true
cp "$FFMPEG_SRC/libavfilter/avfilter-"*.pdb "$OUTPUT_DIR/dll/" 2>/dev/null || true
cp "$FFMPEG_SRC/libavformat/avformat-"*.pdb "$OUTPUT_DIR/dll/" 2>/dev/null || true
cp "$FFMPEG_SRC/libswscale/swscale-"*.pdb "$OUTPUT_DIR/dll/" 2>/dev/null || true
cp "$FFMPEG_SRC/libswresample/swresample-"*.pdb "$OUTPUT_DIR/dll/" 2>/dev/null || true

echo ""
echo "=== Build complete ==="
echo "DLLs:    $(ls -1 "$OUTPUT_DIR/dll/"*.dll 2>/dev/null | wc -l) files in $OUTPUT_DIR/dll/"
echo "Libs:    $(ls -1 "$OUTPUT_DIR/lib/"*.lib 2>/dev/null | wc -l) files in $OUTPUT_DIR/lib/"
echo "PDBs:    $(ls -1 "$OUTPUT_DIR/dll/"*.pdb 2>/dev/null | wc -l) files in $OUTPUT_DIR/dll/"

echo "Headers: $INSTALL_DIR/include/"
echo ""
echo "Next: run generate_bindings.ps1"
