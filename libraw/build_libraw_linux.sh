#!/bin/bash
# Build LibRaw as an x86_64 static library for Linux, position independent so it can go into an executable
# or a shared object. zlib (deflate DNG) and libjpeg-turbo (lossy DNG) are built too and merged into the
# same libraw.a. Requires clang and CMake.
#
# Usage: ./build_libraw_linux.sh [release|debug|clean]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VERSION=0.22.2
ZLIB_VERSION=1.3.2
JPEG_VERSION=3.2.0
BUILD_DIR="$SCRIPT_DIR/build-linux"
SOURCE_DIR="$BUILD_DIR/LibRaw-$VERSION"
ZLIB_DIR="$BUILD_DIR/zlib-$ZLIB_VERSION"
JPEG_DIR="$BUILD_DIR/libjpeg-turbo-$JPEG_VERSION"
JPEG_BUILD="$BUILD_DIR/libjpeg-turbo-build"
OUTPUT_DIR="$SCRIPT_DIR/output"
LIBRARY="$OUTPUT_DIR/linux/libraw.a"
MODE="${1:-release}"

case "$MODE" in
    release) OPTIMIZATION_FLAGS="-O2" ;;
    debug)   OPTIMIZATION_FLAGS="-O0 -g" ;;
    clean)
        rm -rf "$BUILD_DIR" "$LIBRARY"
        echo "Cleaned."
        exit 0
        ;;
    *) echo "Unknown mode '$MODE' (release, debug, clean)" >&2; exit 1 ;;
esac

for tool in clang clang++ cmake ar ranlib; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "ERROR: $tool was not found (Debian/Ubuntu: sudo apt install clang cmake binutils)" >&2
        exit 1
    fi
done

echo ">>> Verifying and extracting the source archives..."
mkdir -p "$BUILD_DIR"
for ARCHIVE in "LibRaw-$VERSION.tar.gz" "zlib-$ZLIB_VERSION.tar.gz" "libjpeg-turbo-$JPEG_VERSION.tar.gz"; do
    (cd "$SCRIPT_DIR/source" && grep "  $ARCHIVE\$" SHA256SUMS.txt | sha256sum -c -)
    if [ ! -d "$BUILD_DIR/${ARCHIVE%.tar.gz}" ]; then
        tar -xzf "$SCRIPT_DIR/source/$ARCHIVE" -C "$BUILD_DIR"
    fi
done

OBJECT_DIR="$BUILD_DIR/object-$MODE"
ZLIB_OBJECT_DIR="$BUILD_DIR/zlib-object-$MODE"
JPEG_OBJECT_DIR="$BUILD_DIR/jpeg-object-$MODE"
rm -rf "$OBJECT_DIR" "$ZLIB_OBJECT_DIR" "$JPEG_OBJECT_DIR"
mkdir -p "$OBJECT_DIR" "$ZLIB_OBJECT_DIR" "$JPEG_OBJECT_DIR" "$OUTPUT_DIR/linux"

JOBS=$(nproc 2>/dev/null || echo 4)

# Without zlib's ./configure, the two defines it sets on Linux go on the command line.
echo ">>> Compiling zlib $ZLIB_VERSION..."
for FILE in "$ZLIB_DIR"/*.c; do
    clang -c -fPIC $OPTIMIZATION_FLAGS -w -DHAVE_UNISTD_H -DHAVE_STDARG_H \
        "$FILE" -o "$ZLIB_OBJECT_DIR/$(basename "$FILE" .c).o"
done

# Only the static libjpeg library, without SIMD, the same as the Windows and macOS builds. Lossy DNG is rare.
echo ">>> Building libjpeg-turbo $JPEG_VERSION..."
cmake -S "$JPEG_DIR" -B "$JPEG_BUILD" -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=clang \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DENABLE_SHARED=OFF -DENABLE_STATIC=ON -DWITH_SIMD=OFF -DWITH_TURBOJPEG=OFF -DWITH_TOOLS=OFF -DWITH_TESTS=OFF > /dev/null
cmake --build "$JPEG_BUILD" --target jpeg-static -j "$JOBS" > /dev/null

# The same source list as LibRaw's Makefile.msvc: every src/**/*.cpp except the *_ph.cpp placeholders.
# USE_ZLIB and USE_JPEG enable deflate and lossy DNG.
export SOURCE_DIR OBJECT_DIR OPTIMIZATION_FLAGS ZLIB_DIR JPEG_DIR JPEG_BUILD
echo ">>> Compiling LibRaw ($MODE, $JOBS jobs)..."
find "$SOURCE_DIR/src" -name '*.cpp' ! -name '*_ph.cpp' -print0 |
    xargs -0 -P "$JOBS" -n 1 sh -c '
        name=$(basename "$1" .cpp)
        clang++ -c -fPIC $OPTIMIZATION_FLAGS -w \
            -DLIBRAW_NODLL -DLIBRAW_BUILDLIB -DUSE_ZLIB -DUSE_JPEG \
            -I"$SOURCE_DIR" -I"$ZLIB_DIR" -I"$JPEG_DIR/src" -I"$JPEG_BUILD" "$1" -o "$OBJECT_DIR/$name.o"' sh

# ar has no libtool -static, so libjpeg's objects are taken out of its archive and appended with the rest.
# Appending (q) keeps every member even if two share a name, where replacing (r) would drop one.
(cd "$JPEG_OBJECT_DIR" && ar x "$JPEG_BUILD/libjpeg.a")
rm -f "$LIBRARY"
ar qc "$LIBRARY" "$OBJECT_DIR"/*.o "$ZLIB_OBJECT_DIR"/*.o "$JPEG_OBJECT_DIR"/*.o
ranlib "$LIBRARY"

cp "$SOURCE_DIR/LICENSE.CDDL" "$SOURCE_DIR/COPYRIGHT" "$OUTPUT_DIR/"
cp "$ZLIB_DIR/LICENSE" "$OUTPUT_DIR/LICENSE.zlib"
cp "$JPEG_DIR/LICENSE.md" "$OUTPUT_DIR/LICENSE.libjpeg-turbo.md"
cp "$JPEG_DIR/README.ijg" "$OUTPUT_DIR/README.ijg"

echo ">>> Done! $LIBRARY ($(ls "$OBJECT_DIR"/*.o | wc -l | tr -d ' ') LibRaw objects, zlib and libjpeg merged)"
