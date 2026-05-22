#!/bin/bash
# Build FFmpeg 8.0 as universal (arm64 + x86_64) LGPL shared dylibs for macOS.
# Codecs (same set as build_ffmpeg.sh) are built from source and static-linked,
# so output-macos/dylib/ depends only on macOS system frameworks. @rpath/ install
# names; min-OS macOS 13.0. Build tools auto-install via Homebrew; sources cached
# in src-cache-macos/.
#
# Usage: ./build_ffmpeg_macos.sh [clean|debug|release_info]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FFMPEG_SRC="$SCRIPT_DIR/ffmpeg"
OUTPUT_DIR="$SCRIPT_DIR/output-macos"
SRC_CACHE="$SCRIPT_DIR/src-cache-macos"
MIN_OS="13.0"
HOST_ARCH="$(uname -m)"
ARCHS=(arm64 x86_64)

# ---- codec/dependency version pins -----------------------------------------
OGG_VER=1.3.5
VORBIS_VER=1.3.7
THEORA_VER=1.1.1
LAME_VER=3.100
OPUS_VER=1.5.2
DAV1D_VER=1.5.1
SVTAV1_VER=2.3.0
AOM_VER=3.11.0
VPX_VER=1.15.0
OPENH264_VER=2.5.0
WEBP_VER=1.5.0
SOXR_VER=0.1.3
ZIMG_VER=3.0.5
FRIBIDI_VER=1.0.16
FREETYPE_VER=2.13.3
HARFBUZZ_VER=10.1.0
UNIBREAK_VER=6.1
LIBASS_VER=0.17.3

echo "=== FFmpeg LGPL 2.1+ macOS universal Shared Build (codecs from source) ==="
echo "Source:  $FFMPEG_SRC"
echo "Output:  $OUTPUT_DIR"
echo "Min OS:  macOS $MIN_OS"
echo ""

# ---- clean ------------------------------------------------------------------
if [ "${1:-}" = "clean" ]; then
    echo ">>> Cleaning previous build..."
    for arch in "${ARCHS[@]}"; do
        rm -rf "$SCRIPT_DIR/build-macos-$arch"
        rm -rf "$SCRIPT_DIR/ffmpeg-install-macos-$arch"
        rm -rf "$SCRIPT_DIR/deps-macos-$arch"
        rm -rf "$SCRIPT_DIR/depbuild-macos-$arch"
    done
    rm -rf "$SCRIPT_DIR/ffmpeg-install-macos"   # legacy single-arch dir
    rm -rf "$OUTPUT_DIR"
    # src-cache-macos (downloaded tarballs) kept; rm by hand for a full reset.
    if [ -f "$FFMPEG_SRC/config.mak" ] || [ -f "$FFMPEG_SRC/ffbuild/config.mak" ]; then
        (cd "$FFMPEG_SRC" && make distclean 2>/dev/null || true)
    fi
    exit 0
fi

# ---- optimization flags -----------------------------------------------------
OPTIMIZATION_FLAGS="-O3"
if [ "${1:-}" = "release_info" ]; then OPTIMIZATION_FLAGS="-O3 -g"; fi
if [ "${1:-}" = "debug" ]; then OPTIMIZATION_FLAGS="-O0 -g"; fi

# ---- tool check -------------------------------------------------------------
# Xcode Command Line Tools — can't be brew-installed; error if missing.
XCODE_MISSING=()
for tool in clang clang++ make lipo otool codesign curl tar git; do
    command -v "$tool" >/dev/null 2>&1 || XCODE_MISSING+=("$tool")
done
if [ "${#XCODE_MISSING[@]}" -gt 0 ]; then
    echo "ERROR: missing Xcode Command Line Tools: ${XCODE_MISSING[*]}" >&2
    echo "Install with: xcode-select --install" >&2
    exit 1
fi

# Homebrew build tools, auto-installed if missing. "command:formula".
BREW_TOOLS=(
    pkg-config:pkg-config
    nasm:nasm
    cmake:cmake
    meson:meson
    ninja:ninja
    autoreconf:autoconf
    aclocal:automake
    glibtoolize:libtool
)
NEED_FORMULAS=()
for entry in "${BREW_TOOLS[@]}"; do
    cmd="${entry%%:*}"; formula="${entry##*:}"
    command -v "$cmd" >/dev/null 2>&1 || NEED_FORMULAS+=("$formula")
done
if [ "${#NEED_FORMULAS[@]}" -gt 0 ]; then
    if ! command -v brew >/dev/null 2>&1; then
        echo "ERROR: missing build tools and Homebrew not found: ${NEED_FORMULAS[*]}" >&2
        echo "Install Homebrew (https://brew.sh) or install these tools manually." >&2
        exit 1
    fi
    echo ">>> Installing missing build tools via Homebrew: ${NEED_FORMULAS[*]}"
    brew install "${NEED_FORMULAS[@]}"
    hash -r
fi

# Auto-init the ffmpeg submodule so a fresh clone builds with no manual steps.
if [ ! -f "$FFMPEG_SRC/configure" ] && [ -f "$SCRIPT_DIR/.gitmodules" ]; then
    echo ">>> ffmpeg submodule not initialized; fetching..."
    git -C "$SCRIPT_DIR" submodule update --init --recursive ffmpeg
fi
if [ ! -f "$FFMPEG_SRC/configure" ]; then
    echo "ERROR: ffmpeg source not found at $FFMPEG_SRC" >&2
    echo "Run: git submodule update --init --recursive ffmpeg" >&2
    exit 1
fi

JOBS=$(sysctl -n hw.logicalcpu 2>/dev/null || echo 4)
if [ "$JOBS" -gt 8 ]; then JOBS=8; fi

mkdir -p "$SRC_CACHE"

# ---- generic helpers (read per-arch globals set in build_deps_for_arch) -----

# fetch <url> [outfile] -> caches into $SRC_CACHE, echoes the local path
fetch() {
    local url="$1"
    local out="${2:-$(basename "$url")}"
    local dst="$SRC_CACHE/$out"
    if [ ! -f "$dst" ]; then
        echo ">>> Downloading $out" >&2
        curl -fL --retry 3 -o "$dst.tmp" "$url" >&2
        mv "$dst.tmp" "$dst"
    fi
    echo "$dst"
}

# unpack <tarball> <subdir> -> fresh extract into $WORK, echoes dir
unpack() {
    local tarball="$1" subdir="$2"
    rm -rf "${WORK:?}/$subdir"
    tar -C "$WORK" -xf "$tarball"
    echo "$WORK/$subdir"
}

# write_meson_cross -> writes $MESON_CROSS for the target arch
write_meson_cross() {
    local cpu_family
    case "$ARCH" in
        arm64)  cpu_family=aarch64 ;;
        x86_64) cpu_family=x86_64 ;;
    esac
    cat > "$MESON_CROSS" <<EOF
[binaries]
c = ['clang', '-arch', '$ARCH']
cpp = ['clang++', '-arch', '$ARCH']
objc = ['clang', '-arch', '$ARCH']
ar = 'ar'
strip = 'strip'
pkg-config = 'pkg-config'
nasm = 'nasm'

[built-in options]
c_args = ['-arch', '$ARCH', '-mmacosx-version-min=$MIN_OS']
c_link_args = ['-arch', '$ARCH', '-mmacosx-version-min=$MIN_OS']
cpp_args = ['-arch', '$ARCH', '-mmacosx-version-min=$MIN_OS']
cpp_link_args = ['-arch', '$ARCH', '-mmacosx-version-min=$MIN_OS']

[host_machine]
system = 'darwin'
cpu_family = '$cpu_family'
cpu = '$ARCH'
endian = 'little'
EOF
}

# build_autotools <src-dir> [extra configure args...]
build_autotools() {
    local dir="$1"; shift
    ( cd "$dir"
      # Xiph libs inject the obsolete PPC flag -force_cpusubtype_ALL; modern ld rejects it.
      sed -i '' 's/-force_cpusubtype_ALL//g' configure 2>/dev/null || true
      ./configure --prefix="$PREFIX" --enable-static --disable-shared \
          ${CONFIGURE_HOST[@]+"${CONFIGURE_HOST[@]}"} \
          CC="$CC" CXX="$CXX" \
          CFLAGS="$ARCH_CFLAGS" CXXFLAGS="$ARCH_CFLAGS" LDFLAGS="$ARCH_LDFLAGS" \
          "$@"
      make -j"$JOBS"
      make install )
}

# build_cmake <src-dir> [extra -D args...]
build_cmake() {
    local dir="$1"; shift
    ( cd "$dir"
      rm -rf _b && mkdir _b && cd _b
      cmake -G Ninja "${CMAKE_CROSS[@]}" \
          -DCMAKE_INSTALL_PREFIX="$PREFIX" \
          -DCMAKE_BUILD_TYPE=Release \
          -DBUILD_SHARED_LIBS=OFF \
          -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
          -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
          "$@" ..
      ninja -j"$JOBS"
      ninja install )
}

# build_meson <src-dir> [extra -D args...]
build_meson() {
    local dir="$1"; shift
    local cross=()
    [ -n "$MESON_CROSS" ] && cross=(--cross-file "$MESON_CROSS")
    ( cd "$dir"
      rm -rf _b
      meson setup _b ${cross[@]+"${cross[@]}"} \
          --prefix="$PREFIX" \
          --buildtype=release \
          --default-library=static \
          -Db_staticpic=true \
          "$@"
      ninja -C _b -j"$JOBS"
      ninja -C _b install )
}

# ---- individual codec builds (each builds into the current $PREFIX) ---------
dep_ogg() {
    local t d; t=$(fetch "https://downloads.xiph.org/releases/ogg/libogg-$OGG_VER.tar.gz")
    d=$(unpack "$t" "libogg-$OGG_VER"); build_autotools "$d"
}
dep_vorbis() {
    local t d; t=$(fetch "https://downloads.xiph.org/releases/vorbis/libvorbis-$VORBIS_VER.tar.gz")
    d=$(unpack "$t" "libvorbis-$VORBIS_VER")
    build_autotools "$d" --with-ogg="$PREFIX" PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
}
dep_theora() {
    local t d; t=$(fetch "https://downloads.xiph.org/releases/theora/libtheora-$THEORA_VER.tar.gz")
    d=$(unpack "$t" "libtheora-$THEORA_VER")
    build_autotools "$d" --with-ogg="$PREFIX" --disable-examples --disable-oggtest \
        PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
}
dep_lame() {
    local t d; t=$(fetch "https://downloads.sourceforge.net/project/lame/lame/$LAME_VER/lame-$LAME_VER.tar.gz")
    d=$(unpack "$t" "lame-$LAME_VER")
    build_autotools "$d" --disable-frontend --disable-decoder
}
dep_opus() {
    local t d; t=$(fetch "https://downloads.xiph.org/releases/opus/opus-$OPUS_VER.tar.gz")
    d=$(unpack "$t" "opus-$OPUS_VER")
    build_cmake "$d" -DOPUS_BUILD_SHARED_LIBRARY=OFF -DOPUS_BUILD_TESTING=OFF
}
dep_dav1d() {
    local t d; t=$(fetch "https://code.videolan.org/videolan/dav1d/-/archive/$DAV1D_VER/dav1d-$DAV1D_VER.tar.gz")
    d=$(unpack "$t" "dav1d-$DAV1D_VER")
    build_meson "$d" -Denable_tools=false -Denable_tests=false
}
dep_svtav1() {
    local t d; t=$(fetch "https://gitlab.com/AOMediaCodec/SVT-AV1/-/archive/v$SVTAV1_VER/SVT-AV1-v$SVTAV1_VER.tar.gz")
    d=$(unpack "$t" "SVT-AV1-v$SVTAV1_VER")
    # Force CMAKE_SYSTEM_PROCESSOR so bundled cpuinfo compiles the target's x86 sources, not the host's.
    local svt_cross=()
    if [ "$ARCH" != "$HOST_ARCH" ]; then
        svt_cross=(-DCMAKE_SYSTEM_NAME=Darwin -DCMAKE_SYSTEM_PROCESSOR="$ARCH")
    fi
    build_cmake "$d" -DBUILD_APPS=OFF -DBUILD_DEC=OFF -DBUILD_TESTING=OFF \
        ${svt_cross[@]+"${svt_cross[@]}"}
}
dep_aom() {
    # aom ships only via git; cache a shallow clone.
    local repo="$SRC_CACHE/aom-$AOM_VER"
    if [ ! -d "$repo" ]; then
        git clone --depth 1 -b "v$AOM_VER" https://aomedia.googlesource.com/aom "$repo"
    fi
    local d="$WORK/aom-$AOM_VER"; rm -rf "$d"; cp -R "$repo" "$d"
    local aom_cross=()
    if [ "$ARCH" != "$HOST_ARCH" ]; then
        aom_cross=(-DCMAKE_TOOLCHAIN_FILE="$d/build/cmake/toolchains/x86_64-macos.cmake")
    fi
    build_cmake "$d" -DENABLE_EXAMPLES=OFF -DENABLE_TESTS=OFF -DENABLE_DOCS=OFF \
        -DENABLE_TOOLS=OFF -DCONFIG_AV1_ENCODER=1 -DCONFIG_AV1_DECODER=1 ${aom_cross[@]+"${aom_cross[@]}"}
}
dep_vpx() {
    local t d; t=$(fetch "https://github.com/webmproject/libvpx/archive/refs/tags/v$VPX_VER.tar.gz" "libvpx-$VPX_VER.tar.gz")
    d=$(unpack "$t" "libvpx-$VPX_VER")
    local vpx_target
    case "$ARCH" in
        arm64)  vpx_target="arm64-darwin22-gcc" ;;
        x86_64) vpx_target="x86_64-darwin22-gcc" ;;
    esac
    ( cd "$d"
      CC="$CC" CXX="$CXX" \
      ./configure --prefix="$PREFIX" --target="$vpx_target" \
          --enable-static --disable-shared \
          --disable-examples --disable-tools --disable-docs --disable-unit-tests \
          --enable-vp8 --enable-vp9 --enable-pic \
          --extra-cflags="$ARCH_CFLAGS"
      make -j"$JOBS"
      make install )
}
dep_openh264() {
    local t d; t=$(fetch "https://github.com/cisco/openh264/archive/refs/tags/v$OPENH264_VER.tar.gz" "openh264-$OPENH264_VER.tar.gz")
    d=$(unpack "$t" "openh264-$OPENH264_VER")
    build_meson "$d" -Dtests=disabled
}
dep_webp() {
    local t d; t=$(fetch "https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-$WEBP_VER.tar.gz")
    d=$(unpack "$t" "libwebp-$WEBP_VER")
    build_cmake "$d" -DWEBP_BUILD_ANIM_UTILS=OFF -DWEBP_BUILD_CWEBP=OFF \
        -DWEBP_BUILD_DWEBP=OFF -DWEBP_BUILD_GIF2WEBP=OFF -DWEBP_BUILD_IMG2WEBP=OFF \
        -DWEBP_BUILD_VWEBP=OFF -DWEBP_BUILD_WEBPINFO=OFF -DWEBP_BUILD_WEBPMUX=OFF \
        -DWEBP_BUILD_EXTRAS=OFF
}
dep_soxr() {
    local t d; t=$(fetch "https://downloads.sourceforge.net/project/soxr/soxr-$SOXR_VER-Source.tar.xz")
    d=$(unpack "$t" "soxr-$SOXR_VER-Source")
    build_cmake "$d" -DBUILD_TESTS=OFF -DWITH_OPENMP=OFF -DBUILD_EXAMPLES=OFF
}
dep_zimg() {
    local t d; t=$(fetch "https://github.com/sekrit-twc/zimg/archive/refs/tags/release-$ZIMG_VER.tar.gz" "zimg-$ZIMG_VER.tar.gz")
    d=$(unpack "$t" "zimg-release-$ZIMG_VER")
    ( cd "$d" && ./autogen.sh )
    build_autotools "$d"
}
dep_fribidi() {
    local t d; t=$(fetch "https://github.com/fribidi/fribidi/releases/download/v$FRIBIDI_VER/fribidi-$FRIBIDI_VER.tar.xz")
    d=$(unpack "$t" "fribidi-$FRIBIDI_VER")
    build_meson "$d" -Dtests=false -Dbin=false -Ddocs=false
}
dep_freetype() {
    local t d; t=$(fetch "https://downloads.sourceforge.net/project/freetype/freetype2/$FREETYPE_VER/freetype-$FREETYPE_VER.tar.xz")
    d=$(unpack "$t" "freetype-$FREETYPE_VER")
    # Build without harfbuzz to break the freetype<->harfbuzz cycle.
    build_cmake "$d" -DFT_DISABLE_HARFBUZZ=ON -DFT_DISABLE_BROTLI=ON \
        -DFT_DISABLE_BZIP2=ON -DFT_DISABLE_PNG=ON
}
dep_harfbuzz() {
    local t d; t=$(fetch "https://github.com/harfbuzz/harfbuzz/releases/download/$HARFBUZZ_VER/harfbuzz-$HARFBUZZ_VER.tar.xz")
    d=$(unpack "$t" "harfbuzz-$HARFBUZZ_VER")
    build_meson "$d" -Dtests=disabled -Ddocs=disabled -Dutilities=disabled \
        -Dfreetype=enabled -Dcairo=disabled -Dglib=disabled -Dgobject=disabled \
        -Dicu=disabled
}
dep_unibreak() {
    local t d; t=$(fetch "https://github.com/adah1972/libunibreak/releases/download/libunibreak_${UNIBREAK_VER//./_}/libunibreak-$UNIBREAK_VER.tar.gz")
    d=$(unpack "$t" "libunibreak-$UNIBREAK_VER")
    build_autotools "$d"
}
dep_libass() {
    local t d; t=$(fetch "https://github.com/libass/libass/releases/download/$LIBASS_VER/libass-$LIBASS_VER.tar.xz")
    d=$(unpack "$t" "libass-$LIBASS_VER")
    build_autotools "$d" --disable-fontconfig
}

# run_dep <name>: build dep_<name> unless its per-library stamp exists.
run_dep() {
    local name="$1"
    local stamp="$PREFIX/.stamps/$name"
    if [ -f "$stamp" ]; then
        echo ">>> [$ARCH] $name: already built (skip)"
        return
    fi
    echo ">>> [$ARCH] building $name"
    "dep_$name"
    mkdir -p "$PREFIX/.stamps"
    touch "$stamp"
}

build_deps_for_arch() {
    ARCH="$1"
    PREFIX="$SCRIPT_DIR/deps-macos-$ARCH"
    WORK="$SCRIPT_DIR/depbuild-macos-$ARCH"
    # Bake arch/min-OS into CC/CXX so they survive configures that clobber CFLAGS (Xiph).
    CC="clang -arch $ARCH -mmacosx-version-min=$MIN_OS"
    CXX="clang++ -arch $ARCH -mmacosx-version-min=$MIN_OS"
    ARCH_CFLAGS="-arch $ARCH -mmacosx-version-min=$MIN_OS -O3 -fPIC"
    ARCH_LDFLAGS="-arch $ARCH -mmacosx-version-min=$MIN_OS"
    # --host only for real cross-builds (it forces cross-mode, tripping old config.sub);
    # autotools wants 'aarch64', not clang's 'arm64'.
    if [ "$ARCH" != "$HOST_ARCH" ]; then
        case "$ARCH" in
            arm64)  CONFIGURE_HOST=(--host=aarch64-apple-darwin) ;;
            x86_64) CONFIGURE_HOST=(--host=x86_64-apple-darwin) ;;
        esac
    else
        CONFIGURE_HOST=()
    fi
    CMAKE_CROSS=(
        -DCMAKE_OSX_ARCHITECTURES="$ARCH"
        -DCMAKE_OSX_DEPLOYMENT_TARGET="$MIN_OS"
        -DCMAKE_PREFIX_PATH="$PREFIX"
    )
    if [ "$ARCH" != "$HOST_ARCH" ]; then
        MESON_CROSS="$WORK/meson-cross-$ARCH.txt"
    else
        MESON_CROSS=""
    fi

    mkdir -p "$WORK"
    [ -n "$MESON_CROSS" ] && write_meson_cross
    # Sandbox pkg-config to our prefix only, so codecs can't pick up Homebrew's
    # arch-specific dylibs (e.g. libunibreak) and break the cross slice.
    export PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig"
    unset PKG_CONFIG_PATH 2>/dev/null || true

    # Sandbox hides system zlib.pc; seed one pointing at the SDK's universal libz.
    mkdir -p "$PREFIX/lib/pkgconfig"
    if [ ! -f "$PREFIX/lib/pkgconfig/zlib.pc" ]; then
        cat > "$PREFIX/lib/pkgconfig/zlib.pc" <<'PC'
prefix=/usr
exec_prefix=${prefix}
libdir=${exec_prefix}/lib
includedir=${prefix}/include
Name: zlib
Description: zlib compression library (macOS system, universal)
Version: 1.2.12
Libs: -lz
Cflags:
PC
    fi

    echo ""
    echo ">>> [$ARCH] Building codec dependencies into $PREFIX"
    # Order matters: ogg before vorbis/theora; freetype/fribidi/harfbuzz/unibreak before libass.
    for name in ogg vorbis theora lame opus dav1d svtav1 aom vpx openh264 \
                webp soxr zimg fribidi freetype harfbuzz unibreak libass; do
        run_dep "$name"
    done
    echo ">>> [$ARCH] deps complete."
}

# ---- FFmpeg build per arch --------------------------------------------------
build_ffmpeg_for_arch() {
    local arch="$1"
    local build_dir="$SCRIPT_DIR/build-macos-$arch"
    local install_dir="$SCRIPT_DIR/ffmpeg-install-macos-$arch"
    local deps="$SCRIPT_DIR/deps-macos-$arch"

    echo ""
    echo ">>> [$arch] FFmpeg build dir:   $build_dir"
    echo ">>> [$arch] FFmpeg install dir: $install_dir"

    local cross_args=()
    if [ "$arch" != "$HOST_ARCH" ]; then
        cross_args+=(--enable-cross-compile --target-os=darwin)
    fi

    if [ ! -f "$build_dir/ffbuild/config.mak" ]; then
        mkdir -p "$build_dir"
        ( cd "$build_dir"
          echo ">>> [$arch] Configuring FFmpeg..."
          PKG_CONFIG_LIBDIR="$deps/lib/pkgconfig" \
          "$FFMPEG_SRC/configure" \
              --prefix="$install_dir" \
              --cc="clang -arch $arch" \
              --cxx="clang++ -arch $arch" \
              --arch="$arch" \
              ${cross_args[@]+"${cross_args[@]}"} \
              --pkg-config-flags=--static \
              --enable-shared \
              --disable-static \
              --install-name-dir=@rpath \
              --disable-programs \
              --disable-doc \
              --enable-runtime-cpudetect \
              --enable-videotoolbox \
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
              --extra-cflags="-arch $arch -mmacosx-version-min=$MIN_OS -I$deps/include $OPTIMIZATION_FLAGS" \
              --extra-ldflags="-arch $arch -mmacosx-version-min=$MIN_OS -L$deps/lib" \
              --extra-libs="-lc++"
          echo ">>> [$arch] Configure done." )
    else
        echo ">>> [$arch] Skipping configure (already configured). Use 'clean' to reconfigure."
    fi

    echo ">>> [$arch] Building FFmpeg ($JOBS threads)..."
    ( cd "$build_dir" && make -j"$JOBS" )
    echo ">>> [$arch] Installing FFmpeg..."
    ( cd "$build_dir" && make install )
}

# ---- run --------------------------------------------------------------------
for arch in "${ARCHS[@]}"; do
    build_deps_for_arch "$arch"
    build_ffmpeg_for_arch "$arch"
done

echo ""
echo ">>> Creating universal dylibs..."
ARM_LIB="$SCRIPT_DIR/ffmpeg-install-macos-arm64/lib"
X86_LIB="$SCRIPT_DIR/ffmpeg-install-macos-x86_64/lib"
rm -rf "$OUTPUT_DIR/dylib"
mkdir -p "$OUTPUT_DIR/dylib"
# For each real arm64 dylib, lipo-merge with its x86_64 twin. Output filename is
# the install_name basename (what dyld searches for), not the versioned filename.
for f in "$ARM_LIB"/*.dylib; do
    if [ -L "$f" ]; then continue; fi
    id=$(otool -D "$f" | tail -n1)
    ship_name=$(basename "$id")
    x86_file="$X86_LIB/$(basename "$f")"
    if [ ! -f "$x86_file" ]; then
        echo "ERROR: x86_64 counterpart missing for $(basename "$f"): $x86_file" >&2
        exit 1
    fi
    lipo -create "$f" "$x86_file" -output "$OUTPUT_DIR/dylib/$ship_name"
done

# Ad-hoc sign: Apple Silicon won't load dylibs without it, and lipo strips signatures.
codesign --force --sign - "$OUTPUT_DIR/dylib/"*.dylib 2>/dev/null || true

# Mirror into Blick's tree (Blick references these directly; ffpackage just produces them).
BLICK_MACOS_LIB="$SCRIPT_DIR/../blick/lib/ffmpeg/macos"
if [ -d "$SCRIPT_DIR/../blick/lib/ffmpeg" ]; then
    rm -rf "$BLICK_MACOS_LIB"
    mkdir -p "$BLICK_MACOS_LIB"
    cp -p "$OUTPUT_DIR/dylib/"*.dylib "$BLICK_MACOS_LIB/"
    codesign --force --sign - "$BLICK_MACOS_LIB/"*.dylib 2>/dev/null || true
    echo ">>> Synced into $BLICK_MACOS_LIB"
fi

echo ""
echo "=== Build complete ==="
echo "Universal dylibs: $(ls -1 "$OUTPUT_DIR/dylib/"*.dylib 2>/dev/null | wc -l | tr -d ' ') files in $OUTPUT_DIR/dylib/"
ls -lh "$OUTPUT_DIR/dylib/"
echo ""
echo "Arch check:"
for f in "$OUTPUT_DIR/dylib/"*.dylib; do
    printf "  %-32s " "$(basename "$f")"
    lipo -archs "$f"
done
