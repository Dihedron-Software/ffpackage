// Odin bindings for LibRaw 0.22.2, generated from the LibRaw headers by
// generate_bindings.ps1 (https://github.com/Dihedron-Software/ffpackage, libraw/).
//
// LibRaw: Copyright (C) 2008-2025 LibRaw LLC (http://www.libraw.org, info@libraw.org)
// Generated bindings: Dihedron Software GmbH
//
// This file is distributed under the COMMON DEVELOPMENT AND DISTRIBUTION LICENSE (CDDL)
// Version 1.0, which is one of the two licenses LibRaw offers. See LICENSE.CDDL and COPYRIGHT.
/* -*- C++ -*-
 * File: libraw_types.h
 * Copyright 2008-2025 LibRaw LLC (info@libraw.org)
 * Created: Sat Mar  8 , 2008
 *
 * LibRaw C data structures
 *

LibRaw is free software; you can redistribute it and/or modify
it under the terms of the one of two licenses as you choose:

1. GNU LESSER GENERAL PUBLIC LICENSE version 2.1
   (See file LICENSE.LGPL provided in LibRaw distribution archive for details).

2. COMMON DEVELOPMENT AND DISTRIBUTION LICENSE (CDDL) Version 1.0
   (See file LICENSE.CDDL provided in LibRaw distribution archive for details).

 */
package libraw

import "core:c/libc"

when ODIN_OS == .Windows {
    foreign import lib "libraw.lib"
} else when ODIN_OS == .Darwin {
    foreign import lib { "libraw.a", "system:c++" }
}

INT64  :: i64
UINT64 :: u64
uchar  :: u8
ushort :: u16

libraw_decoder_info_t :: struct {
	decoder_name:  cstring,
	decoder_flags: u32,
}

libraw_internal_output_params_t :: struct {
	mix_green:   u32,
	raw_color:   u32,
	zero_is_bad: u32,
	shrink:      ushort,
	fuji_width:  ushort,
}

memory_callback      :: proc "c" (data: rawptr, file: cstring, _where: cstring)
exif_parser_callback :: proc "c" (_context: rawptr, tag: i32, type: i32, len: i32, ord: u32, ifp: rawptr, base: INT64)
data_callback        :: proc "c" (data: rawptr, file: cstring, offset: INT64)

@(default_calling_convention="c")
foreign lib {
	default_data_callback :: proc(data: rawptr, file: cstring, offset: INT64) ---
}

progress_callback      :: proc "c" (data: rawptr, stage: LibRaw_progress, iteration: i32, expected: i32) -> i32
pre_identify_callback  :: proc "c" (ctx: rawptr) -> i32
post_identify_callback :: proc "c" (ctx: rawptr)
process_step_callback  :: proc "c" (ctx: rawptr)

libraw_callbacks_t :: struct {
	data_cb:                                                         data_callback,
	datacb_data:                                                     rawptr,
	progress_cb:                                                     progress_callback,
	progresscb_data:                                                 rawptr,
	exif_cb, makernotes_cb:                                          exif_parser_callback,
	exifparser_data, makernotesparser_data:                          rawptr,
	pre_identify_cb:                                                 pre_identify_callback,
	post_identify_cb:                                                post_identify_callback,
	pre_subtractblack_cb, pre_scalecolors_cb:                        process_step_callback,
	pre_preinterpolate_cb, pre_interpolate_cb, interpolate_bayer_cb: process_step_callback,
	interpolate_xtrans_cb, post_interpolate_cb, pre_converttorgb_cb: process_step_callback,
	post_converttorgb_cb:                                            process_step_callback,
}

libraw_processed_image_t :: struct {
	type:                        LibRaw_image_formats,
	height, width, colors, bits: ushort,
	data_size:                   u32,
	data:                        [1]u8,
}

libraw_iparams_t :: struct {
	guard:            [4]i8,
	make:             [64]i8,
	model:            [64]i8,
	software:         [64]i8,
	normalized_make:  [64]i8,
	normalized_model: [64]i8,
	maker_index:      u32,
	raw_count:        u32,
	dng_version:      u32,
	is_foveon:        u32,
	colors:           i32,
	filters:          u32,
	xtrans:           [6][6]i8,
	xtrans_abs:       [6][6]i8,
	cdesc:            [5]i8,
	xmplen:           u32,
	xmpdata:          cstring,
}

libraw_raw_inset_crop_t :: struct {
	cleft, ctop, cwidth, cheight: ushort,
}

libraw_image_sizes_t :: struct {
	raw_height, raw_width, height, width, top_margin, left_margin: ushort,
	iheight, iwidth:                                               ushort,
	raw_pitch:                                                     u32,
	pixel_aspect:                                                  f64,
	flip:                                                          i32,
	mask:                                                          [8][4]i32,
	raw_aspect:                                                    ushort,
	raw_inset_crops:                                               [2]libraw_raw_inset_crop_t,
}

libraw_area_t :: struct {
	t, l, b, r: i16, // top, left, bottom, right pixel coordinates, (0,0) is top left pixel;
}

ph1_t :: struct {
	format, key_off, tag_21a:                            i32,
	t_black, split_col, black_col, split_row, black_row: i32,
	tag_210:                                             f32,
}

libraw_dng_color_t :: struct {
	parsedfields:  u32,
	illuminant:    ushort,
	calibration:   [4][4]f32,
	colormatrix:   [4][3]f32,
	forwardmatrix: [3][4]f32,
}

libraw_dng_rawopcode_t :: struct {
	len:  u32,
	data: rawptr,
}

libraw_dng_levels_t :: struct {
	parsedfields:        u32,
	dng_cblack:          [4104]u32,
	dng_black:           u32,
	dng_fcblack:         [4104]f32,
	dng_fblack:          f32,
	dng_whitelevel:      [4]u32,
	default_crop:        [4]ushort, /* Origin and size */
	user_crop:           [4]f32,    // top-left-bottom-right relative to default_crop
	preview_colorspace:  u32,
	analogbalance:       [4]f32,
	asshotneutral:       [4]f32,
	baseline_exposure:   f32,
	LinearResponseLimit: f32,
	rawopcodes:          [3]libraw_dng_rawopcode_t,
}

libraw_P1_color_t :: struct {
	romm_cam: [9]f32,
}

libraw_canon_makernotes_t :: struct {
	ColorDataVer:       i32,
	ColorDataSubVer:    i32,
	SpecularWhiteLevel: i32,
	NormalWhiteLevel:   i32,
	ChannelBlackLevel:  [4]i32,
	AverageBlackLevel:  i32,

	/* multishot */
	multishot: [4]u32,

	/* metering */
	MeteringMode:      i16,
	SpotMeteringMode:  i16,
	FlashMeteringMode: uchar,
	FlashExposureLock: i16,
	ExposureMode:      i16,
	AESetting:         i16,

	/* stabilization */
	ImageStabilization: i16,

	/* flash */
	FlashMode:         i16,
	FlashActivity:     i16,
	FlashBits:         i16,
	ManualFlashOutput: i16,
	FlashOutput:       i16,
	FlashGuideNumber:  i16,

	/* drive */
	ContinuousDrive: i16,

	/* sensor */
	SensorWidth:           i16,
	SensorHeight:          i16,
	AFMicroAdjMode:        i32,
	AFMicroAdjValue:       f32,
	MakernotesFlip:        i16,
	AutoRotateMode:        i16,
	RecordMode:            i16,
	SRAWQuality:           i16,
	wbi:                   u32,
	RF_lensID:             i16,
	AutoLightingOptimizer: i32,
	HighlightTonePriority: i32,

	/* -1 = n/a            1 = Economy
	2 = Normal         3 = Fine
	4 = RAW            5 = Superfine
	7 = CRAW         130 = Normal Movie, CRM LightRaw
	131 = CRM  StandardRaw */
	Quality: i16,

	/* data compression curve
	0 = OFF  1 = CLogV1 2 = CLogV2? 3 = CLogV3 */
	CanonLog:             i32,
	DefaultCropAbsolute:  libraw_area_t,
	RecommendedImageArea: libraw_area_t, // contains the image in proper aspect ratio?
	LeftOpticalBlack:     libraw_area_t, // use this, when present, to estimate black levels?
	UpperOpticalBlack:    libraw_area_t,
	ActiveArea:           libraw_area_t,
	ISOgain:              [2]i16,        // AutoISO & BaseISO per ExifTool
}

libraw_hasselblad_makernotes_t :: struct {
	BaseISO:       i32,
	Gain:          f64,
	Sensor:        [8]i8,
	SensorUnit:    [64]i8, // SU
	HostBody:      [64]i8, // HB
	SensorCode:    i32,
	SensorSubCode: i32,
	CoatingCode:   i32,
	uncropped:     i32,

	/* CaptureSequenceInitiator is based on the content of the 'model' tag
	- values like 'Pinhole', 'Flash Sync', '500 Mech.' etc in .3FR 'model' tag
	come from MAIN MENU > SETTINGS > Camera;
	- otherwise 'model' contains:
	1. if CF/CFV/CFH, SU enclosure, can be with SU type if '-' is present
	2. else if '-' is present, HB + SU type;
	3. HB;
	*/
	CaptureSequenceInitiator: [32]i8,

	/* SensorUnitConnector, makernotes 0x0015 tag:
	- in .3FR - SU side
	- in .FFF - HB side
	*/
	SensorUnitConnector: [64]i8,
	format:              i32,    // 3FR, FFF, Imacon (H3D-39 and maybe others), Hasselblad/Phocus DNG, Adobe DNG
	nIFD_CM:             [2]i32, // number of IFD containing CM
	RecommendedCrop:     [2]i32,

	/* mnColorMatrix is in makernotes tag 0x002a;
	not present in .3FR files and Imacon/H3D-39 .FFF files;
	when present in .FFF and Phocus .DNG files, it is a copy of CM1 from .3FR;
	available samples contain all '1's in the first 3 elements
	*/
	mnColorMatrix: [4][3]f64,
}

libraw_fuji_info_t :: struct {
	ExpoMidPointShift:       f32,
	DynamicRange:            ushort,
	FilmMode:                ushort,
	DynamicRangeSetting:     ushort,
	DevelopmentDynamicRange: ushort,
	AutoDynamicRange:        ushort,
	DRangePriority:          ushort,
	DRangePriorityAuto:      ushort,
	DRangePriorityFixed:     ushort,
	FujiModel:               [33]i8,
	FujiModel2:              [33]i8,

	/*
	tag 0x9200, converted to BrightnessCompensation
	F700, S3Pro, S5Pro, S20Pro, S200EXR
	E550, E900, F810, S5600, S6500fd, S9000, S9500, S100FS
	*/
	BrightnessCompensation: f32, /* in EV, if =4, raw data * 2^4 */
	FocusMode:              ushort,
	AFMode:                 ushort,
	FocusPixel:             [2]ushort,
	PrioritySettings:       ushort,
	FocusSettings:          u32,
	AF_C_Settings:          u32,
	FocusWarning:           ushort,
	ImageStabilization:     [3]ushort,
	FlashMode:              ushort,
	WB_Preset:              ushort,

	/* ShutterType:
	0 - mechanical
	1 = electronic
	2 = electronic, long shutter speed
	3 = electronic, front curtain
	*/
	ShutterType: ushort,
	ExrMode:     ushort,
	Macro:       ushort,
	Rating:      u32,

	/* CropMode:
	1 - FF on GFX,
	2 - sports finder (mechanical shutter),
	4 - 1.25x crop (electronic shutter, continuous high)
	*/
	CropMode:          ushort,
	SerialSignature:   [13]i8,
	SensorID:          [5]i8,
	RAFVersion:        [5]i8,
	RAFDataGeneration: i32, // 0 (none), 1..4, 4096
	RAFDataVersion:    ushort,
	isTSNERDTS:        i32,

	/* DriveMode:
	0 - single frame
	1 - continuous low
	2 - continuous high
	*/
	DriveMode: i16,

	/*
	tag 0x4000 BlackLevel:
	S9100, S9000, S7000, S6000fd, S5200, S5100, S5000,
	S5Pro, S3Pro, S2Pro, S20Pro,
	S200EXR, S100FS,
	F810, F700,
	E900, E550,
	DBP, and aliases for all of the above
	*/
	BlackLevel:             [9]ushort,
	RAFData_ImageSizeTable: [32]u32,
	AutoBracketing:         i32,
	SequenceNumber:         i32,
	SeriesLength:           i32,
	PixelShiftOffset:       [2]f32,
	ImageCount:             i32,
}

libraw_sensor_highspeed_crop_t :: struct {
	cleft, ctop, cwidth, cheight: ushort,
}

libraw_nikon_makernotes_t :: struct {
	ExposureBracketValue: f64,
	ActiveDLighting:      ushort,
	ShootingMode:         ushort,

	/* stabilization */
	ImageStabilization: [7]uchar,
	VibrationReduction: uchar,
	VRMode:             uchar,

	/* flash */
	FlashSetting:                    [13]i8,
	FlashType:                       [20]i8,
	FlashExposureCompensation:       [4]uchar,
	ExternalFlashExposureComp:       [4]uchar,
	FlashExposureBracketValue:       [4]uchar,
	FlashMode:                       uchar,
	FlashExposureCompensation2:      i8,
	FlashExposureCompensation3:      i8,
	FlashExposureCompensation4:      i8,
	FlashSource:                     uchar,
	FlashFirmware:                   [2]uchar,
	ExternalFlashFlags:              uchar,
	FlashControlCommanderMode:       uchar,
	FlashOutputAndCompensation:      uchar,
	FlashFocalLength:                uchar,
	FlashGNDistance:                 uchar,
	FlashGroupControlMode:           [4]uchar,
	FlashGroupOutputAndCompensation: [4]uchar,
	FlashColorFilter:                uchar,

	/* NEF compression, comments follow those for ExifTool tag 0x0093:
	1: Lossy (type 1)
	2: Uncompressed
	3: Lossless
	4: Lossy (type 2)
	5: Striped packed 12-bit
	6: Uncompressed (14-bit reduced to 12-bit)
	7: Unpacked 12-bit
	8: Small raw
	9: Packed 12-bit
	10: Packed 14-bit
	13: High Efficiency  (HE)
	14: High Efficiency* (HE*)
	*/
	NEFCompression:         ushort,
	ExposureMode:           i32,
	ExposureProgram:        i32,
	nMEshots:               i32,
	MEgainOn:               i32,
	ME_WB:                  [4]f64,
	AFFineTune:             uchar,
	AFFineTuneIndex:        uchar,
	AFFineTuneAdj:          i8,
	LensDataVersion:        u32,
	FlashInfoVersion:       u32,
	ColorBalanceVersion:    u32,
	key:                    uchar,
	NEFBitDepth:            [4]ushort,
	HighSpeedCropFormat:    ushort, /* 1 -> 1.3x; 2 -> DX; 3 -> 5:4; 4 -> 3:2; 6 ->
                                   16:9; 11 -> FX uncropped; 12 -> DX uncropped;
                                   17 -> 1:1 */
	SensorHighSpeedCrop:    libraw_sensor_highspeed_crop_t,
	SensorWidth:            ushort,
	SensorHeight:           ushort,
	Active_D_Lighting:      ushort,
	PictureControlVersion:  u32,
	PictureControlName:     [20]i8,
	PictureControlBase:     [20]i8,
	ShotInfoVersion:        u32,
	ShotInfoFirmware:       [9]i8,
	BurstTable_0x0056_len:  u32,
	BurstTable_0x0056:      ^uchar,
	BurstTable_0x0056_ver:  ushort,
	BurstTable_0x0056_gid:  ushort,
	BurstTable_0x0056_fnum: uchar,
	MakernotesFlip:         i16,
	RollAngle:              f64,    // positive is clockwise, CW
	PitchAngle:             f64,    // positive is upwords
	YawAngle:               f64,    // positive is to the right
}

libraw_olympus_makernotes_t :: struct {
	CameraType2: [6]i8,
	ValidBits:   ushort,

	// decoder data
	tagX640, tagX641, tagX642, tagX643, tagX644, tagX645, tagX646, tagX647: u32,
	tagX648, tagX649, tagX650, tagX651, tagX652, tagX653:                   u32,

	//
	SensorCalibration: [2]i32,
	DriveMode:         [5]ushort,
	ColorSpace:        ushort,
	FocusMode:         [2]ushort,
	AutoFocus:         ushort,
	AFPoint:           ushort,
	AFAreas:           [64]u32,
	AFPointSelected:   [5]f64,
	AFResult:          ushort,
	AFFineTune:        uchar,
	AFFineTuneAdj:     [3]i16,
	SpecialMode:       [3]u32,
	ZoomStepCount:     ushort,
	FocusStepCount:    ushort,
	FocusStepInfinity: ushort,
	FocusStepNear:     ushort,
	FocusDistance:     f64,
	AspectFrame:       [4]ushort, // left, top, width, height
	StackedImage:      [2]u32,
	isLiveND:          uchar,
	LiveNDfactor:      u32,
	Panorama_mode:     ushort,
	Panorama_frameNum: ushort,
}

libraw_panasonic_makernotes_t :: struct {
	/* Compression:
	34826 (Panasonic RAW 2): LEICA DIGILUX 2;
	34828 (Panasonic RAW 3): LEICA D-LUX 3; LEICA V-LUX 1; Panasonic DMC-LX1;
	Panasonic DMC-LX2; Panasonic DMC-FZ30; Panasonic DMC-FZ50; 34830 (not in
	exiftool): LEICA DIGILUX 3; Panasonic DMC-L1; 34316 (Panasonic RAW 1):
	others (LEICA, Panasonic, YUNEEC);
	*/
	Compression:       ushort,
	BlackLevelDim:     ushort,
	BlackLevel:        [8]f32,
	Multishot:         u32,    /* 0 is Off, 65536 is Pixel Shift */
	gamma:             f32,
	HighISOMultiplier: [3]i32, /* 0->R, 1->G, 2->B */
	FocusStepNear:     i16,
	FocusStepCount:    i16,
	ZoomPosition:      u32,
	LensManufacturer:  u32,
}

libraw_pentax_makernotes_t :: struct {
	DriveMode:               [4]uchar,
	FocusMode:               [2]ushort,
	AFPointSelected:         [2]ushort,
	AFPointSelected_Area:    ushort,
	AFPointsInFocus_version: i32,
	AFPointsInFocus:         u32,
	FocusPosition:           ushort,
	DynamicRangeExpansion:   [4]uchar, /* if (DynamicRangeExpansion[1] > 0) BLE+=DynamicRangeExpansion[0] */
	AFAdjustment:            i16,
	AFPointMode:             uchar,
	MultiExposure:           uchar,    /* last bit is not "1" if ME is not used */
	Quality:                 ushort,   /* 4 is raw, 7 is raw w/ pixel shift, 8 is raw w/ dynamic
                       pixel shift */
}

libraw_ricoh_makernotes_t :: struct {
	AFStatus:           ushort,
	AFAreaXPosition:    [2]u32,
	AFAreaYPosition:    [2]u32,
	AFAreaMode:         ushort,
	SensorWidth:        u32,
	SensorHeight:       u32,
	CroppedImageWidth:  u32,
	CroppedImageHeight: u32,
	WideAdapter:        ushort,
	CropMode:           ushort,
	NDFilter:           ushort,
	AutoBracketing:     ushort,
	MacroMode:          ushort,
	FlashMode:          ushort,
	FlashExposureComp:  f64,
	ManualFlashOutput:  f64,
}

libraw_samsung_makernotes_t :: struct {
	ImageSizeFull: [4]u32,
	ImageSizeCrop: [4]u32,
	ColorSpace:    [2]i32,
	key:           [11]u32,
	DigitalGain:   f64, /* PostAEGain, digital stretch */
	DeviceType:    i32,
	LensFirmware:  [32]i8,
}

libraw_kodak_makernotes_t :: struct {
	BlackLevelTop:                               ushort,
	BlackLevelBottom:                            ushort,
	offset_left, offset_top:                     i16,    /* KDC files, negative values or zeros */
	clipBlack, clipWhite:                        ushort, /* valid for P712, P850, P880 */
	romm_camDaylight:                            [3][3]f32,
	romm_camTungsten:                            [3][3]f32,
	romm_camFluorescent:                         [3][3]f32,
	romm_camFlash:                               [3][3]f32,
	romm_camCustom:                              [3][3]f32,
	romm_camAuto:                                [3][3]f32,
	val018percent, val100percent, val170percent: ushort,
	MakerNoteKodak8a:                            i16,
	ISOCalibrationGain:                          f32,
	AnalogISO:                                   f32,
}

libraw_p1_makernotes_t :: struct {
	Software:       [64]i8,  // tag 0x0203
	SystemType:     [64]i8,  // tag 0x0204
	FirmwareString: [256]i8, // tag 0x0301
	SystemModel:    [64]i8,
}

libraw_sony_info_t :: struct {
	/* afdata:
	0x0010 CameraInfo
	0x2020 AFPointsUsed
	0x2022 FocalPlaneAFPointsUsed
	0x202a Tag202a
	0x940e AFInfo
	*/
	CameraType:                      ushort,    // init in 0xffff
	Sony0x9400_version:              uchar,     /* 0 if not found/deciphered,
                                    0xa, 0xb, 0xc following exiftool convention */
	Sony0x9400_ReleaseMode2:         uchar,
	Sony0x9400_SequenceImageNumber:  u32,
	Sony0x9400_SequenceLength1:      uchar,
	Sony0x9400_SequenceFileNumber:   u32,
	Sony0x9400_SequenceLength2:      uchar,
	AFAreaModeSetting:               u8,        // init in 0xff; +
	AFAreaMode:                      u16,       // init in 0xffff; +
	FlexibleSpotPosition:            [2]ushort, // init in (0xffff, 0xffff)
	AFPointSelected:                 u8,        // init in 0xff
	AFPointSelected_0x201e:          u8,        // init in 0xff
	nAFPointsUsed:                   i16,
	AFPointsUsed:                    [10]u8,
	AFTracking:                      u8,        // init in 0xff
	AFType:                          u8,
	FocusLocation:                   [4]ushort,
	FocusPosition:                   ushort,    // init in 0xffff
	AFMicroAdjValue:                 i8,        // init in 0x7f
	AFMicroAdjOn:                    i8,        // init in -1
	AFMicroAdjRegisteredLenses:      uchar,     // init in 0xff
	VariableLowPassFilter:           ushort,
	LongExposureNoiseReduction:      u32,       // init in 0xffffffff
	HighISONoiseReduction:           ushort,    // init in 0xffff
	HDR:                             [2]ushort,
	group2010:                       ushort,
	group9050:                       ushort,
	len_group9050:                   ushort,    // currently, for debugging only
	real_iso_offset:                 ushort,    // init in 0xffff
	MeteringMode_offset:             ushort,
	ExposureProgram_offset:          ushort,
	ReleaseMode2_offset:             ushort,
	MinoltaCamID:                    u32,       // init in 0xffffffff
	firmware:                        f32,
	ImageCount3_offset:              ushort,    // init in 0xffff
	ImageCount3:                     u32,
	ElectronicFrontCurtainShutter:   u32,       // init in 0xffffffff
	MeteringMode2:                   ushort,
	SonyDateTime:                    [20]i8,
	ShotNumberSincePowerUp:          u32,
	PixelShiftGroupPrefix:           ushort,
	PixelShiftGroupID:               u32,
	nShotsInPixelShiftGroup:         i8,
	numInPixelShiftGroup:            i8,        /* '0' if ARQ, first shot in the group has '1'
                                  here */
	prd_ImageHeight, prd_ImageWidth: ushort,
	prd_Total_bps:                   ushort,
	prd_Active_bps:                  ushort,
	prd_StorageMethod:               ushort,    /* 82 -> Padded; 89 -> Linear */
	prd_BayerPattern:                ushort,    /* 0 -> not valid; 1 -> RGGB; 4 -> GBRG */
	SonyRawFileType:                 ushort,    /* init in 0xffff
                               valid for ARW 2.0 and up (FileFormat >= 3000)
                               takes precedence over RAWFileType and Quality:
                               0  for uncompressed 14-bit raw
                               1  for uncompressed 12-bit raw
                               2  for compressed raw (lossy)
                               3  for lossless compressed raw
                               4  for lossless compressed raw v.2 (ILCE-1)
                            */
	RAWFileType:                     ushort,    /* init in 0xffff
                               takes precedence over Quality
                               0 for compressed raw,
                               1 for uncompressed;
                               2 lossless compressed raw v.2
                            */
	RawSizeType:                     ushort,    /* init in 0xffff
                               1 - large,
                               2 - small,
                               3 - medium
                            */
	Quality:                         u32,       /* init in 0xffffffff
                               0 or 6 for raw, 7 or 8 for compressed raw */
	FileFormat:                      ushort,    /*  1000 SR2
                                2000 ARW 1.0
                                3000 ARW 2.0
                                3100 ARW 2.1
                                3200 ARW 2.2
                                3300 ARW 2.3
                                3310 ARW 2.3.1
                                3320 ARW 2.3.2
                                3330 ARW 2.3.3
                                3350 ARW 2.3.5
                                4000 ARW 4.0
                                4010 ARW 4.0.1
                                5000 ARW 5.0
                             */
	MetaVersion:                     [16]i8,
	AspectRatio:                     f32,
}

libraw_colordata_t :: struct {
	curve:        [65536]ushort,
	cblack:       [4104]u32,
	black:        u32,
	data_maximum: u32,
	maximum:      u32,

	// Canon (SpecularWhiteLevel)
	// Kodak (14N, 14nx, SLR/c/n, DCS720X, DCS760C, DCS760M, ProBack, ProBack645, P712, P880, P850)
	// Olympus, except:
	//	C5050Z, C5060WZ, C7070WZ, C8080WZ
	//	SP350, SP500UZ, SP510UZ, SP565UZ
	//	E-10, E-20
	//	E-300, E-330, E-400, E-410, E-420, E-450, E-500, E-510, E-520
	//	E-1, E-3
	//	XZ-1
	// Panasonic
	// Pentax
	// Sony
	// and aliases of the above
	// DNG
	linear_max:           [4]u32,
	fmaximum:             f32,
	fnorm:                f32,
	white:                [8][8]ushort,
	cam_mul:              [4]f32,
	pre_mul:              [4]f32,
	cmatrix:              [3][4]f32,
	ccm:                  [3][4]f32,
	rgb_cam:              [3][4]f32,
	cam_xyz:              [4][3]f32,
	phase_one_data:       ph1_t,
	flash_used:           f32,
	canon_ev:             f32,
	model2:               [64]i8,
	UniqueCameraModel:    [64]i8,
	LocalizedCameraModel: [64]i8,
	ImageUniqueID:        [64]i8,
	RawDataUniqueID:      [17]i8,
	OriginalRawFileName:  [64]i8,
	profile:              rawptr,
	profile_length:       u32,
	black_stat:           [8]u32,
	dng_color:            [2]libraw_dng_color_t,
	dng_levels:           libraw_dng_levels_t,
	WB_Coeffs:            [256][4]i32, /* R, G1, B, G2 coeffs */
	WBCT_Coeffs:          [64][5]f32,  /* CCT, than R, G1, B, G2 coeffs */
	as_shot_wb_applied:   i32,
	P1_color:             [2]libraw_P1_color_t,
	raw_bps:              u32,         /* for Phase One: raw format; For other cameras: bits per pixel (copy of tiff_bps in most cases) */

	/* Phase One raw format values, makernotes tag 0x010e:
	0    Name unknown
	1    "RAW 1"
	2    "RAW 2"
	3    "IIQ L" (IIQ L14)
	4    Never seen
	5    "IIQ S"
	6    "IIQ Sv2" (S14 / S14+)
	7    Never seen
	8    "IIQ L16" (IIQ L16EX / IIQ L16)
	*/
	ExifColorSpace: i32,
}

libraw_thumbnail_t :: struct {
	tformat:         LibRaw_thumbnail_formats,
	twidth, theight: ushort,
	tlength:         u32,
	tcolors:         i32,
	thumb:           cstring,
}

libraw_thumbnail_item_t :: struct {
	tformat:                LibRaw_internal_thumbnail_formats,
	twidth, theight, tflip: ushort,
	tlength:                u32,
	tmisc:                  u32,
	toffset:                INT64,
}

libraw_thumbnail_list_t :: struct {
	thumbcount: i32,
	thumblist:  [8]libraw_thumbnail_item_t,
}

libraw_gps_info_t :: struct {
	latitude:                           [3]f32, /* Deg,min,sec */
	longitude:                          [3]f32, /* Deg,min,sec */
	gpstimestamp:                       [3]f32, /* Deg,min,sec */
	altitude:                           f32,
	altref, latref, longref, gpsstatus: i8,
	gpsparsed:                          i8,
}

libraw_imgother_t :: struct {
	iso_speed:     f32,
	shutter:       f32,
	aperture:      f32,
	focal_len:     f32,
	timestamp:     libc.time_t,
	shot_order:    u32,
	gpsdata:       [32]u32,
	parsed_gps:    libraw_gps_info_t,
	desc:          [512]i8,
	artist:        [64]i8,
	analogbalance: [4]f32,
}

libraw_afinfo_item_t :: struct {
	AFInfoData_tag:     u32,
	AFInfoData_order:   i16,
	AFInfoData_version: u32,
	AFInfoData_length:  u32,
	AFInfoData:         ^uchar,
}

libraw_metadata_common_t :: struct {
	FlashEC:                  f32,
	FlashGN:                  f32,
	CameraTemperature:        f32,
	SensorTemperature:        f32,
	SensorTemperature2:       f32,
	LensTemperature:          f32,
	AmbientTemperature:       f32,
	BatteryTemperature:       f32,
	exifAmbientTemperature:   f32,
	exifHumidity:             f32,
	exifPressure:             f32,
	exifWaterDepth:           f32,
	exifAcceleration:         f32,
	exifCameraElevationAngle: f32,
	real_ISO:                 f32,
	exifExposureIndex:        f32,
	ColorSpace:               ushort,
	firmware:                 [128]i8,
	ExposureCalibrationShift: f32,
	afdata:                   [4]libraw_afinfo_item_t,
	afcount:                  i32,
}

libraw_output_params_t :: struct {
	greybox:            [4]u32,  /* -A  x1 y1 x2 y2 */
	cropbox:            [4]u32,  /* -B x1 y1 x2 y2 */
	aber:               [4]f64,  /* -C */
	gamm:               [6]f64,  /* -g */
	user_mul:           [4]f32,  /* -r mul0 mul1 mul2 mul3 */
	bright:             f32,     /* -b */
	threshold:          f32,     /* -n */
	half_size:          i32,     /* -h */
	four_color_rgb:     i32,     /* -f */
	highlight:          i32,     /* -H */
	use_auto_wb:        i32,     /* -a */
	use_camera_wb:      i32,     /* -w */
	use_camera_matrix:  i32,     /* +M/-M */
	output_color:       i32,     /* -o */
	output_profile:     cstring, /* -o */
	camera_profile:     cstring, /* -p */
	bad_pixels:         cstring, /* -P */
	dark_frame:         cstring, /* -K */
	output_bps:         i32,     /* -4 */
	output_tiff:        i32,     /* -T */
	output_flags:       i32,
	user_flip:          i32,     /* -t */
	user_qual:          i32,     /* -q */
	user_black:         i32,     /* -k */
	user_cblack:        [4]i32,
	user_sat:           i32,     /* -S */
	med_passes:         i32,     /* -m */
	auto_bright_thr:    f32,
	adjust_maximum_thr: f32,
	no_auto_bright:     i32,     /* -W */
	use_fuji_rotate:    i32,     /* -j */
	use_p1_correction:  i32,
	green_matching:     i32,

	/* DCB parameters */
	dcb_iterations: i32,
	dcb_enhance_fl: i32,
	fbdd_noiserd:   i32,
	exp_correc:     i32,
	exp_shift:      f32,
	exp_preser:     f32,

	/* Disable Auto-scale */
	no_auto_scale: i32,

	/* Disable intepolation */
	no_interpolation: i32,
}

libraw_raw_unpack_params_t :: struct {
	/* Raw speed */
	use_rawspeed: i32,

	/* DNG SDK */
	use_dngsdk:                  i32,
	options:                     u32,
	shot_select:                 u32, /* -s */
	specials:                    u32,
	max_raw_memory_mb:           u32,
	sony_arw2_posterization_thr: i32,

	/* Nikon Coolscan */
	coolscan_nef_gamma: f32,
	p4shot_order:       [5]i8,

	/* Custom camera list */
	custom_camera_strings: ^cstring,
}

libraw_rawdata_t :: struct {
	/* really allocated bitmap */
	raw_alloc: rawptr,

	/* alias to single_channel variant */
	raw_image: ^ushort,

	/* alias to 4-channel variant */
	color4_image: ^[4]ushort,

	/* alias to 3-color variand decoded by RawSpeed */
	color3_image: ^[3]ushort,

	/* float bayer */
	float_image: ^f32,

	/* float 3-component */
	float3_image: ^[3]f32,

	/* float 4-component */
	float4_image: ^[4]f32,

	/* Phase One black level data; */
	ph1_cblack: ^[2]i16,
	ph1_rblack: ^[2]i16,

	/* save color and sizes here, too.... */
	iparams:  libraw_iparams_t,
	sizes:    libraw_image_sizes_t,
	ioparams: libraw_internal_output_params_t,
	color:    libraw_colordata_t,
}

libraw_makernotes_lens_t :: struct {
	LensID:                                                         UINT64,
	Lens:                                                           [128]i8,
	LensFormat:                                                     ushort, /* to characterize the image circle the lens covers */
	LensMount:                                                      ushort, /* 'male', lens itself */
	CamID:                                                          UINT64,
	CameraFormat:                                                   ushort, /* some of the sensor formats */
	CameraMount:                                                    ushort, /* 'female', body throat */
	body:                                                           [64]i8,
	FocalType:                                                      i16,    /* -1/0 is unknown; 1 is fixed focal; 2 is zoom */
	LensFeatures_pre, LensFeatures_suf:                             [16]i8,
	MinFocal, MaxFocal:                                             f32,
	MaxAp4MinFocal, MaxAp4MaxFocal, MinAp4MinFocal, MinAp4MaxFocal: f32,
	MaxAp, MinAp:                                                   f32,
	CurFocal, CurAp:                                                f32,
	MaxAp4CurFocal, MinAp4CurFocal:                                 f32,
	MinFocusDistance:                                               f32,
	FocusRangeIndex:                                                f32,
	LensFStops:                                                     f32,
	TeleconverterID:                                                UINT64,
	Teleconverter:                                                  [128]i8,
	AdapterID:                                                      UINT64,
	Adapter:                                                        [128]i8,
	AttachmentID:                                                   UINT64,
	Attachment:                                                     [128]i8,
	FocalUnits:                                                     ushort,
	FocalLengthIn35mmFormat:                                        f32,
}

libraw_nikonlens_t :: struct {
	EffectiveMaxAp:                                 f32,
	LensIDNumber, LensFStops, MCUVersion, LensType: uchar,
}

libraw_dnglens_t :: struct {
	MinFocal, MaxFocal, MaxAp4MinFocal, MaxAp4MaxFocal: f32,
}

libraw_lensinfo_t :: struct {
	MinFocal, MaxFocal, MaxAp4MinFocal, MaxAp4MaxFocal, EXIF_MaxAp: f32,
	LensMake, Lens, LensSerial, InternalLensSerial:                 [128]i8,
	FocalLengthIn35mmFormat:                                        ushort,
	nikon:                                                          libraw_nikonlens_t,
	dng:                                                            libraw_dnglens_t,
	makernotes:                                                     libraw_makernotes_lens_t,
}

libraw_makernotes_t :: struct {
	canon:      libraw_canon_makernotes_t,
	nikon:      libraw_nikon_makernotes_t,
	hasselblad: libraw_hasselblad_makernotes_t,
	fuji:       libraw_fuji_info_t,
	olympus:    libraw_olympus_makernotes_t,
	sony:       libraw_sony_info_t,
	kodak:      libraw_kodak_makernotes_t,
	panasonic:  libraw_panasonic_makernotes_t,
	pentax:     libraw_pentax_makernotes_t,
	phaseone:   libraw_p1_makernotes_t,
	ricoh:      libraw_ricoh_makernotes_t,
	samsung:    libraw_samsung_makernotes_t,
	common:     libraw_metadata_common_t,
}

libraw_shootinginfo_t :: struct {
	DriveMode:          i16,
	FocusMode:          i16,
	MeteringMode:       i16,
	AFPoint:            i16,
	ExposureMode:       i16,
	ExposureProgram:    i16,
	ImageStabilization: i16,
	BodySerial:         [64]i8,
	InternalBodySerial: [64]i8, /* this may be PCB or sensor serial, depends on
                                    make/model */
}

libraw_custom_camera_t :: struct {
	fsize:          u32,
	rw, rh:         ushort,
	lm, tm, rm, bm: uchar,
	lf:             ushort,
	cf, max, flags: uchar,
	t_make:         [10]i8,
	t_model:        [20]i8,
	offset:         ushort,
}

libraw_data_t :: struct {
	image:            ^[4]ushort,
	sizes:            libraw_image_sizes_t,
	idata:            libraw_iparams_t,
	lens:             libraw_lensinfo_t,
	makernotes:       libraw_makernotes_t,
	shootinginfo:     libraw_shootinginfo_t,
	params:           libraw_output_params_t,
	rawparams:        libraw_raw_unpack_params_t,
	progress_flags:   u32,
	process_warnings: u32,
	color:            libraw_colordata_t,
	other:            libraw_imgother_t,
	thumbnail:        libraw_thumbnail_t,
	thumbs_list:      libraw_thumbnail_list_t,
	rawdata:          libraw_rawdata_t,
	parent_class:     rawptr,
}

fuji_q_table :: struct {
	q_table:      ^i8, /* quantization table */
	raw_bits:     i32,
	total_values: i32,
	max_grad:     i32, // sdp val
	q_grad_mult:  i32, // quant_gradient multiplier
	q_base:       i32,
}

fuji_compressed_params :: struct {
	qt:         [4]fuji_q_table,
	buf:        rawptr,
	max_bits:   i32,
	min_value:  i32,
	max_value:  i32, // q_point[4]
	line_width: ushort,
}

LibRawBigEndian :: 0

