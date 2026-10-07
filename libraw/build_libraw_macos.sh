#!/bin/bash
# Build LibRaw as an arm64 static library for macOS (min-OS macOS 13.0, the same as the FFmpeg dylibs).
# zlib (deflate DNG) and libjpeg-turbo (lossy DNG) are built too and merged into the same libraw.a.
# Requires the Xcode Command Line Tools and CMake.
#
# Usage: ./build_libraw_macos.sh [release|debug|clean]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VERSION=0.22.2
ZLIB_VERSION=1.3.2
JPEG_VERSION=3.2.0
BUILD_DIR="$SCRIPT_DIR/build-macos"
SOURCE_DIR="$BUILD_DIR/LibRaw-$VERSION"
ZLIB_DIR="$BUILD_DIR/zlib-$ZLIB_VERSION"
JPEG_DIR="$BUILD_DIR/libjpeg-turbo-$JPEG_VERSION"
JPEG_BUILD="$BUILD_DIR/libjpeg-turbo-build"
OUTPUT_DIR="$SCRIPT_DIR/output"
MIN_OS="13.0"
ARCH=arm64
MODE="${1:-release}"

case "$MODE" in
    release) OPTIMIZATION_FLAGS="-O2" ;;
    debug)   OPTIMIZATION_FLAGS="-O0 -g" ;;
    clean)
        rm -rf "$BUILD_DIR" "$OUTPUT_DIR/libraw.a"
        echo "Cleaned."
        exit 0
        ;;
    *) echo "Unknown mode '$MODE' (release, debug, clean)" >&2; exit 1 ;;
esac

echo ">>> Verifying and extracting the source archives..."
mkdir -p "$BUILD_DIR"
for ARCHIVE in "LibRaw-$VERSION.tar.gz" "zlib-$ZLIB_VERSION.tar.gz" "libjpeg-turbo-$JPEG_VERSION.tar.gz"; do
    (cd "$SCRIPT_DIR/source" && grep "  $ARCHIVE\$" SHA256SUMS.txt | shasum -a 256 -c -)
    if [ ! -d "$BUILD_DIR/${ARCHIVE%.tar.gz}" ]; then
        tar -xzf "$SCRIPT_DIR/source/$ARCHIVE" -C "$BUILD_DIR"
    fi
done

OBJECT_DIR="$BUILD_DIR/object-$MODE"
ZLIB_OBJECT_DIR="$BUILD_DIR/zlib-object-$MODE"
rm -rf "$OBJECT_DIR" "$ZLIB_OBJECT_DIR"
mkdir -p "$OBJECT_DIR" "$ZLIB_OBJECT_DIR" "$OUTPUT_DIR"

JOBS=$(sysctl -n hw.logicalcpu 2>/dev/null || echo 4)

echo ">>> Compiling zlib $ZLIB_VERSION..."
for FILE in "$ZLIB_DIR"/*.c; do
    clang -c -arch "$ARCH" -mmacosx-version-min="$MIN_OS" $OPTIMIZATION_FLAGS -w "$FILE" -o "$ZLIB_OBJECT_DIR/$(basename "$FILE" .c).o"
done

# Only the static libjpeg library, without SIMD, the same as the Windows build. Lossy DNG is rare.
echo ">>> Building libjpeg-turbo $JPEG_VERSION..."
cmake -S "$JPEG_DIR" -B "$JPEG_BUILD" -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_OSX_ARCHITECTURES="$ARCH" -DCMAKE_OSX_DEPLOYMENT_TARGET="$MIN_OS" \
    -DENABLE_SHARED=OFF -DENABLE_STATIC=ON -DWITH_SIMD=OFF -DWITH_TURBOJPEG=OFF -DWITH_TOOLS=OFF -DWITH_TESTS=OFF > /dev/null
cmake --build "$JPEG_BUILD" --target jpeg-static -j "$JOBS" > /dev/null

# The same source list as LibRaw's Makefile.msvc: every src/**/*.cpp except the *_ph.cpp placeholders.
# USE_ZLIB and USE_JPEG enable deflate and lossy DNG.
export SOURCE_DIR OBJECT_DIR OPTIMIZATION_FLAGS MIN_OS ARCH ZLIB_DIR JPEG_DIR JPEG_BUILD
echo ">>> Compiling LibRaw ($MODE, $JOBS jobs)..."
# The file goes to sh as $1, because BSD xargs limits a command that -I builds to 255 bytes.
find "$SOURCE_DIR/src" -name '*.cpp' ! -name '*_ph.cpp' -print0 |
    xargs -0 -P "$JOBS" -n 1 sh -c '
        name=$(basename "$1" .cpp)
        clang++ -c -arch "$ARCH" -mmacosx-version-min="$MIN_OS" $OPTIMIZATION_FLAGS -w \
            -DLIBRAW_NODLL -DLIBRAW_BUILDLIB -DUSE_ZLIB -DUSE_JPEG \
            -I"$SOURCE_DIR" -I"$ZLIB_DIR" -I"$JPEG_DIR/src" -I"$JPEG_BUILD" "$1" -o "$OBJECT_DIR/$name.o"' sh

rm -f "$OUTPUT_DIR/libraw.a"
libtool -static -o "$OUTPUT_DIR/libraw.a" "$OBJECT_DIR"/*.o "$ZLIB_OBJECT_DIR"/*.o "$JPEG_BUILD/libjpeg.a"

cp "$SOURCE_DIR/LICENSE.CDDL" "$SOURCE_DIR/COPYRIGHT" "$OUTPUT_DIR/"
cp "$ZLIB_DIR/LICENSE" "$OUTPUT_DIR/LICENSE.zlib"
cp "$JPEG_DIR/LICENSE.md" "$OUTPUT_DIR/LICENSE.libjpeg-turbo.md"
cp "$JPEG_DIR/README.ijg" "$OUTPUT_DIR/README.ijg"

echo ">>> Done! $OUTPUT_DIR/libraw.a ($(ls "$OBJECT_DIR"/*.o | wc -l | tr -d ' ') LibRaw objects, zlib and libjpeg merged)"
