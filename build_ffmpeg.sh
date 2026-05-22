#!/bin/bash
# Build FFmpeg 8.0 as LGPL 2.1+ shared DLLs using MSYS2/CLANG64.
#
# Usage:
#   ./build_ffmpeg.sh                 # release
#   ./build_ffmpeg.sh debug           # -O0 + debug info
#   ./build_ffmpeg.sh release_info    # -O3 + debug info
#   ./build_ffmpeg.sh clean           # wipe build + install + output

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
    mingw-w64-clang-x86_64-nasm \
    mingw-w64-clang-x86_64-tools-git \
    mingw-w64-clang-x86_64-pkgconf \
    make \
    diffutils \
    git

pacman -S --needed --noconfirm \
    mingw-w64-clang-x86_64-amf-headers \
    mingw-w64-clang-x86_64-libvpl \
    mingw-w64-clang-x86_64-vulkan-headers \
    mingw-w64-clang-x86_64-vulkan-loader

# nv-codec-headers isn't packaged for clang64 so install from upstream
NVCODEC_DIR="$SCRIPT_DIR/nv-codec-headers"
if [ ! -f "/clang64/lib/pkgconfig/ffnvcodec.pc" ]; then
    echo ">>> Installing nv-codec-headers from upstream..."
    if [ ! -d "$NVCODEC_DIR" ]; then
        git clone --depth 1 https://github.com/FFmpeg/nv-codec-headers.git "$NVCODEC_DIR"
    fi
    make -C "$NVCODEC_DIR" install PREFIX=/clang64
fi

pacman -S --needed --noconfirm \
    mingw-w64-clang-x86_64-openh264 \
    mingw-w64-clang-x86_64-dav1d \
    mingw-w64-clang-x86_64-svt-av1 \
    mingw-w64-clang-x86_64-aom \
    mingw-w64-clang-x86_64-libvpx \
    mingw-w64-clang-x86_64-opus \
    mingw-w64-clang-x86_64-libvorbis \
    mingw-w64-clang-x86_64-lame \
    mingw-w64-clang-x86_64-libtheora \
    mingw-w64-clang-x86_64-libwebp

pacman -S --needed --noconfirm \
    mingw-w64-clang-x86_64-libass \
    mingw-w64-clang-x86_64-libsoxr \
    mingw-w64-clang-x86_64-zimg

for tool in clang nasm make pkg-config ; do
    if ! command -v $tool &>/dev/null; then
        echo "ERROR: $tool not found. Check your MSYS2 environment."
        exit 1
    fi
done

cd "$FFMPEG_SRC"

OPTIMIZATION_FLAGS="-O3"
LIBRARY_FLAGS=""

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
    # MSYS base pkg-config only searches /usr/lib/pkgconfig, we need to force the clang64 one
    export PKG_CONFIG="/clang64/bin/pkg-config"
    export PKG_CONFIG_PATH="/clang64/lib/pkgconfig:/clang64/share/pkgconfig:${PKG_CONFIG_PATH:-}"
    ./configure \
        --pkg-config="$PKG_CONFIG" \
        --pkg-config-flags=--static \
        --prefix="$INSTALL_DIR" \
        --cc=clang \
        --enable-shared \
        --disable-static \
        --disable-programs \
        --disable-doc \
        --enable-runtime-cpudetect \
        \
        --enable-amf \
        --enable-nvenc \
        --enable-nvdec \
        --enable-cuvid \
        --enable-ffnvcodec \
        --enable-libvpl \
        --enable-d3d11va \
        --enable-dxva2 \
        --enable-mediafoundation \
        \
        --enable-libopenh264 \
        --enable-libdav1d \
        --enable-libsvtav1 \
        --enable-libaom \
        --enable-libvpx \
        --enable-libopus \
        --enable-libvorbis \
        --enable-libmp3lame \
        --enable-libtheora \
        --enable-libwebp \
        \
        --enable-libass \
        --enable-libsoxr \
        --enable-libzimg \
        \
        --extra-cflags="$OPTIMIZATION_FLAGS" \
        --extra-ldflags="$LIBRARY_FLAGS -static -static-libgcc -static-libstdc++" \
        --extra-libs="-lz -liconv -lc++ -lc++abi -lunwind"
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
