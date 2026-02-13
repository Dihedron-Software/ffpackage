# ffpackage

Build FFmpeg 8.0 as LGPL 2.1+ shared DLLs for Windows and generate Odin language bindings.

## What this produces

```
output/
  dll/          *.dll files (runtime)
  lib/          *.lib files (link-time)
  *.odin        Odin bindings (package ffmpeg)
```

Drop `output/` into Blick's source as `lib/ffmpeg/`. Copy `output/dll/*.dll` next to the Blick executable.

## Prerequisites

### For building FFmpeg (one-time setup)

1. **MSYS2** -- https://www.msys2.org/
2. Open **MSYS2 MINGW64** shell and install dependencies:

```bash
pacman -S --needed mingw-w64-x86_64-gcc mingw-w64-x86_64-nasm make pkg-config diffutils
```

### For generating Odin bindings (one-time setup)

1. **Odin compiler** -- https://odin-lang.org/ (must be on PATH)
2. **LLVM/Clang 16+** -- https://github.com/llvm/llvm-project/releases
   - Copy `lib/libclang.lib` into `odin-c-bindgen/libclang/`
   - Copy `bin/libclang.dll` into `odin-c-bindgen/` (next to where `bindgen.exe` will be)

## Step 1: Build FFmpeg

From the **MSYS2 MINGW64** shell, in this directory:

```bash
./build_ffmpeg.sh
```

This configures FFmpeg as LGPL 2.1+, builds shared DLLs, and outputs them into `output/dll/` and `output/lib/`.

**Output:**
- `output/dll/` .dll files
- `output/lib/` .lib files
- `ffmpeg-install/` used internally by the bindgen 

## Step 2: Generate Odin bindings

From **PowerShell**, in this directory:

```powershell
.\generate_bindings.ps1
```

This builds the bindgen (if needed), runs it against all FFmpeg headers listed in `bindgen-config/bindgen.sjson`, post-processes each `.odin` file to set the correct `foreign import` per library, and copies `helpers.odin` into the output.

**Output:**
- `output/*.odin` -- one file per FFmpeg header, all in `package ffmpeg`

## Step 3: Manual fixups

If the bindgen produces declarations that don't compile or aren't needed, edit `bindgen-config/bindgen.sjson` and add entries to the `remove` list, or override types.
Ideally we should be able to do this through the config, and not manually touch the generated files at all.

## Adding/removing headers

Edit `bindgen-config/bindgen.sjson` to add or remove headers from the `inputs` list.

If you add a header from a new FFmpeg library, also update the `$headerToLib` mapping in `generate_bindings.ps1` so the post-processing assigns the correct `foreign import`.
