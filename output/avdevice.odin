/*
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
    foreign import lib "lib/avdevice.lib"
} else when ODIN_OS == .Darwin {
    @(extra_linker_flags = "-L/opt/homebrew/lib")
    foreign import lib "system:avdevice"
}

@(default_calling_convention="c")
foreign lib {
	/**
	* Return the LIBAVDEVICE_VERSION_INT constant.
	*/
	avdevice_version :: proc() -> u32 ---

	/**
	* Return the libavdevice build-time configuration.
	*/
	avdevice_configuration :: proc() -> cstring ---

	/**
	* Return the libavdevice license.
	*/
	avdevice_license :: proc() -> cstring ---

	/**
	* Initialize libavdevice and register all the input and output devices.
	*/
	avdevice_register_all :: proc() ---

	/**
	* Audio input devices iterator.
	*
	* If d is NULL, returns the first registered input audio/video device,
	* if d is non-NULL, returns the next registered input audio/video device after d
	* or NULL if d is the last one.
	*/
	av_input_audio_device_next :: proc(d: ^i32) -> ^i32 ---

	/**
	* Video input devices iterator.
	*
	* If d is NULL, returns the first registered input audio/video device,
	* if d is non-NULL, returns the next registered input audio/video device after d
	* or NULL if d is the last one.
	*/
	av_input_video_device_next :: proc(d: ^i32) -> ^i32 ---

	/**
	* Audio output devices iterator.
	*
	* If d is NULL, returns the first registered output audio/video device,
	* if d is non-NULL, returns the next registered output audio/video device after d
	* or NULL if d is the last one.
	*/
	av_output_audio_device_next :: proc(d: ^i32) -> ^i32 ---

	/**
	* Video output devices iterator.
	*
	* If d is NULL, returns the first registered output audio/video device,
	* if d is non-NULL, returns the next registered output audio/video device after d
	* or NULL if d is the last one.
	*/
	av_output_video_device_next :: proc(d: ^i32) -> ^i32 ---
}

AVDeviceRect :: struct {
	x:      i32, /**< x coordinate of top left corner */
	y:      i32, /**< y coordinate of top left corner */
	width:  i32, /**< width */
	height: i32, /**< height */
}

/**
* Message types used by avdevice_app_to_dev_control_message().
*/
AVAppToDevMessageType :: enum i32 {
	/**
	* Dummy message.
	*/
	NONE           = 0,

	/**
	* Window size change message.
	*
	* Message is sent to the device every time the application changes the size
	* of the window device renders to.
	* Message should also be sent right after window is created.
	*
	* data: AVDeviceRect: new window size.
	*/
	WINDOW_SIZE    = 1,

	/**
	* Repaint request message.
	*
	* Message is sent to the device when window has to be repainted.
	*
	* data: AVDeviceRect: area required to be repainted.
	*       NULL: whole area is required to be repainted.
	*/
	WINDOW_REPAINT = 2,

	/**
	* Request pause/play.
	*
	* Application requests pause/unpause playback.
	* Mostly usable with devices that have internal buffer.
	* By default devices are not paused.
	*
	* data: NULL
	*/
	PAUSE          = 3,
	PLAY           = 4,
	TOGGLE_PAUSE   = 5,

	/**
	* Volume control message.
	*
	* Set volume level. It may be device-dependent if volume
	* is changed per stream or system wide. Per stream volume
	* change is expected when possible.
	*
	* data: double: new volume with range of 0.0 - 1.0.
	*/
	SET_VOLUME     = 6,

	/**
	* Mute control messages.
	*
	* Change mute state. It may be device-dependent if mute status
	* is changed per stream or system wide. Per stream mute status
	* change is expected when possible.
	*
	* data: NULL.
	*/
	MUTE           = 7,
	UNMUTE         = 8,
	TOGGLE_MUTE    = 9,

	/**
	* Get volume/mute messages.
	*
	* Force the device to send AV_DEV_TO_APP_VOLUME_LEVEL_CHANGED or
	* AV_DEV_TO_APP_MUTE_STATE_CHANGED command respectively.
	*
	* data: NULL.
	*/
	GET_VOLUME     = 10,
	GET_MUTE       = 11,
}

/**
* Message types used by avdevice_dev_to_app_control_message().
*/
AVDevToAppMessageType :: enum i32 {
	/**
	* Dummy message.
	*/
	NONE                  = 0,

	/**
	* Create window buffer message.
	*
	* Device requests to create a window buffer. Exact meaning is device-
	* and application-dependent. Message is sent before rendering first
	* frame and all one-shot initializations should be done here.
	* Application is allowed to ignore preferred window buffer size.
	*
	* @note: Application is obligated to inform about window buffer size
	*        with AV_APP_TO_DEV_WINDOW_SIZE message.
	*
	* data: AVDeviceRect: preferred size of the window buffer.
	*       NULL: no preferred size of the window buffer.
	*/
	CREATE_WINDOW_BUFFER  = 1,

	/**
	* Prepare window buffer message.
	*
	* Device requests to prepare a window buffer for rendering.
	* Exact meaning is device- and application-dependent.
	* Message is sent before rendering of each frame.
	*
	* data: NULL.
	*/
	PREPARE_WINDOW_BUFFER = 2,

	/**
	* Display window buffer message.
	*
	* Device requests to display a window buffer.
	* Message is sent when new frame is ready to be displayed.
	* Usually buffers need to be swapped in handler of this message.
	*
	* data: NULL.
	*/
	DISPLAY_WINDOW_BUFFER = 3,

	/**
	* Destroy window buffer message.
	*
	* Device requests to destroy a window buffer.
	* Message is sent when device is about to be destroyed and window
	* buffer is not required anymore.
	*
	* data: NULL.
	*/
	DESTROY_WINDOW_BUFFER = 4,

	/**
	* Buffer fullness status messages.
	*
	* Device signals buffer overflow/underflow.
	*
	* data: NULL.
	*/
	BUFFER_OVERFLOW       = 5,
	BUFFER_UNDERFLOW      = 6,

	/**
	* Buffer readable/writable.
	*
	* Device informs that buffer is readable/writable.
	* When possible, device informs how many bytes can be read/write.
	*
	* @warning Device may not inform when number of bytes than can be read/write changes.
	*
	* data: int64_t: amount of bytes available to read/write.
	*       NULL: amount of bytes available to read/write is not known.
	*/
	BUFFER_READABLE       = 7,
	BUFFER_WRITABLE       = 8,

	/**
	* Mute state change message.
	*
	* Device informs that mute state has changed.
	*
	* data: int: 0 for not muted state, non-zero for muted state.
	*/
	MUTE_STATE_CHANGED    = 9,

	/**
	* Volume level change message.
	*
	* Device informs that volume level has changed.
	*
	* data: double: new volume with range of 0.0 - 1.0.
	*/
	VOLUME_LEVEL_CHANGED  = 10,
}

@(default_calling_convention="c")
foreign lib {
	/**
	* Send control message from application to device.
	*
	* @param s         device context.
	* @param type      message type.
	* @param data      message data. Exact type depends on message type.
	* @param data_size size of message data.
	* @return >= 0 on success, negative on error.
	*         AVERROR(ENOSYS) when device doesn't implement handler of the message.
	*/
	avdevice_app_to_dev_control_message :: proc(s: ^AVFormatContext, type: AVAppToDevMessageType, data: rawptr, data_size: c.size_t) -> i32 ---

	/**
	* Send control message from device to application.
	*
	* @param s         device context.
	* @param type      message type.
	* @param data      message data. Can be NULL.
	* @param data_size size of message data.
	* @return >= 0 on success, negative on error.
	*         AVERROR(ENOSYS) when application doesn't implement handler of the message.
	*/
	avdevice_dev_to_app_control_message :: proc(s: ^AVFormatContext, type: AVDevToAppMessageType, data: rawptr, data_size: c.size_t) -> i32 ---
}

/**
* Structure describes basic parameters of the device.
*/
AVDeviceInfo :: struct {
	device_name:        cstring,      /**< device name, format depends on device */
	device_description: cstring,      /**< human friendly name */
	media_types:        ^AVMediaType, /**< array indicating what media types(s), if any, a device can provide. If null, cannot provide any */
	nb_media_types:     i32,          /**< length of media_types array, 0 if device cannot provide any media types */
}

AVMediaType :: enum i32 {
} /**< array indicating what media types(s), if any, a device can provide. If null, cannot provide any */

/**
* List of devices.
*/
AVDeviceInfoList :: struct {
	devices:        ^^AVDeviceInfo, /**< list of autodetected devices */
	nb_devices:     i32,            /**< number of autodetected devices */
	default_device: i32,            /**< index of default device or -1 if no default */
}

@(default_calling_convention="c")
foreign lib {
	/**
	* List devices.
	*
	* Returns available device names and their parameters.
	*
	* @note: Some devices may accept system-dependent device names that cannot be
	*        autodetected. The list returned by this function cannot be assumed to
	*        be always completed.
	*
	* @param s                device context.
	* @param[out] device_list list of autodetected devices.
	* @return count of autodetected devices, negative on error.
	*/
	avdevice_list_devices :: proc(s: ^AVFormatContext, device_list: ^^AVDeviceInfoList) -> i32 ---

	/**
	* Convenient function to free result of avdevice_list_devices().
	*
	* @param device_list device list to be freed.
	*/
	avdevice_free_list_devices :: proc(device_list: ^^AVDeviceInfoList) ---

	/**
	* List devices.
	*
	* Returns available device names and their parameters.
	* These are convenient wrappers for avdevice_list_devices().
	* Device context is allocated and deallocated internally.
	*
	* @param device           device format. May be NULL if device name is set.
	* @param device_name      device name. May be NULL if device format is set.
	* @param device_options   An AVDictionary filled with device-private options. May be NULL.
	*                         The same options must be passed later to avformat_write_header() for output
	*                         devices or avformat_open_input() for input devices, or at any other place
	*                         that affects device-private options.
	* @param[out] device_list list of autodetected devices
	* @return count of autodetected devices, negative on error.
	* @note device argument takes precedence over device_name when both are set.
	*/
	avdevice_list_input_sources :: proc(device: ^i32, device_name: cstring, device_options: ^i32, device_list: ^^AVDeviceInfoList) -> i32 ---
	avdevice_list_output_sinks  :: proc(device: ^i32, device_name: cstring, device_options: ^i32, device_list: ^^AVDeviceInfoList) -> i32 ---
}

