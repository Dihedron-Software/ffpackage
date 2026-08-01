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

/**
 * @file
 * @ingroup lavu_buffer
 * refcounted data buffer API
 */
package ffmpeg

import "core:c"

when ODIN_OS == .Windows {
    foreign import lib "lib/avutil.lib"
} else when ODIN_OS == .Darwin {
    @(extra_linker_flags = "-L/opt/homebrew/lib")
    foreign import lib "system:avutil"
}

AVBuffer :: struct {}

/**
* A reference to a data buffer.
*
* The size of this struct is not a part of the public ABI and it is not meant
* to be allocated directly.
*/
AVBufferRef :: struct {
	buffer: ^AVBuffer,

	/**
	* The data buffer. It is considered writable if and only if
	* this is the only reference to the buffer, in which case
	* av_buffer_is_writable() returns 1.
	*/
	data: ^u8,

	/**
	* Size of data in bytes.
	*/
	size: c.size_t,
}

@(default_calling_convention="c")
foreign lib {
	/**
	* Allocate an AVBuffer of the given size using av_malloc().
	*
	* @return an AVBufferRef of given size or NULL when out of memory
	*/
	av_buffer_alloc :: proc(size: c.size_t) -> ^AVBufferRef ---

	/**
	* Same as av_buffer_alloc(), except the returned buffer will be initialized
	* to zero.
	*/
	av_buffer_allocz :: proc(size: c.size_t) -> ^AVBufferRef ---
}

/**
* Always treat the buffer as read-only, even when it has only one
* reference.
*/
AV_BUFFER_FLAG_READONLY :: (1<<0)

@(default_calling_convention="c")
foreign lib {
	/**
	* Create an AVBuffer from an existing array.
	*
	* If this function is successful, data is owned by the AVBuffer. The caller may
	* only access data through the returned AVBufferRef and references derived from
	* it.
	* If this function fails, data is left untouched.
	* @param data   data array
	* @param size   size of data in bytes
	* @param free   a callback for freeing this buffer's data
	* @param opaque parameter to be got for processing or passed to free
	* @param flags  a combination of AV_BUFFER_FLAG_*
	*
	* @return an AVBufferRef referring to data on success, NULL on failure.
	*/
	av_buffer_create :: proc(data: ^u8, size: c.size_t, free: proc "c" (opaque: rawptr, data: ^u8), opaque: rawptr, flags: i32) -> ^AVBufferRef ---

	/**
	* Default free callback, which calls av_free() on the buffer data.
	* This function is meant to be passed to av_buffer_create(), not called
	* directly.
	*/
	av_buffer_default_free :: proc(opaque: rawptr, data: ^u8) ---

	/**
	* Create a new reference to an AVBuffer.
	*
	* @return a new AVBufferRef referring to the same AVBuffer as buf or NULL on
	* failure.
	*/
	av_buffer_ref :: proc(buf: ^AVBufferRef) -> ^AVBufferRef ---

	/**
	* Free a given reference and automatically free the buffer if there are no more
	* references to it.
	*
	* @param buf the reference to be freed. The pointer is set to NULL on return.
	*/
	av_buffer_unref :: proc(buf: ^^AVBufferRef) ---

	/**
	* @return 1 if the caller may write to the data referred to by buf (which is
	* true if and only if buf is the only reference to the underlying AVBuffer).
	* Return 0 otherwise.
	* A positive answer is valid until av_buffer_ref() is called on buf.
	*/
	av_buffer_is_writable :: proc(buf: ^AVBufferRef) -> i32 ---

	/**
	* @return the opaque parameter set by av_buffer_create.
	*/
	av_buffer_get_opaque    :: proc(buf: ^AVBufferRef) -> rawptr ---
	av_buffer_get_ref_count :: proc(buf: ^AVBufferRef) -> i32 ---

	/**
	* Create a writable reference from a given buffer reference, avoiding data copy
	* if possible.
	*
	* @param buf buffer reference to make writable. On success, buf is either left
	*            untouched, or it is unreferenced and a new writable AVBufferRef is
	*            written in its place. On failure, buf is left untouched.
	* @return 0 on success, a negative AVERROR on failure.
	*/
	av_buffer_make_writable :: proc(buf: ^^AVBufferRef) -> i32 ---

	/**
	* Reallocate a given buffer.
	*
	* @param buf  a buffer reference to reallocate. On success, buf will be
	*             unreferenced and a new reference with the required size will be
	*             written in its place. On failure buf will be left untouched. *buf
	*             may be NULL, then a new buffer is allocated.
	* @param size required new buffer size.
	* @return 0 on success, a negative AVERROR on failure.
	*
	* @note the buffer is actually reallocated with av_realloc() only if it was
	* initially allocated through av_buffer_realloc(NULL) and there is only one
	* reference to it (i.e. the one passed to this function). In all other cases
	* a new buffer is allocated and the data is copied.
	*/
	av_buffer_realloc :: proc(buf: ^^AVBufferRef, size: c.size_t) -> i32 ---

	/**
	* Ensure dst refers to the same data as src.
	*
	* When *dst is already equivalent to src, do nothing. Otherwise unreference dst
	* and replace it with a new reference to src.
	*
	* @param dst Pointer to either a valid buffer reference or NULL. On success,
	*            this will point to a buffer reference equivalent to src. On
	*            failure, dst will be left untouched.
	* @param src A buffer reference to replace dst with. May be NULL, then this
	*            function is equivalent to av_buffer_unref(dst).
	* @return 0 on success
	*         AVERROR(ENOMEM) on memory allocation failure.
	*/
	av_buffer_replace :: proc(dst: ^^AVBufferRef, src: ^AVBufferRef) -> i32 ---
}

AVBufferPool :: struct {}

@(default_calling_convention="c")
foreign lib {
	/**
	* Allocate and initialize a buffer pool.
	*
	* @param size size of each buffer in this pool
	* @param alloc a function that will be used to allocate new buffers when the
	* pool is empty. May be NULL, then the default allocator will be used
	* (av_buffer_alloc()).
	* @return newly created buffer pool on success, NULL on error.
	*/
	av_buffer_pool_init :: proc(size: c.size_t, alloc: proc "c" (size: c.size_t) -> ^AVBufferRef) -> ^AVBufferPool ---

	/**
	* Allocate and initialize a buffer pool with a more complex allocator.
	*
	* @param size size of each buffer in this pool
	* @param opaque arbitrary user data used by the allocator
	* @param alloc a function that will be used to allocate new buffers when the
	*              pool is empty. May be NULL, then the default allocator will be
	*              used (av_buffer_alloc()).
	* @param pool_free a function that will be called immediately before the pool
	*                  is freed. I.e. after av_buffer_pool_uninit() is called
	*                  by the caller and all the frames are returned to the pool
	*                  and freed. It is intended to uninitialize the user opaque
	*                  data. May be NULL.
	* @return newly created buffer pool on success, NULL on error.
	*/
	av_buffer_pool_init2 :: proc(size: c.size_t, opaque: rawptr, alloc: proc "c" (opaque: rawptr, size: c.size_t) -> ^AVBufferRef, pool_free: proc "c" (opaque: rawptr)) -> ^AVBufferPool ---

	/**
	* Mark the pool as being available for freeing. It will actually be freed only
	* once all the allocated buffers associated with the pool are released. Thus it
	* is safe to call this function while some of the allocated buffers are still
	* in use.
	*
	* @param pool pointer to the pool to be freed. It will be set to NULL.
	*/
	av_buffer_pool_uninit :: proc(pool: ^^AVBufferPool) ---

	/**
	* Allocate a new AVBuffer, reusing an old buffer from the pool when available.
	* This function may be called simultaneously from multiple threads.
	*
	* @return a reference to the new buffer on success, NULL on error.
	*/
	av_buffer_pool_get :: proc(pool: ^AVBufferPool) -> ^AVBufferRef ---

	/**
	* Query the original opaque parameter of an allocated buffer in the pool.
	*
	* @param ref a buffer reference to a buffer returned by av_buffer_pool_get.
	* @return the opaque parameter set by the buffer allocator function of the
	*         buffer pool.
	*
	* @note the opaque parameter of ref is used by the buffer pool implementation,
	* therefore you have to use this function to access the original opaque
	* parameter of an allocated buffer.
	*/
	av_buffer_pool_buffer_get_opaque :: proc(ref: ^AVBufferRef) -> rawptr ---
}

