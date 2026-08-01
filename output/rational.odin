/*
 * rational numbers
 * Copyright (c) 2003 Michael Niedermayer <michaelni@gmx.at>
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
 * @ingroup lavu_math_rational
 * Utilities for rational number calculation.
 * @author Michael Niedermayer <michaelni@gmx.at>
 */
package ffmpeg

when ODIN_OS == .Windows {
    foreign import lib "lib/avutil.lib"
} else when ODIN_OS == .Darwin {
    @(extra_linker_flags = "-L/opt/homebrew/lib")
    foreign import lib "system:avutil"
}

/**
* Rational number (pair of numerator and denominator).
*/
AVRational :: struct {
	num: i32, ///< Numerator
	den: i32, ///< Denominator
}

@(default_calling_convention="c")
foreign lib {
	/**
	* Reduce a fraction.
	*
	* This is useful for framerate calculations.
	*
	* @param[out] dst_num Destination numerator
	* @param[out] dst_den Destination denominator
	* @param[in]      num Source numerator
	* @param[in]      den Source denominator
	* @param[in]      max Maximum allowed values for `dst_num` & `dst_den`
	* @return 1 if the operation is exact, 0 otherwise
	*/
	av_reduce :: proc(dst_num: ^i32, dst_den: ^i32, num: i64, den: i64, max: i64) -> i32 ---

	/**
	* Multiply two rationals.
	* @param b First rational
	* @param c Second rational
	* @return b*c
	*/
	av_mul_q :: proc(b: AVRational, _c: AVRational) -> AVRational ---

	/**
	* Divide one rational by another.
	* @param b First rational
	* @param c Second rational
	* @return b/c
	*/
	av_div_q :: proc(b: AVRational, _c: AVRational) -> AVRational ---

	/**
	* Add two rationals.
	* @param b First rational
	* @param c Second rational
	* @return b+c
	*/
	av_add_q :: proc(b: AVRational, _c: AVRational) -> AVRational ---

	/**
	* Subtract one rational from another.
	* @param b First rational
	* @param c Second rational
	* @return b-c
	*/
	av_sub_q :: proc(b: AVRational, _c: AVRational) -> AVRational ---

	/**
	* Convert a double precision floating point number to a rational.
	*
	* In case of infinity, the returned value is expressed as `{1, 0}` or
	* `{-1, 0}` depending on the sign.
	*
	* In general rational numbers with |num| <= 1<<26 && |den| <= 1<<26
	* can be recovered exactly from their double representation.
	* (no exceptions were found within 1B random ones)
	*
	* @param d   `double` to convert
	* @param max Maximum allowed numerator and denominator
	* @return `d` in AVRational form
	* @see av_q2d()
	*/
	av_d2q :: proc(d: f64, max: i32) -> AVRational ---

	/**
	* Find which of the two rationals is closer to another rational.
	*
	* @param q     Rational to be compared against
	* @param q1    Rational to be tested
	* @param q2    Rational to be tested
	* @return One of the following values:
	*         - 1 if `q1` is nearer to `q` than `q2`
	*         - -1 if `q2` is nearer to `q` than `q1`
	*         - 0 if they have the same distance
	*/
	av_nearer_q :: proc(q: AVRational, q1: AVRational, q2: AVRational) -> i32 ---

	/**
	* Find the value in a list of rationals nearest a given reference rational.
	*
	* @param q      Reference rational
	* @param q_list Array of rationals terminated by `{0, 0}`
	* @return Index of the nearest value found in the array
	*/
	av_find_nearest_q_idx :: proc(q: AVRational, q_list: ^AVRational) -> i32 ---

	/**
	* Convert an AVRational to a IEEE 32-bit `float` expressed in fixed-point
	* format.
	*
	* @param q Rational to be converted
	* @return Equivalent floating-point value, expressed as an unsigned 32-bit
	*         integer.
	* @note The returned value is platform-indepedant.
	*/
	av_q2intfloat :: proc(q: AVRational) -> u32 ---

	/**
	* Return the best rational so that a and b are multiple of it.
	* If the resulting denominator is larger than max_den, return def.
	*/
	av_gcd_q :: proc(a: AVRational, b: AVRational, max_den: i32, def: AVRational) -> AVRational ---
}

