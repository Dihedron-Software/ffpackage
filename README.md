# ffpackage

Builds FFmpeg 8.0 as LGPL 2.1+ shared libraries for Windows and macOS, and generates the Odin
bindings Blick uses against them.

This repository is also the **corresponding source** for the FFmpeg libraries shipped with Blick:
it pins the exact FFmpeg commit (as a submodule) and contains the scripts that configure and build
it, which is what LGPL 2.1 section 0 means by "the scripts used to control compilation and
installation of the library". See [LGPL compliance](#lgpl-compliance) below.

## Clone

The FFmpeg source is a submodule pinned to the exact shipped commit:

```bash
git clone --recursive https://github.com/Dihedron-Software/ffpackage.git
# or, in an existing clone:
git submodule update --init --recursive
```

## What this produces

```
output/          Windows
  dll/           *.dll  (runtime)
  lib/           *.lib  (link-time)
  *.odin         Odin bindings (package ffmpeg)

output-macos/    macOS
  dylib/         *.dylib (universal arm64 + x86_64, @rpath install names, min-OS 13.0)
```

Drop `output/` into Blick's source as `lib/ffmpeg/`.

## Building FFmpeg -- Windows

Requires [MSYS2](https://www.msys2.org/). Open the **MSYS2 CLANG64** shell (not MINGW64 -- the
build is clang-based) and run:

```bash
./build_ffmpeg.sh
```

The script installs its own toolchain and codec packages via `pacman`, so there is no manual
dependency step. Other modes:

```bash
./build_ffmpeg.sh debug           # -O0 + debug info
./build_ffmpeg.sh release_info    # -O3 + debug info
./build_ffmpeg.sh clean           # wipe build + install + output
./build_ffmpeg.sh --relock        # accept new dependency versions (see below)
```

### Dependency locking

`pacman` has no version pinning, so an MSYS2 upgrade can silently change what gets linked into the
DLLs -- which would leave the published source no longer matching the shipped binaries.

`windows-deps.lock` records the exact package versions and FFmpeg commit that were used. Every
build verifies against it and **aborts on any mismatch**. When a bump is intentional:

```bash
./build_ffmpeg.sh --relock        # rewrite the lock, then rebuild
```

Then regenerate `THIRD-PARTY-LICENSES.txt` in the Blick repo (`update_licenses.sh`) so the shipped
notices match the new versions.

macOS pins every dependency *version* inline in `build_ffmpeg_macos.sh`, so there is nothing to
resolve and no version drift to catch. What it does need is *content* verification, since it
downloads those versions over the network:

```bash
./build_ffmpeg_macos.sh --relock   # hash src-cache-macos/ into macos-deps.sha256
```

Run that once after a full build. From then on every `fetch()` checks each archive against
`macos-deps.sha256` and aborts on a mismatch, so a replaced upstream tarball, a bad mirror or a
truncated download can't silently change what gets built. Re-run `--relock` after an intentional
version bump.

aom is the exception: it has no release tarball, only a git tag, so it is cached as a shallow clone
and recorded as `git:<commit>` instead of a hash. That pin is checked in `dep_aom` rather than in
`fetch()`, which guards against the upstream tag being moved.

## Building FFmpeg -- macOS

```bash
./build_ffmpeg_macos.sh           # also: clean | debug | release_info
```

Builds universal (arm64 + x86_64) dylibs depending only on macOS system frameworks. Every codec
dependency is compiled from upstream source at the versions pinned near the top of the script and
statically linked in. Build tools (nasm, cmake, meson, ...) auto-install via Homebrew; Xcode Command
Line Tools must already be present. Source tarballs are cached in `src-cache-macos/`.

## Generating the Odin bindings

Requires the [Odin compiler](https://odin-lang.org/) on PATH and LLVM/Clang 16+:

- copy `lib/libclang.lib` into `odin-c-bindgen/libclang/`
- copy `bin/libclang.dll` into `odin-c-bindgen/`

Then, from **PowerShell**:

```powershell
.\generate_bindings.ps1
```

Builds the bindgen if needed, runs it over the headers listed in `bindgen-config/bindgen.sjson`,
rewrites each `.odin` file's `foreign import` to the right library, and copies `hand-written/` into
the output.

To add or remove a header, edit `bindgen-config/bindgen.sjson`. If it comes from a new FFmpeg
library, also update the `$headerToLib` mapping in `generate_bindings.ps1`.

If the bindgen emits declarations that don't compile, prefer adding them to the config's `remove`
list or overriding the type there, rather than hand-editing generated files.

## Packaging into Blick

```powershell
.\package_windows.ps1             # -SkipSign to skip Authenticode signing
```
```bash
./package_macos.sh                # --notarize to submit to Apple
```

Both verify the build is legally clean (no GPL/nonfree in `config.h`), confirm the expected shared
libraries are present, sign them, zip them, and replace the corresponding archive in the Blick repo.

Windows signing uses the Dihedron certificate held on Certum's SimplySign cloud CSP -- log in via
SimplySign Desktop first. macOS signing needs a Developer ID Application identity, and
notarization additionally needs a `notarytool` keychain profile.

## LGPL compliance

FFmpeg is configured **without** `--enable-gpl` and **without** `--enable-nonfree`, so the output is
LGPL 2.1+ and may be linked by closed-source software. `package_windows.ps1` and `package_macos.sh`
both assert this against the generated `config.h` rather than trusting the configure line.

The libraries are shipped as separate shared library files and are not statically linked into Blick,
so they can be replaced with a user's own rebuild. On macOS, Blick is signed with
`com.apple.security.cs.disable-library-validation` specifically so that a replacement dylib signed
by someone else still loads under the hardened runtime.

Several LGPL libraries are statically linked *into* the FFmpeg libraries and are therefore covered
by the same obligation: **LAME 3.100**, **libsoxr 0.1.3**, **FriBidi 1.0.16** (all platforms) and
**GNU libiconv 1.18** (Windows only). Their upstream source tarballs are committed here in
`lgpl-sources/`, with `SHA256SUMS.txt` to verify them -- committed rather than attached as release
assets so that a clone or a mirror to another host carries the corresponding source with it.

The Windows builds of those four come from MSYS2 packages whose `-N` version suffix denotes
distribution patches on top of these tarballs; those patches are in
[msys2/MINGW-packages](https://github.com/msys2/MINGW-packages) at the package versions recorded in
`windows-deps.lock`. The macOS builds use these tarballs unmodified.

When a dependency is bumped, add the new tarball alongside the old one rather than replacing it --
Blick versions already shipped still correspond to the older source.

Full license texts for every bundled component ship with Blick and are viewable via
**Help > Third-party licenses**.

## License

The build, packaging and binding-generation scripts in this repository are MIT licensed -- see
[LICENSE](LICENSE). They are deliberately permissive because LGPL 2.1 requires the scripts that
control compilation to be provided as part of the corresponding source, which means recipients have
to be free to actually run and modify them in order to rebuild the libraries.

The `ffmpeg/` and `odin-c-bindgen/` submodules are covered by their own upstream licenses, not by
this one.
