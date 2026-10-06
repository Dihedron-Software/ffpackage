# LibRaw

Builds [LibRaw](https://www.libraw.org) 0.22.2 as a static library for Windows and macOS, and
generates the Odin bindings Zeiger uses against it.

This folder is also the **corresponding source** for the LibRaw code shipped inside Zeiger: the
unmodified upstream tarball is committed in `source/`, with `SHA256SUMS.txt` to verify it.

## License

LibRaw is offered under LGPL-2.1 or CDDL-1.0. We use it under the **CDDL 1.0**, which allows a
static link into a closed-source executable.

- `source/` -- the unmodified LibRaw tarball, CDDL 1.0.
- `output/*.odin` -- the generated bindings, CDDL 1.0 (each file carries the notice).
- `output/LICENSE.CDDL`, `output/COPYRIGHT` -- copied from the tarball by the build.
- Everything else in this folder is MIT, see the repository `LICENSE`.

Ship `COPYRIGHT` with the product as well: besides LibRaw itself it carries the notices for the dcraw,
DCB/FBDD, X3F and Adobe DNG SDK code that LibRaw includes.

When LibRaw is bumped, add the new tarball next to the old one rather than replacing it. Zeiger
versions already shipped still correspond to the older source.

## Building -- Windows

Requires Visual Studio with the MSVC 14.44 toolset. From PowerShell:

```powershell
.\build_libraw.ps1           # also: debug | clean
```

Produces `output\libraw.lib`: x64, static CRT (`/MT`, the same as Hydra), no OpenMP.

The build always uses MSVC 14.44 (VS 2022 17.14, "MSVC v143"), set in `$toolset` at the top of the
script. Microsoft supports a library from an older toolset with a newer linker, but not the opposite:
a library from a newer toolset can call STL functions that an older `libcpmt.lib` does not have.
Odin links with the first Visual Studio that it finds, so the library must not be newer than the
oldest toolset on any machine that links Zeiger (developers and CI).

- Raise `$toolset` only when every machine that links Zeiger has the newer toolset.
- Visual Studio 2026 can install 14.44: add the "MSVC v143 - VS 2022 C++ x64/x86 build tools"
  component in the Visual Studio Installer.

## Building -- macOS

```bash
./build_libraw_macos.sh      # also: debug | clean
```

Produces `output/libraw.a`: arm64, min-OS macOS 13.0, no OpenMP. Odin links it with `system:c++`.

## Generating the Odin bindings

Run `build_libraw.ps1` first (it extracts the headers), then from PowerShell:

```powershell
.\generate_bindings.ps1
```

Uses the `odin-c-bindgen` submodule at the repository root (see the root README for its libclang
setup). Inputs: `libraw.h`, `libraw_types.h`, `libraw_const.h`, `libraw_version.h`. Names stay as in
the C headers (`libraw_init`, `libraw_data_t`), the same as the FFmpeg bindings.

The struct layouts in `libraw_types.h` do not depend on build defines, so one set of bindings serves
both platforms. Verified on Windows: all 45 struct sizes and every `libraw_data_t` field offset match
MSVC. `libraw_data_t` is about 380 KB, so only ever hold it through the pointer `libraw_init` returns.

## Packaging into the monorepo

Copy `output/` into the monorepo as `lib/libraw/`: the four `.odin` files, `libraw.lib`, `libraw.a`,
`LICENSE.CDDL` and `COPYRIGHT`. Never edit the bindings there by hand; change the generator here.
