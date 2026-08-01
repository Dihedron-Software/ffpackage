/*
 * Copyright (C) 2024 Niklas Haas
 * Copyright (C) 2001-2011 Michael Niedermayer <michaelni@gmx.at>
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
    foreign import lib "lib/swscale.lib"
} else when ODIN_OS == .Darwin {
    @(extra_linker_flags = "-L/opt/homebrew/lib")
    foreign import lib "system:swscale"
}

@(default_calling_convention="c")
foreign lib {
	/**
	* @defgroup libsws libswscale
	* Color conversion and scaling library.
	*
	* @{
	*
	* Return the LIBSWSCALE_VERSION_INT constant.
	*/
	swscale_version :: proc() -> u32 ---

	/**
	* Return the libswscale build-time configuration.
	*/
	swscale_configuration :: proc() -> cstring ---

	/**
	* Return the libswscale license.
	*/
	swscale_license :: proc() -> cstring ---

	/**
	* Get the AVClass for SwsContext. It can be used in combination with
	* AV_OPT_SEARCH_FAKE_OBJ for examining options.
	*
	* @see av_opt_find().
	*/
	sws_get_class :: proc() -> ^i32 ---
}

/******************************
* Flags and quality settings *
******************************/
SwsDither :: enum i32 {
	NONE     = 0, /* disable dithering */
	AUTO     = 1, /* auto-select from preset */
	BAYER    = 2, /* ordered dither matrix */
	ED       = 3, /* error diffusion */
	A_DITHER = 4, /* arithmetic addition */
	X_DITHER = 5, /* arithmetic xor */
	NB       = 6, /* not part of the ABI */
}

SwsAlphaBlend :: enum i32 {
	NONE         = 0,
	UNIFORM      = 1,
	CHECKERBOARD = 2,
	NB           = 3, /* not part of the ABI */
}

SwsFlags :: enum i32 {
	/**
	* Scaler selection options. Only one may be active at a time.
	*/
	FAST_BILINEAR   = 1,       ///< fast bilinear filtering
	BILINEAR        = 2,       ///< bilinear filtering
	BICUBIC         = 4,       ///< 2-tap cubic B-spline
	X               = 8,       ///< experimental
	POINT           = 16,      ///< nearest neighbor
	AREA            = 32,      ///< area averaging
	BICUBLIN        = 64,      ///< bicubic luma, bilinear chroma
	GAUSS           = 128,     ///< gaussian approximation
	SINC            = 256,     ///< unwindowed sinc
	LANCZOS         = 512,     ///< 3-tap sinc/sinc
	SPLINE          = 1024,    ///< cubic Keys spline

	/**
	* Return an error on underspecified conversions. Without this flag,
	* unspecified fields are defaulted to sensible values.
	*/
	STRICT          = 2048,

	/**
	* Emit verbose log of scaling parameters.
	*/
	PRINT_INFO      = 4096,

	/**
	* Perform full chroma upsampling when upscaling to RGB.
	*
	* For example, when converting 50x50 yuv420p to 100x100 rgba, setting this flag
	* will scale the chroma plane from 25x25 to 100x100 (4:4:4), and then convert
	* the 100x100 yuv444p image to rgba in the final output step.
	*
	* Without this flag, the chroma plane is instead scaled to 50x100 (4:2:2),
	* with a single chroma sample being reused for both of the horizontally
	* adjacent RGBA output pixels.
	*/
	FULL_CHR_H_INT  = 8192,

	/**
	* Perform full chroma interpolation when downscaling RGB sources.
	*
	* For example, when converting a 100x100 rgba source to 50x50 yuv444p, setting
	* this flag will generate a 100x100 (4:4:4) chroma plane, which is then
	* downscaled to the required 50x50.
	*
	* Without this flag, the chroma plane is instead generated at 50x100 (dropping
	* every other pixel), before then being downscaled to the required 50x50
	* resolution.
	*/
	FULL_CHR_H_INP  = 16384,

	/**
	* Force bit-exact output. This will prevent the use of platform-specific
	* optimizations that may lead to slight difference in rounding, in favor
	* of always maintaining exact bit output compatibility with the reference
	* C code.
	*
	* Note: It is recommended to set both of these flags simultaneously.
	*/
	ACCURATE_RND    = 262144,
	BITEXACT        = 524288,

	/**
	* Deprecated flags.
	*/
	DIRECT_BGR      = 32768,   ///< This flag has no effect
	ERROR_DIFFUSION = 8388608, ///< Set `SwsContext.dither` instead
}

SwsIntent :: enum i32 {
	PERCEPTUAL            = 0, ///< Perceptual tone mapping
	RELATIVE_COLORIMETRIC = 1, ///< Relative colorimetric clipping
	SATURATION            = 2, ///< Saturation mapping
	ABSOLUTE_COLORIMETRIC = 3, ///< Absolute colorimetric clipping
	NB                    = 4, ///< not part of the ABI
}

/**
* Main external API structure. New fields can be added to the end with
* minor version bumps. Removal, reordering and changes to existing fields
* require a major version bump. sizeof(SwsContext) is not part of the ABI.
*/
SwsContext :: struct {
	av_class: ^i32,

	/**
	* Private data of the user, can be used to carry app specific stuff.
	*/
	opaque: rawptr,

	/**
	* Bitmask of SWS_*. See `SwsFlags` for details.
	*/
	flags: u32,

	/**
	* Extra parameters for fine-tuning certain scalers.
	*/
	scaler_params: [2]f64,

	/**
	* How many threads to use for processing, or 0 for automatic selection.
	*/
	threads: i32,

	/**
	* Dither mode.
	*/
	dither: SwsDither,

	/**
	* Alpha blending mode. See `SwsAlphaBlend` for details.
	*/
	alpha_blend: SwsAlphaBlend,

	/**
	* Use gamma correct scaling.
	*/
	gamma_flag: i32,

	/**
	* Deprecated frame property overrides, for the legacy API only.
	*
	* Ignored by sws_scale_frame() when used in dynamic mode, in which
	* case all properties are instead taken from the frame directly.
	*/
	src_w, src_h:  i32, ///< Width and height of the source frame
	dst_w, dst_h:  i32, ///< Width and height of the destination frame
	src_format:    i32, ///< Source pixel format
	dst_format:    i32, ///< Destination pixel format
	src_range:     i32, ///< Source is full range
	dst_range:     i32, ///< Destination is full range
	src_v_chr_pos: i32, ///< Source vertical chroma position in luma grid / 256
	src_h_chr_pos: i32, ///< Source horizontal chroma position
	dst_v_chr_pos: i32, ///< Destination vertical chroma position
	dst_h_chr_pos: i32, ///< Destination horizontal chroma position

	/**
	* Desired ICC intent for color space conversions.
	*/
	intent: i32,
}

@(default_calling_convention="c")
foreign lib {
	/**
	* Allocate an empty SwsContext and set its fields to default values.
	*/
	sws_alloc_context :: proc() -> ^SwsContext ---

	/**
	* Free the context and everything associated with it, and write NULL
	* to the provided pointer.
	*/
	sws_free_context :: proc(ctx: ^^SwsContext) ---

	/**
	* Test if a given pixel format is supported.
	*
	* @param output  If 0, test if compatible with the source/input frame;
	*                otherwise, with the destination/output frame.
	* @param format  The format to check.
	*
	* @return A positive integer if supported, 0 otherwise.
	*/
	sws_test_format :: proc(format: AVPixelFormat, output: i32) -> i32 ---

	/**
	* Test if a given color space is supported.
	*
	* @param output  If 0, test if compatible with the source/input frame;
	*                otherwise, with the destination/output frame.
	* @param colorspace The colorspace to check.
	*
	* @return A positive integer if supported, 0 otherwise.
	*/
	sws_test_colorspace :: proc(colorspace: AVColorSpace, output: i32) -> i32 ---

	/**
	* Test if a given set of color primaries is supported.
	*
	* @param output  If 0, test if compatible with the source/input frame;
	*                otherwise, with the destination/output frame.
	* @param primaries The color primaries to check.
	*
	* @return A positive integer if supported, 0 otherwise.
	*/
	sws_test_primaries :: proc(primaries: AVColorPrimaries, output: i32) -> i32 ---

	/**
	* Test if a given color transfer function is supported.
	*
	* @param output  If 0, test if compatible with the source/input frame;
	*                otherwise, with the destination/output frame.
	* @param trc     The color transfer function to check.
	*
	* @return A positive integer if supported, 0 otherwise.
	*/
	sws_test_transfer :: proc(trc: AVColorTransferCharacteristic, output: i32) -> i32 ---

	/**
	* Helper function to run all sws_test_* against a frame, as well as testing
	* the basic frame properties for sanity. Ignores irrelevant properties - for
	* example, AVColorSpace is not checked for RGB frames.
	*/
	sws_test_frame :: proc(frame: ^i32, output: i32) -> i32 ---

	/**
	* Like `sws_scale_frame`, but without actually scaling. It will instead
	* merely initialize internal state that *would* be required to perform the
	* operation, as well as returning the correct error code for unsupported
	* frame combinations.
	*
	* @param ctx   The scaling context.
	* @param dst   The destination frame to consider.
	* @param src   The source frame to consider.
	* @return 0 on success, a negative AVERROR code on failure.
	*/
	sws_frame_setup :: proc(ctx: ^SwsContext, dst: ^i32, src: ^i32) -> i32 ---

	/**
	* Check if a given conversion is a noop. Returns a positive integer if
	* no operation needs to be performed, 0 otherwise.
	*/
	sws_is_noop :: proc(dst: ^i32, src: ^i32) -> i32 ---

	/**
	* Scale source data from `src` and write the output to `dst`.
	*
	* This function can be used directly on an allocated context, without setting
	* up any frame properties or calling `sws_init_context()`. Such usage is fully
	* dynamic and does not require reallocation if the frame properties change.
	*
	* Alternatively, this function can be called on a context that has been
	* explicitly initialized. However, this is provided only for backwards
	* compatibility. In this usage mode, all frame properties must be correctly
	* set at init time, and may no longer change after initialization.
	*
	* @param ctx   The scaling context.
	* @param dst   The destination frame. The data buffers may either be already
	*              allocated by the caller or left clear, in which case they will
	*              be allocated by the scaler. The latter may have performance
	*              advantages - e.g. in certain cases some (or all) output planes
	*              may be references to input planes, rather than copies.
	* @param src   The source frame. If the data buffers are set to NULL, then
	*              this function behaves identically to `sws_frame_setup`.
	* @return >= 0 on success, a negative AVERROR code on failure.
	*/
	sws_scale_frame :: proc(_c: ^SwsContext, dst: ^i32, src: ^i32) -> i32 ---
}

/*************************
* Legacy (stateful) API *
*************************/
SWS_SRC_V_CHR_DROP_MASK     :: 0x30000
SWS_SRC_V_CHR_DROP_SHIFT    :: 16
SWS_PARAM_DEFAULT           :: 123456
SWS_MAX_REDUCE_CUTOFF    :: 0.002
SWS_CS_ITU709            :: 1
SWS_CS_FCC               :: 4
SWS_CS_ITU601            :: 5
SWS_CS_ITU624            :: 5
SWS_CS_SMPTE170M         :: 5
SWS_CS_SMPTE240M         :: 7
SWS_CS_DEFAULT           :: 5
SWS_CS_BT2020            :: 9

@(default_calling_convention="c")
foreign lib {
	/**
	* Return a pointer to yuv<->rgb coefficients for the given colorspace
	* suitable for sws_setColorspaceDetails().
	*
	* @param colorspace One of the SWS_CS_* macros. If invalid,
	* SWS_CS_DEFAULT is used.
	*/
	sws_getCoefficients :: proc(colorspace: i32) -> ^i32 ---
}

// when used for filters they must have an odd number of elements
// coeffs cannot be shared between vectors
SwsVector :: struct {
	coeff:  ^f64, ///< pointer to the list of coefficients
	length: i32,  ///< number of coefficients in the vector
}

// vectors can be shared
SwsFilter :: struct {
	lumH: ^SwsVector,
	lumV: ^SwsVector,
	chrH: ^SwsVector,
	chrV: ^SwsVector,
}

@(default_calling_convention="c")
foreign lib {
	/**
	* Return a positive value if pix_fmt is a supported input format, 0
	* otherwise.
	*/
	sws_isSupportedInput :: proc(pix_fmt: AVPixelFormat) -> i32 ---

	/**
	* Return a positive value if pix_fmt is a supported output format, 0
	* otherwise.
	*/
	sws_isSupportedOutput :: proc(pix_fmt: AVPixelFormat) -> i32 ---

	/**
	* @param[in]  pix_fmt the pixel format
	* @return a positive value if an endianness conversion for pix_fmt is
	* supported, 0 otherwise.
	*/
	sws_isSupportedEndiannessConversion :: proc(pix_fmt: AVPixelFormat) -> i32 ---

	/**
	* Initialize the swscaler context sws_context.
	*
	* This function is considered deprecated, and provided only for backwards
	* compatibility with sws_scale() and sws_start_frame(). The preferred way to
	* use libswscale is to set all frame properties correctly and call
	* sws_scale_frame() directly, without explicitly initializing the context.
	*
	* @return zero or positive value on success, a negative value on
	* error
	*/
	sws_init_context :: proc(sws_context: ^SwsContext, srcFilter: ^SwsFilter, dstFilter: ^SwsFilter) -> i32 ---

	/**
	* Free the swscaler context swsContext.
	* If swsContext is NULL, then does nothing.
	*/
	sws_freeContext :: proc(swsContext: ^SwsContext) ---

	/**
	* Allocate and return an SwsContext. You need it to perform
	* scaling/conversion operations using sws_scale().
	*
	* @param srcW the width of the source image
	* @param srcH the height of the source image
	* @param srcFormat the source image format
	* @param dstW the width of the destination image
	* @param dstH the height of the destination image
	* @param dstFormat the destination image format
	* @param flags specify which algorithm and options to use for rescaling
	* @param param extra parameters to tune the used scaler
	*              For SWS_BICUBIC param[0] and [1] tune the shape of the basis
	*              function, param[0] tunes f(1) and param[1] f´(1)
	*              For SWS_GAUSS param[0] tunes the exponent and thus cutoff
	*              frequency
	*              For SWS_LANCZOS param[0] tunes the width of the window function
	* @return a pointer to an allocated context, or NULL in case of error
	* @note this function is to be removed after a saner alternative is
	*       written
	*/
	sws_getContext :: proc(srcW: i32, srcH: i32, srcFormat: AVPixelFormat, dstW: i32, dstH: i32, dstFormat: AVPixelFormat, flags: i32, srcFilter: ^SwsFilter, dstFilter: ^SwsFilter, param: ^f64) -> ^SwsContext ---

	/**
	* Scale the image slice in srcSlice and put the resulting scaled
	* slice in the image in dst. A slice is a sequence of consecutive
	* rows in an image. Requires a context that has been previously
	* been initialized with sws_init_context().
	*
	* Slices have to be provided in sequential order, either in
	* top-bottom or bottom-top order. If slices are provided in
	* non-sequential order the behavior of the function is undefined.
	*
	* @param c         the scaling context previously created with
	*                  sws_getContext()
	* @param srcSlice  the array containing the pointers to the planes of
	*                  the source slice
	* @param srcStride the array containing the strides for each plane of
	*                  the source image
	* @param srcSliceY the position in the source image of the slice to
	*                  process, that is the number (counted starting from
	*                  zero) in the image of the first row of the slice
	* @param srcSliceH the height of the source slice, that is the number
	*                  of rows in the slice
	* @param dst       the array containing the pointers to the planes of
	*                  the destination image
	* @param dstStride the array containing the strides for each plane of
	*                  the destination image
	* @return          the height of the output slice
	*/
	sws_scale :: proc(_c: ^SwsContext, srcSlice: [^]^u8, srcStride: [^]i32, srcSliceY: i32, srcSliceH: i32, dst: [^]^u8, dstStride: [^]i32) -> i32 ---

	/**
	* Initialize the scaling process for a given pair of source/destination frames.
	* Must be called before any calls to sws_send_slice() and sws_receive_slice().
	* Requires a context that has been previously been initialized with
	* sws_init_context().
	*
	* This function will retain references to src and dst, so they must both use
	* refcounted buffers (if allocated by the caller, in case of dst).
	*
	* @param c   The scaling context
	* @param dst The destination frame.
	*
	*            The data buffers may either be already allocated by the caller or
	*            left clear, in which case they will be allocated by the scaler.
	*            The latter may have performance advantages - e.g. in certain cases
	*            some output planes may be references to input planes, rather than
	*            copies.
	*
	*            Output data will be written into this frame in successful
	*            sws_receive_slice() calls.
	* @param src The source frame. The data buffers must be allocated, but the
	*            frame data does not have to be ready at this point. Data
	*            availability is then signalled by sws_send_slice().
	* @return 0 on success, a negative AVERROR code on failure
	*
	* @see sws_frame_end()
	*/
	sws_frame_start :: proc(_c: ^SwsContext, dst: ^i32, src: ^i32) -> i32 ---

	/**
	* Finish the scaling process for a pair of source/destination frames previously
	* submitted with sws_frame_start(). Must be called after all sws_send_slice()
	* and sws_receive_slice() calls are done, before any new sws_frame_start()
	* calls.
	*
	* @param c   The scaling context
	*/
	sws_frame_end :: proc(_c: ^SwsContext) ---

	/**
	* Indicate that a horizontal slice of input data is available in the source
	* frame previously provided to sws_frame_start(). The slices may be provided in
	* any order, but may not overlap. For vertically subsampled pixel formats, the
	* slices must be aligned according to subsampling.
	*
	* @param c   The scaling context
	* @param slice_start first row of the slice
	* @param slice_height number of rows in the slice
	*
	* @return a non-negative number on success, a negative AVERROR code on failure.
	*/
	sws_send_slice :: proc(_c: ^SwsContext, slice_start: u32, slice_height: u32) -> i32 ---

	/**
	* Request a horizontal slice of the output data to be written into the frame
	* previously provided to sws_frame_start().
	*
	* @param c   The scaling context
	* @param slice_start first row of the slice; must be a multiple of
	*                    sws_receive_slice_alignment()
	* @param slice_height number of rows in the slice; must be a multiple of
	*                     sws_receive_slice_alignment(), except for the last slice
	*                     (i.e. when slice_start+slice_height is equal to output
	*                     frame height)
	*
	* @return a non-negative number if the data was successfully written into the output
	*         AVERROR(EAGAIN) if more input data needs to be provided before the
	*                         output can be produced
	*         another negative AVERROR code on other kinds of scaling failure
	*/
	sws_receive_slice :: proc(_c: ^SwsContext, slice_start: u32, slice_height: u32) -> i32 ---

	/**
	* Get the alignment required for slices. Requires a context that has been
	* previously been initialized with sws_init_context().
	*
	* @param c   The scaling context
	* @return alignment required for output slices requested with sws_receive_slice().
	*         Slice offsets and sizes passed to sws_receive_slice() must be
	*         multiples of the value returned from this function.
	*/
	sws_receive_slice_alignment :: proc(_c: ^SwsContext) -> u32 ---

	/**
	* @param c the scaling context
	* @param dstRange flag indicating the while-black range of the output (1=jpeg / 0=mpeg)
	* @param srcRange flag indicating the while-black range of the input (1=jpeg / 0=mpeg)
	* @param table the yuv2rgb coefficients describing the output yuv space, normally ff_yuv2rgb_coeffs[x]
	* @param inv_table the yuv2rgb coefficients describing the input yuv space, normally ff_yuv2rgb_coeffs[x]
	* @param brightness 16.16 fixed point brightness correction
	* @param contrast 16.16 fixed point contrast correction
	* @param saturation 16.16 fixed point saturation correction
	*
	* @return A negative error code on error, non negative otherwise.
	*         If `LIBSWSCALE_VERSION_MAJOR < 7`, returns -1 if not supported.
	*/
	sws_setColorspaceDetails :: proc(_c: ^SwsContext, inv_table: ^[4]i32, srcRange: i32, table: ^[4]i32, dstRange: i32, brightness: i32, contrast: i32, saturation: i32) -> i32 ---

	/**
	* @return A negative error code on error, non negative otherwise.
	*         If `LIBSWSCALE_VERSION_MAJOR < 7`, returns -1 if not supported.
	*/
	sws_getColorspaceDetails :: proc(_c: ^SwsContext, inv_table: ^^i32, srcRange: ^i32, table: ^^i32, dstRange: ^i32, brightness: ^i32, contrast: ^i32, saturation: ^i32) -> i32 ---

	/**
	* Allocate and return an uninitialized vector with length coefficients.
	*/
	sws_allocVec :: proc(length: i32) -> ^SwsVector ---

	/**
	* Return a normalized Gaussian curve used to filter stuff
	* quality = 3 is high quality, lower is lower quality.
	*/
	sws_getGaussianVec :: proc(variance: f64, quality: f64) -> ^SwsVector ---

	/**
	* Scale all the coefficients of a by the scalar value.
	*/
	sws_scaleVec :: proc(a: ^SwsVector, scalar: f64) ---

	/**
	* Scale all the coefficients of a so that their sum equals height.
	*/
	sws_normalizeVec     :: proc(a: ^SwsVector, height: f64) ---
	sws_freeVec          :: proc(a: ^SwsVector) ---
	sws_getDefaultFilter :: proc(lumaGBlur: f32, chromaGBlur: f32, lumaSharpen: f32, chromaSharpen: f32, chromaHShift: f32, chromaVShift: f32, verbose: i32) -> ^SwsFilter ---
	sws_freeFilter       :: proc(filter: ^SwsFilter) ---

	/**
	* Check if context can be reused, otherwise reallocate a new one.
	*
	* If context is NULL, just calls sws_getContext() to get a new
	* context. Otherwise, checks if the parameters are the ones already
	* saved in context. If that is the case, returns the current
	* context. Otherwise, frees context and gets a new context with
	* the new parameters.
	*
	* Be warned that srcFilter and dstFilter are not checked, they
	* are assumed to remain the same.
	*/
	sws_getCachedContext :: proc(_context: ^SwsContext, srcW: i32, srcH: i32, srcFormat: AVPixelFormat, dstW: i32, dstH: i32, dstFormat: AVPixelFormat, flags: i32, srcFilter: ^SwsFilter, dstFilter: ^SwsFilter, param: ^f64) -> ^SwsContext ---

	/**
	* Convert an 8-bit paletted frame into a frame with a color depth of 32 bits.
	*
	* The output frame will have the same packed format as the palette.
	*
	* @param src        source frame buffer
	* @param dst        destination frame buffer
	* @param num_pixels number of pixels to convert
	* @param palette    array with [256] entries, which must match color arrangement (RGB or BGR) of src
	*/
	sws_convertPalette8ToPacked32 :: proc(src: ^u8, dst: ^u8, num_pixels: i32, palette: ^u8) ---

	/**
	* Convert an 8-bit paletted frame into a frame with a color depth of 24 bits.
	*
	* With the palette format "ABCD", the destination frame ends up with the format "ABC".
	*
	* @param src        source frame buffer
	* @param dst        destination frame buffer
	* @param num_pixels number of pixels to convert
	* @param palette    array with [256] entries, which must match color arrangement (RGB or BGR) of src
	*/
	sws_convertPalette8ToPacked24 :: proc(src: ^u8, dst: ^u8, num_pixels: i32, palette: ^u8) ---
}

