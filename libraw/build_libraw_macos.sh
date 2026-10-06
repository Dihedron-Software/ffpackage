#!/bin/bash
# Build LibRaw as an arm64 static library for macOS (min-OS macOS 13.0, the same as the FFmpeg dylibs).
# Requires the Xcode Command Line Tools.
#
# Usage: ./build_libraw_macos.sh [release|debug|clean]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VERSION=0.22.2
ARCHIVE="$SCRIPT_DIR/source/LibRaw-$VERSION.tar.gz"
BUILD_DIR="$SCRIPT_DIR/build-macos"
SOURCE_DIR="$BUILD_DIR/LibRaw-$VERSION"
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

echo ">>> Verifying source archive..."
(cd "$SCRIPT_DIR/source" && grep "LibRaw-$VERSION.tar.gz" SHA256SUMS.txt | shasum -a 256 -c -)

if [ ! -d "$SOURCE_DIR" ]; then
    mkdir -p "$BUILD_DIR"
    echo ">>> Extracting LibRaw $VERSION..."
    tar -xzf "$ARCHIVE" -C "$BUILD_DIR"
fi

# The same source list as LibRaw's Makefile.msvc: every src/**/*.cpp except the *_ph.cpp placeholders.
OBJECT_DIR="$BUILD_DIR/object-$MODE"
rm -rf "$OBJECT_DIR"
mkdir -p "$OBJECT_DIR" "$OUTPUT_DIR"

JOBS=$(sysctl -n hw.logicalcpu 2>/dev/null || echo 4)
export SOURCE_DIR OBJECT_DIR OPTIMIZATION_FLAGS MIN_OS ARCH

echo ">>> Compiling ($MODE, $JOBS jobs)..."
# The file goes to sh as $1, because BSD xargs limits a command that -I builds to 255 bytes.
find "$SOURCE_DIR/src" -name '*.cpp' ! -name '*_ph.cpp' -print0 |
    xargs -0 -P "$JOBS" -n 1 sh -c '
        name=$(basename "$1" .cpp)
        clang++ -c -arch "$ARCH" -mmacosx-version-min="$MIN_OS" $OPTIMIZATION_FLAGS -w \
            -DLIBRAW_NODLL -DLIBRAW_BUILDLIB -I"$SOURCE_DIR" "$1" -o "$OBJECT_DIR/$name.o"' sh

rm -f "$OUTPUT_DIR/libraw.a"
ar rcs "$OUTPUT_DIR/libraw.a" "$OBJECT_DIR"/*.o

cp "$SOURCE_DIR/LICENSE.CDDL" "$SOURCE_DIR/COPYRIGHT" "$OUTPUT_DIR/"

echo ">>> Done! $OUTPUT_DIR/libraw.a ($(ls "$OBJECT_DIR"/*.o | wc -l | tr -d ' ') objects)"
