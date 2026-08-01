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

@(default_calling_convention="c")
foreign lib {
	/**
	* Return the LIBAVUTIL_VERSION_INT constant.
	*/
	avutil_version :: proc() -> u32 ---

	/**
	* Return an informative version string. This usually is the actual release
	* version number or a git commit description. This string has no fixed format
	* and can change any time. It should never be parsed by code.
	*/
	av_version_info :: proc() -> cstring ---

	/**
	* Return the libavutil build-time configuration.
	*/
	avutil_configuration :: proc() -> cstring ---

	/**
	* Return the libavutil license.
	*/
	avutil_license :: proc() -> cstring ---
}

/**
* @addtogroup lavu_media Media Type
* @brief Media Type
*/
AVMediaType :: enum i32 {
	UNKNOWN    = -1, ///< Usually treated as AVMEDIA_TYPE_DATA
	VIDEO      = 0,
	AUDIO      = 1,
	DATA       = 2,  ///< Opaque data information usually continuous
	SUBTITLE   = 3,
	ATTACHMENT = 4,  ///< Opaque data information usually sparse
	NB         = 5,
}

@(default_calling_convention="c")
foreign lib {
	/**
	* Return a string describing the media_type enum, NULL if media_type
	* is unknown.
	*/
	av_get_media_type_string :: proc(media_type: AVMediaType) -> cstring ---
}

/**
* @defgroup lavu_const Constants
* @{
*
* @defgroup lavu_enc Encoding specific
*
* @note those definition should move to avcodec
* @{
*/
FF_LAMBDA_SHIFT  :: 7
FF_LAMBDA_SCALE  :: (1<<FF_LAMBDA_SHIFT)
FF_QP2LAMBDA     :: 118             ///< factor to convert from H.263 QP to lambda
FF_LAMBDA_MAX    :: (256*128-1)
FF_QUALITY_SCALE :: FF_LAMBDA_SCALE //FIXME maybe remove

/**
* Internal time base represented as integer
*/
AV_TIME_BASE            :: 1000000

/**
* @}
* @}
* @defgroup lavu_picture Image related
*
* AVPicture types, pixel formats and basic image planes manipulation.
*
* @{
*/
AVPictureType :: enum i32 {
	NONE = 0, ///< Undefined
	I    = 1, ///< Intra
	P    = 2, ///< Predicted
	B    = 3, ///< Bi-dir predicted
	S    = 4, ///< S(GMC)-VOP MPEG-4
	SI   = 5, ///< Switching Intra
	SP   = 6, ///< Switching Predicted
	BI   = 7, ///< BI type
}

@(default_calling_convention="c")
foreign lib {
	/**
	* Return a single letter to describe the given picture type
	* pict_type.
	*
	* @param[in] pict_type the picture type @return a single character
	* representing the picture type, '?' if pict_type is unknown
	*/
	av_get_picture_type_char :: proc(pict_type: AVPictureType) -> i8 ---

	/**
	* Compute the length of an integer list.
	*
	* @param elsize  size in bytes of each list element (only 1, 2, 4 or 8)
	* @param term    list terminator (usually 0 or -1)
	* @param list    pointer to the list
	* @return  length of the list, in elements, not counting the terminator
	*/
	av_int_list_length_for_size :: proc(elsize: u32, list: rawptr, term: u64) -> u32 ---

	/**
	* Return the fractional representation of the internal time base.
	*/
	av_get_time_base_q :: proc() -> AVRational ---
}

AV_FOURCC_MAX_STRING_SIZE :: 32

@(default_calling_convention="c")
foreign lib {
	/**
	* Fill the provided buffer with a string containing a FourCC (four-character
	* code) representation.
	*
	* @param buf    a buffer with size in bytes of at least AV_FOURCC_MAX_STRING_SIZE
	* @param fourcc the fourcc to represent
	* @return the buffer in input
	*/
	av_fourcc_make_string :: proc(buf: cstring, fourcc: u32) -> cstring ---
}

