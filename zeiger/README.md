# FFmpeg for Zeiger

Builds the FFmpeg libraries that Zeiger, the image viewer, ships. It uses the same FFmpeg commit as
Blick (the `ffmpeg` submodule) and the same LGPL 2.1+ configuration rules, but with only the parts an
image viewer needs:

- **Libraries:** `avcodec`, `avformat`, `avutil` and `swscale`. No `avdevice`, `avfilter` or
  `swresample`.
- **Decoders:** the image codecs Zeiger opens, `libdav1d` for AVIF and `hevc` for HEIC.
- **Encoders:** `png`, `mjpeg`, `bmp` and `tiff`, for Save.
- **Demuxers and parsers:** `image2`, the image pipe demuxers, `gif`, `apng` and `mov` (for HEIF and
  AVIF), with the parsers of those codecs.
- **External libraries:** dav1d and zlib, linked statically. `--disable-autodetect` keeps out
  everything else, for example iconv, Media Foundation and VideoToolbox.

No audio codec, no H.264, no video encoder and no hardware video API is in this build. The lists are
at the top of `build_ffmpeg.sh`.

Blick's build (`../build_ffmpeg.sh`, `../build_ffmpeg_macos.sh`) is separate and does not change.

## Building

Windows, in the **MSYS2 CLANG64** shell:

```bash
./zeiger/build_ffmpeg.sh          # also: clean
```

macOS, in a terminal (Xcode Command Line Tools; Homebrew installs meson, ninja, nasm and pkg-config
when they are missing):

```bash
./zeiger/build_ffmpeg.sh          # also: clean
```

The script exports the submodule commit into `zeiger/build-<platform>/ffmpeg`, because Blick's
Windows build configures inside `ffmpeg/` and FFmpeg then refuses an out-of-tree build. It reconfigures
only when the configure arguments change.

Dependency versions:

- **Windows:** the MSYS2 packages are checked against `../windows-deps.lock`, the same lock as
  Blick's build.
- **macOS:** dav1d 1.5.1 is built from the tarball in `../src-cache-macos/`, checked against
  `../macos-deps.sha256`, the same as Blick's build.

The script stops when a library needs a DLL or dylib that Zeiger doesn't ship. Every dependency must
be linked statically.

## Output

`zeiger/output-windows/` or `zeiger/output-macos/`:

- the libraries (`avcodec-62.dll` ... or `libavcodec.62.dylib` ..., named after their install names
  on macOS, ad-hoc signed)
- `config.h` and `config_components.h`, which show the license posture (`CONFIG_GPL` and
  `CONFIG_NONFREE` are 0) and the component list
