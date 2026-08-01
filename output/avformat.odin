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

import "core:c/libc"
import "core:c"

when ODIN_OS == .Windows {
    foreign import lib "lib/avformat.lib"
} else when ODIN_OS == .Darwin {
    @(extra_linker_flags = "-L/opt/homebrew/lib")
    foreign import lib "system:avformat"
}

@(default_calling_convention="c")
foreign lib {
	/**
	* Allocate and read the payload of a packet and initialize its
	* fields with default values.
	*
	* @param s    associated IO context
	* @param pkt packet
	* @param size desired payload size
	* @return >0 (read size) if OK, AVERROR_xxx otherwise
	*/
	av_get_packet :: proc(s: ^AVIOContext, pkt: ^i32, size: i32) -> i32 ---

	/**
	* Read data and append it to the current content of the AVPacket.
	* If pkt->size is 0 this is identical to av_get_packet.
	* Note that this uses av_grow_packet and thus involves a realloc
	* which is inefficient. Thus this function should only be used
	* when there is no reasonable way to know (an upper bound of)
	* the final size.
	*
	* @param s    associated IO context
	* @param pkt packet
	* @param size amount of data to read
	* @return >0 (read size) if OK, AVERROR_xxx otherwise, previous data
	*         will not be lost even if an error occurs.
	*/
	av_append_packet :: proc(s: ^AVIOContext, pkt: ^i32, size: i32) -> i32 ---
}

/*************************************************/
/* input/output formats */
AVCodecTag :: struct {}

/**
* This structure contains the data a format has to probe a file.
*/
AVProbeData :: struct {
	filename:  cstring,
	buf:       ^u8,     /**< Buffer must have AVPROBE_PADDING_SIZE of extra allocated bytes filled with zero. */
	buf_size:  i32,     /**< Size of buf except extra allocated bytes */
	mime_type: cstring, /**< mime_type, when known. */
}

AVPROBE_SCORE_RETRY        :: (100/4)
AVPROBE_SCORE_STREAM_RETRY :: (100/4-1)
AVPROBE_SCORE_EXTENSION    :: 50  ///< score for file extension
AVPROBE_SCORE_MIME_BONUS   :: 30  ///< score added for matching mime type
AVPROBE_SCORE_MAX          :: 100 ///< maximum score
AVPROBE_PADDING_SIZE       :: 32             ///< extra allocated bytes at the end of the probe buffer

/// Demuxer will use avio_open, no opened file should be provided by the caller.
AVFMT_NOFILE        :: 0x0001
AVFMT_NEEDNUMBER    :: 0x0002 /**< Needs '%d' in filename. */

/**
* The muxer/demuxer is experimental and should be used with caution.
*
* It will not be selected automatically, and must be specified explicitly.
*/
AVFMT_EXPERIMENTAL  :: 0x0004
AVFMT_SHOW_IDS      :: 0x0008    /**< Show format stream IDs numbers. */
AVFMT_GLOBALHEADER  :: 0x0040    /**< Format wants global header. */
AVFMT_NOTIMESTAMPS  :: 0x0080    /**< Format does not need / have any timestamps. */
AVFMT_GENERIC_INDEX :: 0x0100    /**< Use generic index building code. */
AVFMT_TS_DISCONT    :: 0x0200    /**< Format allows timestamp discontinuities. Note, muxers always require valid (monotone) timestamps */
AVFMT_VARIABLE_FPS  :: 0x0400    /**< Format allows variable fps. */
AVFMT_NODIMENSIONS  :: 0x0800    /**< Format does not need width/height */
AVFMT_NOSTREAMS     :: 0x1000    /**< Format does not require any streams */
AVFMT_NOBINSEARCH   :: 0x2000    /**< Format does not allow to fall back on binary search via read_timestamp */
AVFMT_NOGENSEARCH   :: 0x4000    /**< Format does not allow to fall back on generic search */
AVFMT_NO_BYTE_SEEK  :: 0x8000    /**< Format does not allow seeking by bytes */
AVFMT_TS_NONSTRICT  :: 0x20000   /**< Format does not require strictly
                                        increasing timestamps, but they must
                                        still be monotonic */
AVFMT_TS_NEGATIVE   :: 0x40000   /**< Format allows muxing negative
                                        timestamps. If not set the timestamp
                                        will be shifted in av_write_frame and
                                        av_interleaved_write_frame so they
                                        start from 0.
                                        The user or muxer can override this through
                                        AVFormatContext.avoid_negative_ts
                                        */
AVFMT_SEEK_TO_PTS   :: 0x4000000 /**< Seeking is based on PTS */

/**
* @addtogroup lavf_encoding
* @{
*/
AVOutputFormat :: struct {
	name: cstring,

	/**
	* Descriptive name for the format, meant to be more human-readable
	* than name. You should use the NULL_IF_CONFIG_SMALL() macro
	* to define it.
	*/
	long_name:  cstring,
	mime_type:  cstring,
	extensions: cstring, /**< comma-separated filename extensions */

	/* output support */
	audio_codec:    AVCodecID, /**< default audio codec */
	video_codec:    AVCodecID, /**< default video codec */
	subtitle_codec: AVCodecID, /**< default subtitle codec */

	/**
	* can use flags: AVFMT_NOFILE, AVFMT_NEEDNUMBER,
	* AVFMT_GLOBALHEADER, AVFMT_NOTIMESTAMPS, AVFMT_VARIABLE_FPS,
	* AVFMT_NODIMENSIONS, AVFMT_NOSTREAMS,
	* AVFMT_TS_NONSTRICT, AVFMT_TS_NEGATIVE
	*/
	flags: i32,

	/**
	* List of supported codec_id-codec_tag pairs, ordered by "better
	* choice first". The arrays are all terminated by AV_CODEC_ID_NONE.
	*/
	codec_tag:  ^^AVCodecTag,
	priv_class: ^i32, ///< AVClass for the private context
}

AVCodecID :: enum i32 {
} /**< default audio codec */

/**
* @addtogroup lavf_decoding
* @{
*/
AVInputFormat :: struct {
	/**
	* A comma separated list of short names for the format. New names
	* may be appended with a minor bump.
	*/
	name: cstring,

	/**
	* Descriptive name for the format, meant to be more human-readable
	* than name. You should use the NULL_IF_CONFIG_SMALL() macro
	* to define it.
	*/
	long_name: cstring,

	/**
	* Can use flags: AVFMT_NOFILE, AVFMT_NEEDNUMBER, AVFMT_SHOW_IDS,
	* AVFMT_NOTIMESTAMPS, AVFMT_GENERIC_INDEX, AVFMT_TS_DISCONT, AVFMT_NOBINSEARCH,
	* AVFMT_NOGENSEARCH, AVFMT_NO_BYTE_SEEK, AVFMT_SEEK_TO_PTS.
	*/
	flags: i32,

	/**
	* If extensions are defined, then no probe is done. You should
	* usually not use extension format guessing because it is not
	* reliable enough
	*/
	extensions: cstring,
	codec_tag:  ^^AVCodecTag,
	priv_class: ^i32, ///< AVClass for the private context

	/**
	* Comma-separated list of mime types.
	* It is used check for matching mime types while probing.
	* @see av_probe_input_format2
	*/
	mime_type: cstring,
}

/**
* @}
*/
AVStreamParseType :: enum i32 {
	NONE       = 0,
	FULL       = 1, /**< full parsing and repack */
	HEADERS    = 2, /**< Only parse headers, do not repack. */
	TIMESTAMPS = 3, /**< full parsing and interpolation of timestamps for frames not starting on a packet boundary */
	FULL_ONCE  = 4, /**< full parsing and repack of the first frame only, only implemented for H.264 currently */
	FULL_RAW   = 5, /**< full parsing and repack with timestamp and position generation by parser for raw
                                    this assumes that each packet in the file contains no demuxer level headers and
                                    just codec level data, otherwise position generation would fail */
}

AVIndexEntry :: struct {
	pos:          i64,
	timestamp:    i64, /**<
                               * Timestamp in AVStream.time_base units, preferably the time from which on correctly decoded frames are available
                               * when seeking to this entry. That means preferable PTS on keyframe based formats.
                               * But demuxers can choose to store a different timestamp, if it is more convenient for the implementation or nothing better
                               * is known
                               */
	flags:        i32,
	size:         i32, //Yeah, trying to keep the size of this small to reduce memory requirements (it is 24 vs. 32 bytes due to possible 8-byte alignment).
	min_distance: i32, /**< Minimum distance between this and the previous keyframe, used to avoid unneeded searching. */
}

AVINDEX_KEYFRAME      :: 0x0001
AVINDEX_DISCARD_FRAME  :: 0x0002    /**
                                          * Flag is used to indicate which frame should be discarded after decoding.
                                          */

/**
* The stream should be chosen by default among other streams of the same type,
* unless the user has explicitly specified otherwise.
*/
AV_DISPOSITION_DEFAULT              :: (1<<0)

/**
* The stream is not in original language.
*
* @note AV_DISPOSITION_ORIGINAL is the inverse of this disposition. At most
*       one of them should be set in properly tagged streams.
* @note This disposition may apply to any stream type, not just audio.
*/
AV_DISPOSITION_DUB                  :: (1<<1)

/**
* The stream is in original language.
*
* @see the notes for AV_DISPOSITION_DUB
*/
AV_DISPOSITION_ORIGINAL             :: (1<<2)

/**
* The stream is a commentary track.
*/
AV_DISPOSITION_COMMENT              :: (1<<3)

/**
* The stream contains song lyrics.
*/
AV_DISPOSITION_LYRICS               :: (1<<4)

/**
* The stream contains karaoke audio.
*/
AV_DISPOSITION_KARAOKE              :: (1<<5)

/**
* Track should be used during playback by default.
* Useful for subtitle track that should be displayed
* even when user did not explicitly ask for subtitles.
*/
AV_DISPOSITION_FORCED               :: (1<<6)

/**
* The stream is intended for hearing impaired audiences.
*/
AV_DISPOSITION_HEARING_IMPAIRED     :: (1<<7)

/**
* The stream is intended for visually impaired audiences.
*/
AV_DISPOSITION_VISUAL_IMPAIRED      :: (1<<8)

/**
* The audio stream contains music and sound effects without voice.
*/
AV_DISPOSITION_CLEAN_EFFECTS        :: (1<<9)

/**
* The stream is stored in the file as an attached picture/"cover art" (e.g.
* APIC frame in ID3v2). The first (usually only) packet associated with it
* will be returned among the first few packets read from the file unless
* seeking takes place. It can also be accessed at any time in
* AVStream.attached_pic.
*/
AV_DISPOSITION_ATTACHED_PIC         :: (1<<10)

/**
* The stream is sparse, and contains thumbnail images, often corresponding
* to chapter markers. Only ever used with AV_DISPOSITION_ATTACHED_PIC.
*/
AV_DISPOSITION_TIMED_THUMBNAILS     :: (1<<11)

/**
* The stream is intended to be mixed with a spatial audio track. For example,
* it could be used for narration or stereo music, and may remain unchanged by
* listener head rotation.
*/
AV_DISPOSITION_NON_DIEGETIC         :: (1<<12)

/**
* The subtitle stream contains captions, providing a transcription and possibly
* a translation of audio. Typically intended for hearing-impaired audiences.
*/
AV_DISPOSITION_CAPTIONS             :: (1<<16)

/**
* The subtitle stream contains a textual description of the video content.
* Typically intended for visually-impaired audiences or for the cases where the
* video cannot be seen.
*/
AV_DISPOSITION_DESCRIPTIONS         :: (1<<17)

/**
* The subtitle stream contains time-aligned metadata that is not intended to be
* directly presented to the user.
*/
AV_DISPOSITION_METADATA             :: (1<<18)

/**
* The stream is intended to be mixed with another stream before presentation.
* Used for example to signal the stream contains an image part of a HEIF grid,
* or for mix_type=0 in mpegts.
*/
AV_DISPOSITION_DEPENDENT            :: (1<<19)

/**
* The video stream contains still images.
*/
AV_DISPOSITION_STILL_IMAGE          :: (1<<20)

/**
* The video stream contains multiple layers, e.g. stereoscopic views (cf. H.264
* Annex G/H, or HEVC Annex F).
*/
AV_DISPOSITION_MULTILAYER           :: (1<<21)

@(default_calling_convention="c")
foreign lib {
	/**
	* @return The AV_DISPOSITION_* flag corresponding to disp or a negative error
	*         code if disp does not correspond to a known stream disposition.
	*/
	av_disposition_from_string :: proc(disp: cstring) -> i32 ---

	/**
	* @param disposition a combination of AV_DISPOSITION_* values
	* @return The string description corresponding to the lowest set bit in
	*         disposition. NULL when the lowest set bit does not correspond
	*         to a known disposition or when disposition is 0.
	*/
	av_disposition_to_string :: proc(disposition: i32) -> cstring ---
}

/**
* Options for behavior on timestamp wrap detection.
*/
AV_PTS_WRAP_IGNORE      :: 0   ///< ignore the wrap
AV_PTS_WRAP_ADD_OFFSET  :: 1   ///< add the format specific offset on wrap detection
AV_PTS_WRAP_SUB_OFFSET  :: -1  ///< subtract the format specific offset on wrap detection

/**
* Stream structure.
* New fields can be added to the end with minor version bumps.
* Removal, reordering and changes to existing fields require a major
* version bump.
* sizeof(AVStream) must not be used outside libav*.
*/
AVStream :: struct {
	/**
	* A class for @ref avoptions. Set on stream creation.
	*/
	av_class: ^i32,
	index:    i32, /**< stream index in AVFormatContext */

	/**
	* Format-specific stream ID.
	* decoding: set by libavformat
	* encoding: set by the user, replaced by libavformat if left unset
	*/
	id: i32,

	/**
	* Codec parameters associated with this stream. Allocated and freed by
	* libavformat in avformat_new_stream() and avformat_free_context()
	* respectively.
	*
	* - demuxing: filled by libavformat on stream creation or in
	*             avformat_find_stream_info()
	* - muxing: filled by the caller before avformat_write_header()
	*/
	codecpar:  ^i32,
	priv_data: rawptr,

	/**
	* This is the fundamental unit of time (in seconds) in terms
	* of which frame timestamps are represented.
	*
	* decoding: set by libavformat
	* encoding: May be set by the caller before avformat_write_header() to
	*           provide a hint to the muxer about the desired timebase. In
	*           avformat_write_header(), the muxer will overwrite this field
	*           with the timebase that will actually be used for the timestamps
	*           written into the file (which may or may not be related to the
	*           user-provided one, depending on the format).
	*/
	time_base: i32,

	/**
	* Decoding: pts of the first frame of the stream in presentation order, in stream time base.
	* Only set this if you are absolutely 100% sure that the value you set
	* it to really is the pts of the first frame.
	* This may be undefined (AV_NOPTS_VALUE).
	* @note The ASF header does NOT contain a correct start_time the ASF
	* demuxer must NOT set this.
	*/
	start_time: i64,

	/**
	* Decoding: duration of the stream, in stream time base.
	* If a source file does not specify a duration, but does specify
	* a bitrate, this value will be estimated from bitrate and file size.
	*
	* Encoding: May be set by the caller before avformat_write_header() to
	* provide a hint to the muxer about the estimated duration.
	*/
	duration:  i64,
	nb_frames: i64, ///< number of frames in this stream if known or 0

	/**
	* Stream disposition - a combination of AV_DISPOSITION_* flags.
	* - demuxing: set by libavformat when creating the stream or in
	*             avformat_find_stream_info().
	* - muxing: may be set by the caller before avformat_write_header().
	*/
	disposition: i32,
	discard:     AVDiscard, ///< Selects which packets can be discarded at will and do not need to be demuxed.

	/**
	* sample aspect ratio (0 if unknown)
	* - encoding: Set by user.
	* - decoding: Set by libavformat.
	*/
	sample_aspect_ratio: i32,
	metadata:            ^i32,

	/**
	* Average framerate
	*
	* - demuxing: May be set by libavformat when creating the stream or in
	*             avformat_find_stream_info().
	* - muxing: May be set by the caller before avformat_write_header().
	*/
	avg_frame_rate: i32,

	/**
	* For streams with AV_DISPOSITION_ATTACHED_PIC disposition, this packet
	* will contain the attached picture.
	*
	* decoding: set by libavformat, must not be modified by the caller.
	* encoding: unused
	*/
	attached_pic: i32,

	/**
	* Flags indicating events happening on the stream, a combination of
	* AVSTREAM_EVENT_FLAG_*.
	*
	* - demuxing: may be set by the demuxer in avformat_open_input(),
	*   avformat_find_stream_info() and av_read_frame(). Flags must be cleared
	*   by the user once the event has been handled.
	* - muxing: may be set by the user after avformat_write_header(). to
	*   indicate a user-triggered event.  The muxer will clear the flags for
	*   events it has handled in av_[interleaved]_write_frame().
	*/
	event_flags: i32,

	/**
	* Real base framerate of the stream.
	* This is the lowest framerate with which all timestamps can be
	* represented accurately (it is the least common multiple of all
	* framerates in the stream). Note, this value is just a guess!
	* For example, if the time base is 1/90000 and all frames have either
	* approximately 3600 or 1800 timer ticks, then r_frame_rate will be 50/1.
	*/
	r_frame_rate: i32,

	/**
	* Number of bits in timestamps. Used for wrapping control.
	*
	* - demuxing: set by libavformat
	* - muxing: set by libavformat
	*
	*/
	pts_wrap_bits: i32,
}

AVDiscard :: enum i32 {
} ///< Selects which packets can be discarded at will and do not need to be demuxed.

/**
* - demuxing: the demuxer read new metadata from the file and updated
*     AVStream.metadata accordingly
* - muxing: the user updated AVStream.metadata and wishes the muxer to write
*     it into the file
*/
AVSTREAM_EVENT_FLAG_METADATA_UPDATED :: 0x0001

/**
* - demuxing: new packets for this stream were read from the file. This
*   event is informational only and does not guarantee that new packets
*   for this stream will necessarily be returned from av_read_frame().
*/
AVSTREAM_EVENT_FLAG_NEW_PACKETS :: (1<<1)

/**
* AVStreamGroupTileGrid holds information on how to combine several
* independent images on a single canvas for presentation.
*
* The output should be a @ref AVStreamGroupTileGrid.background "background"
* colored @ref AVStreamGroupTileGrid.coded_width "coded_width" x
* @ref AVStreamGroupTileGrid.coded_height "coded_height" canvas where a
* @ref AVStreamGroupTileGrid.nb_tiles "nb_tiles" amount of tiles are placed in
* the order they appear in the @ref AVStreamGroupTileGrid.offsets "offsets"
* array, at the exact offset described for them. In particular, if two or more
* tiles overlap, the image with higher index in the
* @ref AVStreamGroupTileGrid.offsets "offsets" array takes priority.
* Note that a single image may be used multiple times, i.e. multiple entries
* in @ref AVStreamGroupTileGrid.offsets "offsets" may have the same value of
* idx.
*
* The following is an example of a simple grid with 3 rows and 4 columns:
*
* +---+---+---+---+
* | 0 | 1 | 2 | 3 |
* +---+---+---+---+
* | 4 | 5 | 6 | 7 |
* +---+---+---+---+
* | 8 | 9 |10 |11 |
* +---+---+---+---+
*
* Assuming all tiles have a dimension of 512x512, the
* @ref AVStreamGroupTileGrid.offsets "offset" of the topleft pixel of
* the first @ref AVStreamGroup.streams "stream" in the group is "0,0", the
* @ref AVStreamGroupTileGrid.offsets "offset" of the topleft pixel of
* the second @ref AVStreamGroup.streams "stream" in the group is "512,0", the
* @ref AVStreamGroupTileGrid.offsets "offset" of the topleft pixel of
* the fifth @ref AVStreamGroup.streams "stream" in the group is "0,512", the
* @ref AVStreamGroupTileGrid.offsets "offset", of the topleft pixel of
* the sixth @ref AVStreamGroup.streams "stream" in the group is "512,512",
* etc.
*
* The following is an example of a canvas with overlapping tiles:
*
* +-----------+
* |   %%%%%   |
* |***%%3%%@@@|
* |**0%%%%%2@@|
* |***##1@@@@@|
* |   #####   |
* +-----------+
*
* Assuming a canvas with size 1024x1024 and all tiles with a dimension of
* 512x512, a possible @ref AVStreamGroupTileGrid.offsets "offset" for the
* topleft pixel of the first @ref AVStreamGroup.streams "stream" in the group
* would be 0x256, the @ref AVStreamGroupTileGrid.offsets "offset" for the
* topleft pixel of the second @ref AVStreamGroup.streams "stream" in the group
* would be 256x512, the @ref AVStreamGroupTileGrid.offsets "offset" for the
* topleft pixel of the third @ref AVStreamGroup.streams "stream" in the group
* would be 512x256, and the @ref AVStreamGroupTileGrid.offsets "offset" for
* the topleft pixel of the fourth @ref AVStreamGroup.streams "stream" in the
* group would be 256x0.
*
* sizeof(AVStreamGroupTileGrid) is not a part of the ABI and may only be
* allocated by avformat_stream_group_create().
*/
AVStreamGroupTileGrid :: struct {
	av_class: ^i32,

	/**
	* Amount of tiles in the grid.
	*
	* Must be > 0.
	*/
	nb_tiles: u32,

	/**
	* Width of the canvas.
	*
	* Must be > 0.
	*/
	coded_width: i32,

	/**
	* Width of the canvas.
	*
	* Must be > 0.
	*/
	coded_height: i32,

	offsets: ^struct {
		/**
		* Index of the stream in the group this tile references.
		*
		* Must be < @ref AVStreamGroup.nb_streams "nb_streams".
		*/
		idx: u32,

		/**
		* Offset in pixels from the left edge of the canvas where the tile
		* should be placed.
		*/
		horizontal: i32,

		/**
		* Offset in pixels from the top edge of the canvas where the tile
		* should be placed.
		*/
		vertical: i32,
	},

	/**
	* The pixel value per channel in RGBA format used if no pixel of any tile
	* is located at a particular pixel location.
	*
	* @see av_image_fill_color().
	* @see av_parse_color().
	*/
	background: [4]u8,

	/**
	* Offset in pixels from the left edge of the canvas where the actual image
	* meant for presentation starts.
	*
	* This field must be >= 0 and < @ref coded_width.
	*/
	horizontal_offset: i32,

	/**
	* Offset in pixels from the top edge of the canvas where the actual image
	* meant for presentation starts.
	*
	* This field must be >= 0 and < @ref coded_height.
	*/
	vertical_offset: i32,

	/**
	* Width of the final image for presentation.
	*
	* Must be > 0 and <= (@ref coded_width - @ref horizontal_offset).
	* When it's not equal to (@ref coded_width - @ref horizontal_offset), the
	* result of (@ref coded_width - width - @ref horizontal_offset) is the
	* amount amount of pixels to be cropped from the right edge of the
	* final image before presentation.
	*/
	width: i32,

	/**
	* Height of the final image for presentation.
	*
	* Must be > 0 and <= (@ref coded_height - @ref vertical_offset).
	* When it's not equal to (@ref coded_height - @ref vertical_offset), the
	* result of (@ref coded_height - height - @ref vertical_offset) is the
	* amount amount of pixels to be cropped from the bottom edge of the
	* final image before presentation.
	*/
	height: i32,

	/**
	* Additional data associated with the grid.
	*
	* Should be allocated with av_packet_side_data_new() or
	* av_packet_side_data_add(), and will be freed by avformat_free_context().
	*/
	coded_side_data: ^i32,

	/**
	* Amount of entries in @ref coded_side_data.
	*/
	nb_coded_side_data: i32,
}

/**
* AVStreamGroupLCEVC is meant to define the relation between video streams
* and a data stream containing LCEVC enhancement layer NALUs.
*
* No more than one stream of @ref AVCodecParameters.codec_type "codec_type"
* AVMEDIA_TYPE_DATA shall be present, and it must be of
* @ref AVCodecParameters.codec_id "codec_id" AV_CODEC_ID_LCEVC.
*/
AVStreamGroupLCEVC :: struct {
	av_class: ^i32,

	/**
	* Index of the LCEVC data stream in AVStreamGroup.
	*/
	lcevc_index: u32,

	/**
	* Width of the final stream for presentation.
	*/
	width: i32,

	/**
	* Height of the final image for presentation.
	*/
	height: i32,
}

AVStreamGroupParamsType :: enum i32 {
	NONE                  = 0,
	IAMF_AUDIO_ELEMENT    = 1,
	IAMF_MIX_PRESENTATION = 2,
	TILE_GRID             = 3,
	LCEVC                 = 4,
}

AVIAMFAudioElement    :: struct {}
AVIAMFMixPresentation :: struct {}

AVStreamGroup :: struct {
	/**
	* A class for @ref avoptions. Set by avformat_stream_group_create().
	*/
	av_class:  ^i32,
	priv_data: rawptr,

	/**
	* Group index in AVFormatContext.
	*/
	index: u32,

	/**
	* Group type-specific group ID.
	*
	* decoding: set by libavformat
	* encoding: may set by the user
	*/
	id: i64,

	/**
	* Group type
	*
	* decoding: set by libavformat on group creation
	* encoding: set by avformat_stream_group_create()
	*/
	type: AVStreamGroupParamsType,

	params: struct #raw_union {
		iamf_audio_element:    ^AVIAMFAudioElement,
		iamf_mix_presentation: ^AVIAMFMixPresentation,
		tile_grid:             ^AVStreamGroupTileGrid,
		lcevc:                 ^AVStreamGroupLCEVC,
	},

	/**
	* Metadata that applies to the whole group.
	*
	* - demuxing: set by libavformat on group creation
	* - muxing: may be set by the caller before avformat_write_header()
	*
	* Freed by libavformat in avformat_free_context().
	*/
	metadata: ^i32,

	/**
	* Number of elements in AVStreamGroup.streams.
	*
	* Set by avformat_stream_group_add_stream() must not be modified by any other code.
	*/
	nb_streams: u32,

	/**
	* A list of streams in the group. New entries are created with
	* avformat_stream_group_add_stream().
	*
	* - demuxing: entries are created by libavformat on group creation.
	*             If AVFMTCTX_NOHEADER is set in ctx_flags, then new entries may also
	*             appear in av_read_frame().
	* - muxing: entries are created by the user before avformat_write_header().
	*
	* Freed by libavformat in avformat_free_context().
	*/
	streams: ^^AVStream,

	/**
	* Stream group disposition - a combination of AV_DISPOSITION_* flags.
	* This field currently applies to all defined AVStreamGroupParamsType.
	*
	* - demuxing: set by libavformat when creating the group or in
	*             avformat_find_stream_info().
	* - muxing: may be set by the caller before avformat_write_header().
	*/
	disposition: i32,
}

// AVCodecParserContext :: struct {} // removed duplicate

@(default_calling_convention="c")
foreign lib {
	av_stream_get_parser :: proc(s: ^AVStream) -> ^AVCodecParserContext ---
}

AV_PROGRAM_RUNNING :: 1

/**
* New fields can be added to the end with minor version bumps.
* Removal, reordering and changes to existing fields require a major
* version bump.
* sizeof(AVProgram) must not be used outside libav*.
*/
AVProgram :: struct {
	id:                i32,
	flags:             i32,
	discard:           AVDiscard, ///< selects which program to discard and which to feed to the caller
	stream_index:      ^u32,
	nb_stream_indexes: u32,
	metadata:          ^i32,
	program_num:       i32,
	pmt_pid:           i32,
	pcr_pid:           i32,
	pmt_version:       i32,

	/*****************************************************************
	* All fields below this line are not part of the public API. They
	* may not be used outside of libavformat and can be changed and
	* removed at will.
	* New public fields should be added right above.
	*****************************************************************
	*/
	start_time:         i64,
	end_time:           i64,
	pts_wrap_reference: i64, ///< reference dts for wrap detection
	pts_wrap_behavior:  i32, ///< behavior on wrap detection
}

AVFMTCTX_NOHEADER      :: 0x0001 /**< signal that no header is present
                                         (streams are added dynamically) */
AVFMTCTX_UNSEEKABLE    :: 0x0002 /**< signal that the stream is definitely
                                         not seekable, and attempts to call the
                                         seek function will fail. For some
                                         network protocols (e.g. HLS), this can
                                         change dynamically at runtime. */

AVChapter :: struct {
	id:         i64, ///< unique ID to identify the chapter
	time_base:  i32, ///< time base in which the start/end timestamps are specified
	start, end: i64, ///< chapter start/end time in time_base units
	metadata:   ^i32,
}

/**
* Callback used by devices to communicate with application.
*/
av_format_control_message :: proc "c" (s: ^AVFormatContext, type: i32, data: rawptr, data_size: c.size_t) -> i32
AVOpenCallback            :: proc "c" (s: ^AVFormatContext, pb: ^^AVIOContext, url: cstring, flags: i32, int_cb: ^AVIOInterruptCB, options: ^^i32) -> i32

/**
* The duration of a video can be estimated through various ways, and this enum can be used
* to know how the duration was estimated.
*/
AVDurationEstimationMethod :: enum i32 {
	PTS     = 0, ///< Duration accurately estimated from PTSes
	STREAM  = 1, ///< Duration estimated from a stream with a known duration
	BITRATE = 2, ///< Duration estimated from bitrate (less accurate)
}

/**
* Format I/O context.
* New fields can be added to the end with minor version bumps.
* Removal, reordering and changes to existing fields require a major
* version bump.
* sizeof(AVFormatContext) must not be used outside libav*, use
* avformat_alloc_context() to create an AVFormatContext.
*
* Fields can be accessed through AVOptions (av_opt*),
* the name string used matches the associated command line parameter name and
* can be found in libavformat/options_table.h.
* The AVOption/command line parameter names differ in some cases from the C
* structure field names for historic reasons or brevity.
*/
AVFormatContext :: struct {
	/**
	* A class for logging and @ref avoptions. Set by avformat_alloc_context().
	* Exports (de)muxer private options if they exist.
	*/
	av_class: ^i32,

	/**
	* The input container format.
	*
	* Demuxing only, set by avformat_open_input().
	*/
	iformat: ^AVInputFormat,

	/**
	* The output container format.
	*
	* Muxing only, must be set by the caller before avformat_write_header().
	*/
	oformat: ^AVOutputFormat,

	/**
	* Format private data. This is an AVOptions-enabled struct
	* if and only if iformat/oformat.priv_class is not NULL.
	*
	* - muxing: set by avformat_write_header()
	* - demuxing: set by avformat_open_input()
	*/
	priv_data: rawptr,

	/**
	* I/O context.
	*
	* - demuxing: either set by the user before avformat_open_input() (then
	*             the user must close it manually) or set by avformat_open_input().
	* - muxing: set by the user before avformat_write_header(). The caller must
	*           take care of closing / freeing the IO context.
	*
	* Do NOT set this field if AVFMT_NOFILE flag is set in
	* iformat/oformat.flags. In such a case, the (de)muxer will handle
	* I/O in some other way and this field will be NULL.
	*/
	pb: ^AVIOContext,

	/* stream info */
	/**
	* Flags signalling stream properties. A combination of AVFMTCTX_*.
	* Set by libavformat.
	*/
	ctx_flags: i32,

	/**
	* Number of elements in AVFormatContext.streams.
	*
	* Set by avformat_new_stream(), must not be modified by any other code.
	*/
	nb_streams: u32,

	/**
	* A list of all streams in the file. New streams are created with
	* avformat_new_stream().
	*
	* - demuxing: streams are created by libavformat in avformat_open_input().
	*             If AVFMTCTX_NOHEADER is set in ctx_flags, then new streams may also
	*             appear in av_read_frame().
	* - muxing: streams are created by the user before avformat_write_header().
	*
	* Freed by libavformat in avformat_free_context().
	*/
	streams: [^]^AVStream,

	/**
	* Number of elements in AVFormatContext.stream_groups.
	*
	* Set by avformat_stream_group_create(), must not be modified by any other code.
	*/
	nb_stream_groups: u32,

	/**
	* A list of all stream groups in the file. New groups are created with
	* avformat_stream_group_create(), and filled with avformat_stream_group_add_stream().
	*
	* - demuxing: groups may be created by libavformat in avformat_open_input().
	*             If AVFMTCTX_NOHEADER is set in ctx_flags, then new groups may also
	*             appear in av_read_frame().
	* - muxing: groups may be created by the user before avformat_write_header().
	*
	* Freed by libavformat in avformat_free_context().
	*/
	stream_groups: [^]^AVStreamGroup,

	/**
	* Number of chapters in AVChapter array.
	* When muxing, chapters are normally written in the file header,
	* so nb_chapters should normally be initialized before write_header
	* is called. Some muxers (e.g. mov and mkv) can also write chapters
	* in the trailer.  To write chapters in the trailer, nb_chapters
	* must be zero when write_header is called and non-zero when
	* write_trailer is called.
	* - muxing: set by user
	* - demuxing: set by libavformat
	*/
	nb_chapters: u32,
	chapters:    [^]^AVChapter,

	/**
	* input or output URL. Unlike the old filename field, this field has no
	* length restriction.
	*
	* - demuxing: set by avformat_open_input(), initialized to an empty
	*             string if url parameter was NULL in avformat_open_input().
	* - muxing: may be set by the caller before calling avformat_write_header()
	*           (or avformat_init_output() if that is called first) to a string
	*           which is freeable by av_free(). Set to an empty string if it
	*           was NULL in avformat_init_output().
	*
	* Freed by libavformat in avformat_free_context().
	*/
	url: cstring,

	/**
	* Position of the first frame of the component, in
	* AV_TIME_BASE fractional seconds. NEVER set this value directly:
	* It is deduced from the AVStream values.
	*
	* Demuxing only, set by libavformat.
	*/
	start_time: i64,

	/**
	* Duration of the stream, in AV_TIME_BASE fractional
	* seconds. Only set this value if you know none of the individual stream
	* durations and also do not set any of them. This is deduced from the
	* AVStream values if not set.
	*
	* Demuxing only, set by libavformat.
	*/
	duration: i64,

	/**
	* Total stream bitrate in bit/s, 0 if not
	* available. Never set it directly if the file_size and the
	* duration are known as FFmpeg can compute it automatically.
	*/
	bit_rate:    i64,
	packet_size: u32,
	max_delay:   i32,

	/**
	* Flags modifying the (de)muxer behaviour. A combination of AVFMT_FLAG_*.
	* Set by the user before avformat_open_input() / avformat_write_header().
	*/
	flags: i32,

	/**
	* Maximum number of bytes read from input in order to determine stream
	* properties. Used when reading the global header and in
	* avformat_find_stream_info().
	*
	* Demuxing only, set by the caller before avformat_open_input().
	*
	* @note this is \e not  used for determining the \ref AVInputFormat
	*       "input format"
	* @see format_probesize
	*/
	probesize: i64,

	/**
	* Maximum duration (in AV_TIME_BASE units) of the data read
	* from input in avformat_find_stream_info().
	* Demuxing only, set by the caller before avformat_find_stream_info().
	* Can be set to 0 to let avformat choose using a heuristic.
	*/
	max_analyze_duration: i64,
	key:                  ^u8,
	keylen:               i32,
	nb_programs:          u32,
	programs:             [^]^AVProgram,

	/**
	* Forced video codec_id.
	* Demuxing: Set by user.
	*/
	video_codec_id: AVCodecID,

	/**
	* Forced audio codec_id.
	* Demuxing: Set by user.
	*/
	audio_codec_id: AVCodecID,

	/**
	* Forced subtitle codec_id.
	* Demuxing: Set by user.
	*/
	subtitle_codec_id: AVCodecID,

	/**
	* Forced Data codec_id.
	* Demuxing: Set by user.
	*/
	data_codec_id: AVCodecID,

	/**
	* Metadata that applies to the whole file.
	*
	* - demuxing: set by libavformat in avformat_open_input()
	* - muxing: may be set by the caller before avformat_write_header()
	*
	* Freed by libavformat in avformat_free_context().
	*/
	metadata: ^i32,

	/**
	* Start time of the stream in real world time, in microseconds
	* since the Unix epoch (00:00 1st January 1970). That is, pts=0 in the
	* stream was captured at this real world time.
	* - muxing: Set by the caller before avformat_write_header(). If set to
	*           either 0 or AV_NOPTS_VALUE, then the current wall-time will
	*           be used.
	* - demuxing: Set by libavformat. AV_NOPTS_VALUE if unknown. Note that
	*             the value may become known after some number of frames
	*             have been received.
	*/
	start_time_realtime: i64,

	/**
	* The number of frames used for determining the framerate in
	* avformat_find_stream_info().
	* Demuxing only, set by the caller before avformat_find_stream_info().
	*/
	fps_probe_size: i32,

	/**
	* Error recognition; higher values will detect more errors but may
	* misdetect some more or less valid parts as errors.
	* Demuxing only, set by the caller before avformat_open_input().
	*/
	error_recognition: i32,

	/**
	* Custom interrupt callbacks for the I/O layer.
	*
	* demuxing: set by the user before avformat_open_input().
	* muxing: set by the user before avformat_write_header()
	* (mainly useful for AVFMT_NOFILE formats). The callback
	* should also be passed to avio_open2() if it's used to
	* open the file.
	*/
	interrupt_callback: AVIOInterruptCB,

	/**
	* Flags to enable debugging.
	*/
	debug: i32,

	/**
	* The maximum number of streams.
	* - encoding: unused
	* - decoding: set by user
	*/
	max_streams: i32,

	/**
	* Maximum amount of memory in bytes to use for the index of each stream.
	* If the index exceeds this size, entries will be discarded as
	* needed to maintain a smaller size. This can lead to slower or less
	* accurate seeking (depends on demuxer).
	* Demuxers for which a full in-memory index is mandatory will ignore
	* this.
	* - muxing: unused
	* - demuxing: set by user
	*/
	max_index_size: u32,

	/**
	* Maximum amount of memory in bytes to use for buffering frames
	* obtained from realtime capture devices.
	*/
	max_picture_buffer: u32,

	/**
	* Maximum buffering duration for interleaving.
	*
	* To ensure all the streams are interleaved correctly,
	* av_interleaved_write_frame() will wait until it has at least one packet
	* for each stream before actually writing any packets to the output file.
	* When some streams are "sparse" (i.e. there are large gaps between
	* successive packets), this can result in excessive buffering.
	*
	* This field specifies the maximum difference between the timestamps of the
	* first and the last packet in the muxing queue, above which libavformat
	* will output a packet regardless of whether it has queued a packet for all
	* the streams.
	*
	* Muxing only, set by the caller before avformat_write_header().
	*/
	max_interleave_delta: i64,

	/**
	* Maximum number of packets to read while waiting for the first timestamp.
	* Decoding only.
	*/
	max_ts_probe: i32,

	/**
	* Max chunk time in microseconds.
	* Note, not all formats support this and unpredictable things may happen if it is used when not supported.
	* - encoding: Set by user
	* - decoding: unused
	*/
	max_chunk_duration: i32,

	/**
	* Max chunk size in bytes
	* Note, not all formats support this and unpredictable things may happen if it is used when not supported.
	* - encoding: Set by user
	* - decoding: unused
	*/
	max_chunk_size: i32,

	/**
	* Maximum number of packets that can be probed
	* - encoding: unused
	* - decoding: set by user
	*/
	max_probe_packets: i32,

	/**
	* Allow non-standard and experimental extension
	* @see AVCodecContext.strict_std_compliance
	*/
	strict_std_compliance: i32,

	/**
	* Flags indicating events happening on the file, a combination of
	* AVFMT_EVENT_FLAG_*.
	*
	* - demuxing: may be set by the demuxer in avformat_open_input(),
	*   avformat_find_stream_info() and av_read_frame(). Flags must be cleared
	*   by the user once the event has been handled.
	* - muxing: may be set by the user after avformat_write_header() to
	*   indicate a user-triggered event.  The muxer will clear the flags for
	*   events it has handled in av_[interleaved]_write_frame().
	*/
	event_flags: i32,

	/**
	* Avoid negative timestamps during muxing.
	* Any value of the AVFMT_AVOID_NEG_TS_* constants.
	* Note, this works better when using av_interleaved_write_frame().
	* - muxing: Set by user
	* - demuxing: unused
	*/
	avoid_negative_ts: i32,

	/**
	* Audio preload in microseconds.
	* Note, not all formats support this and unpredictable things may happen if it is used when not supported.
	* - encoding: Set by user
	* - decoding: unused
	*/
	audio_preload: i32,

	/**
	* forces the use of wallclock timestamps as pts/dts of packets
	* This has undefined results in the presence of B frames.
	* - encoding: unused
	* - decoding: Set by user
	*/
	use_wallclock_as_timestamps: i32,

	/**
	* Skip duration calculation in estimate_timings_from_pts.
	* - encoding: unused
	* - decoding: set by user
	*
	* @see duration_probesize
	*/
	skip_estimate_duration_from_pts: i32,

	/**
	* avio flags, used to force AVIO_FLAG_DIRECT.
	* - encoding: unused
	* - decoding: Set by user
	*/
	avio_flags: i32,

	/**
	* The duration field can be estimated through various ways, and this field can be used
	* to know how the duration was estimated.
	* - encoding: unused
	* - decoding: Read by user
	*/
	duration_estimation_method: AVDurationEstimationMethod,

	/**
	* Skip initial bytes when opening stream
	* - encoding: unused
	* - decoding: Set by user
	*/
	skip_initial_bytes: i64,

	/**
	* Correct single timestamp overflows
	* - encoding: unused
	* - decoding: Set by user
	*/
	correct_ts_overflow: u32,

	/**
	* Force seeking to any (also non key) frames.
	* - encoding: unused
	* - decoding: Set by user
	*/
	seek2any: i32,

	/**
	* Flush the I/O context after each packet.
	* - encoding: Set by user
	* - decoding: unused
	*/
	flush_packets: i32,

	/**
	* format probing score.
	* The maximal score is AVPROBE_SCORE_MAX, its set when the demuxer probes
	* the format.
	* - encoding: unused
	* - decoding: set by avformat, read by user
	*/
	probe_score: i32,

	/**
	* Maximum number of bytes read from input in order to identify the
	* \ref AVInputFormat "input format". Only used when the format is not set
	* explicitly by the caller.
	*
	* Demuxing only, set by the caller before avformat_open_input().
	*
	* @see probesize
	*/
	format_probesize: i32,

	/**
	* ',' separated list of allowed decoders.
	* If NULL then all are allowed
	* - encoding: unused
	* - decoding: set by user
	*/
	codec_whitelist: cstring,

	/**
	* ',' separated list of allowed demuxers.
	* If NULL then all are allowed
	* - encoding: unused
	* - decoding: set by user
	*/
	format_whitelist: cstring,

	/**
	* ',' separated list of allowed protocols.
	* - encoding: unused
	* - decoding: set by user
	*/
	protocol_whitelist: cstring,

	/**
	* ',' separated list of disallowed protocols.
	* - encoding: unused
	* - decoding: set by user
	*/
	protocol_blacklist: cstring,

	/**
	* IO repositioned flag.
	* This is set by avformat when the underlying IO context read pointer
	* is repositioned, for example when doing byte based seeking.
	* Demuxers can use the flag to detect such changes.
	*/
	io_repositioned: i32,

	/**
	* Forced video codec.
	* This allows forcing a specific decoder, even when there are multiple with
	* the same codec_id.
	* Demuxing: Set by user
	*/
	video_codec: ^AVCodec,

	/**
	* Forced audio codec.
	* This allows forcing a specific decoder, even when there are multiple with
	* the same codec_id.
	* Demuxing: Set by user
	*/
	audio_codec: ^AVCodec,

	/**
	* Forced subtitle codec.
	* This allows forcing a specific decoder, even when there are multiple with
	* the same codec_id.
	* Demuxing: Set by user
	*/
	subtitle_codec: ^AVCodec,

	/**
	* Forced data codec.
	* This allows forcing a specific decoder, even when there are multiple with
	* the same codec_id.
	* Demuxing: Set by user
	*/
	data_codec: ^AVCodec,

	/**
	* Number of bytes to be written as padding in a metadata header.
	* Demuxing: Unused.
	* Muxing: Set by user.
	*/
	metadata_header_padding: i32,

	/**
	* User data.
	* This is a place for some private data of the user.
	*/
	opaque: rawptr,

	/**
	* Callback used by devices to communicate with application.
	*/
	control_message_cb: av_format_control_message,

	/**
	* Output timestamp offset, in microseconds.
	* Muxing: set by user
	*/
	output_ts_offset: i64,

	/**
	* dump format separator.
	* can be ", " or "\n      " or anything else
	* - muxing: Set by user.
	* - demuxing: Set by user.
	*/
	dump_separator: ^u8,

	/**
	* A callback for opening new IO streams.
	*
	* Whenever a muxer or a demuxer needs to open an IO stream (typically from
	* avformat_open_input() for demuxers, but for certain formats can happen at
	* other times as well), it will call this callback to obtain an IO context.
	*
	* @param s the format context
	* @param pb on success, the newly opened IO context should be returned here
	* @param url the url to open
	* @param flags a combination of AVIO_FLAG_*
	* @param options a dictionary of additional options, with the same
	*                semantics as in avio_open2()
	* @return 0 on success, a negative AVERROR code on failure
	*
	* @note Certain muxers and demuxers do nesting, i.e. they open one or more
	* additional internal format contexts. Thus the AVFormatContext pointer
	* passed to this callback may be different from the one facing the caller.
	* It will, however, have the same 'opaque' field.
	*/
	io_open: proc "c" (s: ^AVFormatContext, pb: ^^AVIOContext, url: cstring, flags: i32, options: ^^i32) -> i32,

	/**
	* A callback for closing the streams opened with AVFormatContext.io_open().
	*
	* @param s the format context
	* @param pb IO context to be closed and freed
	* @return 0 on success, a negative AVERROR code on failure
	*/
	io_close2: proc "c" (s: ^AVFormatContext, pb: ^AVIOContext) -> i32,

	/**
	* Maximum number of bytes read from input in order to determine stream durations
	* when using estimate_timings_from_pts in avformat_find_stream_info().
	* Demuxing only, set by the caller before avformat_find_stream_info().
	* Can be set to 0 to let avformat choose using a heuristic.
	*
	* @see skip_estimate_duration_from_pts
	*/
	duration_probesize: i64,
}

AVFMT_FLAG_GENPTS          :: 0x0001  ///< Generate missing pts even if it requires parsing future frames.
AVFMT_FLAG_IGNIDX          :: 0x0002  ///< Ignore index.
AVFMT_FLAG_NONBLOCK        :: 0x0004  ///< Do not block when reading packets from input.
AVFMT_FLAG_IGNDTS          :: 0x0008  ///< Ignore DTS on frames that contain both DTS & PTS
AVFMT_FLAG_NOFILLIN        :: 0x0010  ///< Do not infer any values from other values, just return what is stored in the container
AVFMT_FLAG_NOPARSE         :: 0x0020  ///< Do not use AVParsers, you also must set AVFMT_FLAG_NOFILLIN as the filling code works on frames and no parsing -> no frames. Also seeking to frames can not work if parsing to find frame boundaries has been disabled
AVFMT_FLAG_NOBUFFER        :: 0x0040  ///< Do not buffer frames when possible
AVFMT_FLAG_CUSTOM_IO       :: 0x0080  ///< The caller has supplied a custom AVIOContext, don't avio_close() it.
AVFMT_FLAG_DISCARD_CORRUPT  :: 0x0100 ///< Discard frames marked corrupted
AVFMT_FLAG_FLUSH_PACKETS    :: 0x0200 ///< Flush the AVIOContext every packet.

/**
* When muxing, try to avoid writing any random/volatile data to the output.
* This includes any random IDs, real-time timestamps/dates, muxer version, etc.
*
* This flag is mainly intended for testing.
*/
AVFMT_FLAG_BITEXACT         :: 0x0400
AVFMT_FLAG_SORT_DTS    :: 0x10000 ///< try to interleave outputted packets by dts (using this flag can slow demuxing down)
AVFMT_FLAG_FAST_SEEK   :: 0x80000 ///< Enable fast, but inaccurate seeks for some formats
AVFMT_FLAG_AUTO_BSF   :: 0x200000 ///< Add bitstream filters as requested by the muxer
FF_FDEBUG_TS         :: 0x0001

/**
* - demuxing: the demuxer read new metadata from the file and updated
*   AVFormatContext.metadata accordingly
* - muxing: the user updated AVFormatContext.metadata and wishes the muxer to
*   write it into the file
*/
AVFMT_EVENT_FLAG_METADATA_UPDATED    :: 0x0001
AVFMT_AVOID_NEG_TS_AUTO              :: -1 ///< Enabled when required by target format
AVFMT_AVOID_NEG_TS_DISABLED          :: 0  ///< Do not shift timestamps even when they are negative.
AVFMT_AVOID_NEG_TS_MAKE_NON_NEGATIVE :: 1  ///< Shift timestamps so they are non negative
AVFMT_AVOID_NEG_TS_MAKE_ZERO         :: 2  ///< Shift timestamps so that they start at 0

// AVCodec :: struct {} // removed duplicate

@(default_calling_convention="c")
foreign lib {
	/**
	* Return the LIBAVFORMAT_VERSION_INT constant.
	*/
	avformat_version :: proc() -> u32 ---

	/**
	* Return the libavformat build-time configuration.
	*/
	avformat_configuration :: proc() -> cstring ---

	/**
	* Return the libavformat license.
	*/
	avformat_license :: proc() -> cstring ---

	/**
	* Do global initialization of network libraries. This is optional,
	* and not recommended anymore.
	*
	* This functions only exists to work around thread-safety issues
	* with older GnuTLS or OpenSSL libraries. If libavformat is linked
	* to newer versions of those libraries, or if you do not use them,
	* calling this function is unnecessary. Otherwise, you need to call
	* this function before any other threads using them are started.
	*
	* This function will be deprecated once support for older GnuTLS and
	* OpenSSL libraries is removed, and this function has no purpose
	* anymore.
	*/
	avformat_network_init :: proc() -> i32 ---

	/**
	* Undo the initialization done by avformat_network_init. Call it only
	* once for each time you called avformat_network_init.
	*/
	avformat_network_deinit :: proc() -> i32 ---

	/**
	* Iterate over all registered muxers.
	*
	* @param opaque a pointer where libavformat will store the iteration state. Must
	*               point to NULL to start the iteration.
	*
	* @return the next registered muxer or NULL when the iteration is
	*         finished
	*/
	av_muxer_iterate :: proc(opaque: ^rawptr) -> ^AVOutputFormat ---

	/**
	* Iterate over all registered demuxers.
	*
	* @param opaque a pointer where libavformat will store the iteration state.
	*               Must point to NULL to start the iteration.
	*
	* @return the next registered demuxer or NULL when the iteration is
	*         finished
	*/
	av_demuxer_iterate :: proc(opaque: ^rawptr) -> ^AVInputFormat ---

	/**
	* Allocate an AVFormatContext.
	* avformat_free_context() can be used to free the context and everything
	* allocated by the framework within it.
	*/
	avformat_alloc_context :: proc() -> ^AVFormatContext ---

	/**
	* Free an AVFormatContext and all its streams.
	* @param s context to free
	*/
	avformat_free_context :: proc(s: ^AVFormatContext) ---

	/**
	* Get the AVClass for AVFormatContext. It can be used in combination with
	* AV_OPT_SEARCH_FAKE_OBJ for examining options.
	*
	* @see av_opt_find().
	*/
	avformat_get_class :: proc() -> ^i32 ---

	/**
	* Get the AVClass for AVStream. It can be used in combination with
	* AV_OPT_SEARCH_FAKE_OBJ for examining options.
	*
	* @see av_opt_find().
	*/
	av_stream_get_class :: proc() -> ^i32 ---

	/**
	* Get the AVClass for AVStreamGroup. It can be used in combination with
	* AV_OPT_SEARCH_FAKE_OBJ for examining options.
	*
	* @see av_opt_find().
	*/
	av_stream_group_get_class :: proc() -> ^i32 ---

	/**
	* @return a string identifying the stream group type, or NULL if unknown
	*/
	avformat_stream_group_name :: proc(type: AVStreamGroupParamsType) -> cstring ---

	/**
	* Add a new empty stream group to a media file.
	*
	* When demuxing, it may be called by the demuxer in read_header(). If the
	* flag AVFMTCTX_NOHEADER is set in s.ctx_flags, then it may also
	* be called in read_packet().
	*
	* When muxing, may be called by the user before avformat_write_header().
	*
	* User is required to call avformat_free_context() to clean up the allocation
	* by avformat_stream_group_create().
	*
	* New streams can be added to the group with avformat_stream_group_add_stream().
	*
	* @param s media file handle
	*
	* @return newly created group or NULL on error.
	* @see avformat_new_stream, avformat_stream_group_add_stream.
	*/
	avformat_stream_group_create :: proc(s: ^AVFormatContext, type: AVStreamGroupParamsType, options: ^^i32) -> ^AVStreamGroup ---

	/**
	* Add a new stream to a media file.
	*
	* When demuxing, it is called by the demuxer in read_header(). If the
	* flag AVFMTCTX_NOHEADER is set in s.ctx_flags, then it may also
	* be called in read_packet().
	*
	* When muxing, should be called by the user before avformat_write_header().
	*
	* User is required to call avformat_free_context() to clean up the allocation
	* by avformat_new_stream().
	*
	* @param s media file handle
	* @param c unused, does nothing
	*
	* @return newly created stream or NULL on error.
	*/
	avformat_new_stream :: proc(s: ^AVFormatContext, _c: ^AVCodec) -> ^AVStream ---

	/**
	* Add an already allocated stream to a stream group.
	*
	* When demuxing, it may be called by the demuxer in read_header(). If the
	* flag AVFMTCTX_NOHEADER is set in s.ctx_flags, then it may also
	* be called in read_packet().
	*
	* When muxing, may be called by the user before avformat_write_header() after
	* having allocated a new group with avformat_stream_group_create() and stream with
	* avformat_new_stream().
	*
	* User is required to call avformat_free_context() to clean up the allocation
	* by avformat_stream_group_add_stream().
	*
	* @param stg stream group belonging to a media file.
	* @param st  stream in the media file to add to the group.
	*
	* @retval 0                 success
	* @retval AVERROR(EEXIST)   the stream was already in the group
	* @retval "another negative error code" legitimate errors
	*
	* @see avformat_new_stream, avformat_stream_group_create.
	*/
	avformat_stream_group_add_stream :: proc(stg: ^AVStreamGroup, st: ^AVStream) -> i32 ---
	av_new_program                   :: proc(s: ^AVFormatContext, id: i32) -> ^AVProgram ---

	/**
	* Allocate an AVFormatContext for an output format.
	* avformat_free_context() can be used to free the context and
	* everything allocated by the framework within it.
	*
	* @param ctx           pointee is set to the created format context,
	*                      or to NULL in case of failure
	* @param oformat       format to use for allocating the context, if NULL
	*                      format_name and filename are used instead
	* @param format_name   the name of output format to use for allocating the
	*                      context, if NULL filename is used instead
	* @param filename      the name of the filename to use for allocating the
	*                      context, may be NULL
	*
	* @return  >= 0 in case of success, a negative AVERROR code in case of
	*          failure
	*/
	avformat_alloc_output_context2 :: proc(ctx: ^^AVFormatContext, oformat: ^AVOutputFormat, format_name: cstring, filename: cstring) -> i32 ---

	/**
	* Find AVInputFormat based on the short name of the input format.
	*/
	av_find_input_format :: proc(short_name: cstring) -> ^AVInputFormat ---

	/**
	* Guess the file format.
	*
	* @param pd        data to be probed
	* @param is_opened Whether the file is already opened; determines whether
	*                  demuxers with or without AVFMT_NOFILE are probed.
	*/
	av_probe_input_format :: proc(pd: ^AVProbeData, is_opened: i32) -> ^AVInputFormat ---

	/**
	* Guess the file format.
	*
	* @param pd        data to be probed
	* @param is_opened Whether the file is already opened; determines whether
	*                  demuxers with or without AVFMT_NOFILE are probed.
	* @param score_max A probe score larger that this is required to accept a
	*                  detection, the variable is set to the actual detection
	*                  score afterwards.
	*                  If the score is <= AVPROBE_SCORE_MAX / 4 it is recommended
	*                  to retry with a larger probe buffer.
	*/
	av_probe_input_format2 :: proc(pd: ^AVProbeData, is_opened: i32, score_max: ^i32) -> ^AVInputFormat ---

	/**
	* Guess the file format.
	*
	* @param is_opened Whether the file is already opened; determines whether
	*                  demuxers with or without AVFMT_NOFILE are probed.
	* @param score_ret The score of the best detection.
	*/
	av_probe_input_format3 :: proc(pd: ^AVProbeData, is_opened: i32, score_ret: ^i32) -> ^AVInputFormat ---

	/**
	* Probe a bytestream to determine the input format. Each time a probe returns
	* with a score that is too low, the probe buffer size is increased and another
	* attempt is made. When the maximum probe size is reached, the input format
	* with the highest score is returned.
	*
	* @param pb             the bytestream to probe
	* @param fmt            the input format is put here
	* @param url            the url of the stream
	* @param logctx         the log context
	* @param offset         the offset within the bytestream to probe from
	* @param max_probe_size the maximum probe buffer size (zero for default)
	*
	* @return the score in case of success, a negative value corresponding to an
	*         the maximal score is AVPROBE_SCORE_MAX
	*         AVERROR code otherwise
	*/
	av_probe_input_buffer2 :: proc(pb: ^AVIOContext, fmt: ^^AVInputFormat, url: cstring, logctx: rawptr, offset: u32, max_probe_size: u32) -> i32 ---

	/**
	* Like av_probe_input_buffer2() but returns 0 on success
	*/
	av_probe_input_buffer :: proc(pb: ^AVIOContext, fmt: ^^AVInputFormat, url: cstring, logctx: rawptr, offset: u32, max_probe_size: u32) -> i32 ---

	/**
	* Open an input stream and read the header. The codecs are not opened.
	* The stream must be closed with avformat_close_input().
	*
	* @param ps       Pointer to user-supplied AVFormatContext (allocated by
	*                 avformat_alloc_context). May be a pointer to NULL, in
	*                 which case an AVFormatContext is allocated by this
	*                 function and written into ps.
	*                 Note that a user-supplied AVFormatContext will be freed
	*                 on failure and its pointer set to NULL.
	* @param url      URL of the stream to open.
	* @param fmt      If non-NULL, this parameter forces a specific input format.
	*                 Otherwise the format is autodetected.
	* @param options  A dictionary filled with AVFormatContext and demuxer-private
	*                 options.
	*                 On return this parameter will be destroyed and replaced with
	*                 a dict containing options that were not found. May be NULL.
	*
	* @return 0 on success; on failure: frees ps, sets its pointer to NULL,
	*         and returns a negative AVERROR.
	*
	* @note If you want to use custom IO, preallocate the format context and set its pb field.
	*/
	avformat_open_input :: proc(ps: ^^AVFormatContext, url: cstring, fmt: ^AVInputFormat, options: ^^i32) -> i32 ---

	/**
	* Read packets of a media file to get stream information. This
	* is useful for file formats with no headers such as MPEG. This
	* function also computes the real framerate in case of MPEG-2 repeat
	* frame mode.
	* The logical file position is not changed by this function;
	* examined packets may be buffered for later processing.
	*
	* @param ic media file handle
	* @param options  If non-NULL, an ic.nb_streams long array of pointers to
	*                 dictionaries, where i-th member contains options for
	*                 codec corresponding to i-th stream.
	*                 On return each dictionary will be filled with options that were not found.
	* @return >=0 if OK, AVERROR_xxx on error
	*
	* @note this function isn't guaranteed to open all the codecs, so
	*       options being non-empty at return is a perfectly normal behavior.
	*
	* @todo Let the user decide somehow what information is needed so that
	*       we do not waste time getting stuff the user does not need.
	*/
	avformat_find_stream_info :: proc(ic: ^AVFormatContext, options: ^^i32) -> i32 ---

	/**
	* Find the programs which belong to a given stream.
	*
	* @param ic    media file handle
	* @param last  the last found program, the search will start after this
	*              program, or from the beginning if it is NULL
	* @param s     stream index
	*
	* @return the next program which belongs to s, NULL if no program is found or
	*         the last program is not among the programs of ic.
	*/
	av_find_program_from_stream :: proc(ic: ^AVFormatContext, last: ^AVProgram, s: i32) -> ^AVProgram ---
	av_program_add_stream_index :: proc(ac: ^AVFormatContext, progid: i32, idx: u32) ---

	/**
	* Find the "best" stream in the file.
	* The best stream is determined according to various heuristics as the most
	* likely to be what the user expects.
	* If the decoder parameter is non-NULL, av_find_best_stream will find the
	* default decoder for the stream's codec; streams for which no decoder can
	* be found are ignored.
	*
	* @param ic                media file handle
	* @param type              stream type: video, audio, subtitles, etc.
	* @param wanted_stream_nb  user-requested stream number,
	*                          or -1 for automatic selection
	* @param related_stream    try to find a stream related (eg. in the same
	*                          program) to this one, or -1 if none
	* @param decoder_ret       if non-NULL, returns the decoder for the
	*                          selected stream
	* @param flags             flags; none are currently defined
	*
	* @return  the non-negative stream number in case of success,
	*          AVERROR_STREAM_NOT_FOUND if no stream with the requested type
	*          could be found,
	*          AVERROR_DECODER_NOT_FOUND if streams were found but no decoder
	*
	* @note  If av_find_best_stream returns successfully and decoder_ret is not
	*        NULL, then *decoder_ret is guaranteed to be set to a valid AVCodec.
	*/
	av_find_best_stream :: proc(ic: ^AVFormatContext, type: AVMediaType, wanted_stream_nb: i32, related_stream: i32, decoder_ret: ^^AVCodec, flags: i32) -> i32 ---

	/**
	* Return the next frame of a stream.
	* This function returns what is stored in the file, and does not validate
	* that what is there are valid frames for the decoder. It will split what is
	* stored in the file into frames and return one for each call. It will not
	* omit invalid data between valid frames so as to give the decoder the maximum
	* information possible for decoding.
	*
	* On success, the returned packet is reference-counted (pkt->buf is set) and
	* valid indefinitely. The packet must be freed with av_packet_unref() when
	* it is no longer needed. For video, the packet contains exactly one frame.
	* For audio, it contains an integer number of frames if each frame has
	* a known fixed size (e.g. PCM or ADPCM data). If the audio frames have
	* a variable size (e.g. MPEG audio), then it contains one frame.
	*
	* pkt->pts, pkt->dts and pkt->duration are always set to correct
	* values in AVStream.time_base units (and guessed if the format cannot
	* provide them). pkt->pts can be AV_NOPTS_VALUE if the video format
	* has B-frames, so it is better to rely on pkt->dts if you do not
	* decompress the payload.
	*
	* @return 0 if OK, < 0 on error or end of file. On error, pkt will be blank
	*         (as if it came from av_packet_alloc()).
	*
	* @note pkt will be initialized, so it may be uninitialized, but it must not
	*       contain data that needs to be freed.
	*/
	av_read_frame :: proc(s: ^AVFormatContext, pkt: ^i32) -> i32 ---

	/**
	* Seek to the keyframe at timestamp.
	* 'timestamp' in 'stream_index'.
	*
	* @param s            media file handle
	* @param stream_index If stream_index is (-1), a default stream is selected,
	*                     and timestamp is automatically converted from
	*                     AV_TIME_BASE units to the stream specific time_base.
	* @param timestamp    Timestamp in AVStream.time_base units or, if no stream
	*                     is specified, in AV_TIME_BASE units.
	* @param flags        flags which select direction and seeking mode
	*
	* @return >= 0 on success
	*/
	av_seek_frame :: proc(s: ^AVFormatContext, stream_index: i32, timestamp: i64, flags: i32) -> i32 ---

	/**
	* Seek to timestamp ts.
	* Seeking will be done so that the point from which all active streams
	* can be presented successfully will be closest to ts and within min/max_ts.
	* Active streams are all streams that have AVStream.discard < AVDISCARD_ALL.
	*
	* If flags contain AVSEEK_FLAG_BYTE, then all timestamps are in bytes and
	* are the file position (this may not be supported by all demuxers).
	* If flags contain AVSEEK_FLAG_FRAME, then all timestamps are in frames
	* in the stream with stream_index (this may not be supported by all demuxers).
	* Otherwise all timestamps are in units of the stream selected by stream_index
	* or if stream_index is -1, in AV_TIME_BASE units.
	* If flags contain AVSEEK_FLAG_ANY, then non-keyframes are treated as
	* keyframes (this may not be supported by all demuxers).
	* If flags contain AVSEEK_FLAG_BACKWARD, it is ignored.
	*
	* @param s            media file handle
	* @param stream_index index of the stream which is used as time base reference
	* @param min_ts       smallest acceptable timestamp
	* @param ts           target timestamp
	* @param max_ts       largest acceptable timestamp
	* @param flags        flags
	* @return >=0 on success, error code otherwise
	*
	* @note This is part of the new seek API which is still under construction.
	*/
	avformat_seek_file :: proc(s: ^AVFormatContext, stream_index: i32, min_ts: i64, ts: i64, max_ts: i64, flags: i32) -> i32 ---

	/**
	* Discard all internally buffered data. This can be useful when dealing with
	* discontinuities in the byte stream. Generally works only with formats that
	* can resync. This includes headerless formats like MPEG-TS/TS but should also
	* work with NUT, Ogg and in a limited way AVI for example.
	*
	* The set of streams, the detected duration, stream parameters and codecs do
	* not change when calling this function. If you want a complete reset, it's
	* better to open a new AVFormatContext.
	*
	* This does not flush the AVIOContext (s->pb). If necessary, call
	* avio_flush(s->pb) before calling this function.
	*
	* @param s media file handle
	* @return >=0 on success, error code otherwise
	*/
	avformat_flush :: proc(s: ^AVFormatContext) -> i32 ---

	/**
	* Start playing a network-based stream (e.g. RTSP stream) at the
	* current position.
	*/
	av_read_play :: proc(s: ^AVFormatContext) -> i32 ---

	/**
	* Pause a network-based stream (e.g. RTSP stream).
	*
	* Use av_read_play() to resume it.
	*/
	av_read_pause :: proc(s: ^AVFormatContext) -> i32 ---

	/**
	* Close an opened input AVFormatContext. Free it and all its contents
	* and set *s to NULL.
	*/
	avformat_close_input :: proc(s: ^^AVFormatContext) ---
}

/**
* @}
*/
AVSEEK_FLAG_BACKWARD :: 1 ///< seek backward
AVSEEK_FLAG_BYTE     :: 2 ///< seeking based on position in bytes
AVSEEK_FLAG_ANY      :: 4 ///< seek to any frame, even non-keyframes
AVSEEK_FLAG_FRAME    :: 8 ///< seeking based on frame number

/**
* @addtogroup lavf_encoding
* @{
*/
AVSTREAM_INIT_IN_WRITE_HEADER :: 0 ///< stream parameters initialized in avformat_write_header
AVSTREAM_INIT_IN_INIT_OUTPUT  :: 1 ///< stream parameters initialized in avformat_init_output

@(default_calling_convention="c")
foreign lib {
	/**
	* Allocate the stream private data and write the stream header to
	* an output media file.
	*
	* @param s        Media file handle, must be allocated with
	*                 avformat_alloc_context().
	*                 Its \ref AVFormatContext.oformat "oformat" field must be set
	*                 to the desired output format;
	*                 Its \ref AVFormatContext.pb "pb" field must be set to an
	*                 already opened ::AVIOContext.
	* @param options  An ::AVDictionary filled with AVFormatContext and
	*                 muxer-private options.
	*                 On return this parameter will be destroyed and replaced with
	*                 a dict containing options that were not found. May be NULL.
	*
	* @retval AVSTREAM_INIT_IN_WRITE_HEADER On success, if the codec had not already been
	*                                       fully initialized in avformat_init_output().
	* @retval AVSTREAM_INIT_IN_INIT_OUTPUT  On success, if the codec had already been fully
	*                                       initialized in avformat_init_output().
	* @retval AVERROR                       A negative AVERROR on failure.
	*
	* @see av_opt_find, av_dict_set, avio_open, av_oformat_next, avformat_init_output.
	*/
	avformat_write_header :: proc(s: ^AVFormatContext, options: ^^i32) -> i32 ---

	/**
	* Allocate the stream private data and initialize the codec, but do not write the header.
	* May optionally be used before avformat_write_header() to initialize stream parameters
	* before actually writing the header.
	* If using this function, do not pass the same options to avformat_write_header().
	*
	* @param s        Media file handle, must be allocated with
	*                 avformat_alloc_context().
	*                 Its \ref AVFormatContext.oformat "oformat" field must be set
	*                 to the desired output format;
	*                 Its \ref AVFormatContext.pb "pb" field must be set to an
	*                 already opened ::AVIOContext.
	* @param options  An ::AVDictionary filled with AVFormatContext and
	*                 muxer-private options.
	*                 On return this parameter will be destroyed and replaced with
	*                 a dict containing options that were not found. May be NULL.
	*
	* @retval AVSTREAM_INIT_IN_WRITE_HEADER On success, if the codec requires
	*                                       avformat_write_header to fully initialize.
	* @retval AVSTREAM_INIT_IN_INIT_OUTPUT  On success, if the codec has been fully
	*                                       initialized.
	* @retval AVERROR                       Anegative AVERROR on failure.
	*
	* @see av_opt_find, av_dict_set, avio_open, av_oformat_next, avformat_write_header.
	*/
	avformat_init_output :: proc(s: ^AVFormatContext, options: ^^i32) -> i32 ---

	/**
	* Write a packet to an output media file.
	*
	* This function passes the packet directly to the muxer, without any buffering
	* or reordering. The caller is responsible for correctly interleaving the
	* packets if the format requires it. Callers that want libavformat to handle
	* the interleaving should call av_interleaved_write_frame() instead of this
	* function.
	*
	* @param s media file handle
	* @param pkt The packet containing the data to be written. Note that unlike
	*            av_interleaved_write_frame(), this function does not take
	*            ownership of the packet passed to it (though some muxers may make
	*            an internal reference to the input packet).
	*            <br>
	*            This parameter can be NULL (at any time, not just at the end), in
	*            order to immediately flush data buffered within the muxer, for
	*            muxers that buffer up data internally before writing it to the
	*            output.
	*            <br>
	*            Packet's @ref AVPacket.stream_index "stream_index" field must be
	*            set to the index of the corresponding stream in @ref
	*            AVFormatContext.streams "s->streams".
	*            <br>
	*            The timestamps (@ref AVPacket.pts "pts", @ref AVPacket.dts "dts")
	*            must be set to correct values in the stream's timebase (unless the
	*            output format is flagged with the AVFMT_NOTIMESTAMPS flag, then
	*            they can be set to AV_NOPTS_VALUE).
	*            The dts for subsequent packets passed to this function must be strictly
	*            increasing when compared in their respective timebases (unless the
	*            output format is flagged with the AVFMT_TS_NONSTRICT, then they
	*            merely have to be nondecreasing).  @ref AVPacket.duration
	*            "duration") should also be set if known.
	* @return < 0 on error, = 0 if OK, 1 if flushed and there is no more data to flush
	*
	* @see av_interleaved_write_frame()
	*/
	av_write_frame :: proc(s: ^AVFormatContext, pkt: ^i32) -> i32 ---

	/**
	* Write a packet to an output media file ensuring correct interleaving.
	*
	* This function will buffer the packets internally as needed to make sure the
	* packets in the output file are properly interleaved, usually ordered by
	* increasing dts. Callers doing their own interleaving should call
	* av_write_frame() instead of this function.
	*
	* Using this function instead of av_write_frame() can give muxers advance
	* knowledge of future packets, improving e.g. the behaviour of the mp4
	* muxer for VFR content in fragmenting mode.
	*
	* @param s media file handle
	* @param pkt The packet containing the data to be written.
	*            <br>
	*            If the packet is reference-counted, this function will take
	*            ownership of this reference and unreference it later when it sees
	*            fit. If the packet is not reference-counted, libavformat will
	*            make a copy.
	*            The returned packet will be blank (as if returned from
	*            av_packet_alloc()), even on error.
	*            <br>
	*            This parameter can be NULL (at any time, not just at the end), to
	*            flush the interleaving queues.
	*            <br>
	*            Packet's @ref AVPacket.stream_index "stream_index" field must be
	*            set to the index of the corresponding stream in @ref
	*            AVFormatContext.streams "s->streams".
	*            <br>
	*            The timestamps (@ref AVPacket.pts "pts", @ref AVPacket.dts "dts")
	*            must be set to correct values in the stream's timebase (unless the
	*            output format is flagged with the AVFMT_NOTIMESTAMPS flag, then
	*            they can be set to AV_NOPTS_VALUE).
	*            The dts for subsequent packets in one stream must be strictly
	*            increasing (unless the output format is flagged with the
	*            AVFMT_TS_NONSTRICT, then they merely have to be nondecreasing).
	*            @ref AVPacket.duration "duration" should also be set if known.
	*
	* @return 0 on success, a negative AVERROR on error.
	*
	* @see av_write_frame(), AVFormatContext.max_interleave_delta
	*/
	av_interleaved_write_frame :: proc(s: ^AVFormatContext, pkt: ^i32) -> i32 ---

	/**
	* Write an uncoded frame to an output media file.
	*
	* The frame must be correctly interleaved according to the container
	* specification; if not, av_interleaved_write_uncoded_frame() must be used.
	*
	* See av_interleaved_write_uncoded_frame() for details.
	*/
	av_write_uncoded_frame :: proc(s: ^AVFormatContext, stream_index: i32, frame: ^AVFrame) -> i32 ---

	/**
	* Write an uncoded frame to an output media file.
	*
	* If the muxer supports it, this function makes it possible to write an AVFrame
	* structure directly, without encoding it into a packet.
	* It is mostly useful for devices and similar special muxers that use raw
	* video or PCM data and will not serialize it into a byte stream.
	*
	* To test whether it is possible to use it with a given muxer and stream,
	* use av_write_uncoded_frame_query().
	*
	* The caller gives up ownership of the frame and must not access it
	* afterwards.
	*
	* @return  >=0 for success, a negative code on error
	*/
	av_interleaved_write_uncoded_frame :: proc(s: ^AVFormatContext, stream_index: i32, frame: ^AVFrame) -> i32 ---

	/**
	* Test whether a muxer supports uncoded frame.
	*
	* @return  >=0 if an uncoded frame can be written to that muxer and stream,
	*          <0 if not
	*/
	av_write_uncoded_frame_query :: proc(s: ^AVFormatContext, stream_index: i32) -> i32 ---

	/**
	* Write the stream trailer to an output media file and free the
	* file private data.
	*
	* May only be called after a successful call to avformat_write_header.
	*
	* @param s media file handle
	* @return 0 if OK, AVERROR_xxx on error
	*/
	av_write_trailer :: proc(s: ^AVFormatContext) -> i32 ---

	/**
	* Return the output format in the list of registered output formats
	* which best matches the provided parameters, or return NULL if
	* there is no match.
	*
	* @param short_name if non-NULL checks if short_name matches with the
	*                   names of the registered formats
	* @param filename   if non-NULL checks if filename terminates with the
	*                   extensions of the registered formats
	* @param mime_type  if non-NULL checks if mime_type matches with the
	*                   MIME type of the registered formats
	*/
	av_guess_format :: proc(short_name: cstring, filename: cstring, mime_type: cstring) -> ^AVOutputFormat ---

	/**
	* Guess the codec ID based upon muxer and filename.
	*/
	av_guess_codec :: proc(fmt: ^AVOutputFormat, short_name: cstring, filename: cstring, mime_type: cstring, type: AVMediaType) -> AVCodecID ---

	/**
	* Get timing information for the data currently output.
	* The exact meaning of "currently output" depends on the format.
	* It is mostly relevant for devices that have an internal buffer and/or
	* work in real time.
	* @param s          media file handle
	* @param stream     stream in the media file
	* @param[out] dts   DTS of the last packet output for the stream, in stream
	*                   time_base units
	* @param[out] wall  absolute time when that packet whas output,
	*                   in microsecond
	* @retval  0               Success
	* @retval  AVERROR(ENOSYS) The format does not support it
	*
	* @note Some formats or devices may not allow to measure dts and wall
	*       atomically.
	*/
	av_get_output_timestamp :: proc(s: ^AVFormatContext, stream: i32, dts: ^i64, wall: ^i64) -> i32 ---

	/**
	* Send a nice hexadecimal dump of a buffer to the log.
	*
	* @param avcl A pointer to an arbitrary struct of which the first field is a
	* pointer to an AVClass struct.
	* @param level The importance level of the message, lower values signifying
	* higher importance.
	* @param buf buffer
	* @param size buffer size
	*
	* @see av_hex_dump, av_pkt_dump2, av_pkt_dump_log2
	*/
	av_hex_dump_log :: proc(avcl: rawptr, level: i32, buf: ^u8, size: i32) ---

	/**
	* Send a nice dump of a packet to the log.
	*
	* @param avcl A pointer to an arbitrary struct of which the first field is a
	* pointer to an AVClass struct.
	* @param level The importance level of the message, lower values signifying
	* higher importance.
	* @param pkt packet to dump
	* @param dump_payload True if the payload must be displayed, too.
	* @param st AVStream that the packet belongs to
	*/
	av_pkt_dump_log2 :: proc(avcl: rawptr, level: i32, pkt: ^i32, dump_payload: i32, st: ^AVStream) ---

	/**
	* Get the AVCodecID for the given codec tag tag.
	* If no codec id is found returns AV_CODEC_ID_NONE.
	*
	* @param tags list of supported codec_id-codec_tag pairs, as stored
	* in AVInputFormat.codec_tag and AVOutputFormat.codec_tag
	* @param tag  codec tag to match to a codec ID
	*/
	av_codec_get_id :: proc(tags: ^^AVCodecTag, tag: u32) -> AVCodecID ---

	/**
	* Get the codec tag for the given codec id id.
	* If no codec tag is found returns 0.
	*
	* @param tags list of supported codec_id-codec_tag pairs, as stored
	* in AVInputFormat.codec_tag and AVOutputFormat.codec_tag
	* @param id   codec ID to match to a codec tag
	*/
	av_codec_get_tag :: proc(tags: ^^AVCodecTag, id: AVCodecID) -> u32 ---

	/**
	* Get the codec tag for the given codec id.
	*
	* @param tags list of supported codec_id - codec_tag pairs, as stored
	* in AVInputFormat.codec_tag and AVOutputFormat.codec_tag
	* @param id codec id that should be searched for in the list
	* @param tag A pointer to the found tag
	* @return 0 if id was not found in tags, > 0 if it was found
	*/
	av_codec_get_tag2            :: proc(tags: ^^AVCodecTag, id: AVCodecID, tag: ^u32) -> i32 ---
	av_find_default_stream_index :: proc(s: ^AVFormatContext) -> i32 ---

	/**
	* Get the index for a specific timestamp.
	*
	* @param st        stream that the timestamp belongs to
	* @param timestamp timestamp to retrieve the index for
	* @param flags if AVSEEK_FLAG_BACKWARD then the returned index will correspond
	*                 to the timestamp which is <= the requested one, if backward
	*                 is 0, then it will be >=
	*              if AVSEEK_FLAG_ANY seek to any frame, only keyframes otherwise
	* @return < 0 if no such timestamp could be found
	*/
	av_index_search_timestamp :: proc(st: ^AVStream, timestamp: i64, flags: i32) -> i32 ---

	/**
	* Get the index entry count for the given AVStream.
	*
	* @param st stream
	* @return the number of index entries in the stream
	*/
	avformat_index_get_entries_count :: proc(st: ^AVStream) -> i32 ---

	/**
	* Get the AVIndexEntry corresponding to the given index.
	*
	* @param st          Stream containing the requested AVIndexEntry.
	* @param idx         The desired index.
	* @return A pointer to the requested AVIndexEntry if it exists, NULL otherwise.
	*
	* @note The pointer returned by this function is only guaranteed to be valid
	*       until any function that takes the stream or the parent AVFormatContext
	*       as input argument is called.
	*/
	avformat_index_get_entry :: proc(st: ^AVStream, idx: i32) -> ^AVIndexEntry ---

	/**
	* Get the AVIndexEntry corresponding to the given timestamp.
	*
	* @param st          Stream containing the requested AVIndexEntry.
	* @param wanted_timestamp   Timestamp to retrieve the index entry for.
	* @param flags       If AVSEEK_FLAG_BACKWARD then the returned entry will correspond
	*                    to the timestamp which is <= the requested one, if backward
	*                    is 0, then it will be >=
	*                    if AVSEEK_FLAG_ANY seek to any frame, only keyframes otherwise.
	* @return A pointer to the requested AVIndexEntry if it exists, NULL otherwise.
	*
	* @note The pointer returned by this function is only guaranteed to be valid
	*       until any function that takes the stream or the parent AVFormatContext
	*       as input argument is called.
	*/
	avformat_index_get_entry_from_timestamp :: proc(st: ^AVStream, wanted_timestamp: i64, flags: i32) -> ^AVIndexEntry ---

	/**
	* Add an index entry into a sorted list. Update the entry if the list
	* already contains it.
	*
	* @param timestamp timestamp in the time base of the given stream
	*/
	av_add_index_entry :: proc(st: ^AVStream, pos: i64, timestamp: i64, size: i32, distance: i32, flags: i32) -> i32 ---

	/**
	* Split a URL string into components.
	*
	* The pointers to buffers for storing individual components may be null,
	* in order to ignore that component. Buffers for components not found are
	* set to empty strings. If the port is not found, it is set to a negative
	* value.
	*
	* @param proto the buffer for the protocol
	* @param proto_size the size of the proto buffer
	* @param authorization the buffer for the authorization
	* @param authorization_size the size of the authorization buffer
	* @param hostname the buffer for the host name
	* @param hostname_size the size of the hostname buffer
	* @param port_ptr a pointer to store the port number in
	* @param path the buffer for the path
	* @param path_size the size of the path buffer
	* @param url the URL to split
	*/
	av_url_split :: proc(proto: cstring, proto_size: i32, authorization: cstring, authorization_size: i32, hostname: cstring, hostname_size: i32, port_ptr: ^i32, path: cstring, path_size: i32, url: cstring) ---

	/**
	* Print detailed information about the input or output format, such as
	* duration, bitrate, streams, container, programs, metadata, side data,
	* codec and time base.
	*
	* @param ic        the context to analyze
	* @param index     index of the stream to dump information about
	* @param url       the URL to print, such as source or destination file
	* @param is_output Select whether the specified context is an input(0) or output(1)
	*/
	av_dump_format :: proc(ic: ^AVFormatContext, index: i32, url: cstring, is_output: i32) ---
}

AV_FRAME_FILENAME_FLAGS_MULTIPLE :: 1 ///< Allow multiple %d

@(default_calling_convention="c")
foreign lib {
	/**
	* Return in 'buf' the path with '%d' replaced by a number.
	*
	* Also handles the '%0nd' format where 'n' is the total number
	* of digits and '%%'.
	*
	* @param buf destination buffer
	* @param buf_size destination buffer size
	* @param path numbered sequence string
	* @param number frame number
	* @param flags AV_FRAME_FILENAME_FLAGS_*
	* @return 0 if OK, -1 on format error
	*/
	av_get_frame_filename2 :: proc(buf: cstring, buf_size: i32, path: cstring, number: i32, flags: i32) -> i32 ---
	av_get_frame_filename  :: proc(buf: cstring, buf_size: i32, path: cstring, number: i32) -> i32 ---

	/**
	* Check whether filename actually is a numbered sequence generator.
	*
	* @param filename possible numbered sequence string
	* @return 1 if a valid numbered sequence string, 0 otherwise
	*/
	av_filename_number_test :: proc(filename: cstring) -> i32 ---

	/**
	* Generate an SDP for an RTP session.
	*
	* Note, this overwrites the id values of AVStreams in the muxer contexts
	* for getting unique dynamic payload types.
	*
	* @param ac array of AVFormatContexts describing the RTP streams. If the
	*           array is composed by only one context, such context can contain
	*           multiple AVStreams (one AVStream per RTP stream). Otherwise,
	*           all the contexts in the array (an AVCodecContext per RTP stream)
	*           must contain only one AVStream.
	* @param n_files number of AVCodecContexts contained in ac
	* @param buf buffer where the SDP will be stored (must be allocated by
	*            the caller)
	* @param size the size of the buffer
	* @return 0 if OK, AVERROR_xxx on error
	*/
	av_sdp_create :: proc(ac: [^]^AVFormatContext, n_files: i32, buf: cstring, size: i32) -> i32 ---

	/**
	* Return a positive value if the given filename has one of the given
	* extensions, 0 otherwise.
	*
	* @param filename   file name to check against the given extensions
	* @param extensions a comma-separated list of filename extensions
	*/
	av_match_ext :: proc(filename: cstring, extensions: cstring) -> i32 ---

	/**
	* Test if the given container can store a codec.
	*
	* @param ofmt           container to check for compatibility
	* @param codec_id       codec to potentially store in container
	* @param std_compliance standards compliance level, one of FF_COMPLIANCE_*
	*
	* @return 1 if codec with ID codec_id can be stored in ofmt, 0 if it cannot.
	*         A negative number if this information is not available.
	*/
	avformat_query_codec :: proc(ofmt: ^AVOutputFormat, codec_id: AVCodecID, std_compliance: i32) -> i32 ---

	/**
	* @defgroup riff_fourcc RIFF FourCCs
	* @{
	* Get the tables mapping RIFF FourCCs to libavcodec AVCodecIDs. The tables are
	* meant to be passed to av_codec_get_id()/av_codec_get_tag() as in the
	* following code:
	* @code
	* uint32_t tag = MKTAG('H', '2', '6', '4');
	* const struct AVCodecTag *table[] = { avformat_get_riff_video_tags(), 0 };
	* enum AVCodecID id = av_codec_get_id(table, tag);
	* @endcode
	*/
	/**
	* @return the table mapping RIFF FourCCs for video to libavcodec AVCodecID.
	*/
	avformat_get_riff_video_tags :: proc() -> ^AVCodecTag ---

	/**
	* @return the table mapping RIFF FourCCs for audio to AVCodecID.
	*/
	avformat_get_riff_audio_tags :: proc() -> ^AVCodecTag ---

	/**
	* @return the table mapping MOV FourCCs for video to libavcodec AVCodecID.
	*/
	avformat_get_mov_video_tags :: proc() -> ^AVCodecTag ---

	/**
	* @return the table mapping MOV FourCCs for audio to AVCodecID.
	*/
	avformat_get_mov_audio_tags :: proc() -> ^AVCodecTag ---

	/**
	* Guess the sample aspect ratio of a frame, based on both the stream and the
	* frame aspect ratio.
	*
	* Since the frame aspect ratio is set by the codec but the stream aspect ratio
	* is set by the demuxer, these two may not be equal. This function tries to
	* return the value that you should use if you would like to display the frame.
	*
	* Basic logic is to use the stream aspect ratio if it is set to something sane
	* otherwise use the frame aspect ratio. This way a container setting, which is
	* usually easy to modify can override the coded value in the frames.
	*
	* @param format the format context which the stream is part of
	* @param stream the stream which the frame is part of
	* @param frame the frame with the aspect ratio to be determined
	* @return the guessed (valid) sample_aspect_ratio, 0/1 if no idea
	*/
	av_guess_sample_aspect_ratio :: proc(format: ^AVFormatContext, stream: ^AVStream, frame: ^AVFrame) -> i32 ---

	/**
	* Guess the frame rate, based on both the container and codec information.
	*
	* @param ctx the format context which the stream is part of
	* @param stream the stream which the frame is part of
	* @param frame the frame for which the frame rate should be determined, may be NULL
	* @return the guessed (valid) frame rate, 0/1 if no idea
	*/
	av_guess_frame_rate :: proc(ctx: ^AVFormatContext, stream: ^AVStream, frame: ^AVFrame) -> i32 ---

	/**
	* Check if the stream st contained in s is matched by the stream specifier
	* spec.
	*
	* See the "stream specifiers" chapter in the documentation for the syntax
	* of spec.
	*
	* @return  >0 if st is matched by spec;
	*          0  if st is not matched by spec;
	*          AVERROR code if spec is invalid
	*
	* @note  A stream specifier can match several streams in the format.
	*/
	avformat_match_stream_specifier  :: proc(s: ^AVFormatContext, st: ^AVStream, spec: cstring) -> i32 ---
	avformat_queue_attached_pictures :: proc(s: ^AVFormatContext) -> i32 ---
}

