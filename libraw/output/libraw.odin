// Odin bindings for LibRaw 0.22.2, generated from the LibRaw headers by
// generate_bindings.ps1 (https://github.com/Dihedron-Software/ffpackage, libraw/).
//
// LibRaw: Copyright (C) 2008-2025 LibRaw LLC (http://www.libraw.org, info@libraw.org)
// Generated bindings: Dihedron Software GmbH
//
// This file is distributed under the COMMON DEVELOPMENT AND DISTRIBUTION LICENSE (CDDL)
// Version 1.0, which is one of the two licenses LibRaw offers. See LICENSE.CDDL and COPYRIGHT.
/* -*- C++ -*-
 * File: libraw.h
 * Copyright 2008-2025 LibRaw LLC (info@libraw.org)
 * Created: Sat Mar  8, 2008
 *
 * LibRaw C++ interface
 *

LibRaw is free software; you can redistribute it and/or modify
it under the terms of the one of two licenses as you choose:

1. GNU LESSER GENERAL PUBLIC LICENSE version 2.1
   (See file LICENSE.LGPL provided in LibRaw distribution archive for details).

2. COMMON DEVELOPMENT AND DISTRIBUTION LICENSE (CDDL) Version 1.0
   (See file LICENSE.CDDL provided in LibRaw distribution archive for details).

*/
package libraw

import "core:c"

when ODIN_OS == .Windows {
    foreign import lib "libraw.lib"
} else when ODIN_OS == .Darwin {
    foreign import lib { "libraw.a", "system:c++" }
}

@(default_calling_convention="c")
foreign lib {
	libraw_strerror    :: proc(errorcode: i32) -> cstring ---
	libraw_strprogress :: proc(LibRaw_progress) -> cstring ---

	/* LibRaw C API */
	libraw_init               :: proc(flags: u32) -> ^libraw_data_t ---
	libraw_open_file          :: proc(^libraw_data_t, cstring) -> i32 ---
	libraw_open_wfile         :: proc(^libraw_data_t, ^c.wchar_t) -> i32 ---
	libraw_open_buffer        :: proc(_: ^libraw_data_t, buffer: rawptr, size: c.size_t) -> i32 ---
	libraw_open_bayer         :: proc(lr: ^libraw_data_t, data: ^u8, datalen: u32, _raw_width: ushort, _raw_height: ushort, _left_margin: ushort, _top_margin: ushort, _right_margin: ushort, _bottom_margin: ushort, procflags: u8, bayer_battern: u8, unused_bits: u32, otherflags: u32, black_level: u32) -> i32 ---
	libraw_unpack             :: proc(^libraw_data_t) -> i32 ---
	libraw_unpack_thumb       :: proc(^libraw_data_t) -> i32 ---
	libraw_unpack_thumb_ex    :: proc(^libraw_data_t, i32) -> i32 ---
	libraw_recycle_datastream :: proc(^libraw_data_t) ---
	libraw_recycle            :: proc(^libraw_data_t) ---
	libraw_close              :: proc(^libraw_data_t) ---
	libraw_subtract_black     :: proc(^libraw_data_t) ---
	libraw_raw2image          :: proc(^libraw_data_t) -> i32 ---
	libraw_free_image         :: proc(^libraw_data_t) ---

	/* version helpers */
	libraw_version       :: proc() -> cstring ---
	libraw_versionNumber :: proc() -> i32 ---

	/* Camera list */
	libraw_cameraList  :: proc() -> ^cstring ---
	libraw_cameraCount :: proc() -> i32 ---

	/* helpers */
	libraw_set_exifparser_handler   :: proc(_: ^libraw_data_t, cb: exif_parser_callback, datap: rawptr) ---
	libraw_set_makernotes_handler   :: proc(_: ^libraw_data_t, cb: exif_parser_callback, datap: rawptr) ---
	libraw_set_dataerror_handler    :: proc(_: ^libraw_data_t, func: data_callback, datap: rawptr) ---
	libraw_set_progress_handler     :: proc(_: ^libraw_data_t, cb: progress_callback, datap: rawptr) ---
	libraw_unpack_function_name     :: proc(lr: ^libraw_data_t) -> cstring ---
	libraw_get_decoder_info         :: proc(lr: ^libraw_data_t, d: ^libraw_decoder_info_t) -> i32 ---
	libraw_COLOR                    :: proc(_: ^libraw_data_t, row: i32, col: i32) -> i32 ---
	libraw_capabilities             :: proc() -> u32 ---
	libraw_adjust_to_raw_inset_crop :: proc(lr: ^libraw_data_t, mask: u32, maxcrop: f32) -> i32 ---

	/* DCRAW compatibility */
	libraw_adjust_sizes_info_only :: proc(^libraw_data_t) -> i32 ---
	libraw_dcraw_ppm_tiff_writer  :: proc(lr: ^libraw_data_t, filename: cstring) -> i32 ---
	libraw_dcraw_thumb_writer     :: proc(lr: ^libraw_data_t, fname: cstring) -> i32 ---
	libraw_dcraw_process          :: proc(lr: ^libraw_data_t) -> i32 ---
	libraw_dcraw_make_mem_image   :: proc(lr: ^libraw_data_t, errc: ^i32) -> ^libraw_processed_image_t ---
	libraw_dcraw_make_mem_thumb   :: proc(lr: ^libraw_data_t, errc: ^i32) -> ^libraw_processed_image_t ---
	libraw_dcraw_clear_mem        :: proc(^libraw_processed_image_t) ---

	/* getters/setters used by 3DLut Creator */
	libraw_set_demosaic           :: proc(lr: ^libraw_data_t, value: i32) ---
	libraw_set_output_color       :: proc(lr: ^libraw_data_t, value: i32) ---
	libraw_set_adjust_maximum_thr :: proc(lr: ^libraw_data_t, value: f32) ---
	libraw_set_user_mul           :: proc(lr: ^libraw_data_t, index: i32, val: f32) ---
	libraw_set_output_bps         :: proc(lr: ^libraw_data_t, value: i32) ---
	libraw_set_gamma              :: proc(lr: ^libraw_data_t, index: i32, value: f32) ---
	libraw_set_no_auto_bright     :: proc(lr: ^libraw_data_t, value: i32) ---
	libraw_set_bright             :: proc(lr: ^libraw_data_t, value: f32) ---
	libraw_set_highlight          :: proc(lr: ^libraw_data_t, value: i32) ---
	libraw_set_fbdd_noiserd       :: proc(lr: ^libraw_data_t, value: i32) ---
	libraw_get_raw_height         :: proc(lr: ^libraw_data_t) -> i32 ---
	libraw_get_raw_width          :: proc(lr: ^libraw_data_t) -> i32 ---
	libraw_get_iheight            :: proc(lr: ^libraw_data_t) -> i32 ---
	libraw_get_iwidth             :: proc(lr: ^libraw_data_t) -> i32 ---
	libraw_get_cam_mul            :: proc(lr: ^libraw_data_t, index: i32) -> f32 ---
	libraw_get_pre_mul            :: proc(lr: ^libraw_data_t, index: i32) -> f32 ---
	libraw_get_rgb_cam            :: proc(lr: ^libraw_data_t, index1: i32, index2: i32) -> f32 ---
	libraw_get_color_maximum      :: proc(lr: ^libraw_data_t) -> i32 ---
	libraw_set_output_tif         :: proc(lr: ^libraw_data_t, value: i32) ---
	libraw_get_iparams            :: proc(lr: ^libraw_data_t) -> ^libraw_iparams_t ---
	libraw_get_lensinfo           :: proc(lr: ^libraw_data_t) -> ^libraw_lensinfo_t ---
	libraw_get_imgother           :: proc(lr: ^libraw_data_t) -> ^libraw_imgother_t ---
}

