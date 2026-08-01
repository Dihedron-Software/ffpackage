/*
 * copyright (c) 2006 Michael Niedermayer <michaelni@gmx.at>
 *
 * This file is part of FFmpeg.
 *
 * FFmpeg is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * FFmpeg is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with FFmpeg; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */
package ffmpeg

when ODIN_OS == .Windows {
    foreign import lib "lib/avutil.lib"
} else when ODIN_OS == .Darwin {
    @(extra_linker_flags = "-L/opt/homebrew/lib")
    foreign import lib "system:avutil"
}

AVPALETTE_SIZE  :: 1024
AVPALETTE_COUNT :: 256

/**
* Maximum number of planes in any pixel format.
* This should be used when a maximum is needed, but code should not
* be written to require a maximum for no good reason.
*/
AV_VIDEO_MAX_PLANES :: 4

/**
* Pixel format.
*
* @note
* AV_PIX_FMT_RGB32 is handled in an endian-specific manner. An RGBA
* color is put together as:
*  (A << 24) | (R << 16) | (G << 8) | B
* This is stored as BGRA on little-endian CPU architectures and ARGB on
* big-endian CPUs.
*
* @note
* If the resolution is not a multiple of the chroma subsampling factor
* then the chroma plane resolution must be rounded up.
*
* @par
* When the pixel format is palettized RGB32 (AV_PIX_FMT_PAL8), the palettized
* image data is stored in AVFrame.data[0]. The palette is transported in
* AVFrame.data[1], is 1024 bytes long (256 4-byte entries) and is
* formatted the same as in AV_PIX_FMT_RGB32 described above (i.e., it is
* also endian-specific). Note also that the individual RGB32 palette
* components stored in AVFrame.data[1] should be in the range 0..255.
* This is important as many custom PAL8 video codecs that were designed
* to run on the IBM VGA graphics adapter use 6-bit palette components.
*
* @par
* For all the 8 bits per pixel formats, an RGB32 palette is in data[1] like
* for pal8. This palette is filled in automatically by the function
* allocating the picture.
*/
AVPixelFormat :: enum i32 {
	NONE           = -1,
	YUV420P        = 0,   ///< planar YUV 4:2:0, 12bpp, (1 Cr & Cb sample per 2x2 Y samples)
	YUYV422        = 1,   ///< packed YUV 4:2:2, 16bpp, Y0 Cb Y1 Cr
	RGB24          = 2,   ///< packed RGB 8:8:8, 24bpp, RGBRGB...
	BGR24          = 3,   ///< packed RGB 8:8:8, 24bpp, BGRBGR...
	YUV422P        = 4,   ///< planar YUV 4:2:2, 16bpp, (1 Cr & Cb sample per 2x1 Y samples)
	YUV444P        = 5,   ///< planar YUV 4:4:4, 24bpp, (1 Cr & Cb sample per 1x1 Y samples)
	YUV410P        = 6,   ///< planar YUV 4:1:0,  9bpp, (1 Cr & Cb sample per 4x4 Y samples)
	YUV411P        = 7,   ///< planar YUV 4:1:1, 12bpp, (1 Cr & Cb sample per 4x1 Y samples)
	GRAY8          = 8,   ///<        Y        ,  8bpp
	MONOWHITE      = 9,   ///<        Y        ,  1bpp, 0 is white, 1 is black, in each byte pixels are ordered from the msb to the lsb
	MONOBLACK      = 10,  ///<        Y        ,  1bpp, 0 is black, 1 is white, in each byte pixels are ordered from the msb to the lsb
	PAL8           = 11,  ///< 8 bits with AV_PIX_FMT_RGB32 palette
	YUVJ420P       = 12,  ///< planar YUV 4:2:0, 12bpp, full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV420P and setting color_range
	YUVJ422P       = 13,  ///< planar YUV 4:2:2, 16bpp, full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV422P and setting color_range
	YUVJ444P       = 14,  ///< planar YUV 4:4:4, 24bpp, full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV444P and setting color_range
	UYVY422        = 15,  ///< packed YUV 4:2:2, 16bpp, Cb Y0 Cr Y1
	UYYVYY411      = 16,  ///< packed YUV 4:1:1, 12bpp, Cb Y0 Y1 Cr Y2 Y3
	BGR8           = 17,  ///< packed RGB 3:3:2,  8bpp, (msb)2B 3G 3R(lsb)
	BGR4           = 18,  ///< packed RGB 1:2:1 bitstream,  4bpp, (msb)1B 2G 1R(lsb), a byte contains two pixels, the first pixel in the byte is the one composed by the 4 msb bits
	BGR4_BYTE      = 19,  ///< packed RGB 1:2:1,  8bpp, (msb)1B 2G 1R(lsb)
	RGB8           = 20,  ///< packed RGB 3:3:2,  8bpp, (msb)3R 3G 2B(lsb)
	RGB4           = 21,  ///< packed RGB 1:2:1 bitstream,  4bpp, (msb)1R 2G 1B(lsb), a byte contains two pixels, the first pixel in the byte is the one composed by the 4 msb bits
	RGB4_BYTE      = 22,  ///< packed RGB 1:2:1,  8bpp, (msb)1R 2G 1B(lsb)
	NV12           = 23,  ///< planar YUV 4:2:0, 12bpp, 1 plane for Y and 1 plane for the UV components, which are interleaved (first byte U and the following byte V)
	NV21           = 24,  ///< as above, but U and V bytes are swapped
	ARGB           = 25,  ///< packed ARGB 8:8:8:8, 32bpp, ARGBARGB...
	RGBA           = 26,  ///< packed RGBA 8:8:8:8, 32bpp, RGBARGBA...
	ABGR           = 27,  ///< packed ABGR 8:8:8:8, 32bpp, ABGRABGR...
	BGRA           = 28,  ///< packed BGRA 8:8:8:8, 32bpp, BGRABGRA...
	GRAY16BE       = 29,  ///<        Y        , 16bpp, big-endian
	GRAY16LE       = 30,  ///<        Y        , 16bpp, little-endian
	YUV440P        = 31,  ///< planar YUV 4:4:0 (1 Cr & Cb sample per 1x2 Y samples)
	YUVJ440P       = 32,  ///< planar YUV 4:4:0 full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV440P and setting color_range
	YUVA420P       = 33,  ///< planar YUV 4:2:0, 20bpp, (1 Cr & Cb sample per 2x2 Y & A samples)
	RGB48BE        = 34,  ///< packed RGB 16:16:16, 48bpp, 16R, 16G, 16B, the 2-byte value for each R/G/B component is stored as big-endian
	RGB48LE        = 35,  ///< packed RGB 16:16:16, 48bpp, 16R, 16G, 16B, the 2-byte value for each R/G/B component is stored as little-endian
	RGB565BE       = 36,  ///< packed RGB 5:6:5, 16bpp, (msb)   5R 6G 5B(lsb), big-endian
	RGB565LE       = 37,  ///< packed RGB 5:6:5, 16bpp, (msb)   5R 6G 5B(lsb), little-endian
	RGB555BE       = 38,  ///< packed RGB 5:5:5, 16bpp, (msb)1X 5R 5G 5B(lsb), big-endian   , X=unused/undefined
	RGB555LE       = 39,  ///< packed RGB 5:5:5, 16bpp, (msb)1X 5R 5G 5B(lsb), little-endian, X=unused/undefined
	BGR565BE       = 40,  ///< packed BGR 5:6:5, 16bpp, (msb)   5B 6G 5R(lsb), big-endian
	BGR565LE       = 41,  ///< packed BGR 5:6:5, 16bpp, (msb)   5B 6G 5R(lsb), little-endian
	BGR555BE       = 42,  ///< packed BGR 5:5:5, 16bpp, (msb)1X 5B 5G 5R(lsb), big-endian   , X=unused/undefined
	BGR555LE       = 43,  ///< packed BGR 5:5:5, 16bpp, (msb)1X 5B 5G 5R(lsb), little-endian, X=unused/undefined

	/**
	*  Hardware acceleration through VA-API, data[3] contains a
	*  VASurfaceID.
	*/
	VAAPI          = 44,
	YUV420P16LE    = 45,  ///< planar YUV 4:2:0, 24bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
	YUV420P16BE    = 46,  ///< planar YUV 4:2:0, 24bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
	YUV422P16LE    = 47,  ///< planar YUV 4:2:2, 32bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
	YUV422P16BE    = 48,  ///< planar YUV 4:2:2, 32bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
	YUV444P16LE    = 49,  ///< planar YUV 4:4:4, 48bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
	YUV444P16BE    = 50,  ///< planar YUV 4:4:4, 48bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
	DXVA2_VLD      = 51,  ///< HW decoding through DXVA2, Picture.data[3] contains a LPDIRECT3DSURFACE9 pointer
	RGB444LE       = 52,  ///< packed RGB 4:4:4, 16bpp, (msb)4X 4R 4G 4B(lsb), little-endian, X=unused/undefined
	RGB444BE       = 53,  ///< packed RGB 4:4:4, 16bpp, (msb)4X 4R 4G 4B(lsb), big-endian,    X=unused/undefined
	BGR444LE       = 54,  ///< packed BGR 4:4:4, 16bpp, (msb)4X 4B 4G 4R(lsb), little-endian, X=unused/undefined
	BGR444BE       = 55,  ///< packed BGR 4:4:4, 16bpp, (msb)4X 4B 4G 4R(lsb), big-endian,    X=unused/undefined
	YA8            = 56,  ///< 8 bits gray, 8 bits alpha
	Y400A          = 56,  ///< alias for AV_PIX_FMT_YA8
	GRAY8A         = 56,  ///< alias for AV_PIX_FMT_YA8
	BGR48BE        = 57,  ///< packed RGB 16:16:16, 48bpp, 16B, 16G, 16R, the 2-byte value for each R/G/B component is stored as big-endian
	BGR48LE        = 58,  ///< packed RGB 16:16:16, 48bpp, 16B, 16G, 16R, the 2-byte value for each R/G/B component is stored as little-endian

	/**
	* The following 12 formats have the disadvantage of needing 1 format for each bit depth.
	* Notice that each 9/10 bits sample is stored in 16 bits with extra padding.
	* If you want to support multiple bit depths, then using AV_PIX_FMT_YUV420P16* with the bpp stored separately is better.
	*/
	YUV420P9BE     = 59,  ///< planar YUV 4:2:0, 13.5bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
	YUV420P9LE     = 60,  ///< planar YUV 4:2:0, 13.5bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
	YUV420P10BE    = 61,  ///< planar YUV 4:2:0, 15bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
	YUV420P10LE    = 62,  ///< planar YUV 4:2:0, 15bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
	YUV422P10BE    = 63,  ///< planar YUV 4:2:2, 20bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
	YUV422P10LE    = 64,  ///< planar YUV 4:2:2, 20bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
	YUV444P9BE     = 65,  ///< planar YUV 4:4:4, 27bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
	YUV444P9LE     = 66,  ///< planar YUV 4:4:4, 27bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
	YUV444P10BE    = 67,  ///< planar YUV 4:4:4, 30bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
	YUV444P10LE    = 68,  ///< planar YUV 4:4:4, 30bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
	YUV422P9BE     = 69,  ///< planar YUV 4:2:2, 18bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
	YUV422P9LE     = 70,  ///< planar YUV 4:2:2, 18bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
	GBRP           = 71,  ///< planar GBR 4:4:4 24bpp
	GBR24P         = 71,  // alias for #AV_PIX_FMT_GBRP
	GBRP9BE        = 72,  ///< planar GBR 4:4:4 27bpp, big-endian
	GBRP9LE        = 73,  ///< planar GBR 4:4:4 27bpp, little-endian
	GBRP10BE       = 74,  ///< planar GBR 4:4:4 30bpp, big-endian
	GBRP10LE       = 75,  ///< planar GBR 4:4:4 30bpp, little-endian
	GBRP16BE       = 76,  ///< planar GBR 4:4:4 48bpp, big-endian
	GBRP16LE       = 77,  ///< planar GBR 4:4:4 48bpp, little-endian
	YUVA422P       = 78,  ///< planar YUV 4:2:2 24bpp, (1 Cr & Cb sample per 2x1 Y & A samples)
	YUVA444P       = 79,  ///< planar YUV 4:4:4 32bpp, (1 Cr & Cb sample per 1x1 Y & A samples)
	YUVA420P9BE    = 80,  ///< planar YUV 4:2:0 22.5bpp, (1 Cr & Cb sample per 2x2 Y & A samples), big-endian
	YUVA420P9LE    = 81,  ///< planar YUV 4:2:0 22.5bpp, (1 Cr & Cb sample per 2x2 Y & A samples), little-endian
	YUVA422P9BE    = 82,  ///< planar YUV 4:2:2 27bpp, (1 Cr & Cb sample per 2x1 Y & A samples), big-endian
	YUVA422P9LE    = 83,  ///< planar YUV 4:2:2 27bpp, (1 Cr & Cb sample per 2x1 Y & A samples), little-endian
	YUVA444P9BE    = 84,  ///< planar YUV 4:4:4 36bpp, (1 Cr & Cb sample per 1x1 Y & A samples), big-endian
	YUVA444P9LE    = 85,  ///< planar YUV 4:4:4 36bpp, (1 Cr & Cb sample per 1x1 Y & A samples), little-endian
	YUVA420P10BE   = 86,  ///< planar YUV 4:2:0 25bpp, (1 Cr & Cb sample per 2x2 Y & A samples, big-endian)
	YUVA420P10LE   = 87,  ///< planar YUV 4:2:0 25bpp, (1 Cr & Cb sample per 2x2 Y & A samples, little-endian)
	YUVA422P10BE   = 88,  ///< planar YUV 4:2:2 30bpp, (1 Cr & Cb sample per 2x1 Y & A samples, big-endian)
	YUVA422P10LE   = 89,  ///< planar YUV 4:2:2 30bpp, (1 Cr & Cb sample per 2x1 Y & A samples, little-endian)
	YUVA444P10BE   = 90,  ///< planar YUV 4:4:4 40bpp, (1 Cr & Cb sample per 1x1 Y & A samples, big-endian)
	YUVA444P10LE   = 91,  ///< planar YUV 4:4:4 40bpp, (1 Cr & Cb sample per 1x1 Y & A samples, little-endian)
	YUVA420P16BE   = 92,  ///< planar YUV 4:2:0 40bpp, (1 Cr & Cb sample per 2x2 Y & A samples, big-endian)
	YUVA420P16LE   = 93,  ///< planar YUV 4:2:0 40bpp, (1 Cr & Cb sample per 2x2 Y & A samples, little-endian)
	YUVA422P16BE   = 94,  ///< planar YUV 4:2:2 48bpp, (1 Cr & Cb sample per 2x1 Y & A samples, big-endian)
	YUVA422P16LE   = 95,  ///< planar YUV 4:2:2 48bpp, (1 Cr & Cb sample per 2x1 Y & A samples, little-endian)
	YUVA444P16BE   = 96,  ///< planar YUV 4:4:4 64bpp, (1 Cr & Cb sample per 1x1 Y & A samples, big-endian)
	YUVA444P16LE   = 97,  ///< planar YUV 4:4:4 64bpp, (1 Cr & Cb sample per 1x1 Y & A samples, little-endian)
	VDPAU          = 98,  ///< HW acceleration through VDPAU, Picture.data[3] contains a VdpVideoSurface
	XYZ12LE        = 99,  ///< packed XYZ 4:4:4, 36 bpp, (msb) 12X, 12Y, 12Z (lsb), the 2-byte value for each X/Y/Z is stored as little-endian, the 4 lower bits are set to 0
	XYZ12BE        = 100, ///< packed XYZ 4:4:4, 36 bpp, (msb) 12X, 12Y, 12Z (lsb), the 2-byte value for each X/Y/Z is stored as big-endian, the 4 lower bits are set to 0
	NV16           = 101, ///< interleaved chroma YUV 4:2:2, 16bpp, (1 Cr & Cb sample per 2x1 Y samples)
	NV20LE         = 102, ///< interleaved chroma YUV 4:2:2, 20bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
	NV20BE         = 103, ///< interleaved chroma YUV 4:2:2, 20bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
	RGBA64BE       = 104, ///< packed RGBA 16:16:16:16, 64bpp, 16R, 16G, 16B, 16A, the 2-byte value for each R/G/B/A component is stored as big-endian
	RGBA64LE       = 105, ///< packed RGBA 16:16:16:16, 64bpp, 16R, 16G, 16B, 16A, the 2-byte value for each R/G/B/A component is stored as little-endian
	BGRA64BE       = 106, ///< packed RGBA 16:16:16:16, 64bpp, 16B, 16G, 16R, 16A, the 2-byte value for each R/G/B/A component is stored as big-endian
	BGRA64LE       = 107, ///< packed RGBA 16:16:16:16, 64bpp, 16B, 16G, 16R, 16A, the 2-byte value for each R/G/B/A component is stored as little-endian
	YVYU422        = 108, ///< packed YUV 4:2:2, 16bpp, Y0 Cr Y1 Cb
	YA16BE         = 109, ///< 16 bits gray, 16 bits alpha (big-endian)
	YA16LE         = 110, ///< 16 bits gray, 16 bits alpha (little-endian)
	GBRAP          = 111, ///< planar GBRA 4:4:4:4 32bpp
	GBRAP16BE      = 112, ///< planar GBRA 4:4:4:4 64bpp, big-endian
	GBRAP16LE      = 113, ///< planar GBRA 4:4:4:4 64bpp, little-endian

	/**
	* HW acceleration through QSV, data[3] contains a pointer to the
	* mfxFrameSurface1 structure.
	*
	* Before FFmpeg 5.0:
	* mfxFrameSurface1.Data.MemId contains a pointer when importing
	* the following frames as QSV frames:
	*
	* VAAPI:
	* mfxFrameSurface1.Data.MemId contains a pointer to VASurfaceID
	*
	* DXVA2:
	* mfxFrameSurface1.Data.MemId contains a pointer to IDirect3DSurface9
	*
	* FFmpeg 5.0 and above:
	* mfxFrameSurface1.Data.MemId contains a pointer to the mfxHDLPair
	* structure when importing the following frames as QSV frames:
	*
	* VAAPI:
	* mfxHDLPair.first contains a VASurfaceID pointer.
	* mfxHDLPair.second is always MFX_INFINITE.
	*
	* DXVA2:
	* mfxHDLPair.first contains IDirect3DSurface9 pointer.
	* mfxHDLPair.second is always MFX_INFINITE.
	*
	* D3D11:
	* mfxHDLPair.first contains a ID3D11Texture2D pointer.
	* mfxHDLPair.second contains the texture array index of the frame if the
	* ID3D11Texture2D is an array texture, or always MFX_INFINITE if it is a
	* normal texture.
	*/
	QSV            = 114,

	/**
	* HW acceleration though MMAL, data[3] contains a pointer to the
	* MMAL_BUFFER_HEADER_T structure.
	*/
	MMAL           = 115,
	D3D11VA_VLD    = 116, ///< HW decoding through Direct3D11 via old API, Picture.data[3] contains a ID3D11VideoDecoderOutputView pointer

	/**
	* HW acceleration through CUDA. data[i] contain CUdeviceptr pointers
	* exactly as for system memory frames.
	*/
	CUDA           = 117,
	_0RGB          = 118, ///< packed RGB 8:8:8, 32bpp, XRGBXRGB...   X=unused/undefined
	RGB0           = 119, ///< packed RGB 8:8:8, 32bpp, RGBXRGBX...   X=unused/undefined
	_0BGR          = 120, ///< packed BGR 8:8:8, 32bpp, XBGRXBGR...   X=unused/undefined
	BGR0           = 121, ///< packed BGR 8:8:8, 32bpp, BGRXBGRX...   X=unused/undefined
	YUV420P12BE    = 122, ///< planar YUV 4:2:0,18bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
	YUV420P12LE    = 123, ///< planar YUV 4:2:0,18bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
	YUV420P14BE    = 124, ///< planar YUV 4:2:0,21bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
	YUV420P14LE    = 125, ///< planar YUV 4:2:0,21bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
	YUV422P12BE    = 126, ///< planar YUV 4:2:2,24bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
	YUV422P12LE    = 127, ///< planar YUV 4:2:2,24bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
	YUV422P14BE    = 128, ///< planar YUV 4:2:2,28bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
	YUV422P14LE    = 129, ///< planar YUV 4:2:2,28bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
	YUV444P12BE    = 130, ///< planar YUV 4:4:4,36bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
	YUV444P12LE    = 131, ///< planar YUV 4:4:4,36bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
	YUV444P14BE    = 132, ///< planar YUV 4:4:4,42bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
	YUV444P14LE    = 133, ///< planar YUV 4:4:4,42bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
	GBRP12BE       = 134, ///< planar GBR 4:4:4 36bpp, big-endian
	GBRP12LE       = 135, ///< planar GBR 4:4:4 36bpp, little-endian
	GBRP14BE       = 136, ///< planar GBR 4:4:4 42bpp, big-endian
	GBRP14LE       = 137, ///< planar GBR 4:4:4 42bpp, little-endian
	YUVJ411P       = 138, ///< planar YUV 4:1:1, 12bpp, (1 Cr & Cb sample per 4x1 Y samples) full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV411P and setting color_range
	BAYER_BGGR8    = 139, ///< bayer, BGBG..(odd line), GRGR..(even line), 8-bit samples
	BAYER_RGGB8    = 140, ///< bayer, RGRG..(odd line), GBGB..(even line), 8-bit samples
	BAYER_GBRG8    = 141, ///< bayer, GBGB..(odd line), RGRG..(even line), 8-bit samples
	BAYER_GRBG8    = 142, ///< bayer, GRGR..(odd line), BGBG..(even line), 8-bit samples
	BAYER_BGGR16LE = 143, ///< bayer, BGBG..(odd line), GRGR..(even line), 16-bit samples, little-endian
	BAYER_BGGR16BE = 144, ///< bayer, BGBG..(odd line), GRGR..(even line), 16-bit samples, big-endian
	BAYER_RGGB16LE = 145, ///< bayer, RGRG..(odd line), GBGB..(even line), 16-bit samples, little-endian
	BAYER_RGGB16BE = 146, ///< bayer, RGRG..(odd line), GBGB..(even line), 16-bit samples, big-endian
	BAYER_GBRG16LE = 147, ///< bayer, GBGB..(odd line), RGRG..(even line), 16-bit samples, little-endian
	BAYER_GBRG16BE = 148, ///< bayer, GBGB..(odd line), RGRG..(even line), 16-bit samples, big-endian
	BAYER_GRBG16LE = 149, ///< bayer, GRGR..(odd line), BGBG..(even line), 16-bit samples, little-endian
	BAYER_GRBG16BE = 150, ///< bayer, GRGR..(odd line), BGBG..(even line), 16-bit samples, big-endian
	YUV440P10LE    = 151, ///< planar YUV 4:4:0,20bpp, (1 Cr & Cb sample per 1x2 Y samples), little-endian
	YUV440P10BE    = 152, ///< planar YUV 4:4:0,20bpp, (1 Cr & Cb sample per 1x2 Y samples), big-endian
	YUV440P12LE    = 153, ///< planar YUV 4:4:0,24bpp, (1 Cr & Cb sample per 1x2 Y samples), little-endian
	YUV440P12BE    = 154, ///< planar YUV 4:4:0,24bpp, (1 Cr & Cb sample per 1x2 Y samples), big-endian
	AYUV64LE       = 155, ///< packed AYUV 4:4:4,64bpp (1 Cr & Cb sample per 1x1 Y & A samples), little-endian
	AYUV64BE       = 156, ///< packed AYUV 4:4:4,64bpp (1 Cr & Cb sample per 1x1 Y & A samples), big-endian
	VIDEOTOOLBOX   = 157, ///< hardware decoding through Videotoolbox
	P010LE         = 158, ///< like NV12, with 10bpp per component, data in the high bits, zeros in the low bits, little-endian
	P010BE         = 159, ///< like NV12, with 10bpp per component, data in the high bits, zeros in the low bits, big-endian
	GBRAP12BE      = 160, ///< planar GBR 4:4:4:4 48bpp, big-endian
	GBRAP12LE      = 161, ///< planar GBR 4:4:4:4 48bpp, little-endian
	GBRAP10BE      = 162, ///< planar GBR 4:4:4:4 40bpp, big-endian
	GBRAP10LE      = 163, ///< planar GBR 4:4:4:4 40bpp, little-endian
	MEDIACODEC     = 164, ///< hardware decoding through MediaCodec
	GRAY12BE       = 165, ///<        Y        , 12bpp, big-endian
	GRAY12LE       = 166, ///<        Y        , 12bpp, little-endian
	GRAY10BE       = 167, ///<        Y        , 10bpp, big-endian
	GRAY10LE       = 168, ///<        Y        , 10bpp, little-endian
	P016LE         = 169, ///< like NV12, with 16bpp per component, little-endian
	P016BE         = 170, ///< like NV12, with 16bpp per component, big-endian

	/**
	* Hardware surfaces for Direct3D11.
	*
	* This is preferred over the legacy AV_PIX_FMT_D3D11VA_VLD. The new D3D11
	* hwaccel API and filtering support AV_PIX_FMT_D3D11 only.
	*
	* data[0] contains a ID3D11Texture2D pointer, and data[1] contains the
	* texture array index of the frame as intptr_t if the ID3D11Texture2D is
	* an array texture (or always 0 if it's a normal texture).
	*/
	D3D11          = 171,
	GRAY9BE        = 172, ///<        Y        , 9bpp, big-endian
	GRAY9LE        = 173, ///<        Y        , 9bpp, little-endian
	GBRPF32BE      = 174, ///< IEEE-754 single precision planar GBR 4:4:4,     96bpp, big-endian
	GBRPF32LE      = 175, ///< IEEE-754 single precision planar GBR 4:4:4,     96bpp, little-endian
	GBRAPF32BE     = 176, ///< IEEE-754 single precision planar GBRA 4:4:4:4, 128bpp, big-endian
	GBRAPF32LE     = 177, ///< IEEE-754 single precision planar GBRA 4:4:4:4, 128bpp, little-endian

	/**
	* DRM-managed buffers exposed through PRIME buffer sharing.
	*
	* data[0] points to an AVDRMFrameDescriptor.
	*/
	DRM_PRIME      = 178,

	/**
	* Hardware surfaces for OpenCL.
	*
	* data[i] contain 2D image objects (typed in C as cl_mem, used
	* in OpenCL as image2d_t) for each plane of the surface.
	*/
	OPENCL         = 179,
	GRAY14BE       = 180, ///<        Y        , 14bpp, big-endian
	GRAY14LE       = 181, ///<        Y        , 14bpp, little-endian
	GRAYF32BE      = 182, ///< IEEE-754 single precision Y, 32bpp, big-endian
	GRAYF32LE      = 183, ///< IEEE-754 single precision Y, 32bpp, little-endian
	YUVA422P12BE   = 184, ///< planar YUV 4:2:2,24bpp, (1 Cr & Cb sample per 2x1 Y samples), 12b alpha, big-endian
	YUVA422P12LE   = 185, ///< planar YUV 4:2:2,24bpp, (1 Cr & Cb sample per 2x1 Y samples), 12b alpha, little-endian
	YUVA444P12BE   = 186, ///< planar YUV 4:4:4,36bpp, (1 Cr & Cb sample per 1x1 Y samples), 12b alpha, big-endian
	YUVA444P12LE   = 187, ///< planar YUV 4:4:4,36bpp, (1 Cr & Cb sample per 1x1 Y samples), 12b alpha, little-endian
	NV24           = 188, ///< planar YUV 4:4:4, 24bpp, 1 plane for Y and 1 plane for the UV components, which are interleaved (first byte U and the following byte V)
	NV42           = 189, ///< as above, but U and V bytes are swapped

	/**
	* Vulkan hardware images.
	*
	* data[0] points to an AVVkFrame
	*/
	VULKAN         = 190,
	Y210BE         = 191, ///< packed YUV 4:2:2 like YUYV422, 20bpp, data in the high bits, big-endian
	Y210LE         = 192, ///< packed YUV 4:2:2 like YUYV422, 20bpp, data in the high bits, little-endian
	X2RGB10LE      = 193, ///< packed RGB 10:10:10, 30bpp, (msb)2X 10R 10G 10B(lsb), little-endian, X=unused/undefined
	X2RGB10BE      = 194, ///< packed RGB 10:10:10, 30bpp, (msb)2X 10R 10G 10B(lsb), big-endian, X=unused/undefined
	X2BGR10LE      = 195, ///< packed BGR 10:10:10, 30bpp, (msb)2X 10B 10G 10R(lsb), little-endian, X=unused/undefined
	X2BGR10BE      = 196, ///< packed BGR 10:10:10, 30bpp, (msb)2X 10B 10G 10R(lsb), big-endian, X=unused/undefined
	P210BE         = 197, ///< interleaved chroma YUV 4:2:2, 20bpp, data in the high bits, big-endian
	P210LE         = 198, ///< interleaved chroma YUV 4:2:2, 20bpp, data in the high bits, little-endian
	P410BE         = 199, ///< interleaved chroma YUV 4:4:4, 30bpp, data in the high bits, big-endian
	P410LE         = 200, ///< interleaved chroma YUV 4:4:4, 30bpp, data in the high bits, little-endian
	P216BE         = 201, ///< interleaved chroma YUV 4:2:2, 32bpp, big-endian
	P216LE         = 202, ///< interleaved chroma YUV 4:2:2, 32bpp, little-endian
	P416BE         = 203, ///< interleaved chroma YUV 4:4:4, 48bpp, big-endian
	P416LE         = 204, ///< interleaved chroma YUV 4:4:4, 48bpp, little-endian
	VUYA           = 205, ///< packed VUYA 4:4:4:4, 32bpp (1 Cr & Cb sample per 1x1 Y & A samples), VUYAVUYA...
	RGBAF16BE      = 206, ///< IEEE-754 half precision packed RGBA 16:16:16:16, 64bpp, RGBARGBA..., big-endian
	RGBAF16LE      = 207, ///< IEEE-754 half precision packed RGBA 16:16:16:16, 64bpp, RGBARGBA..., little-endian
	VUYX           = 208, ///< packed VUYX 4:4:4:4, 32bpp, Variant of VUYA where alpha channel is left undefined
	P012LE         = 209, ///< like NV12, with 12bpp per component, data in the high bits, zeros in the low bits, little-endian
	P012BE         = 210, ///< like NV12, with 12bpp per component, data in the high bits, zeros in the low bits, big-endian
	Y212BE         = 211, ///< packed YUV 4:2:2 like YUYV422, 24bpp, data in the high bits, zeros in the low bits, big-endian
	Y212LE         = 212, ///< packed YUV 4:2:2 like YUYV422, 24bpp, data in the high bits, zeros in the low bits, little-endian
	XV30BE         = 213, ///< packed XVYU 4:4:4, 32bpp, (msb)2X 10V 10Y 10U(lsb), big-endian, variant of Y410 where alpha channel is left undefined
	XV30LE         = 214, ///< packed XVYU 4:4:4, 32bpp, (msb)2X 10V 10Y 10U(lsb), little-endian, variant of Y410 where alpha channel is left undefined
	XV36BE         = 215, ///< packed XVYU 4:4:4, 48bpp, data in the high bits, zeros in the low bits, big-endian, variant of Y412 where alpha channel is left undefined
	XV36LE         = 216, ///< packed XVYU 4:4:4, 48bpp, data in the high bits, zeros in the low bits, little-endian, variant of Y412 where alpha channel is left undefined
	RGBF32BE       = 217, ///< IEEE-754 single precision packed RGB 32:32:32, 96bpp, RGBRGB..., big-endian
	RGBF32LE       = 218, ///< IEEE-754 single precision packed RGB 32:32:32, 96bpp, RGBRGB..., little-endian
	RGBAF32BE      = 219, ///< IEEE-754 single precision packed RGBA 32:32:32:32, 128bpp, RGBARGBA..., big-endian
	RGBAF32LE      = 220, ///< IEEE-754 single precision packed RGBA 32:32:32:32, 128bpp, RGBARGBA..., little-endian
	P212BE         = 221, ///< interleaved chroma YUV 4:2:2, 24bpp, data in the high bits, big-endian
	P212LE         = 222, ///< interleaved chroma YUV 4:2:2, 24bpp, data in the high bits, little-endian
	P412BE         = 223, ///< interleaved chroma YUV 4:4:4, 36bpp, data in the high bits, big-endian
	P412LE         = 224, ///< interleaved chroma YUV 4:4:4, 36bpp, data in the high bits, little-endian
	GBRAP14BE      = 225, ///< planar GBR 4:4:4:4 56bpp, big-endian
	GBRAP14LE      = 226, ///< planar GBR 4:4:4:4 56bpp, little-endian

	/**
	* Hardware surfaces for Direct3D 12.
	*
	* data[0] points to an AVD3D12VAFrame
	*/
	D3D12          = 227,
	AYUV           = 228, ///< packed AYUV 4:4:4:4, 32bpp (1 Cr & Cb sample per 1x1 Y & A samples), AYUVAYUV...
	UYVA           = 229, ///< packed UYVA 4:4:4:4, 32bpp (1 Cr & Cb sample per 1x1 Y & A samples), UYVAUYVA...
	VYU444         = 230, ///< packed VYU 4:4:4, 24bpp (1 Cr & Cb sample per 1x1 Y), VYUVYU...
	V30XBE         = 231, ///< packed VYUX 4:4:4 like XV30, 32bpp, (msb)10V 10Y 10U 2X(lsb), big-endian
	V30XLE         = 232, ///< packed VYUX 4:4:4 like XV30, 32bpp, (msb)10V 10Y 10U 2X(lsb), little-endian
	RGBF16BE       = 233, ///< IEEE-754 half precision packed RGB 16:16:16, 48bpp, RGBRGB..., big-endian
	RGBF16LE       = 234, ///< IEEE-754 half precision packed RGB 16:16:16, 48bpp, RGBRGB..., little-endian
	RGBA128BE      = 235, ///< packed RGBA 32:32:32:32, 128bpp, RGBARGBA..., big-endian
	RGBA128LE      = 236, ///< packed RGBA 32:32:32:32, 128bpp, RGBARGBA..., little-endian
	RGB96BE        = 237, ///< packed RGBA 32:32:32, 96bpp, RGBRGB..., big-endian
	RGB96LE        = 238, ///< packed RGBA 32:32:32, 96bpp, RGBRGB..., little-endian
	Y216BE         = 239, ///< packed YUV 4:2:2 like YUYV422, 32bpp, big-endian
	Y216LE         = 240, ///< packed YUV 4:2:2 like YUYV422, 32bpp, little-endian
	XV48BE         = 241, ///< packed XVYU 4:4:4, 64bpp, big-endian, variant of Y416 where alpha channel is left undefined
	XV48LE         = 242, ///< packed XVYU 4:4:4, 64bpp, little-endian, variant of Y416 where alpha channel is left undefined
	GBRPF16BE      = 243, ///< IEEE-754 half precision planer GBR 4:4:4, 48bpp, big-endian
	GBRPF16LE      = 244, ///< IEEE-754 half precision planer GBR 4:4:4, 48bpp, little-endian
	GBRAPF16BE     = 245, ///< IEEE-754 half precision planar GBRA 4:4:4:4, 64bpp, big-endian
	GBRAPF16LE     = 246, ///< IEEE-754 half precision planar GBRA 4:4:4:4, 64bpp, little-endian
	GRAYF16BE      = 247, ///< IEEE-754 half precision Y, 16bpp, big-endian
	GRAYF16LE      = 248, ///< IEEE-754 half precision Y, 16bpp, little-endian

	/**
	* HW acceleration through AMF. data[0] contain AMFSurface pointer
	*/
	AMF_SURFACE    = 249,
	GRAY32BE       = 250, ///<         Y        , 32bpp, big-endian
	GRAY32LE       = 251, ///<         Y        , 32bpp, little-endian
	YAF32BE        = 252, ///< IEEE-754 single precision packed YA, 32 bits gray, 32 bits alpha, 64bpp, big-endian
	YAF32LE        = 253, ///< IEEE-754 single precision packed YA, 32 bits gray, 32 bits alpha, 64bpp, little-endian
	YAF16BE        = 254, ///< IEEE-754 half precision packed YA, 16 bits gray, 16 bits alpha, 32bpp, big-endian
	YAF16LE        = 255, ///< IEEE-754 half precision packed YA, 16 bits gray, 16 bits alpha, 32bpp, little-endian
	GBRAP32BE      = 256, ///< planar GBRA 4:4:4:4 128bpp, big-endian
	GBRAP32LE      = 257, ///< planar GBRA 4:4:4:4 128bpp, little-endian
	YUV444P10MSBBE = 258, ///< planar YUV 4:4:4, 30bpp, (1 Cr & Cb sample per 1x1 Y samples), lowest bits zero, big-endian
	YUV444P10MSBLE = 259, ///< planar YUV 4:4:4, 30bpp, (1 Cr & Cb sample per 1x1 Y samples), lowest bits zero, little-endian
	YUV444P12MSBBE = 260, ///< planar YUV 4:4:4, 30bpp, (1 Cr & Cb sample per 1x1 Y samples), lowest bits zero, big-endian
	YUV444P12MSBLE = 261, ///< planar YUV 4:4:4, 30bpp, (1 Cr & Cb sample per 1x1 Y samples), lowest bits zero, little-endian
	GBRP10MSBBE    = 262, ///< planar GBR 4:4:4 30bpp, lowest bits zero, big-endian
	GBRP10MSBLE    = 263, ///< planar GBR 4:4:4 30bpp, lowest bits zero, little-endian
	GBRP12MSBBE    = 264, ///< planar GBR 4:4:4 36bpp, lowest bits zero, big-endian
	GBRP12MSBLE    = 265, ///< planar GBR 4:4:4 36bpp, lowest bits zero, little-endian
	OHCODEC        = 266, /// hardware decoding through openharmony
	NB             = 267, ///< number of pixel formats, DO NOT USE THIS if you want to link with shared libav* because the number of formats might differ between versions
}

/**
* Chromaticity coordinates of the source primaries.
* These values match the ones defined by ISO/IEC 23091-2_2019 subclause 8.1 and ITU-T H.273.
*/
AVColorPrimaries :: enum i32 {
	RESERVED0    = 0,
	BT709        = 1,  ///< also ITU-R BT1361 / IEC 61966-2-4 / SMPTE RP 177 Annex B
	UNSPECIFIED  = 2,
	RESERVED     = 3,
	BT470M       = 4,  ///< also FCC Title 47 Code of Federal Regulations 73.682 (a)(20)
	BT470BG      = 5,  ///< also ITU-R BT601-6 625 / ITU-R BT1358 625 / ITU-R BT1700 625 PAL & SECAM
	SMPTE170M    = 6,  ///< also ITU-R BT601-6 525 / ITU-R BT1358 525 / ITU-R BT1700 NTSC
	SMPTE240M    = 7,  ///< identical to above, also called "SMPTE C" even though it uses D65
	FILM         = 8,  ///< colour filters using Illuminant C
	BT2020       = 9,  ///< ITU-R BT2020
	SMPTE428     = 10, ///< SMPTE ST 428-1 (CIE 1931 XYZ)
	SMPTEST428_1 = 10,
	SMPTE431     = 11, ///< SMPTE ST 431-2 (2011) / DCI P3
	SMPTE432     = 12, ///< SMPTE ST 432-1 (2010) / P3 D65 / Display P3
	EBU3213      = 22, ///< EBU Tech. 3213-E (nothing there) / one of JEDEC P22 group phosphors
	JEDEC_P22    = 22,
	NB           = 23, ///< Not part of ABI
}

/**
* Color Transfer Characteristic.
* These values match the ones defined by ISO/IEC 23091-2_2019 subclause 8.2.
*/
AVColorTransferCharacteristic :: enum i32 {
	RESERVED0    = 0,
	BT709        = 1,  ///< also ITU-R BT1361
	UNSPECIFIED  = 2,
	RESERVED     = 3,
	GAMMA22      = 4,  ///< also ITU-R BT470M / ITU-R BT1700 625 PAL & SECAM
	GAMMA28      = 5,  ///< also ITU-R BT470BG
	SMPTE170M    = 6,  ///< also ITU-R BT601-6 525 or 625 / ITU-R BT1358 525 or 625 / ITU-R BT1700 NTSC
	SMPTE240M    = 7,
	LINEAR       = 8,  ///< "Linear transfer characteristics"
	LOG          = 9,  ///< "Logarithmic transfer characteristic (100:1 range)"
	LOG_SQRT     = 10, ///< "Logarithmic transfer characteristic (100 * Sqrt(10) : 1 range)"
	IEC61966_2_4 = 11, ///< IEC 61966-2-4
	BT1361_ECG   = 12, ///< ITU-R BT1361 Extended Colour Gamut
	IEC61966_2_1 = 13, ///< IEC 61966-2-1 (sRGB or sYCC)
	BT2020_10    = 14, ///< ITU-R BT2020 for 10-bit system
	BT2020_12    = 15, ///< ITU-R BT2020 for 12-bit system
	SMPTE2084    = 16, ///< SMPTE ST 2084 for 10-, 12-, 14- and 16-bit systems
	SMPTEST2084  = 16,
	SMPTE428     = 17, ///< SMPTE ST 428-1
	SMPTEST428_1 = 17,
	ARIB_STD_B67 = 18, ///< ARIB STD-B67, known as "Hybrid log-gamma"
	NB           = 19, ///< Not part of ABI
}

/**
* YUV colorspace type.
* These values match the ones defined by ISO/IEC 23091-2_2019 subclause 8.3.
*/
AVColorSpace :: enum i32 {
	RGB                = 0,  ///< order of coefficients is actually GBR, also IEC 61966-2-1 (sRGB), YZX and ST 428-1
	BT709              = 1,  ///< also ITU-R BT1361 / IEC 61966-2-4 xvYCC709 / derived in SMPTE RP 177 Annex B
	UNSPECIFIED        = 2,
	RESERVED           = 3,  ///< reserved for future use by ITU-T and ISO/IEC just like 15-255 are
	FCC                = 4,  ///< FCC Title 47 Code of Federal Regulations 73.682 (a)(20)
	BT470BG            = 5,  ///< also ITU-R BT601-6 625 / ITU-R BT1358 625 / ITU-R BT1700 625 PAL & SECAM / IEC 61966-2-4 xvYCC601
	SMPTE170M          = 6,  ///< also ITU-R BT601-6 525 / ITU-R BT1358 525 / ITU-R BT1700 NTSC / functionally identical to above
	SMPTE240M          = 7,  ///< derived from 170M primaries and D65 white point, 170M is derived from BT470 System M's primaries
	YCGCO              = 8,  ///< used by Dirac / VC-2 and H.264 FRext, see ITU-T SG16
	YCOCG              = 8,
	BT2020_NCL         = 9,  ///< ITU-R BT2020 non-constant luminance system
	BT2020_CL          = 10, ///< ITU-R BT2020 constant luminance system
	SMPTE2085          = 11, ///< SMPTE 2085, Y'D'zD'x
	CHROMA_DERIVED_NCL = 12, ///< Chromaticity-derived non-constant luminance system
	CHROMA_DERIVED_CL  = 13, ///< Chromaticity-derived constant luminance system
	ICTCP              = 14, ///< ITU-R BT.2100-0, ICtCp
	IPT_C2             = 15, ///< SMPTE ST 2128, IPT-C2
	YCGCO_RE           = 16, ///< YCgCo-R, even addition of bits
	YCGCO_RO           = 17, ///< YCgCo-R, odd addition of bits
	NB                 = 18, ///< Not part of ABI
}

/**
* Visual content value range.
*
* These values are based on definitions that can be found in multiple
* specifications, such as ITU-T BT.709 (3.4 - Quantization of RGB, luminance
* and colour-difference signals), ITU-T BT.2020 (Table 5 - Digital
* Representation) as well as ITU-T BT.2100 (Table 9 - Digital 10- and 12-bit
* integer representation). At the time of writing, the BT.2100 one is
* recommended, as it also defines the full range representation.
*
* Common definitions:
*   - For RGB and luma planes such as Y in YCbCr and I in ICtCp,
*     'E' is the original value in range of 0.0 to 1.0.
*   - For chroma planes such as Cb,Cr and Ct,Cp, 'E' is the original
*     value in range of -0.5 to 0.5.
*   - 'n' is the output bit depth.
*   - For additional definitions such as rounding and clipping to valid n
*     bit unsigned integer range, please refer to BT.2100 (Table 9).
*/
AVColorRange :: enum i32 {
	UNSPECIFIED = 0,

	/**
	* Narrow or limited range content.
	*
	* - For luma planes:
	*
	*       (219 * E + 16) * 2^(n-8)
	*
	*   F.ex. the range of 16-235 for 8 bits
	*
	* - For chroma planes:
	*
	*       (224 * E + 128) * 2^(n-8)
	*
	*   F.ex. the range of 16-240 for 8 bits
	*/
	MPEG        = 1,

	/**
	* Full range content.
	*
	* - For RGB and luma planes:
	*
	*       (2^n - 1) * E
	*
	*   F.ex. the range of 0-255 for 8 bits
	*
	* - For chroma planes:
	*
	*       (2^n - 1) * E + 2^(n - 1)
	*
	*   F.ex. the range of 1-255 for 8 bits
	*/
	JPEG        = 2,
	NB          = 3, ///< Not part of ABI
}

/**
* Location of chroma samples.
*
* Illustration showing the location of the first (top left) chroma sample of the
* image, the left shows only luma, the right
* shows the location of the chroma sample, the 2 could be imagined to overlay
* each other but are drawn separately due to limitations of ASCII
*
*                1st 2nd       1st 2nd horizontal luma sample positions
*                 v   v         v   v
*                 ______        ______
*1st luma line > |X   X ...    |3 4 X ...     X are luma samples,
*                |             |1 2           1-6 are possible chroma positions
*2nd luma line > |X   X ...    |5 6 X ...     0 is undefined/unknown position
*/
AVChromaLocation :: enum i32 {
	UNSPECIFIED = 0,
	LEFT        = 1, ///< MPEG-2/4 4:2:0, H.264 default for 4:2:0
	CENTER      = 2, ///< MPEG-1 4:2:0, JPEG 4:2:0, H.263 4:2:0
	TOPLEFT     = 3, ///< ITU-R 601, SMPTE 274M 296M S314M(DV 4:1:1), mpeg2 4:2:2
	TOP         = 4,
	BOTTOMLEFT  = 5,
	BOTTOM      = 6,
	NB          = 7, ///< Not part of ABI
}

