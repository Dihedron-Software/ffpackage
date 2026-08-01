/*
 * Codec parameters public API
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
* This struct describes the properties of an encoded stream.
*
* sizeof(AVCodecParameters) is not a part of the public ABI, this struct must
* be allocated with avcodec_parameters_alloc() and freed with
* avcodec_parameters_free().
*/
AVCodecParameters :: struct {
	/**
	* General type of the encoded data.
	*/
	codec_type: AVMediaType,

	/**
	* Specific type of the encoded data (the codec used).
	*/
	codec_id: AVCodecID,

	/**
	* Additional information about the codec (corresponds to the AVI FOURCC).
	*/
	codec_tag: u32,

	/**
	* Extra binary data needed for initializing the decoder, codec-dependent.
	*
	* Must be allocated with av_malloc() and will be freed by
	* avcodec_parameters_free(). The allocated size of extradata must be at
	* least extradata_size + AV_INPUT_BUFFER_PADDING_SIZE, with the padding
	* bytes zeroed.
	*/
	extradata: ^u8,

	/**
	* Size of the extradata content in bytes.
	*/
	extradata_size: i32,

	/**
	* Additional data associated with the entire stream.
	*
	* Should be allocated with av_packet_side_data_new() or
	* av_packet_side_data_add(), and will be freed by avcodec_parameters_free().
	*/
	coded_side_data: ^AVPacketSideData,

	/**
	* Amount of entries in @ref coded_side_data.
	*/
	nb_coded_side_data: i32,

	/**
	* - video: the pixel format, the value corresponds to enum AVPixelFormat.
	* - audio: the sample format, the value corresponds to enum AVSampleFormat.
	*/
	format: i32,

	/**
	* The average bitrate of the encoded data (in bits per second).
	*/
	bit_rate: i64,

	/**
	* The number of bits per sample in the codedwords.
	*
	* This is basically the bitrate per sample. It is mandatory for a bunch of
	* formats to actually decode them. It's the number of bits for one sample in
	* the actual coded bitstream.
	*
	* This could be for example 4 for ADPCM
	* For PCM formats this matches bits_per_raw_sample
	* Can be 0
	*/
	bits_per_coded_sample: i32,

	/**
	* This is the number of valid bits in each output sample. If the
	* sample format has more bits, the least significant bits are additional
	* padding bits, which are always 0. Use right shifts to reduce the sample
	* to its actual size. For example, audio formats with 24 bit samples will
	* have bits_per_raw_sample set to 24, and format set to AV_SAMPLE_FMT_S32.
	* To get the original sample use "(int32_t)sample >> 8"."
	*
	* For ADPCM this might be 12 or 16 or similar
	* Can be 0
	*/
	bits_per_raw_sample: i32,

	/**
	* Codec-specific bitstream restrictions that the stream conforms to.
	*/
	profile: i32,
	level:   i32,

	/**
	* Video only. The dimensions of the video frame in pixels.
	*/
	width:  i32,
	height: i32,

	/**
	* Video only. The aspect ratio (width / height) which a single pixel
	* should have when displayed.
	*
	* When the aspect ratio is unknown / undefined, the numerator should be
	* set to 0 (the denominator may have any value).
	*/
	sample_aspect_ratio: i32,

	/**
	* Video only. Number of frames per second, for streams with constant frame
	* durations. Should be set to { 0, 1 } when some frames have differing
	* durations or if the value is not known.
	*
	* @note This field corresponds to values that are stored in codec-level
	* headers and is typically overridden by container/transport-layer
	* timestamps, when available. It should thus be used only as a last resort,
	* when no higher-level timing information is available.
	*/
	framerate: i32,

	/**
	* Video only. The order of the fields in interlaced video.
	*/
	field_order: AVFieldOrder,

	/**
	* Video only. Additional colorspace characteristics.
	*/
	color_range:     AVColorRange,
	color_primaries: AVColorPrimaries,
	color_trc:       AVColorTransferCharacteristic,
	color_space:     AVColorSpace,
	chroma_location: AVChromaLocation,

	/**
	* Video only. Number of delayed frames.
	*/
	video_delay: i32,

	/**
	* Audio only. The channel layout and number of channels.
	*/
	ch_layout: i32,

	/**
	* Audio only. The number of audio samples per second.
	*/
	sample_rate: i32,

	/**
	* Audio only. The number of bytes per coded audio frame, required by some
	* formats.
	*
	* Corresponds to nBlockAlign in WAVEFORMATEX.
	*/
	block_align: i32,

	/**
	* Audio only. Audio frame size, if known. Required by some formats to be static.
	*/
	frame_size: i32,

	/**
	* Audio only. The amount of padding (in samples) inserted by the encoder at
	* the beginning of the audio. I.e. this number of leading decoded samples
	* must be discarded by the caller to get the original audio without leading
	* padding.
	*/
	initial_padding: i32,

	/**
	* Audio only. The amount of padding (in samples) appended by the encoder to
	* the end of the audio. I.e. this number of decoded samples must be
	* discarded by the caller from the end of the stream to get the original
	* audio without any trailing padding.
	*/
	trailing_padding: i32,

	/**
	* Audio only. Number of samples to skip after a discontinuity.
	*/
	seek_preroll: i32,
}

AVColorRange :: enum i32 {
}

AVColorPrimaries :: enum i32 {
}

AVColorTransferCharacteristic :: enum i32 {
}

AVColorSpace :: enum i32 {
}

AVChromaLocation :: enum i32 {
}

@(default_calling_convention="c")
foreign lib {
	/**
	* Allocate a new AVCodecParameters and set its fields to default values
	* (unknown/invalid/0). The returned struct must be freed with
	* avcodec_parameters_free().
	*/
	avcodec_parameters_alloc :: proc() -> ^AVCodecParameters ---

	/**
	* Free an AVCodecParameters instance and everything associated with it and
	* write NULL to the supplied pointer.
	*/
	avcodec_parameters_free :: proc(par: ^^AVCodecParameters) ---

	/**
	* Copy the contents of src to dst. Any allocated fields in dst are freed and
	* replaced with newly allocated duplicates of the corresponding fields in src.
	*
	* @return >= 0 on success, a negative AVERROR code on failure.
	*/
	avcodec_parameters_copy :: proc(dst: ^AVCodecParameters, src: ^AVCodecParameters) -> i32 ---

	/**
	* This function is the same as av_get_audio_frame_duration(), except it works
	* with AVCodecParameters instead of an AVCodecContext.
	*/
	av_get_audio_frame_duration2 :: proc(par: ^AVCodecParameters, frame_bytes: i32) -> i32 ---
}

