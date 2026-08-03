#!/bin/bash
# Verify -> sign (Developer ID) -> [notarize] -> zip -> replace ffmpeg_macos.zip in Blick.
#
# Runs on macOS AFTER build_ffmpeg_macos.sh has produced output-macos/dylib/*.dylib.
# Mirrors package_windows.ps1. Steps:
#   1. Assert the build is legally clean (config.h + config_components.h: no GPL/nonfree,
#      excluded encoders gone).
#   2. Assert the 7 expected dylibs are present and arm64.
#   3. Re-sign each dylib with a Developer ID Application identity (hardened runtime +
#      secure timestamp), replacing the ad-hoc signature build_ffmpeg_macos.sh applied.
#   4. Verify each signature (strict, Developer ID authority, timestamp present).
#   5. Pack the signed dylibs flat into ffmpeg_macos.zip.
#   6. (optional, --notarize) Submit the zip to Apple via notarytool and wait.
#   7. Back up and replace Blick's ffmpeg_macos.zip.
#
# Signing identity: pass --identity "Developer ID Application: NAME (TEAMID)" or set
# MACOS_SIGN_IDENTITY; if unset, auto-detects a single Developer ID Application identity.
# Notarization needs a notarytool keychain profile (xcrun notarytool store-credentials):
# pass --profile <name> or set NOTARY_PROFILE, together with --notarize.
#
# Usage:
#   ./package_macos.sh                              # verify, Developer ID sign, zip, replace
#   ./package_macos.sh --notarize --profile blick   # also notarize the zip
#   ./package_macos.sh --skip-sign                  # zip + replace as-is (dev only)
#   ./package_macos.sh --no-replace                 # sign + zip, do not touch Blick

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DYLIB_DIR="$SCRIPT_DIR/output-macos/dylib"
TARGET_ZIP="$SCRIPT_DIR/../blick/ffmpeg_macos.zip"
STAGE_ZIP="$SCRIPT_DIR/output-macos/ffmpeg_macos.zip"
CONFIG_DIR="$SCRIPT_DIR/build-macos-arm64"

IDENTITY="${MACOS_SIGN_IDENTITY:-}"
KEYCHAIN_PROFILE="${NOTARY_PROFILE:-}"
DO_SIGN=1
DO_REPLACE=1
DO_NOTARIZE=0

# The libs Blick links; must match the sonames the Odin bindings expect.
EXPECTED="libavcodec.62.dylib libavdevice.62.dylib libavfilter.11.dylib libavformat.62.dylib libavutil.60.dylib libswresample.6.dylib libswscale.9.dylib"

# ---- args -------------------------------------------------------------------
while [ $# -gt 0 ]; do
    case "$1" in
        --skip-sign)  DO_SIGN=0 ;;
        --no-replace) DO_REPLACE=0 ;;
        --notarize)   DO_NOTARIZE=1 ;;
        --identity)   IDENTITY="${2:-}"; shift ;;
        --profile)    KEYCHAIN_PROFILE="${2:-}"; shift ;;
        *) echo "unknown argument: $1" >&2; exit 2 ;;
    esac
    shift
done

RED=$'\033[31m'; GREEN=$'\033[32m'; CYAN=$'\033[36m'; YELLOW=$'\033[33m'; RST=$'\033[0m'
ok()   { echo "  ${GREEN}OK${RST}  $1"; }
fail() { echo "${RED}FAIL:${RST} $1" >&2; exit 1; }

# ---- 1. legal verification --------------------------------------------------
echo ""
echo "${CYAN}[1/7] Verifying license posture in config.h / config_components.h${RST}"

macro_val() {  # macro_val <file> <MACRO> -> value (0 if absent)
    local v
    v=$(grep -E "^#define[[:space:]]+$2[[:space:]]+[0-9]+" "$1" 2>/dev/null | awk '{print $3}' | head -n1 || true)
    if [ -n "$v" ]; then echo "$v"; else echo 0; fi
}

CONFIG_BAD=0
check() {  # check <file> <MACRO> <want>
    local have; have=$(macro_val "$1" "$2" "$3")
    if [ "$have" != "$3" ]; then
        echo "  ${RED}BAD${RST}  $2 = $have (want $3) in $(basename "$1")"
        CONFIG_BAD=1
    fi
}

ch="$CONFIG_DIR/config.h"; cc="$CONFIG_DIR/config_components.h"
[ -f "$ch" ] || fail "$ch not found - run build_ffmpeg_macos.sh first."
[ -f "$cc" ] || fail "$cc missing (stale build?) - re-run build_ffmpeg_macos.sh"
# GPL/nonfree/external libs live in config.h
check "$ch" CONFIG_GPL 0
check "$ch" CONFIG_NONFREE 0
check "$ch" CONFIG_LIBX264 0
check "$ch" CONFIG_LIBX265 0
check "$ch" CONFIG_LIBFDK_AAC 0
check "$ch" CONFIG_LIBOPENH264 1
# per-codec encoder macros live in config_components.h
check "$cc" CONFIG_AAC_ENCODER 1
check "$cc" CONFIG_PRORES_ENCODER 0
check "$cc" CONFIG_PRORES_AW_ENCODER 0
check "$cc" CONFIG_PRORES_KS_ENCODER 0
check "$cc" CONFIG_EAC3_ENCODER 0
check "$cc" CONFIG_TRUEHD_ENCODER 0
check "$cc" CONFIG_MLP_ENCODER 0
check "$cc" CONFIG_DCA_ENCODER 0
[ "$CONFIG_BAD" -eq 0 ] || fail "config does not match the licensed posture. Do NOT ship this build."
ok "GPL/nonfree off; x264/x265/fdk-aac and ProRes/Dolby/DTS encoders absent; AAC+openh264 present."

# ---- 2. presence + arch check -----------------------------------------------
echo ""
echo "${CYAN}[2/7] Checking dylibs${RST}"
[ -d "$DYLIB_DIR" ] || fail "dylib dir not found: $DYLIB_DIR"
for f in $EXPECTED; do
    [ -f "$DYLIB_DIR/$f" ] || fail "missing expected dylib: $f"
    archs=$(lipo -archs "$DYLIB_DIR/$f")
    [ "$archs" = "arm64" ] || fail "$f is not arm64-only (got: $archs)"
done
ok "7 arm64 dylibs present."

# ---- 3. sign ----------------------------------------------------------------
if [ "$DO_SIGN" -eq 0 ]; then
    echo ""
    echo "${YELLOW}[3/7] Signing SKIPPED (--skip-sign)${RST}"
else
    echo ""
    echo "${CYAN}[3/7] Signing with Developer ID${RST}"
    if [ -z "$IDENTITY" ]; then
        ids=$(security find-identity -v -p codesigning | grep "Developer ID Application" || true)
        n=$(printf '%s\n' "$ids" | grep -c "Developer ID Application" || true)
        if [ "$n" -eq 1 ]; then
            IDENTITY=$(printf '%s\n' "$ids" | sed -E 's/^.*"(Developer ID Application:[^"]*)".*$/\1/')
        elif [ "$n" -eq 0 ]; then
            fail "no 'Developer ID Application' identity in keychain; pass --identity or set MACOS_SIGN_IDENTITY."
        else
            printf '%s\n' "$ids" >&2
            fail "multiple Developer ID Application identities; pass --identity to choose one."
        fi
    fi
    echo "  identity: $IDENTITY"
    for f in $EXPECTED; do
        codesign --force --timestamp --options runtime --sign "$IDENTITY" "$DYLIB_DIR/$f"
    done
    ok "Signed 7 dylibs (hardened runtime + secure timestamp)."

    echo ""
    echo "${CYAN}[4/7] Verifying signatures${RST}"
    for f in $EXPECTED; do
        codesign --verify --strict --verbose=2 "$DYLIB_DIR/$f" 2>/dev/null \
            || fail "signature verify failed for $f"
        info=$(codesign -dvv "$DYLIB_DIR/$f" 2>&1)
        echo "$info" | grep -q "Authority=Developer ID Application" \
            || fail "$f not signed by a Developer ID Application authority"
        echo "$info" | grep -q "Timestamp=" \
            || fail "$f has no secure timestamp"
    done
    ok "All signatures valid, Developer ID, timestamped."
fi

# ---- 5. pack flat zip -------------------------------------------------------
echo ""
echo "${CYAN}[5/7] Packing flat zip${RST}"
rm -f "$STAGE_ZIP"
( cd "$DYLIB_DIR" && zip -q "$STAGE_ZIP" $EXPECTED )
ok "Wrote $STAGE_ZIP"

# ---- 6. notarize (optional) -------------------------------------------------
if [ "$DO_NOTARIZE" -eq 0 ]; then
    echo ""
    echo "${YELLOW}[6/7] Notarization SKIPPED (pass --notarize --profile <name> to enable)${RST}"
    echo "       Loose dylibs can't be stapled anyway; app-level notarization+staple of"
    echo "       Blick.app (which embeds these) is what Gatekeeper checks at release."
else
    echo ""
    echo "${CYAN}[6/7] Notarizing zip${RST}"
    [ -n "$KEYCHAIN_PROFILE" ] || fail "notarization needs --profile <notarytool keychain profile> (or NOTARY_PROFILE)."
    command -v xcrun >/dev/null 2>&1 || fail "xcrun not found (Xcode Command Line Tools)."
    xcrun notarytool submit "$STAGE_ZIP" --keychain-profile "$KEYCHAIN_PROFILE" --wait
    ok "notarytool accepted the submission (note: bare dylibs are not stapleable)."
fi

# ---- 7. replace Blick's zip -------------------------------------------------
if [ "$DO_REPLACE" -eq 0 ]; then
    echo ""
    echo "${YELLOW}[7/7] Replace SKIPPED (--no-replace). Staged zip: $STAGE_ZIP${RST}"
else
    echo ""
    echo "${CYAN}[7/7] Replacing Blick zip${RST}"
    blick_dir=$(dirname "$TARGET_ZIP")
    [ -d "$blick_dir" ] || fail "Blick dir not found: $blick_dir"
    if [ -f "$TARGET_ZIP" ]; then
        cp -p "$TARGET_ZIP" "$TARGET_ZIP.bak"
        ok "Backed up existing zip -> $TARGET_ZIP.bak"
    fi
    cp -p "$STAGE_ZIP" "$TARGET_ZIP"
    ok "Replaced $TARGET_ZIP"
fi

echo ""
echo "${CYAN}Done.${RST}"
