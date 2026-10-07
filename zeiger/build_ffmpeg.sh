#!/bin/bash
# Build FFmpeg 8.0 for Zeiger, the image viewer: LGPL 2.1+ shared libraries with only the image
# codecs, demuxers and parsers Zeiger uses, plus dav1d for AVIF and the HEVC decoder for HEIC.
# It uses the same FFmpeg commit as Blick (the ffmpeg submodule), but it never touches Blick's build.
#
# Windows: run it in the MSYS2 CLANG64 shell. macOS: run it in a terminal (arm64, min-OS 13.0).
#
# Usage: ./zeiger/build_ffmpeg.sh [clean]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
FFMPEG_SRC="$ROOT_DIR/ffmpeg"

case "$(uname -s)" in
    Darwin)       PLATFORM=macos ;;
    MINGW*|MSYS*) PLATFORM=windows ;;
    *) echo "Unsupported platform: $(uname -s)" >&2; exit 1 ;;
esac

BUILD_DIR="$SCRIPT_DIR/build-$PLATFORM"
SOURCE_DIR="$BUILD_DIR/ffmpeg"
INSTALL_DIR="$BUILD_DIR/install"
OUTPUT_DIR="$SCRIPT_DIR/output-$PLATFORM"

if [ "${1:-}" = "clean" ]; then
    rm -rf "$BUILD_DIR" "$OUTPUT_DIR"
    echo "Cleaned."
    exit 0
fi

# The formats Zeiger opens and saves decide these lists. Anything else stays out,
# in particular every audio codec, H.264, and all hardware video APIs.
DECODERS=(apng bmp dds exr gif hdr hevc jpeg2000 jpegls libdav1d mjpeg pam pbm pcx pfm pgm phm png ppm
          psd qoi sgi sunrast targa tiff wbmp webp xbm xpm xwd)
ENCODERS=(bmp mjpeg png tiff)
DEMUXERS=(apng gif image2 mov
          image_bmp_pipe image_dds_pipe image_exr_pipe image_gif_pipe image_hdr_pipe image_j2k_pipe
          image_jpeg_pipe image_jpegls_pipe image_pam_pipe image_pbm_pipe image_pcx_pipe image_pfm_pipe
          image_pgm_pipe image_phm_pipe image_png_pipe image_ppm_pipe image_psd_pipe image_qoi_pipe
          image_sgi_pipe image_sunrast_pipe image_tiff_pipe image_webp_pipe image_xbm_pipe image_xpm_pipe
          image_xwd_pipe)
PARSERS=(av1 bmp gif hdr hevc jpeg2000 mjpeg png pnm qoi webp xbm xwd)

join_commas() { local IFS=,; echo "$*"; }

if [ ! -f "$FFMPEG_SRC/configure" ]; then
    git -C "$ROOT_DIR" submodule update --init ffmpeg
fi
COMMIT=$(git -C "$FFMPEG_SRC" rev-parse HEAD)

echo "=== FFmpeg LGPL 2.1+ shared build for Zeiger ($PLATFORM) ==="
echo "FFmpeg: $COMMIT"
echo "Output: $OUTPUT_DIR"
echo ""

mkdir -p "$BUILD_DIR"

# ---- platform dependencies ---------------------------------------------------
if [ "$PLATFORM" = "windows" ]; then
    PACKAGES=(clang llvm lld nasm pkgconf dav1d zlib)
    pacman -S --needed --noconfirm "${PACKAGES[@]/#/mingw-w64-clang-x86_64-}" make diffutils git

    # The same lock as Blick's build: the shipped DLLs must match the published package versions.
    echo ">>> Verifying dependency versions against windows-deps.lock..."
    LOCKFILE="$ROOT_DIR/windows-deps.lock"
    drift=0
    for name in "${PACKAGES[@]}"; do
        package="mingw-w64-clang-x86_64-$name"
        locked=$(awk -v p="$package" '$1 == p { print $2 }' "$LOCKFILE")
        if [ -z "$locked" ]; then
            continue
        fi
        installed=$(pacman -Q "$package" | awk '{ print $2 }')
        if [ "$installed" != "$locked" ]; then
            echo "    DRIFT: $package locked $locked, installed $installed"
            drift=$((drift + 1))
        fi
    done
    locked_commit=$(grep -oE 'ffmpeg submodule commit: [0-9a-f]+' "$LOCKFILE" | awk '{ print $4 }')
    if [ "$locked_commit" != "$COMMIT" ]; then
        echo "    DRIFT: ffmpeg locked $locked_commit, checked out $COMMIT"
        drift=$((drift + 1))
    fi
    if [ "$drift" -ne 0 ]; then
        echo "ERROR: $drift mismatch(es) with windows-deps.lock. Fix them the same way as for Blick's build." >&2
        exit 1
    fi

    export PKG_CONFIG="/clang64/bin/pkg-config"
    export PKG_CONFIG_PATH="/clang64/lib/pkgconfig:/clang64/share/pkgconfig"
    PLATFORM_FLAGS=(
        --cc=clang
        --pkg-config="$PKG_CONFIG"
        --enable-w32threads
        --extra-ldflags="-static"
    )
else
    DAV1D_VERSION=1.5.1 # the same as Blick's macOS build
    MIN_OS="13.0"
    DEPS_DIR="$BUILD_DIR/deps"

    for tool in meson ninja nasm pkg-config; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            brew install "$tool"
        fi
    done

    if [ ! -f "$DEPS_DIR/lib/libdav1d.a" ]; then
        # The tarball cache and macos-deps.sha256 are shared with Blick's build.
        ARCHIVE="dav1d-$DAV1D_VERSION.tar.gz"
        CACHE="$ROOT_DIR/src-cache-macos"
        mkdir -p "$CACHE"
        if [ ! -f "$CACHE/$ARCHIVE" ]; then
            curl -fL --retry 3 -o "$CACHE/$ARCHIVE.tmp" "https://code.videolan.org/videolan/dav1d/-/archive/$DAV1D_VERSION/$ARCHIVE"
            mv "$CACHE/$ARCHIVE.tmp" "$CACHE/$ARCHIVE"
        fi
        (cd "$CACHE" && grep "  $ARCHIVE\$" "$ROOT_DIR/macos-deps.sha256" | shasum -a 256 -c -)

        echo ">>> Building dav1d $DAV1D_VERSION..."
        rm -rf "$BUILD_DIR/dav1d-$DAV1D_VERSION"
        tar -xzf "$CACHE/$ARCHIVE" -C "$BUILD_DIR"
        (cd "$BUILD_DIR/dav1d-$DAV1D_VERSION"
         CC="clang -arch arm64 -mmacosx-version-min=$MIN_OS" meson setup _build --prefix="$DEPS_DIR" --libdir=lib \
             --buildtype=release --default-library=static -Db_staticpic=true -Denable_tools=false -Denable_tests=false
         ninja -C _build install)
    fi

    # Only our own prefix, so pkg-config can't link a Homebrew dylib into the libraries.
    export PKG_CONFIG_LIBDIR="$DEPS_DIR/lib/pkgconfig"
    PLATFORM_FLAGS=(
        --cc="clang -arch arm64"
        --arch=arm64
        --install-name-dir=@rpath
        --enable-pthreads
        --extra-cflags="-arch arm64 -mmacosx-version-min=$MIN_OS -I$DEPS_DIR/include"
        --extra-ldflags="-arch arm64 -mmacosx-version-min=$MIN_OS -L$DEPS_DIR/lib"
    )
fi

# ---- source ------------------------------------------------------------------
# Blick's Windows build configures inside ffmpeg/, and FFmpeg refuses an out-of-tree build next to
# that config.h. So Zeiger builds an exported copy of the same commit.
if [ "$(cat "$SOURCE_DIR/.commit" 2>/dev/null || true)" != "$COMMIT" ]; then
    echo ">>> Exporting the ffmpeg submodule at $COMMIT..."
    rm -rf "$SOURCE_DIR"
    mkdir -p "$SOURCE_DIR"
    git -C "$FFMPEG_SRC" -c core.autocrlf=false archive HEAD | tar -x -C "$SOURCE_DIR"
    echo "$COMMIT" > "$SOURCE_DIR/.commit"
fi

# ---- configure ---------------------------------------------------------------
# --disable-autodetect keeps out every library FFmpeg would pick up by itself (iconv, lzma, bzlib,
# Media Foundation, VideoToolbox, ...). Threads are on that list too, so they are enabled again above.
CONFIGURE_ARGS=(
    --prefix="$INSTALL_DIR"
    --pkg-config-flags=--static
    --enable-shared
    --disable-static
    --disable-programs
    --disable-doc
    --disable-autodetect
    --disable-everything
    --disable-avdevice
    --disable-avfilter
    --disable-swresample
    --disable-network
    --enable-zlib
    --enable-libdav1d
    --enable-protocol=file
    --enable-decoder="$(join_commas "${DECODERS[@]}")"
    --enable-encoder="$(join_commas "${ENCODERS[@]}")"
    --enable-demuxer="$(join_commas "${DEMUXERS[@]}")"
    --enable-parser="$(join_commas "${PARSERS[@]}")"
    "${PLATFORM_FLAGS[@]}"
)

cd "$SOURCE_DIR"
if [ ! -f ffbuild/config.mak ] || [ "$(cat "$BUILD_DIR/configure.args" 2>/dev/null || true)" != "${CONFIGURE_ARGS[*]}" ]; then
    echo ">>> Configuring FFmpeg..."
    ./configure "${CONFIGURE_ARGS[@]}"
    echo "${CONFIGURE_ARGS[*]}" > "$BUILD_DIR/configure.args"
else
    echo ">>> Configure arguments unchanged, skipping configure."
fi

JOBS=$( (nproc || sysctl -n hw.logicalcpu) 2>/dev/null || echo 4)
echo ">>> Building FFmpeg ($JOBS jobs)..."
make -j"$JOBS"
make install

# ---- output ------------------------------------------------------------------
echo ">>> Collecting outputs..."
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"
cp config.h config_components.h "$OUTPUT_DIR/"

if [ "$PLATFORM" = "windows" ]; then
    cp "$INSTALL_DIR/bin/"*.dll "$OUTPUT_DIR/"

    # Every dependency must be linked statically: only Windows system DLLs and FFmpeg's own may remain.
    for library in "$OUTPUT_DIR/"*.dll; do
        foreign=$(llvm-objdump -p "$library" | awk '/DLL Name:/ { print $3 }' | grep -viE '^(kernel32|user32|advapi32|bcrypt|ole32|shell32|api-ms-win-.*|av[a-z]+-[0-9]+|sw[a-z]+-[0-9]+)\.dll$' || true)
        if [ -n "$foreign" ]; then
            echo "ERROR: $(basename "$library") needs DLLs that Zeiger doesn't ship: $foreign" >&2
            exit 1
        fi
    done
else
    # Name each dylib after its install name, which is the name dyld searches for.
    for library in "$INSTALL_DIR/lib/"*.dylib; do
        if [ -L "$library" ]; then
            continue
        fi
        cp -p "$library" "$OUTPUT_DIR/$(basename "$(otool -D "$library" | tail -n 1)")"
    done

    for library in "$OUTPUT_DIR/"*.dylib; do
        foreign=$(otool -L "$library" | tail -n +2 | awk '{ print $1 }' | grep -vE '^(/usr/lib/|/System/Library/|@rpath/)' || true)
        if [ -n "$foreign" ]; then
            echo "ERROR: $(basename "$library") needs libraries that Zeiger doesn't ship: $foreign" >&2
            exit 1
        fi
    done

    # Apple Silicon loads only signed code.
    codesign --force --sign - "$OUTPUT_DIR/"*.dylib
fi

echo ""
echo "=== Done ==="
ls -l "$OUTPUT_DIR"
