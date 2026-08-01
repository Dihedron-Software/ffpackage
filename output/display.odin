/*
 * Copyright (c) 2014 Vittorio Giovara <vittorio.giovara@gmail.com>
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

/**
 * @file
 * @ingroup lavu_video_display
 * Display matrix
 */
package ffmpeg

when ODIN_OS == .Windows {
    foreign import lib "lib/avutil.lib"
} else when ODIN_OS == .Darwin {
    foreign import lib "macos/libavutil.60.dylib"
}

@(default_calling_convention="c")
foreign lib {
	/**
	* Extract the rotation component of the transformation matrix.
	*
	* @param matrix the transformation matrix
	* @return the angle (in degrees) by which the transformation rotates the frame
	*         counterclockwise. The angle will be in range [-180.0, 180.0],
	*         or NaN if the matrix is singular.
	*
	* @note floating point numbers are inherently inexact, so callers are
	*       recommended to round the return value to nearest integer before use.
	*/
	av_display_rotation_get :: proc(_matrix: ^[9]i32) -> f64 ---

	/**
	* Initialize a transformation matrix describing a pure clockwise
	* rotation by the specified angle (in degrees).
	*
	* @param[out] matrix a transformation matrix (will be fully overwritten
	*                    by this function)
	* @param angle rotation angle in degrees.
	*/
	av_display_rotation_set :: proc(_matrix: ^[9]i32, angle: f64) ---

	/**
	* Flip the input matrix horizontally and/or vertically.
	*
	* @param[in,out] matrix a transformation matrix
	* @param hflip whether the matrix should be flipped horizontally
	* @param vflip whether the matrix should be flipped vertically
	*/
	av_display_matrix_flip :: proc(_matrix: ^[9]i32, hflip: i32, vflip: i32) ---
}

