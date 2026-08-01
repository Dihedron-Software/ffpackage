/*
 * Copyright (c) 2006 Michael Niedermayer <michaelni@gmx.at>
 * Copyright (c) 2008 Peter Ross
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

import "core:c"

when ODIN_OS == .Windows {
    foreign import lib "lib/avutil.lib"
} else when ODIN_OS == .Darwin {
    @(extra_linker_flags = "-L/opt/homebrew/lib")
    foreign import lib "system:avutil"
}

/**
* @defgroup lavu_audio_channels Audio channels
* @ingroup lavu_audio
*
* Audio channel layout utility functions
*
* @{
*/
AVChannel :: enum i32 {
	/// Invalid channel index
	NONE                  = -1,
	FRONT_LEFT            = 0,
	FRONT_RIGHT           = 1,
	FRONT_CENTER          = 2,
	LOW_FREQUENCY         = 3,
	BACK_LEFT             = 4,
	BACK_RIGHT            = 5,
	FRONT_LEFT_OF_CENTER  = 6,
	FRONT_RIGHT_OF_CENTER = 7,
	BACK_CENTER           = 8,
	SIDE_LEFT             = 9,
	SIDE_RIGHT            = 10,
	TOP_CENTER            = 11,
	TOP_FRONT_LEFT        = 12,
	TOP_FRONT_CENTER      = 13,
	TOP_FRONT_RIGHT       = 14,
	TOP_BACK_LEFT         = 15,
	TOP_BACK_CENTER       = 16,
	TOP_BACK_RIGHT        = 17,

	/** Stereo downmix. */
	STEREO_LEFT           = 29,

	/** See above. */
	STEREO_RIGHT          = 30,
	WIDE_LEFT             = 31,
	WIDE_RIGHT            = 32,
	SURROUND_DIRECT_LEFT  = 33,
	SURROUND_DIRECT_RIGHT = 34,
	LOW_FREQUENCY_2       = 35,
	TOP_SIDE_LEFT         = 36,
	TOP_SIDE_RIGHT        = 37,
	BOTTOM_FRONT_CENTER   = 38,
	BOTTOM_FRONT_LEFT     = 39,
	BOTTOM_FRONT_RIGHT    = 40,
	SIDE_SURROUND_LEFT    = 41, ///<  +90 degrees, Lss, SiL
	SIDE_SURROUND_RIGHT   = 42, ///<  -90 degrees, Rss, SiR
	TOP_SURROUND_LEFT     = 43, ///< +110 degrees, Lvs, TpLS
	TOP_SURROUND_RIGHT    = 44, ///< -110 degrees, Rvs, TpRS
	BINAURAL_LEFT         = 61,
	BINAURAL_RIGHT        = 62,

	/** Channel is empty can be safely skipped. */
	UNUSED                = 512,

	/** Channel contains data, but its position is unknown. */
	UNKNOWN               = 768,

	/**
	* Range of channels between AV_CHAN_AMBISONIC_BASE and
	* AV_CHAN_AMBISONIC_END represent Ambisonic components using the ACN system.
	*
	* Given a channel id `<i>` between AV_CHAN_AMBISONIC_BASE and
	* AV_CHAN_AMBISONIC_END (inclusive), the ACN index of the channel `<n>` is
	* `<n> = <i> - AV_CHAN_AMBISONIC_BASE`.
	*
	* @note these values are only used for AV_CHANNEL_ORDER_CUSTOM channel
	* orderings, the AV_CHANNEL_ORDER_AMBISONIC ordering orders the channels
	* implicitly by their position in the stream.
	*/
	AMBISONIC_BASE        = 1024,

	// leave space for 1024 ids, which correspond to maximum order-32 harmonics,
	// which should be enough for the foreseeable use cases
	AMBISONIC_END         = 2047,
}

AVChannelOrder :: enum i32 {
	/**
	* Only the channel count is specified, without any further information
	* about the channel order.
	*/
	AV_CHANNEL_ORDER_UNSPEC    = 0,

	/**
	* The native channel order, i.e. the channels are in the same order in
	* which they are defined in the AVChannel enum. This supports up to 63
	* different channels.
	*/
	AV_CHANNEL_ORDER_NATIVE    = 1,

	/**
	* The channel order does not correspond to any other predefined order and
	* is stored as an explicit map. For example, this could be used to support
	* layouts with 64 or more channels, or with empty/skipped (AV_CHAN_UNUSED)
	* channels at arbitrary positions.
	*/
	AV_CHANNEL_ORDER_CUSTOM    = 2,

	/**
	* The audio is represented as the decomposition of the sound field into
	* spherical harmonics. Each channel corresponds to a single expansion
	* component. Channels are ordered according to ACN (Ambisonic Channel
	* Number).
	*
	* The channel with the index n in the stream contains the spherical
	* harmonic of degree l and order m given by
	* @code{.unparsed}
	*   l   = floor(sqrt(n)),
	*   m   = n - l * (l + 1).
	* @endcode
	*
	* Conversely given a spherical harmonic of degree l and order m, the
	* corresponding channel index n is given by
	* @code{.unparsed}
	*   n = l * (l + 1) + m.
	* @endcode
	*
	* Normalization is assumed to be SN3D (Schmidt Semi-Normalization)
	* as defined in AmbiX format $ 2.1.
	*/
	AV_CHANNEL_ORDER_AMBISONIC = 3,

	/**
	* Number of channel orders, not part of ABI/API
	*/
	FF_CHANNEL_ORDER_NB        = 4,
}

AVMatrixEncoding :: enum i32 {
	NONE           = 0,
	DOLBY          = 1,
	DPLII          = 2,
	DPLIIX         = 3,
	DPLIIZ         = 4,
	DOLBYEX        = 5,
	DOLBYHEADPHONE = 6,
	NB             = 7,
}

/**
* An AVChannelCustom defines a single channel within a custom order layout
*
* Unlike most structures in FFmpeg, sizeof(AVChannelCustom) is a part of the
* public ABI.
*
* No new fields may be added to it without a major version bump.
*/
AVChannelCustom :: struct {
	id:     AVChannel,
	name:   [16]i8,
	opaque: rawptr,
}

/**
* An AVChannelLayout holds information about the channel layout of audio data.
*
* A channel layout here is defined as a set of channels ordered in a specific
* way (unless the channel order is AV_CHANNEL_ORDER_UNSPEC, in which case an
* AVChannelLayout carries only the channel count).
* All orders may be treated as if they were AV_CHANNEL_ORDER_UNSPEC by
* ignoring everything but the channel count, as long as av_channel_layout_check()
* considers they are valid.
*
* Unlike most structures in FFmpeg, sizeof(AVChannelLayout) is a part of the
* public ABI and may be used by the caller. E.g. it may be allocated on stack
* or embedded in caller-defined structs.
*
* AVChannelLayout can be initialized as follows:
* - default initialization with {0}, followed by setting all used fields
*   correctly;
* - by assigning one of the predefined AV_CHANNEL_LAYOUT_* initializers;
* - with a constructor function, such as av_channel_layout_default(),
*   av_channel_layout_from_mask() or av_channel_layout_from_string().
*
* The channel layout must be uninitialized with av_channel_layout_uninit()
*
* Copying an AVChannelLayout via assigning is forbidden,
* av_channel_layout_copy() must be used instead (and its return value should
* be checked)
*
* No new fields may be added to it without a major version bump, except for
* new elements of the union fitting in sizeof(uint64_t).
*/
AVChannelLayout :: struct {
	/**
	* Channel order used in this layout.
	* This is a mandatory field.
	*/
	order: AVChannelOrder,

	/**
	* Number of channels in this layout. Mandatory field.
	*/
	nb_channels: i32,

	u: struct #raw_union {
		/**
		* This member must be used for AV_CHANNEL_ORDER_NATIVE, and may be used
		* for AV_CHANNEL_ORDER_AMBISONIC to signal non-diegetic channels.
		* It is a bitmask, where the position of each set bit means that the
		* AVChannel with the corresponding value is present.
		*
		* I.e. when (mask & (1 << AV_CHAN_FOO)) is non-zero, then AV_CHAN_FOO
		* is present in the layout. Otherwise it is not present.
		*
		* @note when a channel layout using a bitmask is constructed or
		* modified manually (i.e.  not using any of the av_channel_layout_*
		* functions), the code doing it must ensure that the number of set bits
		* is equal to nb_channels.
		*/
		mask: u64,

		/**
		* This member must be used when the channel order is
		* AV_CHANNEL_ORDER_CUSTOM. It is a nb_channels-sized array, with each
		* element signalling the presence of the AVChannel with the
		* corresponding value in map[i].id.
		*
		* I.e. when map[i].id is equal to AV_CHAN_FOO, then AV_CH_FOO is the
		* i-th channel in the audio data.
		*
		* When map[i].id is in the range between AV_CHAN_AMBISONIC_BASE and
		* AV_CHAN_AMBISONIC_END (inclusive), the channel contains an ambisonic
		* component with ACN index (as defined above)
		* n = map[i].id - AV_CHAN_AMBISONIC_BASE.
		*
		* map[i].name may be filled with a 0-terminated string, in which case
		* it will be used for the purpose of identifying the channel with the
		* convenience functions below. Otherwise it must be zeroed.
		*/
		_map: ^AVChannelCustom,
	},

	/**
	* For some private data of the user.
	*/
	opaque: rawptr,
}

/** @} */
// AVBPrint :: struct {} // removed duplicate

@(default_calling_convention="c")
foreign lib {
	/**
	* Get a human readable string in an abbreviated form describing a given channel.
	* This is the inverse function of @ref av_channel_from_string().
	*
	* @param buf pre-allocated buffer where to put the generated string
	* @param buf_size size in bytes of the buffer.
	* @param channel the AVChannel whose name to get
	* @return amount of bytes needed to hold the output string, or a negative AVERROR
	*         on failure. If the returned value is bigger than buf_size, then the
	*         string was truncated.
	*/
	av_channel_name :: proc(buf: cstring, buf_size: c.size_t, channel: AVChannel) -> i32 ---

	/**
	* bprint variant of av_channel_name().
	*
	* @note the string will be appended to the bprint buffer.
	*/
	av_channel_name_bprint :: proc(bp: ^AVBPrint, channel_id: AVChannel) ---

	/**
	* Get a human readable string describing a given channel.
	*
	* @param buf pre-allocated buffer where to put the generated string
	* @param buf_size size in bytes of the buffer.
	* @param channel the AVChannel whose description to get
	* @return amount of bytes needed to hold the output string, or a negative AVERROR
	*         on failure. If the returned value is bigger than buf_size, then the
	*         string was truncated.
	*/
	av_channel_description :: proc(buf: cstring, buf_size: c.size_t, channel: AVChannel) -> i32 ---

	/**
	* bprint variant of av_channel_description().
	*
	* @note the string will be appended to the bprint buffer.
	*/
	av_channel_description_bprint :: proc(bp: ^AVBPrint, channel_id: AVChannel) ---

	/**
	* This is the inverse function of @ref av_channel_name().
	*
	* @return the channel with the given name
	*         AV_CHAN_NONE when name does not identify a known channel
	*/
	av_channel_from_string :: proc(name: cstring) -> AVChannel ---

	/**
	* Initialize a custom channel layout with the specified number of channels.
	* The channel map will be allocated and the designation of all channels will
	* be set to AV_CHAN_UNKNOWN.
	*
	* This is only a convenience helper function, a custom channel layout can also
	* be constructed without using this.
	*
	* @param channel_layout the layout structure to be initialized
	* @param nb_channels the number of channels
	*
	* @return 0 on success
	*         AVERROR(EINVAL) if the number of channels <= 0
	*         AVERROR(ENOMEM) if the channel map could not be allocated
	*/
	av_channel_layout_custom_init :: proc(channel_layout: ^AVChannelLayout, nb_channels: i32) -> i32 ---

	/**
	* Initialize a native channel layout from a bitmask indicating which channels
	* are present.
	*
	* @param channel_layout the layout structure to be initialized
	* @param mask bitmask describing the channel layout
	*
	* @return 0 on success
	*         AVERROR(EINVAL) for invalid mask values
	*/
	av_channel_layout_from_mask :: proc(channel_layout: ^AVChannelLayout, mask: u64) -> i32 ---

	/**
	* Initialize a channel layout from a given string description.
	* The input string can be represented by:
	*  - the formal channel layout name (returned by av_channel_layout_describe())
	*  - single or multiple channel names (returned by av_channel_name(), eg. "FL",
	*    or concatenated with "+", each optionally containing a custom name after
	*    a "@", eg. "FL@Left+FR@Right+LFE")
	*  - a decimal or hexadecimal value of a native channel layout (eg. "4" or "0x4")
	*  - the number of channels with default layout (eg. "4c")
	*  - the number of unordered channels (eg. "4C" or "4 channels")
	*  - the ambisonic order followed by optional non-diegetic channels (eg.
	*    "ambisonic 2+stereo")
	* On error, the channel layout will remain uninitialized, but not necessarily
	* untouched.
	*
	* @param channel_layout uninitialized channel layout for the result
	* @param str string describing the channel layout
	* @return 0 on success parsing the channel layout
	*         AVERROR(EINVAL) if an invalid channel layout string was provided
	*         AVERROR(ENOMEM) if there was not enough memory
	*/
	av_channel_layout_from_string :: proc(channel_layout: ^AVChannelLayout, str: cstring) -> i32 ---

	/**
	* Get the default channel layout for a given number of channels.
	*
	* @param ch_layout the layout structure to be initialized
	* @param nb_channels number of channels
	*/
	av_channel_layout_default :: proc(ch_layout: ^AVChannelLayout, nb_channels: i32) ---

	/**
	* Iterate over all standard channel layouts.
	*
	* @param opaque a pointer where libavutil will store the iteration state. Must
	*               point to NULL to start the iteration.
	*
	* @return the standard channel layout or NULL when the iteration is
	*         finished
	*/
	av_channel_layout_standard :: proc(opaque: ^rawptr) -> ^AVChannelLayout ---

	/**
	* Free any allocated data in the channel layout and reset the channel
	* count to 0.
	*
	* @param channel_layout the layout structure to be uninitialized
	*/
	av_channel_layout_uninit :: proc(channel_layout: ^AVChannelLayout) ---

	/**
	* Make a copy of a channel layout. This differs from just assigning src to dst
	* in that it allocates and copies the map for AV_CHANNEL_ORDER_CUSTOM.
	*
	* @note the destination channel_layout will be always uninitialized before copy.
	*
	* @param dst destination channel layout
	* @param src source channel layout
	* @return 0 on success, a negative AVERROR on error.
	*/
	av_channel_layout_copy :: proc(dst: ^AVChannelLayout, src: ^AVChannelLayout) -> i32 ---

	/**
	* Get a human-readable string describing the channel layout properties.
	* The string will be in the same format that is accepted by
	* @ref av_channel_layout_from_string(), allowing to rebuild the same
	* channel layout, except for opaque pointers.
	*
	* @param channel_layout channel layout to be described
	* @param buf pre-allocated buffer where to put the generated string
	* @param buf_size size in bytes of the buffer.
	* @return amount of bytes needed to hold the output string, or a negative AVERROR
	*         on failure. If the returned value is bigger than buf_size, then the
	*         string was truncated.
	*/
	av_channel_layout_describe :: proc(channel_layout: ^AVChannelLayout, buf: cstring, buf_size: c.size_t) -> i32 ---

	/**
	* bprint variant of av_channel_layout_describe().
	*
	* @note the string will be appended to the bprint buffer.
	* @return 0 on success, or a negative AVERROR value on failure.
	*/
	av_channel_layout_describe_bprint :: proc(channel_layout: ^AVChannelLayout, bp: ^AVBPrint) -> i32 ---

	/**
	* Get the channel with the given index in a channel layout.
	*
	* @param channel_layout input channel layout
	* @param idx index of the channel
	* @return channel with the index idx in channel_layout on success or
	*         AV_CHAN_NONE on failure (if idx is not valid or the channel order is
	*         unspecified)
	*/
	av_channel_layout_channel_from_index :: proc(channel_layout: ^AVChannelLayout, idx: u32) -> AVChannel ---

	/**
	* Get the index of a given channel in a channel layout. In case multiple
	* channels are found, only the first match will be returned.
	*
	* @param channel_layout input channel layout
	* @param channel the channel whose index to obtain
	* @return index of channel in channel_layout on success or a negative number if
	*         channel is not present in channel_layout.
	*/
	av_channel_layout_index_from_channel :: proc(channel_layout: ^AVChannelLayout, channel: AVChannel) -> i32 ---

	/**
	* Get the index in a channel layout of a channel described by the given string.
	* In case multiple channels are found, only the first match will be returned.
	*
	* This function accepts channel names in the same format as
	* @ref av_channel_from_string().
	*
	* @param channel_layout input channel layout
	* @param name string describing the channel whose index to obtain
	* @return a channel index described by the given string, or a negative AVERROR
	*         value.
	*/
	av_channel_layout_index_from_string :: proc(channel_layout: ^AVChannelLayout, name: cstring) -> i32 ---

	/**
	* Get a channel described by the given string.
	*
	* This function accepts channel names in the same format as
	* @ref av_channel_from_string().
	*
	* @param channel_layout input channel layout
	* @param name string describing the channel to obtain
	* @return a channel described by the given string in channel_layout on success
	*         or AV_CHAN_NONE on failure (if the string is not valid or the channel
	*         order is unspecified)
	*/
	av_channel_layout_channel_from_string :: proc(channel_layout: ^AVChannelLayout, name: cstring) -> AVChannel ---

	/**
	* Find out what channels from a given set are present in a channel layout,
	* without regard for their positions.
	*
	* @param channel_layout input channel layout
	* @param mask a combination of AV_CH_* representing a set of channels
	* @return a bitfield representing all the channels from mask that are present
	*         in channel_layout
	*/
	av_channel_layout_subset :: proc(channel_layout: ^AVChannelLayout, mask: u64) -> u64 ---

	/**
	* Check whether a channel layout is valid, i.e. can possibly describe audio
	* data.
	*
	* @param channel_layout input channel layout
	* @return 1 if channel_layout is valid, 0 otherwise.
	*/
	av_channel_layout_check :: proc(channel_layout: ^AVChannelLayout) -> i32 ---

	/**
	* Check whether two channel layouts are semantically the same, i.e. the same
	* channels are present on the same positions in both.
	*
	* If one of the channel layouts is AV_CHANNEL_ORDER_UNSPEC, while the other is
	* not, they are considered to be unequal. If both are AV_CHANNEL_ORDER_UNSPEC,
	* they are considered equal iff the channel counts are the same in both.
	*
	* @param chl input channel layout
	* @param chl1 input channel layout
	* @return 0 if chl and chl1 are equal, 1 if they are not equal. A negative
	*         AVERROR code if one or both are invalid.
	*/
	av_channel_layout_compare :: proc(chl: ^AVChannelLayout, chl1: ^AVChannelLayout) -> i32 ---

	/**
	* Return the order if the layout is n-th order standard-order ambisonic.
	* The presence of optional extra non-diegetic channels at the end is not taken
	* into account.
	*
	* @param channel_layout input channel layout
	* @return the order of the layout, a negative error code otherwise.
	*/
	av_channel_layout_ambisonic_order :: proc(channel_layout: ^AVChannelLayout) -> i32 ---
}

/**
* The conversion must be lossless.
*/
AV_CHANNEL_LAYOUT_RETYPE_FLAG_LOSSLESS :: (1<<0)

/**
* The specified retype target order is ignored and the simplest possible
* (canonical) order is used for which the input layout can be losslessy
* represented.
*/
AV_CHANNEL_LAYOUT_RETYPE_FLAG_CANONICAL :: (1<<1)

@(default_calling_convention="c")
foreign lib {
	/**
	* Change the AVChannelOrder of a channel layout.
	*
	* Change of AVChannelOrder can be either lossless or lossy. In case of a
	* lossless conversion all the channel designations and the associated channel
	* names (if any) are kept. On a lossy conversion the channel names and channel
	* designations might be lost depending on the capabilities of the desired
	* AVChannelOrder. Note that some conversions are simply not possible in which
	* case this function returns AVERROR(ENOSYS).
	*
	* The following conversions are supported:
	*
	* Any       -> Custom     : Always possible, always lossless.
	* Any       -> Unspecified: Always possible, lossless if channel designations
	*   are all unknown and channel names are not used, lossy otherwise.
	* Custom    -> Ambisonic  : Possible if it contains ambisonic channels with
	*   optional non-diegetic channels in the end. Lossy if the channels have
	*   custom names, lossless otherwise.
	* Custom    -> Native     : Possible if it contains native channels in native
	*     order. Lossy if the channels have custom names, lossless otherwise.
	*
	* On error this function keeps the original channel layout untouched.
	*
	* @param channel_layout channel layout which will be changed
	* @param order the desired channel layout order
	* @param flags a combination of AV_CHANNEL_LAYOUT_RETYPE_FLAG_* constants
	* @return 0 if the conversion was successful and lossless or if the channel
	*           layout was already in the desired order
	*         >0 if the conversion was successful but lossy
	*         AVERROR(ENOSYS) if the conversion was not possible (or would be
	*           lossy and AV_CHANNEL_LAYOUT_RETYPE_FLAG_LOSSLESS was specified)
	*         AVERROR(EINVAL), AVERROR(ENOMEM) on error
	*/
	av_channel_layout_retype :: proc(channel_layout: ^AVChannelLayout, order: AVChannelOrder, flags: i32) -> i32 ---
}

