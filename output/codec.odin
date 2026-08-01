/*
 * AVCodec public API
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
    foreign import lib "lib/avcodec.lib"
} else when ODIN_OS == .Darwin {
    @(extra_linker_flags = "-L/opt/homebrew/lib")
    foreign import lib "system:avcodec"
}

/**
* @addtogroup lavc_core
* @{
*/

/**
* Decoder can use draw_horiz_band callback.
*/
AV_CODEC_CAP_DRAW_HORIZ_BAND     :: (1<<0)

/**
* Codec uses get_buffer() or get_encode_buffer() for allocating buffers and
* supports custom allocators.
* If not set, it might not use get_buffer() or get_encode_buffer() at all, or
* use operations that assume the buffer was allocated by
* avcodec_default_get_buffer2 or avcodec_default_get_encode_buffer.
*/
AV_CODEC_CAP_DR1                 :: (1<<1)

/**
* Encoder or decoder requires flushing with NULL input at the end in order to
* give the complete and correct output.
*
* NOTE: If this flag is not set, the codec is guaranteed to never be fed with
*       with NULL data. The user can still send NULL data to the public encode
*       or decode function, but libavcodec will not pass it along to the codec
*       unless this flag is set.
*
* Decoders:
* The decoder has a non-zero delay and needs to be fed with avpkt->data=NULL,
* avpkt->size=0 at the end to get the delayed data until the decoder no longer
* returns frames.
*
* Encoders:
* The encoder needs to be fed with NULL data at the end of encoding until the
* encoder no longer returns data.
*
* NOTE: For encoders implementing the AVCodec.encode2() function, setting this
*       flag also means that the encoder must set the pts and duration for
*       each output packet. If this flag is not set, the pts and duration will
*       be determined by libavcodec from the input frame.
*/
AV_CODEC_CAP_DELAY               :: (1<<5)

/**
* Codec can be fed a final frame with a smaller size.
* This can be used to prevent truncation of the last audio samples.
*/
AV_CODEC_CAP_SMALL_LAST_FRAME    :: (1<<6)

/**
* Codec is experimental and is thus avoided in favor of non experimental
* encoders
*/
AV_CODEC_CAP_EXPERIMENTAL        :: (1<<9)

/**
* Codec should fill in channel configuration and samplerate instead of container
*/
AV_CODEC_CAP_CHANNEL_CONF        :: (1<<10)

/**
* Codec supports frame-level multithreading.
*/
AV_CODEC_CAP_FRAME_THREADS       :: (1<<12)

/**
* Codec supports slice-based (or partition-based) multithreading.
*/
AV_CODEC_CAP_SLICE_THREADS       :: (1<<13)

/**
* Codec supports changed parameters at any point.
*/
AV_CODEC_CAP_PARAM_CHANGE        :: (1<<14)

/**
* Codec supports multithreading through a method other than slice- or
* frame-level multithreading. Typically this marks wrappers around
* multithreading-capable external libraries.
*/
AV_CODEC_CAP_OTHER_THREADS       :: (1<<15)

/**
* Audio encoder supports receiving a different number of samples in each call.
*/
AV_CODEC_CAP_VARIABLE_FRAME_SIZE :: (1<<16)

/**
* Decoder is not a preferred choice for probing.
* This indicates that the decoder is not a good choice for probing.
* It could for example be an expensive to spin up hardware decoder,
* or it could simply not provide a lot of useful information about
* the stream.
* A decoder marked with this flag should only be used as last resort
* choice for probing.
*/
AV_CODEC_CAP_AVOID_PROBING       :: (1<<17)

/**
* Codec is backed by a hardware implementation. Typically used to
* identify a non-hwaccel hardware decoder. For information about hwaccels, use
* avcodec_get_hw_config() instead.
*/
AV_CODEC_CAP_HARDWARE            :: (1<<18)

/**
* Codec is potentially backed by a hardware implementation, but not
* necessarily. This is used instead of AV_CODEC_CAP_HARDWARE, if the
* implementation provides some sort of internal fallback.
*/
AV_CODEC_CAP_HYBRID              :: (1<<19)

/**
* This encoder can reorder user opaque values from input AVFrames and return
* them with corresponding output packets.
* @see AV_CODEC_FLAG_COPY_OPAQUE
*/
AV_CODEC_CAP_ENCODER_REORDERED_OPAQUE :: (1<<20)

/**
* This encoder can be flushed using avcodec_flush_buffers(). If this flag is
* not set, the encoder must be closed and reopened to ensure that no frames
* remain pending.
*/
AV_CODEC_CAP_ENCODER_FLUSH   :: (1<<21)

/**
* The encoder is able to output reconstructed frame data, i.e. raw frames that
* would be produced by decoding the encoded bitstream.
*
* Reconstructed frame output is enabled by the AV_CODEC_FLAG_RECON_FRAME flag.
*/
AV_CODEC_CAP_ENCODER_RECON_FRAME :: (1<<22)

/**
* AVProfile.
*/
AVProfile :: struct {
	profile: i32,
	name:    cstring, ///< short name for the profile
}

/**
* AVCodec.
*/
AVCodec :: struct {
	/**
	* Name of the codec implementation.
	* The name is globally unique among encoders and among decoders (but an
	* encoder and a decoder can share the same name).
	* This is the primary way to find a codec from the user perspective.
	*/
	name: cstring,

	/**
	* Descriptive name for the codec, meant to be more human readable than name.
	* You should use the NULL_IF_CONFIG_SMALL() macro to define it.
	*/
	long_name: cstring,
	type:      AVMediaType,
	id:        AVCodecID,

	/**
	* Codec capabilities.
	* see AV_CODEC_CAP_*
	*/
	capabilities:          i32,
	max_lowres:            u8,         ///< maximum value for lowres supported by the decoder
	AVRational:            i32,        ///< @deprecated use avcodec_get_supported_config()
	pix_fmts:              ^i32,       ///< @deprecated use avcodec_get_supported_config()
	supported_samplerates: ^i32,       ///< @deprecated use avcodec_get_supported_config()
	sample_fmts:           ^i32,       ///< @deprecated use avcodec_get_supported_config()
	priv_class:            ^i32,       ///< AVClass for the private context
	profiles:              ^AVProfile, ///< array of recognized profiles, or NULL if unknown, array is terminated by {AV_PROFILE_UNKNOWN}

	/**
	* Group name of the codec implementation.
	* This is a short symbolic name of the wrapper backing this codec. A
	* wrapper uses some kind of external implementation for the codec, such
	* as an external library, or a codec implementation provided by the OS or
	* the hardware.
	* If this field is NULL, this is a builtin, libavcodec native codec.
	* If non-NULL, this will be the suffix in AVCodec.name in most cases
	* (usually AVCodec.name will be of the form "<codec_name>_<wrapper_name>").
	*/
	wrapper_name:    cstring,
	AVChannelLayout: i32,
}

AVMediaType :: enum i32 {
}

AVCodecID :: enum i32 {
}

AVPixelFormat :: enum i32 {
} ///< @deprecated use avcodec_get_supported_config()

AVSampleFormat :: enum i32 {
} ///< @deprecated use avcodec_get_supported_config()

@(default_calling_convention="c")
foreign lib {
	/**
	* Iterate over all registered codecs.
	*
	* @param opaque a pointer where libavcodec will store the iteration state. Must
	*               point to NULL to start the iteration.
	*
	* @return the next registered codec or NULL when the iteration is
	*         finished
	*/
	av_codec_iterate :: proc(opaque: ^rawptr) -> ^AVCodec ---

	/**
	* Find a registered decoder with a matching codec ID.
	*
	* @param id AVCodecID of the requested decoder
	* @return A decoder if one was found, NULL otherwise.
	*/
	avcodec_find_decoder :: proc(id: AVCodecID) -> ^AVCodec ---

	/**
	* Find a registered decoder with the specified name.
	*
	* @param name name of the requested decoder
	* @return A decoder if one was found, NULL otherwise.
	*/
	avcodec_find_decoder_by_name :: proc(name: cstring) -> ^AVCodec ---

	/**
	* Find a registered encoder with a matching codec ID.
	*
	* @param id AVCodecID of the requested encoder
	* @return An encoder if one was found, NULL otherwise.
	*/
	avcodec_find_encoder :: proc(id: AVCodecID) -> ^AVCodec ---

	/**
	* Find a registered encoder with the specified name.
	*
	* @param name name of the requested encoder
	* @return An encoder if one was found, NULL otherwise.
	*/
	avcodec_find_encoder_by_name :: proc(name: cstring) -> ^AVCodec ---

	/**
	* @return a non-zero number if codec is an encoder, zero otherwise
	*/
	av_codec_is_encoder :: proc(codec: ^AVCodec) -> i32 ---

	/**
	* @return a non-zero number if codec is a decoder, zero otherwise
	*/
	av_codec_is_decoder :: proc(codec: ^AVCodec) -> i32 ---

	/**
	* Return a name for the specified profile, if available.
	*
	* @param codec the codec that is searched for the given profile
	* @param profile the profile value for which a name is requested
	* @return A name for the profile if found, NULL otherwise.
	*/
	av_get_profile_name :: proc(codec: ^AVCodec, profile: i32) -> cstring ---
}

AV_CODEC_HW_CONFIG_METHOD_AD_HOC        :: 8
AV_CODEC_HW_CONFIG_METHOD_HW_FRAMES_CTX :: 2
AV_CODEC_HW_CONFIG_METHOD_HW_DEVICE_CTX :: 1
AV_CODEC_HW_CONFIG_METHOD_INTERNAL      :: 4

AVCodecHWConfig :: struct {
	/**
	* For decoders, a hardware pixel format which that decoder may be
	* able to decode to if suitable hardware is available.
	*
	* For encoders, a pixel format which the encoder may be able to
	* accept.  If set to AV_PIX_FMT_NONE, this applies to all pixel
	* formats supported by the codec.
	*/
	pix_fmt: AVPixelFormat,

	/**
	* Bit set of AV_CODEC_HW_CONFIG_METHOD_* flags, describing the possible
	* setup methods which can be used with this configuration.
	*/
	methods: i32,

	/**
	* The device type associated with the configuration.
	*
	* Must be set for AV_CODEC_HW_CONFIG_METHOD_HW_DEVICE_CTX and
	* AV_CODEC_HW_CONFIG_METHOD_HW_FRAMES_CTX, otherwise unused.
	*/
	device_type: AVHWDeviceType,
}

AVHWDeviceType :: enum i32 {
}

@(default_calling_convention="c")
foreign lib {
	/**
	* Retrieve supported hardware configurations for a codec.
	*
	* Values of index from zero to some maximum return the indexed configuration
	* descriptor; all other values return NULL.  If the codec does not support
	* any hardware configurations then it will always return NULL.
	*/
	avcodec_get_hw_config :: proc(codec: ^AVCodec, index: i32) -> ^AVCodecHWConfig ---
}

