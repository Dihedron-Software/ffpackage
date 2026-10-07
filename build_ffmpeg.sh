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

# LGPL requires us to name the source that corresponds to the shipped DLLs, but pacman has no
# version pinning — so record what was actually linked and shout when MSYS2 moves under us.
LOCKFILE="$SCRIPT_DIR/windows-deps.lock"
LOCKED_PKGS=$(grep -oE '^mingw-w64-clang-x86_64-[^ ]+' "$LOCKFILE" 2>/dev/null | tr '\n' '|' | sed 's/|$//')

if [ "${1:-}" = "--relock" ]; then
    {
        sed -n '1,4p' "$LOCKFILE"
        echo "#"
        echo "# ffmpeg submodule commit: $(git -C "$FFMPEG_SRC" rev-parse HEAD) ($(git -C "$FFMPEG_SRC" log -1 --format=%cs))"
        echo ""
        pacman -Q | grep -E "^($LOCKED_PKGS) "
    } > "$LOCKFILE.new" && mv "$LOCKFILE.new" "$LOCKFILE"
    echo ">>> Relocked $LOCKFILE — commit it alongside the rebuilt DLLs."
    exit 0
fi

if [ ! -f "$LOCKFILE" ]; then
    echo ""
    echo "WARNING: windows-deps.lock is missing — dependency versions will NOT be verified."
    echo "         It is committed to this repo; a missing copy means a broken checkout."
    echo "         Restore it, or generate one with: ./build_ffmpeg.sh --relock"
    echo ""
else
    echo ">>> Verifying dependency versions against windows-deps.lock..."
    drift=0
    while read -r pkg locked_ver; do
        case "$pkg" in ''|'#'*) continue ;; esac
        actual_ver=$(pacman -Q "$pkg" 2>/dev/null | awk '{print $2}')
        if [ -z "$actual_ver" ]; then
            echo "    MISSING: $pkg (locked $locked_ver)"; drift=$((drift+1))
        elif [ "$actual_ver" != "$locked_ver" ]; then
            echo "    DRIFT:   $pkg  locked $locked_ver  ->  installed $actual_ver"; drift=$((drift+1))
        fi
    done < "$LOCKFILE"

    locked_commit=$(grep -oE 'ffmpeg submodule commit: [0-9a-f]+' "$LOCKFILE" | awk '{print $4}')
    actual_commit=$(git -C "$FFMPEG_SRC" rev-parse HEAD 2>/dev/null)
    if [ -n "$locked_commit" ] && [ "$locked_commit" != "$actual_commit" ]; then
        echo "    DRIFT:   ffmpeg  locked $locked_commit  ->  checked out $actual_commit"; drift=$((drift+1))
    fi

    if [ $drift -ne 0 ]; then
        echo ""
        echo "ERROR: $drift dependency mismatch(es). The published source no longer corresponds"
        echo "       to what this build would produce. Either restore the locked versions, or"
        echo "       accept the bump with: ./build_ffmpeg.sh --relock"
        exit 1
    fi
    echo "    all $(grep -c '^mingw-w64' "$LOCKFILE") packages match, ffmpeg at $actual_commit"
fi

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
    # === Excluded codecs ===
    # today (H.264 is our only encode codec).
    #   GPL (copyright, would force the whole linking program to GPL, NEVER TOUCH THESE):
    #     libx264 libx265 libxvid libxavs2 libdavs2 libvidstab librubberband frei0r
    #     (postproc is GPL too but has no --disable in FFmpeg 8.0 — only builds under --enable-gpl)
    #   Nonfree (binary would become legally unredistributable):
    #     libfdk-aac  openssl
    #   Apple ProRes program (software encoders only, prores_videotoolbox is fine):
    #     prores  prores_aw  prores_ks
    #   Dolby (live patents + trademark):
    #     eac3 = Dolby Digital Plus ;  truehd, mlp = Dolby TrueHD
    #   DTS:
    #     dca
    # Kept & encodable, licensed or license-free:
    #   aac (AAC lic)  libopenh264 + hw H.264 (AVC lic)  hw HEVC (HEVC lic)
    #   ac3/ac3_fixed (AC-3 patents expired 2017; license-free — just never brand
    #     output "Dolby Digital")  mp3 opus vorbis flac av1 vp8/9 theora webp (royalty-free)
    # =====================================================================
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
        --enable-vulkan \
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
        --disable-libx264 \
        --disable-libx265 \
        --disable-libxvid \
        --disable-libxavs2 \
        --disable-libdavs2 \
        --disable-libvidstab \
        --disable-librubberband \
        --disable-frei0r \
        --disable-libfdk-aac \
        --disable-openssl \
        --disable-network \
        --disable-encoder=prores,prores_aw,prores_ks,eac3,truehd,mlp,dca \
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
