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
#+build windows
package ffmpeg

import "core:c"

import "vendor:directx/d3d11"

/**
* This struct is allocated as AVHWDeviceContext.hwctx
*/
AVD3D11VADeviceContext :: struct {
	/**
	* Device used for texture creation and access. This can also be used to
	* set the libavcodec decoding device.
	*
	* Must be set by the user. This is the only mandatory field - the other
	* device context fields are set from this and are available for convenience.
	*
	* Deallocating the AVHWDeviceContext will always release this interface,
	* and it does not matter whether it was user-allocated.
	*/
	device: ^d3d11.IDevice,

	/**
	* If unset, this will be set from the device field on init.
	*
	* Deallocating the AVHWDeviceContext will always release this interface,
	* and it does not matter whether it was user-allocated.
	*/
	device_context: ^d3d11.IDeviceContext,

	/**
	* If unset, this will be set from the device field on init.
	*
	* Deallocating the AVHWDeviceContext will always release this interface,
	* and it does not matter whether it was user-allocated.
	*/
	video_device: ^d3d11.IVideoDevice,

	/**
	* If unset, this will be set from the device_context field on init.
	*
	* Deallocating the AVHWDeviceContext will always release this interface,
	* and it does not matter whether it was user-allocated.
	*/
	video_context: ^d3d11.IVideoContext,

	/**
	* Callbacks for locking. They protect accesses to device_context and
	* video_context calls. They also protect access to the internal staging
	* texture (for av_hwframe_transfer_data() calls). They do NOT protect
	* access to hwcontext or decoder state in general.
	*
	* If unset on init, the hwcontext implementation will set them to use an
	* internal mutex.
	*
	* The underlying lock must be recursive. lock_ctx is for free use by the
	* locking implementation.
	*/
	lock:     proc "c" (lock_ctx: rawptr),
	unlock:   proc "c" (lock_ctx: rawptr),
	lock_ctx: rawptr,
}

/**
* D3D11 frame descriptor for pool allocation.
*
* In user-allocated pools, AVHWFramesContext.pool must return AVBufferRefs
* with the data pointer pointing at an object of this type describing the
* planes of the frame.
*
* This has no use outside of custom allocation, and AVFrame AVBufferRef do not
* necessarily point to an instance of this struct.
*/
AVD3D11FrameDescriptor :: struct {
	/**
	* The texture in which the frame is located. The reference count is
	* managed by the AVBufferRef, and destroying the reference will release
	* the interface.
	*
	* Normally stored in AVFrame.data[0].
	*/
	texture: ^d3d11.ITexture2D,

	/**
	* The index into the array texture element representing the frame, or 0
	* if the texture is not an array texture.
	*
	* Normally stored in AVFrame.data[1] (cast from intptr_t).
	*/
	index: c.intptr_t,
}

/**
* This struct is allocated as AVHWFramesContext.hwctx
*/
AVD3D11VAFramesContext :: struct {
	/**
	* The canonical texture used for pool allocation. If this is set to NULL
	* on init, the hwframes implementation will allocate and set an array
	* texture if initial_pool_size > 0.
	*
	* The only situation when the API user should set this is:
	* - the user wants to do manual pool allocation (setting
	*   AVHWFramesContext.pool), instead of letting AVHWFramesContext
	*   allocate the pool
	* - of an array texture
	* - and wants it to use it for decoding
	* - this has to be done before calling av_hwframe_ctx_init()
	*
	* Deallocating the AVHWFramesContext will always release this interface,
	* and it does not matter whether it was user-allocated.
	*
	* This is in particular used by the libavcodec D3D11VA hwaccel, which
	* requires a single array texture. It will create ID3D11VideoDecoderOutputView
	* objects for each array texture element on decoder initialization.
	*/
	texture: ^d3d11.ITexture2D,

	/**
	* D3D11_TEXTURE2D_DESC.BindFlags used for texture creation. The user must
	* at least set D3D11_BIND_DECODER if the frames context is to be used for
	* video decoding.
	* This field is ignored/invalid if a user-allocated texture is provided.
	*/
	BindFlags: u32,

	/**
	* D3D11_TEXTURE2D_DESC.MiscFlags used for texture creation.
	* This field is ignored/invalid if a user-allocated texture is provided.
	*/
	MiscFlags: u32,

	/**
	* In case if texture structure member above is not NULL contains the same texture
	* pointer for all elements and different indexes into the array texture.
	* In case if texture structure member above is NULL, all elements contains
	* pointers to separate non-array textures and 0 indexes.
	* This field is ignored/invalid if a user-allocated texture is provided.
	*/
	texture_infos: ^AVD3D11FrameDescriptor,
}
