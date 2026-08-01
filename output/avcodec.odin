/*
 * copyright (c) 2001 Fabrice Bellard
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
    foreign import lib "lib/avcodec.lib"
} else when ODIN_OS == .Darwin {
    @(extra_linker_flags = "-L/opt/homebrew/lib")
    foreign import lib "system:avcodec"
}

/**
* @ingroup lavc_encoding
*/
RcOverride :: struct {
	start_frame:    i32,
	end_frame:      i32,
	qscale:         i32, // If this is 0 then quality_factor will be used instead.
	quality_factor: f32,
}

/* encoding support
These flags can be passed in AVCodecContext.flags before initialization.
Note: Not everything is supported yet.
*/

/**
* Allow decoders to produce frames with data planes that are not aligned
* to CPU requirements (e.g. due to cropping).
*/
AV_CODEC_FLAG_UNALIGNED       :: (1<<0)

/**
* Use fixed qscale.
*/
AV_CODEC_FLAG_QSCALE          :: (1<<1)

/**
* 4 MV per MB allowed / advanced prediction for H.263.
*/
AV_CODEC_FLAG_4MV             :: (1<<2)

/**
* Output even those frames that might be corrupted.
*/
AV_CODEC_FLAG_OUTPUT_CORRUPT  :: (1<<3)

/**
* Use qpel MC.
*/
AV_CODEC_FLAG_QPEL            :: (1<<4)

/**
* Request the encoder to output reconstructed frames, i.e.\ frames that would
* be produced by decoding the encoded bitstream. These frames may be retrieved
* by calling avcodec_receive_frame() immediately after a successful call to
* avcodec_receive_packet().
*
* Should only be used with encoders flagged with the
* @ref AV_CODEC_CAP_ENCODER_RECON_FRAME capability.
*
* @note
* Each reconstructed frame returned by the encoder corresponds to the last
* encoded packet, i.e. the frames are returned in coded order rather than
* presentation order.
*
* @note
* Frame parameters (like pixel format or dimensions) do not have to match the
* AVCodecContext values. Make sure to use the values from the returned frame.
*/
AV_CODEC_FLAG_RECON_FRAME     :: (1<<6)

/**
* @par decoding
* Request the decoder to propagate each packet's AVPacket.opaque and
* AVPacket.opaque_ref to its corresponding output AVFrame.
*
* @par encoding:
* Request the encoder to propagate each frame's AVFrame.opaque and
* AVFrame.opaque_ref values to its corresponding output AVPacket.
*
* @par
* May only be set on encoders that have the
* @ref AV_CODEC_CAP_ENCODER_REORDERED_OPAQUE capability flag.
*
* @note
* While in typical cases one input frame produces exactly one output packet
* (perhaps after a delay), in general the mapping of frames to packets is
* M-to-N, so
* - Any number of input frames may be associated with any given output packet.
*   This includes zero - e.g. some encoders may output packets that carry only
*   metadata about the whole stream.
* - A given input frame may be associated with any number of output packets.
*   Again this includes zero - e.g. some encoders may drop frames under certain
*   conditions.
* .
* This implies that when using this flag, the caller must NOT assume that
* - a given input frame's opaques will necessarily appear on some output packet;
* - every output packet will have some non-NULL opaque value.
* .
* When an output packet contains multiple frames, the opaque values will be
* taken from the first of those.
*
* @note
* The converse holds for decoders, with frames and packets switched.
*/
AV_CODEC_FLAG_COPY_OPAQUE     :: (1<<7)

/**
* Signal to the encoder that the values of AVFrame.duration are valid and
* should be used (typically for transferring them to output packets).
*
* If this flag is not set, frame durations are ignored.
*/
AV_CODEC_FLAG_FRAME_DURATION  :: (1<<8)

/**
* Use internal 2pass ratecontrol in first pass mode.
*/
AV_CODEC_FLAG_PASS1           :: (1<<9)

/**
* Use internal 2pass ratecontrol in second pass mode.
*/
AV_CODEC_FLAG_PASS2           :: (1<<10)

/**
* loop filter.
*/
AV_CODEC_FLAG_LOOP_FILTER     :: (1<<11)

/**
* Only decode/encode grayscale.
*/
AV_CODEC_FLAG_GRAY            :: (1<<13)

/**
* error[?] variables will be set during encoding.
*/
AV_CODEC_FLAG_PSNR            :: (1<<15)

/**
* Use interlaced DCT.
*/
AV_CODEC_FLAG_INTERLACED_DCT  :: (1<<18)

/**
* Force low delay.
*/
AV_CODEC_FLAG_LOW_DELAY       :: (1<<19)

/**
* Place global headers in extradata instead of every keyframe.
*/
AV_CODEC_FLAG_GLOBAL_HEADER   :: (1<<22)

/**
* Use only bitexact stuff (except (I)DCT).
*/
AV_CODEC_FLAG_BITEXACT        :: (1<<23)

/* Fx : Flag for H.263+ extra options */
/**
* H.263 advanced intra coding / MPEG-4 AC prediction
*/
AV_CODEC_FLAG_AC_PRED         :: (1<<24)

/**
* interlaced motion estimation
*/
AV_CODEC_FLAG_INTERLACED_ME   :: (1<<29)
AV_CODEC_FLAG_CLOSED_GOP      :: (1<<31)

/**
* Allow non spec compliant speedup tricks.
*/
AV_CODEC_FLAG2_FAST           :: (1<<0)

/**
* Skip bitstream encoding.
*/
AV_CODEC_FLAG2_NO_OUTPUT      :: (1<<2)

/**
* Place global headers at every keyframe instead of in extradata.
*/
AV_CODEC_FLAG2_LOCAL_HEADER   :: (1<<3)

/**
* Input bitstream might be truncated at a packet boundaries
* instead of only at frame boundaries.
*/
AV_CODEC_FLAG2_CHUNKS         :: (1<<15)

/**
* Discard cropping information from SPS.
*/
AV_CODEC_FLAG2_IGNORE_CROP    :: (1<<16)

/**
* Show all frames before the first keyframe
*/
AV_CODEC_FLAG2_SHOW_ALL       :: (1<<22)

/**
* Export motion vectors through frame side data
*/
AV_CODEC_FLAG2_EXPORT_MVS     :: (1<<28)

/**
* Do not skip samples and export skip information as frame side data
*/
AV_CODEC_FLAG2_SKIP_MANUAL    :: (1<<29)

/**
* Do not reset ASS ReadOrder field on flush (subtitles decoding)
*/
AV_CODEC_FLAG2_RO_FLUSH_NOOP  :: (1<<30)

/**
* Generate/parse ICC profiles on encode/decode, as appropriate for the type of
* file. No effect on codecs which cannot contain embedded ICC profiles, or
* when compiled without support for lcms2.
*/
AV_CODEC_FLAG2_ICC_PROFILES   :: (1<<31)

/* Exported side data.
These flags can be passed in AVCodecContext.export_side_data before initialization.
*/
/**
* Export motion vectors through frame side data
*/
AV_CODEC_EXPORT_DATA_MVS         :: (1<<0)

/**
* Export encoder Producer Reference Time through packet side data
*/
AV_CODEC_EXPORT_DATA_PRFT        :: (1<<1)

/**
* Decoding only.
* Export the AVVideoEncParams structure through frame side data.
*/
AV_CODEC_EXPORT_DATA_VIDEO_ENC_PARAMS :: (1<<2)

/**
* Decoding only.
* Do not apply film grain, export it instead.
*/
AV_CODEC_EXPORT_DATA_FILM_GRAIN :: (1<<3)

/**
* Decoding only.
* Do not apply picture enhancement layers, export them instead.
*/
AV_CODEC_EXPORT_DATA_ENHANCEMENTS :: (1<<4)

/**
* The decoder will keep a reference to the frame and may reuse it later.
*/
AV_GET_BUFFER_FLAG_REF :: (1<<0)

/**
* The encoder will keep a reference to the packet and may reuse it later.
*/
AV_GET_ENCODE_BUFFER_FLAG_REF :: (1<<0)

/**
* main external API structure.
* New fields can be added to the end with minor version bumps.
* Removal, reordering and changes to existing fields require a major
* version bump.
* You can use AVOptions (av_opt* / av_set/get*()) to access these fields from user
* applications.
* The name string for AVOptions options matches the associated command line
* parameter name and can be found in libavcodec/options_table.h
* The AVOption/command line parameter names differ in some cases from the C
* structure field names for historic reasons or brevity.
* sizeof(AVCodecContext) must not be used outside libav*.
*/
AVCodecContext :: struct {
	/**
	* information on struct for av_log
	* - set by avcodec_alloc_context3
	*/
	av_class:         ^i32,
	log_level_offset: i32,
	codec_type:       AVMediaType, /* see AVMEDIA_TYPE_xxx */
	codec:            ^AVCodec,
	codec_id:         AVCodecID,   /* see AV_CODEC_ID_xxx */

	/**
	* fourcc (LSB first, so "ABCD" -> ('D'<<24) + ('C'<<16) + ('B'<<8) + 'A').
	* This is used to work around some encoder bugs.
	* A demuxer should set this to what is stored in the field used to identify the codec.
	* If there are multiple such fields in a container then the demuxer should choose the one
	* which maximizes the information about the used codec.
	* If the codec tag field in a container is larger than 32 bits then the demuxer should
	* remap the longer ID to 32 bits with a table or other structure. Alternatively a new
	* extra_codec_tag + size could be added but for this a clear advantage must be demonstrated
	* first.
	* - encoding: Set by user, if not then the default based on codec_id will be used.
	* - decoding: Set by user, will be converted to uppercase by libavcodec during init.
	*/
	codec_tag: u32,
	priv_data: rawptr,

	/**
	* Private context used for internal data.
	*
	* Unlike priv_data, this is not codec-specific. It is used in general
	* libavcodec functions.
	*/
	internal: ^AVCodecInternal,

	/**
	* Private data of the user, can be used to carry app specific stuff.
	* - encoding: Set by user.
	* - decoding: Set by user.
	*/
	opaque: rawptr,

	/**
	* the average bitrate
	* - encoding: Set by user; unused for constant quantizer encoding.
	* - decoding: Set by user, may be overwritten by libavcodec
	*             if this info is available in the stream
	*/
	bit_rate: i64,

	/**
	* AV_CODEC_FLAG_*.
	* - encoding: Set by user.
	* - decoding: Set by user.
	*/
	flags: i32,

	/**
	* AV_CODEC_FLAG2_*
	* - encoding: Set by user.
	* - decoding: Set by user.
	*/
	flags2: i32,

	/**
	* Out-of-band global headers that may be used by some codecs.
	*
	* - decoding: Should be set by the caller when available (typically from a
	*   demuxer) before opening the decoder; some decoders require this to be
	*   set and will fail to initialize otherwise.
	*
	*   The array must be allocated with the av_malloc() family of functions;
	*   allocated size must be at least AV_INPUT_BUFFER_PADDING_SIZE bytes
	*   larger than extradata_size.
	*
	* - encoding: May be set by the encoder in avcodec_open2() (possibly
	*   depending on whether the AV_CODEC_FLAG_GLOBAL_HEADER flag is set).
	*
	* After being set, the array is owned by the codec and freed in
	* avcodec_free_context().
	*/
	extradata:      ^u8,
	extradata_size: i32,

	/**
	* This is the fundamental unit of time (in seconds) in terms
	* of which frame timestamps are represented. For fixed-fps content,
	* timebase should be 1/framerate and timestamp increments should be
	* identically 1.
	* This often, but not always is the inverse of the frame rate or field rate
	* for video. 1/time_base is not the average frame rate if the frame rate is not
	* constant.
	*
	* Like containers, elementary streams also can store timestamps, 1/time_base
	* is the unit in which these timestamps are specified.
	* As example of such codec time base see ISO/IEC 14496-2:2001(E)
	* vop_time_increment_resolution and fixed_vop_rate
	* (fixed_vop_rate == 0 implies that it is different from the framerate)
	*
	* - encoding: MUST be set by user.
	* - decoding: unused.
	*/
	time_base: i32,

	/**
	* Timebase in which pkt_dts/pts and AVPacket.dts/pts are expressed.
	* - encoding: unused.
	* - decoding: set by user.
	*/
	pkt_timebase: i32,

	/**
	* - decoding: For codecs that store a framerate value in the compressed
	*             bitstream, the decoder may export it here. { 0, 1} when
	*             unknown.
	* - encoding: May be used to signal the framerate of CFR content to an
	*             encoder.
	*/
	framerate: i32,

	/**
	* Codec delay.
	*
	* Encoding: Number of frames delay there will be from the encoder input to
	*           the decoder output. (we assume the decoder matches the spec)
	* Decoding: Number of frames delay in addition to what a standard decoder
	*           as specified in the spec would produce.
	*
	* Video:
	*   Number of frames the decoded output will be delayed relative to the
	*   encoded input.
	*
	* Audio:
	*   For encoding, this field is unused (see initial_padding).
	*
	*   For decoding, this is the number of samples the decoder needs to
	*   output before the decoder's output is valid. When seeking, you should
	*   start decoding this many samples prior to your desired seek point.
	*
	* - encoding: Set by libavcodec.
	* - decoding: Set by libavcodec.
	*/
	delay: i32,

	/* video only */
	/**
	* picture width / height.
	*
	* @note Those fields may not match the values of the last
	* AVFrame output by avcodec_receive_frame() due frame
	* reordering.
	*
	* - encoding: MUST be set by user.
	* - decoding: May be set by the user before opening the decoder if known e.g.
	*             from the container. Some decoders will require the dimensions
	*             to be set by the caller. During decoding, the decoder may
	*             overwrite those values as required while parsing the data.
	*/
	width, height: i32,

	/**
	* Bitstream width / height, may be different from width/height e.g. when
	* the decoded frame is cropped before being output or lowres is enabled.
	*
	* @note Those field may not match the value of the last
	* AVFrame output by avcodec_receive_frame() due frame
	* reordering.
	*
	* - encoding: unused
	* - decoding: May be set by the user before opening the decoder if known
	*             e.g. from the container. During decoding, the decoder may
	*             overwrite those values as required while parsing the data.
	*/
	coded_width, coded_height: i32,

	/**
	* sample aspect ratio (0 if unknown)
	* That is the width of a pixel divided by the height of the pixel.
	* Numerator and denominator must be relatively prime and smaller than 256 for some video standards.
	* - encoding: Set by user.
	* - decoding: Set by libavcodec.
	*/
	sample_aspect_ratio: i32,

	/**
	* Pixel format, see AV_PIX_FMT_xxx.
	* May be set by the demuxer if known from headers.
	* May be overridden by the decoder if it knows better.
	*
	* @note This field may not match the value of the last
	* AVFrame output by avcodec_receive_frame() due frame
	* reordering.
	*
	* - encoding: Set by user.
	* - decoding: Set by user if known, overridden by libavcodec while
	*             parsing the data.
	*/
	pix_fmt: AVPixelFormat,

	/**
	* Nominal unaccelerated pixel format, see AV_PIX_FMT_xxx.
	* - encoding: unused.
	* - decoding: Set by libavcodec before calling get_format()
	*/
	sw_pix_fmt: AVPixelFormat,

	/**
	* Chromaticity coordinates of the source primaries.
	* - encoding: Set by user
	* - decoding: Set by libavcodec
	*/
	color_primaries: AVColorPrimaries,

	/**
	* Color Transfer Characteristic.
	* - encoding: Set by user
	* - decoding: Set by libavcodec
	*/
	color_trc: AVColorTransferCharacteristic,

	/**
	* YUV colorspace type.
	* - encoding: Set by user
	* - decoding: Set by libavcodec
	*/
	colorspace: AVColorSpace,

	/**
	* MPEG vs JPEG YUV range.
	* - encoding: Set by user to override the default output color range value,
	*   If not specified, libavcodec sets the color range depending on the
	*   output format.
	* - decoding: Set by libavcodec, can be set by the user to propagate the
	*   color range to components reading from the decoder context.
	*/
	color_range: AVColorRange,

	/**
	* This defines the location of chroma samples.
	* - encoding: Set by user
	* - decoding: Set by libavcodec
	*/
	chroma_sample_location: AVChromaLocation,

	/** Field order
	* - encoding: set by libavcodec
	* - decoding: Set by user.
	*/
	field_order: AVFieldOrder,

	/**
	* number of reference frames
	* - encoding: Set by user.
	* - decoding: Set by lavc.
	*/
	refs: i32,

	/**
	* Size of the frame reordering buffer in the decoder.
	* For MPEG-2 it is 1 IPB or 0 low delay IP.
	* - encoding: Set by libavcodec.
	* - decoding: Set by libavcodec.
	*/
	has_b_frames: i32,

	/**
	* slice flags
	* - encoding: unused
	* - decoding: Set by user.
	*/
	slice_flags: i32,

	/**
	* If non NULL, 'draw_horiz_band' is called by the libavcodec
	* decoder to draw a horizontal band. It improves cache usage. Not
	* all codecs can do that. You must check the codec capabilities
	* beforehand.
	* When multithreading is used, it may be called from multiple threads
	* at the same time; threads might draw different parts of the same AVFrame,
	* or multiple AVFrames, and there is no guarantee that slices will be drawn
	* in order.
	* The function is also used by hardware acceleration APIs.
	* It is called at least once during frame decoding to pass
	* the data needed for hardware render.
	* In that mode instead of pixel data, AVFrame points to
	* a structure specific to the acceleration API. The application
	* reads the structure and can change some fields to indicate progress
	* or mark state.
	* - encoding: unused
	* - decoding: Set by user.
	* @param height the height of the slice
	* @param y the y position of the slice
	* @param type 1->top field, 2->bottom field, 3->frame
	* @param offset offset into the AVFrame.data from which the slice should be read
	*/
	draw_horiz_band: proc "c" (s: ^AVCodecContext, src: ^i32, offset: i32, y: i32, type: i32, height: i32),

	/**
	* Callback to negotiate the pixel format. Decoding only, may be set by the
	* caller before avcodec_open2().
	*
	* Called by some decoders to select the pixel format that will be used for
	* the output frames. This is mainly used to set up hardware acceleration,
	* then the provided format list contains the corresponding hwaccel pixel
	* formats alongside the "software" one. The software pixel format may also
	* be retrieved from \ref sw_pix_fmt.
	*
	* This callback will be called when the coded frame properties (such as
	* resolution, pixel format, etc.) change and more than one output format is
	* supported for those new properties. If a hardware pixel format is chosen
	* and initialization for it fails, the callback may be called again
	* immediately.
	*
	* This callback may be called from different threads if the decoder is
	* multi-threaded, but not from more than one thread simultaneously.
	*
	* @param fmt list of formats which may be used in the current
	*            configuration, terminated by AV_PIX_FMT_NONE.
	* @warning Behavior is undefined if the callback returns a value other
	*          than one of the formats in fmt or AV_PIX_FMT_NONE.
	* @return the chosen format or AV_PIX_FMT_NONE
	*/
	get_format: proc "c" (s: ^AVCodecContext, fmt: ^AVPixelFormat) -> AVPixelFormat,

	/**
	* maximum number of B-frames between non-B-frames
	* Note: The output will be delayed by max_b_frames+1 relative to the input.
	* - encoding: Set by user.
	* - decoding: unused
	*/
	max_b_frames: i32,

	/**
	* qscale factor between IP and B-frames
	* If > 0 then the last P-frame quantizer will be used (q= lastp_q*factor+offset).
	* If < 0 then normal ratecontrol will be done (q= -normal_q*factor+offset).
	* - encoding: Set by user.
	* - decoding: unused
	*/
	b_quant_factor: f32,

	/**
	* qscale offset between IP and B-frames
	* - encoding: Set by user.
	* - decoding: unused
	*/
	b_quant_offset: f32,

	/**
	* qscale factor between P- and I-frames
	* If > 0 then the last P-frame quantizer will be used (q = lastp_q * factor + offset).
	* If < 0 then normal ratecontrol will be done (q= -normal_q*factor+offset).
	* - encoding: Set by user.
	* - decoding: unused
	*/
	i_quant_factor: f32,

	/**
	* qscale offset between P and I-frames
	* - encoding: Set by user.
	* - decoding: unused
	*/
	i_quant_offset: f32,

	/**
	* luminance masking (0-> disabled)
	* - encoding: Set by user.
	* - decoding: unused
	*/
	lumi_masking: f32,

	/**
	* temporary complexity masking (0-> disabled)
	* - encoding: Set by user.
	* - decoding: unused
	*/
	temporal_cplx_masking: f32,

	/**
	* spatial complexity masking (0-> disabled)
	* - encoding: Set by user.
	* - decoding: unused
	*/
	spatial_cplx_masking: f32,

	/**
	* p block masking (0-> disabled)
	* - encoding: Set by user.
	* - decoding: unused
	*/
	p_masking: f32,

	/**
	* darkness masking (0-> disabled)
	* - encoding: Set by user.
	* - decoding: unused
	*/
	dark_masking: f32,

	/**
	* noise vs. sse weight for the nsse comparison function
	* - encoding: Set by user.
	* - decoding: unused
	*/
	nsse_weight: i32,

	/**
	* motion estimation comparison function
	* - encoding: Set by user.
	* - decoding: unused
	*/
	me_cmp: i32,

	/**
	* subpixel motion estimation comparison function
	* - encoding: Set by user.
	* - decoding: unused
	*/
	me_sub_cmp: i32,

	/**
	* macroblock comparison function (not supported yet)
	* - encoding: Set by user.
	* - decoding: unused
	*/
	mb_cmp: i32,

	/**
	* interlaced DCT comparison function
	* - encoding: Set by user.
	* - decoding: unused
	*/
	ildct_cmp: i32,

	/**
	* ME diamond size & shape
	* - encoding: Set by user.
	* - decoding: unused
	*/
	dia_size: i32,

	/**
	* amount of previous MV predictors (2a+1 x 2a+1 square)
	* - encoding: Set by user.
	* - decoding: unused
	*/
	last_predictor_count: i32,

	/**
	* motion estimation prepass comparison function
	* - encoding: Set by user.
	* - decoding: unused
	*/
	me_pre_cmp: i32,

	/**
	* ME prepass diamond size & shape
	* - encoding: Set by user.
	* - decoding: unused
	*/
	pre_dia_size: i32,

	/**
	* subpel ME quality
	* - encoding: Set by user.
	* - decoding: unused
	*/
	me_subpel_quality: i32,

	/**
	* maximum motion estimation search range in subpel units
	* If 0 then no limit.
	*
	* - encoding: Set by user.
	* - decoding: unused
	*/
	me_range: i32,

	/**
	* macroblock decision mode
	* - encoding: Set by user.
	* - decoding: unused
	*/
	mb_decision: i32,

	/**
	* custom intra quantization matrix
	* Must be allocated with the av_malloc() family of functions, and will be freed in
	* avcodec_free_context().
	* - encoding: Set/allocated by user, freed by libavcodec. Can be NULL.
	* - decoding: Set/allocated/freed by libavcodec.
	*/
	intra_matrix: ^u16,

	/**
	* custom inter quantization matrix
	* Must be allocated with the av_malloc() family of functions, and will be freed in
	* avcodec_free_context().
	* - encoding: Set/allocated by user, freed by libavcodec. Can be NULL.
	* - decoding: Set/allocated/freed by libavcodec.
	*/
	inter_matrix: ^u16,

	/**
	* custom intra quantization matrix
	* - encoding: Set by user, can be NULL.
	* - decoding: unused.
	*/
	chroma_intra_matrix: ^u16,

	/**
	* precision of the intra DC coefficient - 8
	* - encoding: Set by user.
	* - decoding: Set by libavcodec
	*/
	intra_dc_precision: i32,

	/**
	* minimum MB Lagrange multiplier
	* - encoding: Set by user.
	* - decoding: unused
	*/
	mb_lmin: i32,

	/**
	* maximum MB Lagrange multiplier
	* - encoding: Set by user.
	* - decoding: unused
	*/
	mb_lmax: i32,

	/**
	* - encoding: Set by user.
	* - decoding: unused
	*/
	bidir_refine: i32,

	/**
	* minimum GOP size
	* - encoding: Set by user.
	* - decoding: unused
	*/
	keyint_min: i32,

	/**
	* the number of pictures in a group of pictures, or 0 for intra_only
	* - encoding: Set by user.
	* - decoding: unused
	*/
	gop_size: i32,

	/**
	* Note: Value depends upon the compare function used for fullpel ME.
	* - encoding: Set by user.
	* - decoding: unused
	*/
	mv0_threshold: i32,

	/**
	* Number of slices.
	* Indicates number of picture subdivisions. Used for parallelized
	* decoding.
	* - encoding: Set by user
	* - decoding: unused
	*/
	slices: i32,

	/* audio only */
	sample_rate: i32, ///< samples per second

	/**
	* audio sample format
	* - encoding: Set by user.
	* - decoding: Set by libavcodec.
	*/
	sample_fmt: AVSampleFormat, ///< sample format

	/**
	* Audio channel layout.
	* - encoding: must be set by the caller, to one of AVCodec.ch_layouts.
	* - decoding: may be set by the caller if known e.g. from the container.
	*             The decoder can then override during decoding as needed.
	*/
	ch_layout: i32,

	/* The following data should not be initialized. */
	/**
	* Number of samples per channel in an audio frame.
	*
	* - encoding: set by libavcodec in avcodec_open2(). Each submitted frame
	*   except the last must contain exactly frame_size samples per channel.
	*   May be 0 when the codec has AV_CODEC_CAP_VARIABLE_FRAME_SIZE set, then the
	*   frame size is not restricted.
	* - decoding: may be set by some decoders to indicate constant frame size
	*/
	frame_size: i32,

	/**
	* number of bytes per packet if constant and known or 0
	* Used by some WAV based audio codecs.
	*/
	block_align: i32,

	/**
	* Audio cutoff bandwidth (0 means "automatic")
	* - encoding: Set by user.
	* - decoding: unused
	*/
	cutoff: i32,

	/**
	* Type of service that the audio stream conveys.
	* - encoding: Set by user.
	* - decoding: Set by libavcodec.
	*/
	audio_service_type: AVAudioServiceType,

	/**
	* desired sample format
	* - encoding: Not used.
	* - decoding: Set by user.
	* Decoder will decode to this format if it can.
	*/
	request_sample_fmt: AVSampleFormat,

	/**
	* Audio only. The number of "priming" samples (padding) inserted by the
	* encoder at the beginning of the audio. I.e. this number of leading
	* decoded samples must be discarded by the caller to get the original audio
	* without leading padding.
	*
	* - decoding: unused
	* - encoding: Set by libavcodec. The timestamps on the output packets are
	*             adjusted by the encoder so that they always refer to the
	*             first sample of the data actually contained in the packet,
	*             including any added padding.  E.g. if the timebase is
	*             1/samplerate and the timestamp of the first input sample is
	*             0, the timestamp of the first output packet will be
	*             -initial_padding.
	*/
	initial_padding: i32,

	/**
	* Audio only. The amount of padding (in samples) appended by the encoder to
	* the end of the audio. I.e. this number of decoded samples must be
	* discarded by the caller from the end of the stream to get the original
	* audio without any trailing padding.
	*
	* - decoding: unused
	* - encoding: unused
	*/
	trailing_padding: i32,

	/**
	* Number of samples to skip after a discontinuity
	* - decoding: unused
	* - encoding: set by libavcodec
	*/
	seek_preroll: i32,

	/**
	* This callback is called at the beginning of each frame to get data
	* buffer(s) for it. There may be one contiguous buffer for all the data or
	* there may be a buffer per each data plane or anything in between. What
	* this means is, you may set however many entries in buf[] you feel necessary.
	* Each buffer must be reference-counted using the AVBuffer API (see description
	* of buf[] below).
	*
	* The following fields will be set in the frame before this callback is
	* called:
	* - format
	* - width, height (video only)
	* - sample_rate, channel_layout, nb_samples (audio only)
	* Their values may differ from the corresponding values in
	* AVCodecContext. This callback must use the frame values, not the codec
	* context values, to calculate the required buffer size.
	*
	* This callback must fill the following fields in the frame:
	* - data[]
	* - linesize[]
	* - extended_data:
	*   * if the data is planar audio with more than 8 channels, then this
	*     callback must allocate and fill extended_data to contain all pointers
	*     to all data planes. data[] must hold as many pointers as it can.
	*     extended_data must be allocated with av_malloc() and will be freed in
	*     av_frame_unref().
	*   * otherwise extended_data must point to data
	* - buf[] must contain one or more pointers to AVBufferRef structures. Each of
	*   the frame's data and extended_data pointers must be contained in these. That
	*   is, one AVBufferRef for each allocated chunk of memory, not necessarily one
	*   AVBufferRef per data[] entry. See: av_buffer_create(), av_buffer_alloc(),
	*   and av_buffer_ref().
	* - extended_buf and nb_extended_buf must be allocated with av_malloc() by
	*   this callback and filled with the extra buffers if there are more
	*   buffers than buf[] can hold. extended_buf will be freed in
	*   av_frame_unref().
	*   Decoders will generally initialize the whole buffer before it is output
	*   but it can in rare error conditions happen that uninitialized data is passed
	*   through. \important The buffers returned by get_buffer* should thus not contain sensitive
	*   data.
	*
	* If AV_CODEC_CAP_DR1 is not set then get_buffer2() must call
	* avcodec_default_get_buffer2() instead of providing buffers allocated by
	* some other means.
	*
	* Each data plane must be aligned to the maximum required by the target
	* CPU.
	*
	* @see avcodec_default_get_buffer2()
	*
	* Video:
	*
	* If AV_GET_BUFFER_FLAG_REF is set in flags then the frame may be reused
	* (read and/or written to if it is writable) later by libavcodec.
	*
	* avcodec_align_dimensions2() should be used to find the required width and
	* height, as they normally need to be rounded up to the next multiple of 16.
	*
	* Some decoders do not support linesizes changing between frames.
	*
	* If frame multithreading is used, this callback may be called from a
	* different thread, but not from more than one at once. Does not need to be
	* reentrant.
	*
	* @see avcodec_align_dimensions2()
	*
	* Audio:
	*
	* Decoders request a buffer of a particular size by setting
	* AVFrame.nb_samples prior to calling get_buffer2(). The decoder may,
	* however, utilize only part of the buffer by setting AVFrame.nb_samples
	* to a smaller value in the output frame.
	*
	* As a convenience, av_samples_get_buffer_size() and
	* av_samples_fill_arrays() in libavutil may be used by custom get_buffer2()
	* functions to find the required data size and to fill data pointers and
	* linesize. In AVFrame.linesize, only linesize[0] may be set for audio
	* since all planes must be the same size.
	*
	* @see av_samples_get_buffer_size(), av_samples_fill_arrays()
	*
	* - encoding: unused
	* - decoding: Set by libavcodec, user can override.
	*/
	get_buffer2: proc "c" (s: ^AVCodecContext, frame: ^i32, flags: i32) -> i32,

	/* - encoding parameters */
	/**
	* number of bits the bitstream is allowed to diverge from the reference.
	*           the reference can be CBR (for CBR pass1) or VBR (for pass2)
	* - encoding: Set by user; unused for constant quantizer encoding.
	* - decoding: unused
	*/
	bit_rate_tolerance: i32,

	/**
	* Global quality for codecs which cannot change it per frame.
	* This should be proportional to MPEG-1/2/4 qscale.
	* - encoding: Set by user.
	* - decoding: unused
	*/
	global_quality: i32,

	/**
	* - encoding: Set by user.
	* - decoding: unused
	*/
	compression_level: i32,
	qcompress:         f32, ///< amount of qscale change between easy & hard scenes (0.0-1.0)
	qblur:             f32, ///< amount of qscale smoothing over time (0.0-1.0)

	/**
	* minimum quantizer
	* - encoding: Set by user.
	* - decoding: unused
	*/
	qmin: i32,

	/**
	* maximum quantizer
	* - encoding: Set by user.
	* - decoding: unused
	*/
	qmax: i32,

	/**
	* maximum quantizer difference between frames
	* - encoding: Set by user.
	* - decoding: unused
	*/
	max_qdiff: i32,

	/**
	* decoder bitstream buffer size
	* - encoding: Set by user.
	* - decoding: May be set by libavcodec.
	*/
	rc_buffer_size: i32,

	/**
	* ratecontrol override, see RcOverride
	* - encoding: Allocated/set/freed by user.
	* - decoding: unused
	*/
	rc_override_count: i32,
	rc_override:       ^RcOverride,

	/**
	* maximum bitrate
	* - encoding: Set by user.
	* - decoding: Set by user, may be overwritten by libavcodec.
	*/
	rc_max_rate: i64,

	/**
	* minimum bitrate
	* - encoding: Set by user.
	* - decoding: unused
	*/
	rc_min_rate: i64,

	/**
	* Ratecontrol attempt to use, at maximum, <value> of what can be used without an underflow.
	* - encoding: Set by user.
	* - decoding: unused.
	*/
	rc_max_available_vbv_use: f32,

	/**
	* Ratecontrol attempt to use, at least, <value> times the amount needed to prevent a vbv overflow.
	* - encoding: Set by user.
	* - decoding: unused.
	*/
	rc_min_vbv_overflow_use: f32,

	/**
	* Number of bits which should be loaded into the rc buffer before decoding starts.
	* - encoding: Set by user.
	* - decoding: unused
	*/
	rc_initial_buffer_occupancy: i32,

	/**
	* trellis RD quantization
	* - encoding: Set by user.
	* - decoding: unused
	*/
	trellis: i32,

	/**
	* pass1 encoding statistics output buffer
	* - encoding: Set by libavcodec.
	* - decoding: unused
	*/
	stats_out: cstring,

	/**
	* pass2 encoding statistics input buffer
	* Concatenated stuff from stats_out of pass1 should be placed here.
	* - encoding: Allocated/set/freed by user.
	* - decoding: unused
	*/
	stats_in: cstring,

	/**
	* Work around bugs in encoders which sometimes cannot be detected automatically.
	* - encoding: Set by user
	* - decoding: Set by user
	*/
	workaround_bugs: i32,

	/**
	* strictly follow the standard (MPEG-4, ...).
	* - encoding: Set by user.
	* - decoding: Set by user.
	* Setting this to STRICT or higher means the encoder and decoder will
	* generally do stupid things, whereas setting it to unofficial or lower
	* will mean the encoder might produce output that is not supported by all
	* spec-compliant decoders. Decoders don't differentiate between normal,
	* unofficial and experimental (that is, they always try to decode things
	* when they can) unless they are explicitly asked to behave stupidly
	* (=strictly conform to the specs)
	* This may only be set to one of the FF_COMPLIANCE_* values in defs.h.
	*/
	strict_std_compliance: i32,

	/**
	* error concealment flags
	* - encoding: unused
	* - decoding: Set by user.
	*/
	error_concealment: i32,

	/**
	* debug
	* - encoding: Set by user.
	* - decoding: Set by user.
	*/
	debug: i32,

	/**
	* Error recognition; may misdetect some more or less valid parts as errors.
	* This is a bitfield of the AV_EF_* values defined in defs.h.
	*
	* - encoding: Set by user.
	* - decoding: Set by user.
	*/
	err_recognition: i32,

	/**
	* Hardware accelerator in use
	* - encoding: unused.
	* - decoding: Set by libavcodec
	*/
	hwaccel: ^AVHWAccel,

	/**
	* Legacy hardware accelerator context.
	*
	* For some hardware acceleration methods, the caller may use this field to
	* signal hwaccel-specific data to the codec. The struct pointed to by this
	* pointer is hwaccel-dependent and defined in the respective header. Please
	* refer to the FFmpeg HW accelerator documentation to know how to fill
	* this.
	*
	* In most cases this field is optional - the necessary information may also
	* be provided to libavcodec through @ref hw_frames_ctx or @ref
	* hw_device_ctx (see avcodec_get_hw_config()). However, in some cases it
	* may be the only method of signalling some (optional) information.
	*
	* The struct and its contents are owned by the caller.
	*
	* - encoding: May be set by the caller before avcodec_open2(). Must remain
	*             valid until avcodec_free_context().
	* - decoding: May be set by the caller in the get_format() callback.
	*             Must remain valid until the next get_format() call,
	*             or avcodec_free_context() (whichever comes first).
	*/
	hwaccel_context: rawptr,

	/**
	* A reference to the AVHWFramesContext describing the input (for encoding)
	* or output (decoding) frames. The reference is set by the caller and
	* afterwards owned (and freed) by libavcodec - it should never be read by
	* the caller after being set.
	*
	* - decoding: This field should be set by the caller from the get_format()
	*             callback. The previous reference (if any) will always be
	*             unreffed by libavcodec before the get_format() call.
	*
	*             If the default get_buffer2() is used with a hwaccel pixel
	*             format, then this AVHWFramesContext will be used for
	*             allocating the frame buffers.
	*
	* - encoding: For hardware encoders configured to use a hwaccel pixel
	*             format, this field should be set by the caller to a reference
	*             to the AVHWFramesContext describing input frames.
	*             AVHWFramesContext.format must be equal to
	*             AVCodecContext.pix_fmt.
	*
	*             This field should be set before avcodec_open2() is called.
	*/
	hw_frames_ctx: ^i32,

	/**
	* A reference to the AVHWDeviceContext describing the device which will
	* be used by a hardware encoder/decoder.  The reference is set by the
	* caller and afterwards owned (and freed) by libavcodec.
	*
	* This should be used if either the codec device does not require
	* hardware frames or any that are used are to be allocated internally by
	* libavcodec.  If the user wishes to supply any of the frames used as
	* encoder input or decoder output then hw_frames_ctx should be used
	* instead.  When hw_frames_ctx is set in get_format() for a decoder, this
	* field will be ignored while decoding the associated stream segment, but
	* may again be used on a following one after another get_format() call.
	*
	* For both encoders and decoders this field should be set before
	* avcodec_open2() is called and must not be written to thereafter.
	*
	* Note that some decoders may require this field to be set initially in
	* order to support hw_frames_ctx at all - in that case, all frames
	* contexts used must be created on the same device.
	*/
	hw_device_ctx: ^i32,

	/**
	* Bit set of AV_HWACCEL_FLAG_* flags, which affect hardware accelerated
	* decoding (if active).
	* - encoding: unused
	* - decoding: Set by user (either before avcodec_open2(), or in the
	*             AVCodecContext.get_format callback)
	*/
	hwaccel_flags: i32,

	/**
	* Video decoding only.  Sets the number of extra hardware frames which
	* the decoder will allocate for use by the caller.  This must be set
	* before avcodec_open2() is called.
	*
	* Some hardware decoders require all frames that they will use for
	* output to be defined in advance before decoding starts.  For such
	* decoders, the hardware frame pool must therefore be of a fixed size.
	* The extra frames set here are on top of any number that the decoder
	* needs internally in order to operate normally (for example, frames
	* used as reference pictures).
	*/
	extra_hw_frames: i32,

	/**
	* error
	* - encoding: Set by libavcodec if flags & AV_CODEC_FLAG_PSNR.
	* - decoding: unused
	*/
	error: u64,

	/**
	* DCT algorithm, see FF_DCT_* below
	* - encoding: Set by user.
	* - decoding: unused
	*/
	dct_algo: i32,

	/**
	* IDCT algorithm, see FF_IDCT_* below.
	* - encoding: Set by user.
	* - decoding: Set by user.
	*/
	idct_algo: i32,

	/**
	* bits per sample/pixel from the demuxer (needed for huffyuv).
	* - encoding: Set by libavcodec.
	* - decoding: Set by user.
	*/
	bits_per_coded_sample: i32,

	/**
	* Bits per sample/pixel of internal libavcodec pixel/sample format.
	* - encoding: set by user.
	* - decoding: set by libavcodec.
	*/
	bits_per_raw_sample: i32,

	/**
	* thread count
	* is used to decide how many independent tasks should be passed to execute()
	* - encoding: Set by user.
	* - decoding: Set by user.
	*/
	thread_count: i32,

	/**
	* Which multithreading methods to use.
	* Use of FF_THREAD_FRAME will increase decoding delay by one frame per thread,
	* so clients which cannot provide future frames should not use it.
	*
	* - encoding: Set by user, otherwise the default is used.
	* - decoding: Set by user, otherwise the default is used.
	*/
	thread_type: i32,

	/**
	* Which multithreading methods are in use by the codec.
	* - encoding: Set by libavcodec.
	* - decoding: Set by libavcodec.
	*/
	active_thread_type: i32,

	/**
	* The codec may call this to execute several independent things.
	* It will return only after finishing all tasks.
	* The user may replace this with some multithreaded implementation,
	* the default implementation will execute the parts serially.
	* @param count the number of things to execute
	* - encoding: Set by libavcodec, user can override.
	* - decoding: Set by libavcodec, user can override.
	*/
	execute: proc "c" (_c: ^AVCodecContext, func: proc "c" (c2: ^AVCodecContext, arg: rawptr) -> i32, arg2: rawptr, ret: ^i32, count: i32, size: i32) -> i32,

	/**
	* The codec may call this to execute several independent things.
	* It will return only after finishing all tasks.
	* The user may replace this with some multithreaded implementation,
	* the default implementation will execute the parts serially.
	* @param c context passed also to func
	* @param count the number of things to execute
	* @param arg2 argument passed unchanged to func
	* @param ret return values of executed functions, must have space for "count" values. May be NULL.
	* @param func function that will be called count times, with jobnr from 0 to count-1.
	*             threadnr will be in the range 0 to c->thread_count-1 < MAX_THREADS and so that no
	*             two instances of func executing at the same time will have the same threadnr.
	* @return always 0 currently, but code should handle a future improvement where when any call to func
	*         returns < 0 no further calls to func may be done and < 0 is returned.
	* - encoding: Set by libavcodec, user can override.
	* - decoding: Set by libavcodec, user can override.
	*/
	execute2: proc "c" (_c: ^AVCodecContext, func: proc "c" (c2: ^AVCodecContext, arg: rawptr, jobnr: i32, threadnr: i32) -> i32, arg2: rawptr, ret: ^i32, count: i32) -> i32,

	/**
	* profile
	* - encoding: Set by user.
	* - decoding: Set by libavcodec.
	* See the AV_PROFILE_* defines in defs.h.
	*/
	profile: i32,

	/**
	* Encoding level descriptor.
	* - encoding: Set by user, corresponds to a specific level defined by the
	*   codec, usually corresponding to the profile level, if not specified it
	*   is set to AV_LEVEL_UNKNOWN.
	* - decoding: Set by libavcodec.
	* See AV_LEVEL_* in defs.h.
	*/
	level:      i32,
	properties: i32,

	/**
	* Skip loop filtering for selected frames.
	* - encoding: unused
	* - decoding: Set by user.
	*/
	skip_loop_filter: AVDiscard,

	/**
	* Skip IDCT/dequantization for selected frames.
	* - encoding: unused
	* - decoding: Set by user.
	*/
	skip_idct: AVDiscard,

	/**
	* Skip decoding for selected frames.
	* - encoding: unused
	* - decoding: Set by user.
	*/
	skip_frame: AVDiscard,

	/**
	* Skip processing alpha if supported by codec.
	* Note that if the format uses pre-multiplied alpha (common with VP6,
	* and recommended due to better video quality/compression)
	* the image will look as if alpha-blended onto a black background.
	* However for formats that do not use pre-multiplied alpha
	* there might be serious artefacts (though e.g. libswscale currently
	* assumes pre-multiplied alpha anyway).
	*
	* - decoding: set by user
	* - encoding: unused
	*/
	skip_alpha: i32,

	/**
	* Number of macroblock rows at the top which are skipped.
	* - encoding: unused
	* - decoding: Set by user.
	*/
	skip_top: i32,

	/**
	* Number of macroblock rows at the bottom which are skipped.
	* - encoding: unused
	* - decoding: Set by user.
	*/
	skip_bottom: i32,

	/**
	* low resolution decoding, 1-> 1/2 size, 2->1/4 size
	* - encoding: unused
	* - decoding: Set by user.
	*/
	lowres: i32,

	/**
	* AVCodecDescriptor
	* - encoding: unused.
	* - decoding: set by libavcodec.
	*/
	codec_descriptor: ^AVCodecDescriptor,

	/**
	* Character encoding of the input subtitles file.
	* - decoding: set by user
	* - encoding: unused
	*/
	sub_charenc: cstring,

	/**
	* Subtitles character encoding mode. Formats or codecs might be adjusting
	* this setting (if they are doing the conversion themselves for instance).
	* - decoding: set by libavcodec
	* - encoding: unused
	*/
	sub_charenc_mode: i32,

	/**
	* Header containing style information for text subtitles.
	* For SUBTITLE_ASS subtitle type, it should contain the whole ASS
	* [Script Info] and [V4+ Styles] section, plus the [Events] line and
	* the Format line following. It shouldn't include any Dialogue line.
	*
	* - encoding: May be set by the caller before avcodec_open2() to an array
	*   allocated with the av_malloc() family of functions.
	* - decoding: May be set by libavcodec in avcodec_open2().
	*
	* After being set, the array is owned by the codec and freed in
	* avcodec_free_context().
	*/
	subtitle_header_size: i32,
	subtitle_header:      ^u8,

	/**
	* dump format separator.
	* can be ", " or "\n      " or anything else
	* - encoding: Set by user.
	* - decoding: Set by user.
	*/
	dump_separator: ^u8,

	/**
	* ',' separated list of allowed decoders.
	* If NULL then all are allowed
	* - encoding: unused
	* - decoding: set by user
	*/
	codec_whitelist: cstring,

	/**
	* Additional data associated with the entire coded stream.
	*
	* - decoding: may be set by user before calling avcodec_open2().
	* - encoding: may be set by libavcodec after avcodec_open2().
	*/
	coded_side_data:    ^AVPacketSideData,
	nb_coded_side_data: i32,

	/**
	* Bit set of AV_CODEC_EXPORT_DATA_* flags, which affects the kind of
	* metadata exported in frame, packet, or coded stream side data by
	* decoders and encoders.
	*
	* - decoding: set by user
	* - encoding: set by user
	*/
	export_side_data: i32,

	/**
	* The number of pixels per image to maximally accept.
	*
	* - decoding: set by user
	* - encoding: set by user
	*/
	max_pixels: i64,

	/**
	* Video decoding only. Certain video codecs support cropping, meaning that
	* only a sub-rectangle of the decoded frame is intended for display.  This
	* option controls how cropping is handled by libavcodec.
	*
	* When set to 1 (the default), libavcodec will apply cropping internally.
	* I.e. it will modify the output frame width/height fields and offset the
	* data pointers (only by as much as possible while preserving alignment, or
	* by the full amount if the AV_CODEC_FLAG_UNALIGNED flag is set) so that
	* the frames output by the decoder refer only to the cropped area. The
	* crop_* fields of the output frames will be zero.
	*
	* When set to 0, the width/height fields of the output frames will be set
	* to the coded dimensions and the crop_* fields will describe the cropping
	* rectangle. Applying the cropping is left to the caller.
	*
	* @warning When hardware acceleration with opaque output frames is used,
	* libavcodec is unable to apply cropping from the top/left border.
	*
	* @note when this option is set to zero, the width/height fields of the
	* AVCodecContext and output AVFrames have different meanings. The codec
	* context fields store display dimensions (with the coded dimensions in
	* coded_width/height), while the frame fields store the coded dimensions
	* (with the display dimensions being determined by the crop_* fields).
	*/
	apply_cropping: i32,

	/**
	* The percentage of damaged samples to discard a frame.
	*
	* - decoding: set by user
	* - encoding: unused
	*/
	discard_damaged_percentage: i32,

	/**
	* The number of samples per frame to maximally accept.
	*
	* - decoding: set by user
	* - encoding: set by user
	*/
	max_samples: i64,

	/**
	* This callback is called at the beginning of each packet to get a data
	* buffer for it.
	*
	* The following field will be set in the packet before this callback is
	* called:
	* - size
	* This callback must use the above value to calculate the required buffer size,
	* which must padded by at least AV_INPUT_BUFFER_PADDING_SIZE bytes.
	*
	* In some specific cases, the encoder may not use the entire buffer allocated by this
	* callback. This will be reflected in the size value in the packet once returned by
	* avcodec_receive_packet().
	*
	* This callback must fill the following fields in the packet:
	* - data: alignment requirements for AVPacket apply, if any. Some architectures and
	*   encoders may benefit from having aligned data.
	* - buf: must contain a pointer to an AVBufferRef structure. The packet's
	*   data pointer must be contained in it. See: av_buffer_create(), av_buffer_alloc(),
	*   and av_buffer_ref().
	*
	* If AV_CODEC_CAP_DR1 is not set then get_encode_buffer() must call
	* avcodec_default_get_encode_buffer() instead of providing a buffer allocated by
	* some other means.
	*
	* The flags field may contain a combination of AV_GET_ENCODE_BUFFER_FLAG_ flags.
	* They may be used for example to hint what use the buffer may get after being
	* created.
	* Implementations of this callback may ignore flags they don't understand.
	* If AV_GET_ENCODE_BUFFER_FLAG_REF is set in flags then the packet may be reused
	* (read and/or written to if it is writable) later by libavcodec.
	*
	* This callback must be thread-safe, as when frame threading is used, it may
	* be called from multiple threads simultaneously.
	*
	* @see avcodec_default_get_encode_buffer()
	*
	* - encoding: Set by libavcodec, user can override.
	* - decoding: unused
	*/
	get_encode_buffer: proc "c" (s: ^AVCodecContext, pkt: ^AVPacket, flags: i32) -> i32,

	/**
	* Frame counter, set by libavcodec.
	*
	* - decoding: total number of frames returned from the decoder so far.
	* - encoding: total number of frames passed to the encoder so far.
	*
	*   @note the counter is not incremented if encoding/decoding resulted in
	*   an error.
	*/
	frame_num: i64,

	/**
	* Decoding only. May be set by the caller before avcodec_open2() to an
	* av_malloc()'ed array (or via AVOptions). Owned and freed by the decoder
	* afterwards.
	*
	* Side data attached to decoded frames may come from several sources:
	* 1. coded_side_data, which the decoder will for certain types translate
	*    from packet-type to frame-type and attach to frames;
	* 2. side data attached to an AVPacket sent for decoding (same
	*    considerations as above);
	* 3. extracted from the coded bytestream.
	* The first two cases are supplied by the caller and typically come from a
	* container.
	*
	* This array configures decoder behaviour in cases when side data of the
	* same type is present both in the coded bytestream and in the
	* user-supplied side data (items 1. and 2. above). In all cases, at most
	* one instance of each side data type will be attached to output frames. By
	* default it will be the bytestream side data. Adding an
	* AVPacketSideDataType value to this array will flip the preference for
	* this type, thus making the decoder prefer user-supplied side data over
	* bytestream. In case side data of the same type is present both in
	* coded_data and attacked to a packet, the packet instance always has
	* priority.
	*
	* The array may also contain a single -1, in which case the preference is
	* switched for all side data types.
	*/
	side_data_prefer_packet: ^i32,

	/**
	* Number of entries in side_data_prefer_packet.
	*/
	nb_side_data_prefer_packet: u32,

	/**
	* Array containing static side data, such as HDR10 CLL / MDCV structures.
	* Side data entries should be allocated by usage of helpers defined in
	* libavutil/frame.h.
	*
	* - encoding: may be set by user before calling avcodec_open2() for
	*             encoder configuration. Afterwards owned and freed by the
	*             encoder.
	* - decoding: may be set by libavcodec in avcodec_open2().
	*/
	decoded_side_data:    ^^i32,
	nb_decoded_side_data: i32,
}

AVCodecInternal :: struct {}

SLICE_FLAG_CODED_ORDER            :: 0x0001 ///< draw_horiz_band() is called in coded order instead of display
SLICE_FLAG_ALLOW_FIELD            :: 0x0002 ///< allow draw_horiz_band() with field slices (MPEG-2 field pics)
SLICE_FLAG_ALLOW_PLANE            :: 0x0004 ///< allow draw_horiz_band() with 1 component at a time (SVQ1)
FF_CMP_SAD                        :: 0
FF_CMP_SSE                        :: 1
FF_CMP_SATD                       :: 2
FF_CMP_DCT                        :: 3
FF_CMP_PSNR                       :: 4
FF_CMP_BIT                        :: 5
FF_CMP_RD                         :: 6
FF_CMP_ZERO                       :: 7
FF_CMP_VSAD                       :: 8
FF_CMP_VSSE                       :: 9
FF_CMP_NSSE                       :: 10
FF_CMP_W53                        :: 11
FF_CMP_W97                        :: 12
FF_CMP_DCTMAX                     :: 13
FF_CMP_DCT264                     :: 14
FF_CMP_MEDIAN_SAD                 :: 15
FF_CMP_CHROMA                     :: 256
FF_MB_DECISION_SIMPLE             :: 0        ///< uses mb_cmp
FF_MB_DECISION_BITS               :: 1        ///< chooses the one which needs the fewest bits
FF_MB_DECISION_RD                 :: 2        ///< rate distortion
FF_COMPRESSION_DEFAULT            :: -1
FF_BUG_AUTODETECT                 :: 1      ///< autodetection
FF_BUG_XVID_ILACE                 :: 4
FF_BUG_UMP4                       :: 8
FF_BUG_NO_PADDING                 :: 16
FF_BUG_AMV                        :: 32
FF_BUG_QPEL_CHROMA                :: 64
FF_BUG_STD_QPEL                   :: 128
FF_BUG_QPEL_CHROMA2               :: 256
FF_BUG_DIRECT_BLOCKSIZE           :: 512
FF_BUG_EDGE                       :: 1024
FF_BUG_HPEL_CHROMA                :: 2048
FF_BUG_DC_CLIP                    :: 4096
FF_BUG_MS                         :: 8192   ///< Work around various bugs in Microsoft's broken decoders.
FF_BUG_TRUNCATED                  :: 16384
FF_BUG_IEDGE                      :: 32768
FF_EC_GUESS_MVS                   :: 1
FF_EC_DEBLOCK                     :: 2
FF_EC_FAVOR_INTER                 :: 256
FF_DEBUG_PICT_INFO                :: 1
FF_DEBUG_RC                       :: 2
FF_DEBUG_BITSTREAM                :: 4
FF_DEBUG_MB_TYPE                  :: 8
FF_DEBUG_QP                       :: 16
FF_DEBUG_DCT_COEFF                :: 0x00000040
FF_DEBUG_SKIP                     :: 0x00000080
FF_DEBUG_STARTCODE                :: 0x00000100
FF_DEBUG_ER                       :: 0x00000400
FF_DEBUG_MMCO                     :: 0x00000800
FF_DEBUG_BUGS                     :: 0x00001000
FF_DEBUG_BUFFERS                  :: 0x00008000
FF_DEBUG_THREADS                  :: 0x00010000
FF_DEBUG_GREEN_MD                 :: 0x00800000
FF_DEBUG_NOMC                     :: 0x01000000
FF_DCT_AUTO                       :: 0
FF_DCT_FASTINT                    :: 1
FF_DCT_INT                        :: 2
FF_DCT_MMX                        :: 3
FF_DCT_ALTIVEC                    :: 5
FF_DCT_FAAN                       :: 6
FF_DCT_NEON                       :: 7
FF_IDCT_AUTO                      :: 0
FF_IDCT_INT                       :: 1
FF_IDCT_SIMPLE                    :: 2
FF_IDCT_SIMPLEMMX                 :: 3
FF_IDCT_ARM                       :: 7
FF_IDCT_ALTIVEC                   :: 8
FF_IDCT_SIMPLEARM                 :: 10
FF_IDCT_XVID                      :: 14
FF_IDCT_SIMPLEARMV5TE             :: 16
FF_IDCT_SIMPLEARMV6               :: 17
FF_IDCT_FAAN                      :: 20
FF_IDCT_SIMPLENEON                :: 22
FF_IDCT_SIMPLEAUTO                :: 128
FF_THREAD_FRAME                   :: 1      ///< Decode more than one frame at once
FF_THREAD_SLICE                   :: 2      ///< Decode more than one part of a single frame at once
FF_CODEC_PROPERTY_LOSSLESS        :: 0x00000001
FF_CODEC_PROPERTY_CLOSED_CAPTIONS :: 0x00000002
FF_CODEC_PROPERTY_FILM_GRAIN      :: 0x00000004
FF_SUB_CHARENC_MODE_DO_NOTHING    :: -1     ///< do nothing (demuxer outputs a stream supposed to be already in UTF-8, or the codec is bitmap for instance)
FF_SUB_CHARENC_MODE_AUTOMATIC     :: 0      ///< libavcodec will select the mode itself
FF_SUB_CHARENC_MODE_PRE_DECODER   :: 1      ///< the AVPacket data needs to be recoded to UTF-8 before being fed to the decoder, requires iconv
FF_SUB_CHARENC_MODE_IGNORE        :: 2      ///< neither convert the subtitles, nor check them for valid UTF-8

/**
* @defgroup lavc_hwaccel AVHWAccel
*
* @note  Nothing in this structure should be accessed by the user.  At some
*        point in future it will not be externally visible at all.
*
* @{
*/
AVHWAccel :: struct {}

/**
* HWAccel is experimental and is thus avoided in favor of non experimental
* codecs
*/
AV_HWACCEL_CODEC_CAP_EXPERIMENTAL :: 0x0200

/**
* Hardware acceleration should be used for decoding even if the codec level
* used is unknown or higher than the maximum supported level reported by the
* hardware driver.
*
* It's generally a good idea to pass this flag unless you have a specific
* reason not to, as hardware tends to under-report supported levels.
*/
AV_HWACCEL_FLAG_IGNORE_LEVEL :: (1<<0)

/**
* Hardware acceleration can output YUV pixel formats with a different chroma
* sampling than 4:2:0 and/or other than 8 bits per component.
*/
AV_HWACCEL_FLAG_ALLOW_HIGH_DEPTH :: (1<<1)

/**
* Hardware acceleration should still be attempted for decoding when the
* codec profile does not match the reported capabilities of the hardware.
*
* For example, this can be used to try to decode baseline profile H.264
* streams in hardware - it will often succeed, because many streams marked
* as baseline profile actually conform to constrained baseline profile.
*
* @warning If the stream is actually not supported then the behaviour is
*          undefined, and may include returning entirely incorrect output
*          while indicating success.
*/
AV_HWACCEL_FLAG_ALLOW_PROFILE_MISMATCH :: (1<<2)

/**
* Some hardware decoders (namely nvdec) can either output direct decoder
* surfaces, or make an on-device copy and return said copy.
* There is a hard limit on how many decoder surfaces there can be, and it
* cannot be accurately guessed ahead of time.
* For some processing chains, this can be okay, but others will run into the
* limit and in turn produce very confusing errors that require fine tuning of
* more or less obscure options by the user, or in extreme cases cannot be
* resolved at all without inserting an avfilter that forces a copy.
*
* Thus, the hwaccel will by default make a copy for safety and resilience.
* If a users really wants to minimize the amount of copies, they can set this
* flag and ensure their processing chain does not exhaust the surface pool.
*/
AV_HWACCEL_FLAG_UNSAFE_OUTPUT :: (1<<3)

/**
* @}
*/
AVSubtitleType :: enum i32 {
	NONE   = 0,
	BITMAP = 1, ///< A bitmap, pict will be set

	/**
	* Plain text, the text field must be set by the decoder and is
	* authoritative. ass and pict fields may contain approximations.
	*/
	TEXT   = 2,

	/**
	* Formatted text, the ass field must be set by the decoder and is
	* authoritative. pict and text fields may contain approximations.
	*/
	ASS    = 3,
}

AV_SUBTITLE_FLAG_FORCED :: 0x00000001

AVSubtitleRect :: struct {
	x:         i32, ///< top left corner  of pict, undefined when pict is not set
	y:         i32, ///< top left corner  of pict, undefined when pict is not set
	w:         i32, ///< width            of pict, undefined when pict is not set
	h:         i32, ///< height           of pict, undefined when pict is not set
	nb_colors: i32, ///< number of colors in pict, undefined when pict is not set

	/**
	* data+linesize for the bitmap of this subtitle.
	* Can be set for text/ass as well once they are rendered.
	*/
	data:     [4]^u8,
	linesize: [4]i32,
	flags:    i32,
	type:     AVSubtitleType,
	text:     cstring, ///< 0 terminated plain UTF-8 text

	/**
	* 0 terminated ASS/SSA compatible event line.
	* The presentation of this is unaffected by the other values in this
	* struct.
	*/
	ass: cstring,
}

AVSubtitle :: struct {
	format:             u16, /* 0 = graphics */
	start_display_time: u32, /* relative to packet pts, in ms */
	end_display_time:   u32, /* relative to packet pts, in ms */
	num_rects:          u32,
	rects:              ^^AVSubtitleRect,
	pts:                i64, ///< Same as packet pts, in AV_TIME_BASE
}

@(default_calling_convention="c")
foreign lib {
	/**
	* Return the LIBAVCODEC_VERSION_INT constant.
	*/
	avcodec_version :: proc() -> u32 ---

	/**
	* Return the libavcodec build-time configuration.
	*/
	avcodec_configuration :: proc() -> cstring ---

	/**
	* Return the libavcodec license.
	*/
	avcodec_license :: proc() -> cstring ---

	/**
	* Allocate an AVCodecContext and set its fields to default values. The
	* resulting struct should be freed with avcodec_free_context().
	*
	* @param codec if non-NULL, allocate private data and initialize defaults
	*              for the given codec. It is illegal to then call avcodec_open2()
	*              with a different codec.
	*              If NULL, then the codec-specific defaults won't be initialized,
	*              which may result in suboptimal default settings (this is
	*              important mainly for encoders, e.g. libx264).
	*
	* @return An AVCodecContext filled with default values or NULL on failure.
	*/
	avcodec_alloc_context3 :: proc(codec: ^AVCodec) -> ^AVCodecContext ---

	/**
	* Free the codec context and everything associated with it and write NULL to
	* the provided pointer.
	*/
	avcodec_free_context :: proc(avctx: ^^AVCodecContext) ---

	/**
	* Get the AVClass for AVCodecContext. It can be used in combination with
	* AV_OPT_SEARCH_FAKE_OBJ for examining options.
	*
	* @see av_opt_find().
	*/
	avcodec_get_class :: proc() -> ^i32 ---

	/**
	* Get the AVClass for AVSubtitleRect. It can be used in combination with
	* AV_OPT_SEARCH_FAKE_OBJ for examining options.
	*
	* @see av_opt_find().
	*/
	avcodec_get_subtitle_rect_class :: proc() -> ^i32 ---

	/**
	* Fill the parameters struct based on the values from the supplied codec
	* context. Any allocated fields in par are freed and replaced with duplicates
	* of the corresponding fields in codec.
	*
	* @return >= 0 on success, a negative AVERROR code on failure
	*/
	avcodec_parameters_from_context :: proc(par: ^AVCodecParameters, codec: ^AVCodecContext) -> i32 ---

	/**
	* Fill the codec context based on the values from the supplied codec
	* parameters. Any allocated fields in codec that have a corresponding field in
	* par are freed and replaced with duplicates of the corresponding field in par.
	* Fields in codec that do not have a counterpart in par are not touched.
	*
	* @return >= 0 on success, a negative AVERROR code on failure.
	*/
	avcodec_parameters_to_context :: proc(codec: ^AVCodecContext, par: ^AVCodecParameters) -> i32 ---

	/**
	* Initialize the AVCodecContext to use the given AVCodec. Prior to using this
	* function the context has to be allocated with avcodec_alloc_context3().
	*
	* The functions avcodec_find_decoder_by_name(), avcodec_find_encoder_by_name(),
	* avcodec_find_decoder() and avcodec_find_encoder() provide an easy way for
	* retrieving a codec.
	*
	* Depending on the codec, you might need to set options in the codec context
	* also for decoding (e.g. width, height, or the pixel or audio sample format in
	* the case the information is not available in the bitstream, as when decoding
	* raw audio or video).
	*
	* Options in the codec context can be set either by setting them in the options
	* AVDictionary, or by setting the values in the context itself, directly or by
	* using the av_opt_set() API before calling this function.
	*
	* Example:
	* @code
	* av_dict_set(&opts, "b", "2.5M", 0);
	* codec = avcodec_find_decoder(AV_CODEC_ID_H264);
	* if (!codec)
	*     exit(1);
	*
	* context = avcodec_alloc_context3(codec);
	*
	* if (avcodec_open2(context, codec, opts) < 0)
	*     exit(1);
	* @endcode
	*
	* In the case AVCodecParameters are available (e.g. when demuxing a stream
	* using libavformat, and accessing the AVStream contained in the demuxer), the
	* codec parameters can be copied to the codec context using
	* avcodec_parameters_to_context(), as in the following example:
	*
	* @code
	* AVStream *stream = ...;
	* context = avcodec_alloc_context3(codec);
	* if (avcodec_parameters_to_context(context, stream->codecpar) < 0)
	*     exit(1);
	* if (avcodec_open2(context, codec, NULL) < 0)
	*     exit(1);
	* @endcode
	*
	* @note Always call this function before using decoding routines (such as
	* @ref avcodec_receive_frame()).
	*
	* @param avctx The context to initialize.
	* @param codec The codec to open this context for. If a non-NULL codec has been
	*              previously passed to avcodec_alloc_context3() or
	*              for this context, then this parameter MUST be either NULL or
	*              equal to the previously passed codec.
	* @param options A dictionary filled with AVCodecContext and codec-private
	*                options, which are set on top of the options already set in
	*                avctx, can be NULL. On return this object will be filled with
	*                options that were not found in the avctx codec context.
	*
	* @return zero on success, a negative value on error
	* @see avcodec_alloc_context3(), avcodec_find_decoder(), avcodec_find_encoder(),
	*      av_dict_set(), av_opt_set(), av_opt_find(), avcodec_parameters_to_context()
	*/
	avcodec_open2 :: proc(avctx: ^AVCodecContext, codec: ^AVCodec, options: ^^i32) -> i32 ---

	/**
	* Free all allocated data in the given subtitle struct.
	*
	* @param sub AVSubtitle to free.
	*/
	avsubtitle_free :: proc(sub: ^AVSubtitle) ---

	/**
	* The default callback for AVCodecContext.get_buffer2(). It is made public so
	* it can be called by custom get_buffer2() implementations for decoders without
	* AV_CODEC_CAP_DR1 set.
	*/
	avcodec_default_get_buffer2 :: proc(s: ^AVCodecContext, frame: ^i32, flags: i32) -> i32 ---

	/**
	* The default callback for AVCodecContext.get_encode_buffer(). It is made public so
	* it can be called by custom get_encode_buffer() implementations for encoders without
	* AV_CODEC_CAP_DR1 set.
	*/
	avcodec_default_get_encode_buffer :: proc(s: ^AVCodecContext, pkt: ^AVPacket, flags: i32) -> i32 ---

	/**
	* Modify width and height values so that they will result in a memory
	* buffer that is acceptable for the codec if you do not use any horizontal
	* padding.
	*
	* May only be used if a codec with AV_CODEC_CAP_DR1 has been opened.
	*/
	avcodec_align_dimensions :: proc(s: ^AVCodecContext, width: ^i32, height: ^i32) ---

	/**
	* Modify width and height values so that they will result in a memory
	* buffer that is acceptable for the codec if you also ensure that all
	* line sizes are a multiple of the respective linesize_align[i].
	*
	* May only be used if a codec with AV_CODEC_CAP_DR1 has been opened.
	*/
	avcodec_align_dimensions2 :: proc(s: ^AVCodecContext, width: ^i32, height: ^i32, linesize_align: i32) ---

	/**
	* Decode a subtitle message.
	* Return a negative value on error, otherwise return the number of bytes used.
	* If no subtitle could be decompressed, got_sub_ptr is zero.
	* Otherwise, the subtitle is stored in *sub.
	* Note that AV_CODEC_CAP_DR1 is not available for subtitle codecs. This is for
	* simplicity, because the performance difference is expected to be negligible
	* and reusing a get_buffer written for video codecs would probably perform badly
	* due to a potentially very different allocation pattern.
	*
	* Some decoders (those marked with AV_CODEC_CAP_DELAY) have a delay between input
	* and output. This means that for some packets they will not immediately
	* produce decoded output and need to be flushed at the end of decoding to get
	* all the decoded data. Flushing is done by calling this function with packets
	* with avpkt->data set to NULL and avpkt->size set to 0 until it stops
	* returning subtitles. It is safe to flush even those decoders that are not
	* marked with AV_CODEC_CAP_DELAY, then no subtitles will be returned.
	*
	* @note The AVCodecContext MUST have been opened with @ref avcodec_open2()
	* before packets may be fed to the decoder.
	*
	* @param avctx the codec context
	* @param[out] sub The preallocated AVSubtitle in which the decoded subtitle will be stored,
	*                 must be freed with avsubtitle_free if *got_sub_ptr is set.
	* @param[in,out] got_sub_ptr Zero if no subtitle could be decompressed, otherwise, it is nonzero.
	* @param[in] avpkt The input AVPacket containing the input buffer.
	*/
	avcodec_decode_subtitle2 :: proc(avctx: ^AVCodecContext, sub: ^AVSubtitle, got_sub_ptr: ^i32, avpkt: ^AVPacket) -> i32 ---

	/**
	* Supply raw packet data as input to a decoder.
	*
	* Internally, this call will copy relevant AVCodecContext fields, which can
	* influence decoding per-packet, and apply them when the packet is actually
	* decoded. (For example AVCodecContext.skip_frame, which might direct the
	* decoder to drop the frame contained by the packet sent with this function.)
	*
	* @warning The input buffer, avpkt->data must be AV_INPUT_BUFFER_PADDING_SIZE
	*          larger than the actual read bytes because some optimized bitstream
	*          readers read 32 or 64 bits at once and could read over the end.
	*
	* @note The AVCodecContext MUST have been opened with @ref avcodec_open2()
	*       before packets may be fed to the decoder.
	*
	* @param avctx codec context
	* @param[in] avpkt The input AVPacket. Usually, this will be a single video
	*                  frame, or several complete audio frames.
	*                  Ownership of the packet remains with the caller, and the
	*                  decoder will not write to the packet. The decoder may create
	*                  a reference to the packet data (or copy it if the packet is
	*                  not reference-counted).
	*                  Unlike with older APIs, the packet is always fully consumed,
	*                  and if it contains multiple frames (e.g. some audio codecs),
	*                  will require you to call avcodec_receive_frame() multiple
	*                  times afterwards before you can send a new packet.
	*                  It can be NULL (or an AVPacket with data set to NULL and
	*                  size set to 0); in this case, it is considered a flush
	*                  packet, which signals the end of the stream. Sending the
	*                  first flush packet will return success. Subsequent ones are
	*                  unnecessary and will return AVERROR_EOF. If the decoder
	*                  still has frames buffered, it will return them after sending
	*                  a flush packet.
	*
	* @retval 0                 success
	* @retval AVERROR(EAGAIN)   input is not accepted in the current state - user
	*                           must read output with avcodec_receive_frame() (once
	*                           all output is read, the packet should be resent,
	*                           and the call will not fail with EAGAIN).
	* @retval AVERROR_EOF       the decoder has been flushed, and no new packets can be
	*                           sent to it (also returned if more than 1 flush
	*                           packet is sent)
	* @retval AVERROR(EINVAL)   codec not opened, it is an encoder, or requires flush
	* @retval AVERROR(ENOMEM)   failed to add packet to internal queue, or similar
	* @retval "another negative error code" legitimate decoding errors
	*/
	avcodec_send_packet :: proc(avctx: ^AVCodecContext, avpkt: ^AVPacket) -> i32 ---

	/**
	* Return decoded output data from a decoder or encoder (when the
	* @ref AV_CODEC_FLAG_RECON_FRAME flag is used).
	*
	* @param avctx codec context
	* @param frame This will be set to a reference-counted video or audio
	*              frame (depending on the decoder type) allocated by the
	*              codec. Note that the function will always call
	*              av_frame_unref(frame) before doing anything else.
	*
	* @retval 0                success, a frame was returned
	* @retval AVERROR(EAGAIN)  output is not available in this state - user must
	*                          try to send new input
	* @retval AVERROR_EOF      the codec has been fully flushed, and there will be
	*                          no more output frames
	* @retval AVERROR(EINVAL)  codec not opened, or it is an encoder without the
	*                          @ref AV_CODEC_FLAG_RECON_FRAME flag enabled
	* @retval "other negative error code" legitimate decoding errors
	*/
	avcodec_receive_frame :: proc(avctx: ^AVCodecContext, frame: ^i32) -> i32 ---

	/**
	* Supply a raw video or audio frame to the encoder. Use avcodec_receive_packet()
	* to retrieve buffered output packets.
	*
	* @param avctx     codec context
	* @param[in] frame AVFrame containing the raw audio or video frame to be encoded.
	*                  Ownership of the frame remains with the caller, and the
	*                  encoder will not write to the frame. The encoder may create
	*                  a reference to the frame data (or copy it if the frame is
	*                  not reference-counted).
	*                  It can be NULL, in which case it is considered a flush
	*                  packet.  This signals the end of the stream. If the encoder
	*                  still has packets buffered, it will return them after this
	*                  call. Once flushing mode has been entered, additional flush
	*                  packets are ignored, and sending frames will return
	*                  AVERROR_EOF.
	*
	*                  For audio:
	*                  If AV_CODEC_CAP_VARIABLE_FRAME_SIZE is set, then each frame
	*                  can have any number of samples.
	*                  If it is not set, frame->nb_samples must be equal to
	*                  avctx->frame_size for all frames except the last.
	*                  The final frame may be smaller than avctx->frame_size.
	* @retval 0                 success
	* @retval AVERROR(EAGAIN)   input is not accepted in the current state - user must
	*                           read output with avcodec_receive_packet() (once all
	*                           output is read, the packet should be resent, and the
	*                           call will not fail with EAGAIN).
	* @retval AVERROR_EOF       the encoder has been flushed, and no new frames can
	*                           be sent to it
	* @retval AVERROR(EINVAL)   codec not opened, it is a decoder, or requires flush
	* @retval AVERROR(ENOMEM)   failed to add packet to internal queue, or similar
	* @retval "another negative error code" legitimate encoding errors
	*/
	avcodec_send_frame :: proc(avctx: ^AVCodecContext, frame: ^i32) -> i32 ---

	/**
	* Read encoded data from the encoder.
	*
	* @param avctx codec context
	* @param avpkt This will be set to a reference-counted packet allocated by the
	*              encoder. Note that the function will always call
	*              av_packet_unref(avpkt) before doing anything else.
	* @retval 0               success
	* @retval AVERROR(EAGAIN) output is not available in the current state - user must
	*                         try to send input
	* @retval AVERROR_EOF     the encoder has been fully flushed, and there will be no
	*                         more output packets
	* @retval AVERROR(EINVAL) codec not opened, or it is a decoder
	* @retval "another negative error code" legitimate encoding errors
	*/
	avcodec_receive_packet :: proc(avctx: ^AVCodecContext, avpkt: ^AVPacket) -> i32 ---

	/**
	* Create and return a AVHWFramesContext with values adequate for hardware
	* decoding. This is meant to get called from the get_format callback, and is
	* a helper for preparing a AVHWFramesContext for AVCodecContext.hw_frames_ctx.
	* This API is for decoding with certain hardware acceleration modes/APIs only.
	*
	* The returned AVHWFramesContext is not initialized. The caller must do this
	* with av_hwframe_ctx_init().
	*
	* Calling this function is not a requirement, but makes it simpler to avoid
	* codec or hardware API specific details when manually allocating frames.
	*
	* Alternatively to this, an API user can set AVCodecContext.hw_device_ctx,
	* which sets up AVCodecContext.hw_frames_ctx fully automatically, and makes
	* it unnecessary to call this function or having to care about
	* AVHWFramesContext initialization at all.
	*
	* There are a number of requirements for calling this function:
	*
	* - It must be called from get_format with the same avctx parameter that was
	*   passed to get_format. Calling it outside of get_format is not allowed, and
	*   can trigger undefined behavior.
	* - The function is not always supported (see description of return values).
	*   Even if this function returns successfully, hwaccel initialization could
	*   fail later. (The degree to which implementations check whether the stream
	*   is actually supported varies. Some do this check only after the user's
	*   get_format callback returns.)
	* - The hw_pix_fmt must be one of the choices suggested by get_format. If the
	*   user decides to use a AVHWFramesContext prepared with this API function,
	*   the user must return the same hw_pix_fmt from get_format.
	* - The device_ref passed to this function must support the given hw_pix_fmt.
	* - After calling this API function, it is the user's responsibility to
	*   initialize the AVHWFramesContext (returned by the out_frames_ref parameter),
	*   and to set AVCodecContext.hw_frames_ctx to it. If done, this must be done
	*   before returning from get_format (this is implied by the normal
	*   AVCodecContext.hw_frames_ctx API rules).
	* - The AVHWFramesContext parameters may change every time time get_format is
	*   called. Also, AVCodecContext.hw_frames_ctx is reset before get_format. So
	*   you are inherently required to go through this process again on every
	*   get_format call.
	* - It is perfectly possible to call this function without actually using
	*   the resulting AVHWFramesContext. One use-case might be trying to reuse a
	*   previously initialized AVHWFramesContext, and calling this API function
	*   only to test whether the required frame parameters have changed.
	* - Fields that use dynamically allocated values of any kind must not be set
	*   by the user unless setting them is explicitly allowed by the documentation.
	*   If the user sets AVHWFramesContext.free and AVHWFramesContext.user_opaque,
	*   the new free callback must call the potentially set previous free callback.
	*   This API call may set any dynamically allocated fields, including the free
	*   callback.
	*
	* The function will set at least the following fields on AVHWFramesContext
	* (potentially more, depending on hwaccel API):
	*
	* - All fields set by av_hwframe_ctx_alloc().
	* - Set the format field to hw_pix_fmt.
	* - Set the sw_format field to the most suited and most versatile format. (An
	*   implication is that this will prefer generic formats over opaque formats
	*   with arbitrary restrictions, if possible.)
	* - Set the width/height fields to the coded frame size, rounded up to the
	*   API-specific minimum alignment.
	* - Only _if_ the hwaccel requires a pre-allocated pool: set the initial_pool_size
	*   field to the number of maximum reference surfaces possible with the codec,
	*   plus 1 surface for the user to work (meaning the user can safely reference
	*   at most 1 decoded surface at a time), plus additional buffering introduced
	*   by frame threading. If the hwaccel does not require pre-allocation, the
	*   field is left to 0, and the decoder will allocate new surfaces on demand
	*   during decoding.
	* - Possibly AVHWFramesContext.hwctx fields, depending on the underlying
	*   hardware API.
	*
	* Essentially, out_frames_ref returns the same as av_hwframe_ctx_alloc(), but
	* with basic frame parameters set.
	*
	* The function is stateless, and does not change the AVCodecContext or the
	* device_ref AVHWDeviceContext.
	*
	* @param avctx The context which is currently calling get_format, and which
	*              implicitly contains all state needed for filling the returned
	*              AVHWFramesContext properly.
	* @param device_ref A reference to the AVHWDeviceContext describing the device
	*                   which will be used by the hardware decoder.
	* @param hw_pix_fmt The hwaccel format you are going to return from get_format.
	* @param out_frames_ref On success, set to a reference to an _uninitialized_
	*                       AVHWFramesContext, created from the given device_ref.
	*                       Fields will be set to values required for decoding.
	*                       Not changed if an error is returned.
	* @return zero on success, a negative value on error. The following error codes
	*         have special semantics:
	*      AVERROR(ENOENT): the decoder does not support this functionality. Setup
	*                       is always manual, or it is a decoder which does not
	*                       support setting AVCodecContext.hw_frames_ctx at all,
	*                       or it is a software format.
	*      AVERROR(EINVAL): it is known that hardware decoding is not supported for
	*                       this configuration, or the device_ref is not supported
	*                       for the hwaccel referenced by hw_pix_fmt.
	*/
	avcodec_get_hw_frames_parameters :: proc(avctx: ^AVCodecContext, device_ref: ^i32, hw_pix_fmt: AVPixelFormat, out_frames_ref: ^^i32) -> i32 ---
}

AVCodecConfig :: enum i32 {
	PIX_FORMAT     = 0, ///< AVPixelFormat, terminated by AV_PIX_FMT_NONE
	FRAME_RATE     = 1, ///< AVRational, terminated by {0, 0}
	SAMPLE_RATE    = 2, ///< int, terminated by 0
	SAMPLE_FORMAT  = 3, ///< AVSampleFormat, terminated by AV_SAMPLE_FMT_NONE
	CHANNEL_LAYOUT = 4, ///< AVChannelLayout, terminated by {0}
	COLOR_RANGE    = 5, ///< AVColorRange, terminated by AVCOL_RANGE_UNSPECIFIED
	COLOR_SPACE    = 6, ///< AVColorSpace, terminated by AVCOL_SPC_UNSPECIFIED
}

@(default_calling_convention="c")
foreign lib {
	/**
	* Retrieve a list of all supported values for a given configuration type.
	*
	* @param avctx An optional context to use. Values such as
	*              `strict_std_compliance` may affect the result. If NULL,
	*              default values are used.
	* @param codec The codec to query, or NULL to use avctx->codec.
	* @param config The configuration to query.
	* @param flags Currently unused; should be set to zero.
	* @param out_configs On success, set to a list of configurations, terminated
	*                    by a config-specific terminator, or NULL if all
	*                    possible values are supported.
	* @param out_num_configs On success, set to the number of elements in
	*out_configs, excluding the terminator. Optional.
	*/
	avcodec_get_supported_config :: proc(avctx: ^AVCodecContext, codec: ^AVCodec, config: AVCodecConfig, flags: u32, out_configs: ^rawptr, out_num_configs: ^i32) -> i32 ---
}

/**
* @defgroup lavc_parsing Frame parsing
* @{
*/
AVPictureStructure :: enum i32 {
	UNKNOWN      = 0, ///< unknown
	TOP_FIELD    = 1, ///< coded as top field
	BOTTOM_FIELD = 2, ///< coded as bottom field
	FRAME        = 3, ///< coded as frame
}

AVCodecParserContext :: struct {
	priv_data:         rawptr,
	parser:            ^AVCodecParser,
	frame_offset:      i64, /* offset of the current frame */
	cur_offset:        i64, /* current offset
                           (incremented by each av_parser_parse()) */
	next_frame_offset: i64, /* offset of the next frame */

	/* video info */
	pict_type: i32, /* XXX: Put it back in AVCodecContext. */

	/**
	* This field is used for proper frame duration computation in lavf.
	* It signals, how much longer the frame duration of the current frame
	* is compared to normal frame duration.
	*
	* frame_duration = (1 + repeat_pict) * time_base
	*
	* It is used by codecs like H.264 to display telecined material.
	*/
	repeat_pict: i32, /* XXX: Put it back in AVCodecContext. */
	pts:         i64, /* pts of the current frame */
	dts:         i64, /* dts of the current frame */

	/* private data */
	last_pts:              i64,
	last_dts:              i64,
	fetch_timestamp:       i32,
	cur_frame_start_index: i32,
	cur_frame_offset:      [4]i64,
	cur_frame_pts:         [4]i64,
	cur_frame_dts:         [4]i64,
	flags:                 i32,
	offset:                i64, ///< byte offset from starting packet start
	cur_frame_end:         [4]i64,

	/**
	* Set by parser to 1 for key frames and 0 for non-key frames.
	* It is initialized to -1, so if the parser doesn't set this flag,
	* old-style fallback using AV_PICTURE_TYPE_I picture type as key frames
	* will be used.
	*/
	key_frame: i32,

	// Timestamp generation support:
	/**
	* Synchronization point for start of timestamp generation.
	*
	* Set to >0 for sync point, 0 for no sync point and <0 for undefined
	* (default).
	*
	* For example, this corresponds to presence of H.264 buffering period
	* SEI message.
	*/
	dts_sync_point: i32,

	/**
	* Offset of the current timestamp against last timestamp sync point in
	* units of AVCodecContext.time_base.
	*
	* Set to INT_MIN when dts_sync_point unused. Otherwise, it must
	* contain a valid timestamp offset.
	*
	* Note that the timestamp of sync point has usually a nonzero
	* dts_ref_dts_delta, which refers to the previous sync point. Offset of
	* the next frame after timestamp sync point will be usually 1.
	*
	* For example, this corresponds to H.264 cpb_removal_delay.
	*/
	dts_ref_dts_delta: i32,

	/**
	* Presentation delay of current frame in units of AVCodecContext.time_base.
	*
	* Set to INT_MIN when dts_sync_point unused. Otherwise, it must
	* contain valid non-negative timestamp delta (presentation time of a frame
	* must not lie in the past).
	*
	* This delay represents the difference between decoding and presentation
	* time of the frame.
	*
	* For example, this corresponds to H.264 dpb_output_delay.
	*/
	pts_dts_delta: i32,

	/**
	* Position of the packet in file.
	*
	* Analogous to cur_frame_pts/dts
	*/
	cur_frame_pos: [4]i64,

	/**
	* Byte position of currently parsed frame in stream.
	*/
	pos: i64,

	/**
	* Previous frame byte position.
	*/
	last_pos: i64,

	/**
	* Duration of the current frame.
	* For audio, this is in units of 1 / AVCodecContext.sample_rate.
	* For all other types, this is in units of AVCodecContext.time_base.
	*/
	duration:    i32,
	field_order: AVFieldOrder,

	/**
	* Indicate whether a picture is coded as a frame, top field or bottom field.
	*
	* For example, H.264 field_pic_flag equal to 0 corresponds to
	* AV_PICTURE_STRUCTURE_FRAME. An H.264 picture with field_pic_flag
	* equal to 1 and bottom_field_flag equal to 0 corresponds to
	* AV_PICTURE_STRUCTURE_TOP_FIELD.
	*/
	picture_structure: AVPictureStructure,

	/**
	* Picture number incremented in presentation or output order.
	* This field may be reinitialized at the first picture of a new sequence.
	*
	* For example, this corresponds to H.264 PicOrderCnt.
	*/
	output_picture_number: i32,

	/**
	* Dimensions of the decoded video intended for presentation.
	*/
	width:  i32,
	height: i32,

	/**
	* Dimensions of the coded video.
	*/
	coded_width:  i32,
	coded_height: i32,

	/**
	* The format of the coded data, corresponds to enum AVPixelFormat for video
	* and for enum AVSampleFormat for audio.
	*
	* Note that a decoder can have considerable freedom in how exactly it
	* decodes the data, so the format reported here might be different from the
	* one returned by a decoder.
	*/
	format: i32,
}

AV_PARSER_PTS_NB            :: 4
PARSER_FLAG_COMPLETE_FRAMES           :: 0x0001
PARSER_FLAG_ONCE                      :: 0x0002

/// Set if the parser has a valid file offset
PARSER_FLAG_FETCHED_OFFSET            :: 0x0004
PARSER_FLAG_USE_CODEC_TS              :: 0x1000

AVCodecParser :: struct {}

@(default_calling_convention="c")
foreign lib {
	/**
	* Iterate over all registered codec parsers.
	*
	* @param opaque a pointer where libavcodec will store the iteration state. Must
	*               point to NULL to start the iteration.
	*
	* @return the next registered codec parser or NULL when the iteration is
	*         finished
	*/
	av_parser_iterate :: proc(opaque: ^rawptr) -> ^AVCodecParser ---
	av_parser_init    :: proc(codec_id: i32) -> ^AVCodecParserContext ---

	/**
	* Parse a packet.
	*
	* @param s             parser context.
	* @param avctx         codec context.
	* @param poutbuf       set to pointer to parsed buffer or NULL if not yet finished.
	* @param poutbuf_size  set to size of parsed buffer or zero if not yet finished.
	* @param buf           input buffer.
	* @param buf_size      buffer size in bytes without the padding. I.e. the full buffer
	size is assumed to be buf_size + AV_INPUT_BUFFER_PADDING_SIZE.
	To signal EOF, this should be 0 (so that the last frame
	can be output).
	* @param pts           input presentation timestamp.
	* @param dts           input decoding timestamp.
	* @param pos           input byte position in stream.
	* @return the number of bytes of the input bitstream used.
	*
	* Example:
	* @code
	*   while(in_len){
	*       len = av_parser_parse2(myparser, AVCodecContext, &data, &size,
	*                                        in_data, in_len,
	*                                        pts, dts, pos);
	*       in_data += len;
	*       in_len  -= len;
	*
	*       if(size)
	*          decode_frame(data, size);
	*   }
	* @endcode
	*/
	av_parser_parse2 :: proc(s: ^AVCodecParserContext, avctx: ^AVCodecContext, poutbuf: ^^u8, poutbuf_size: ^i32, buf: ^u8, buf_size: i32, pts: i64, dts: i64, pos: i64) -> i32 ---
	av_parser_close  :: proc(s: ^AVCodecParserContext) ---

	/**
	* @addtogroup lavc_encoding
	* @{
	*/
	avcodec_encode_subtitle :: proc(avctx: ^AVCodecContext, buf: ^u8, buf_size: i32, sub: ^AVSubtitle) -> i32 ---

	/**
	* Return a value representing the fourCC code associated to the
	* pixel format pix_fmt, or 0 if no associated fourCC code can be
	* found.
	*/
	avcodec_pix_fmt_to_codec_tag :: proc(pix_fmt: AVPixelFormat) -> u32 ---

	/**
	* Find the best pixel format to convert to given a certain source pixel
	* format.  When converting from one pixel format to another, information loss
	* may occur.  For example, when converting from RGB24 to GRAY, the color
	* information will be lost. Similarly, other losses occur when converting from
	* some formats to other formats. avcodec_find_best_pix_fmt_of_2() searches which of
	* the given pixel formats should be used to suffer the least amount of loss.
	* The pixel formats from which it chooses one, are determined by the
	* pix_fmt_list parameter.
	*
	*
	* @param[in] pix_fmt_list AV_PIX_FMT_NONE terminated array of pixel formats to choose from
	* @param[in] src_pix_fmt source pixel format
	* @param[in] has_alpha Whether the source pixel format alpha channel is used.
	* @param[out] loss_ptr Combination of flags informing you what kind of losses will occur.
	* @return The best pixel format to convert to or -1 if none was found.
	*/
	avcodec_find_best_pix_fmt_of_list :: proc(pix_fmt_list: ^AVPixelFormat, src_pix_fmt: AVPixelFormat, has_alpha: i32, loss_ptr: ^i32) -> AVPixelFormat ---
	avcodec_default_get_format        :: proc(s: ^AVCodecContext, fmt: ^AVPixelFormat) -> AVPixelFormat ---

	/**
	* @}
	*/
	avcodec_string           :: proc(buf: cstring, buf_size: i32, enc: ^AVCodecContext, encode: i32) ---
	avcodec_default_execute  :: proc(_c: ^AVCodecContext, func: proc "c" (c2: ^AVCodecContext, arg2: rawptr) -> i32, arg: rawptr, ret: ^i32, count: i32, size: i32) -> i32 ---
	avcodec_default_execute2 :: proc(_c: ^AVCodecContext, func: proc "c" (c2: ^AVCodecContext, arg2: rawptr, _: i32, _: i32) -> i32, arg: rawptr, ret: ^i32, count: i32) -> i32 ---

	/**
	* Fill AVFrame audio data and linesize pointers.
	*
	* The buffer buf must be a preallocated buffer with a size big enough
	* to contain the specified samples amount. The filled AVFrame data
	* pointers will point to this buffer.
	*
	* AVFrame extended_data channel pointers are allocated if necessary for
	* planar audio.
	*
	* @param frame       the AVFrame
	*                    frame->nb_samples must be set prior to calling the
	*                    function. This function fills in frame->data,
	*                    frame->extended_data, frame->linesize[0].
	* @param nb_channels channel count
	* @param sample_fmt  sample format
	* @param buf         buffer to use for frame data
	* @param buf_size    size of buffer
	* @param align       plane size sample alignment (0 = default)
	* @return            >=0 on success, negative error code on failure
	* @todo return the size in bytes required to store the samples in
	* case of success, at the next libavutil bump
	*/
	avcodec_fill_audio_frame :: proc(frame: ^i32, nb_channels: i32, sample_fmt: AVSampleFormat, buf: ^u8, buf_size: i32, align: i32) -> i32 ---

	/**
	* Reset the internal codec state / flush internal buffers. Should be called
	* e.g. when seeking or when switching to a different stream.
	*
	* @note for decoders, this function just releases any references the decoder
	* might keep internally, but the caller's references remain valid.
	*
	* @note for encoders, this function will only do something if the encoder
	* declares support for AV_CODEC_CAP_ENCODER_FLUSH. When called, the encoder
	* will drain any remaining packets, and can then be reused for a different
	* stream (as opposed to sending a null frame which will leave the encoder
	* in a permanent EOF state after draining). This can be desirable if the
	* cost of tearing down and replacing the encoder instance is high.
	*/
	avcodec_flush_buffers :: proc(avctx: ^AVCodecContext) ---

	/**
	* Return audio frame duration.
	*
	* @param avctx        codec context
	* @param frame_bytes  size of the frame, or 0 if unknown
	* @return             frame duration, in samples, if known. 0 if not able to
	*                     determine.
	*/
	av_get_audio_frame_duration :: proc(avctx: ^AVCodecContext, frame_bytes: i32) -> i32 ---

	/**
	* Same behaviour av_fast_malloc but the buffer has additional
	* AV_INPUT_BUFFER_PADDING_SIZE at the end which will always be 0.
	*
	* In addition the whole buffer will initially and after resizes
	* be 0-initialized so that no uninitialized data will ever appear.
	*/
	av_fast_padded_malloc :: proc(ptr: rawptr, size: ^u32, min_size: c.size_t) ---

	/**
	* Same behaviour av_fast_padded_malloc except that buffer will always
	* be 0-initialized after call.
	*/
	av_fast_padded_mallocz :: proc(ptr: rawptr, size: ^u32, min_size: c.size_t) ---

	/**
	* @return a positive value if s is open (i.e. avcodec_open2() was called on it),
	* 0 otherwise.
	*/
	avcodec_is_open :: proc(s: ^AVCodecContext) -> i32 ---
}

