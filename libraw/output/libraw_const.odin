// Odin bindings for LibRaw 0.22.2, generated from the LibRaw headers by
// generate_bindings.ps1 (https://github.com/Dihedron-Software/ffpackage, libraw/).
//
// LibRaw: Copyright (C) 2008-2025 LibRaw LLC (http://www.libraw.org, info@libraw.org)
// Generated bindings: Dihedron Software GmbH
//
// This file is distributed under the COMMON DEVELOPMENT AND DISTRIBUTION LICENSE (CDDL)
// Version 1.0, which is one of the two licenses LibRaw offers. See LICENSE.CDDL and COPYRIGHT.
/* -*- C++ -*-
 * File: libraw_const.h
 * Copyright 2008-2025 LibRaw LLC (info@libraw.org)
 * Created: Sat Mar  8 , 2008
 * LibRaw error codes
LibRaw is free software; you can redistribute it and/or modify
it under the terms of the one of two licenses as you choose:

1. GNU LESSER GENERAL PUBLIC LICENSE version 2.1
   (See file LICENSE.LGPL provided in LibRaw distribution archive for details).

2. COMMON DEVELOPMENT AND DISTRIBUTION LICENSE (CDDL) Version 1.0
   (See file LICENSE.CDDL provided in LibRaw distribution archive for details).

 */
package libraw

when ODIN_OS == .Windows {
    foreign import lib "libraw.lib"
} else when ODIN_OS == .Darwin {
    foreign import lib { "libraw.a", "system:c++" }
}

LIBRAW_DEFAULT_ADJUST_MAXIMUM_THRESHOLD  :: 0.75
LIBRAW_DEFAULT_AUTO_BRIGHTNESS_THRESHOLD :: 0.01
LIBRAW_MAX_ALLOC_MB_DEFAULT              :: 2048
LIBRAW_MAX_PROFILE_SIZE_MB               :: 256
LIBRAW_MAX_NONDNG_RAW_FILE_SIZE          :: 2147483647
LIBRAW_MAX_CR3_RAW_FILE_SIZE             :: LIBRAW_MAX_NONDNG_RAW_FILE_SIZE
LIBRAW_MAX_DNG_RAW_FILE_SIZE             :: 2147483647
LIBRAW_MAX_THUMBNAIL_MB                  :: 512
LIBRAW_X3F_ALLOC_LIMIT_MB                :: 512
LIBRAW_MAX_METADATA_BLOCKS               :: 1024
LIBRAW_CBLACK_SIZE                       :: 4104
LIBRAW_IFD_MAXCOUNT                      :: 10
LIBRAW_THUMBNAIL_MAXCOUNT                :: 8
LIBRAW_CRXTRACKS_MAXCOUNT                :: 16
LIBRAW_AFDATA_MAXCOUNT                   :: 4
LIBRAW_AHD_TILE                          :: 512

LibRaw_open_flags :: enum i32 {
	BIGFILE = 1,
	FILE    = 2,
}

LibRaw_openbayer_patterns :: enum i32 {
	RGGB = 148,
	BGGR = 22,
	GRBG = 97,
	GBRG = 73,
}

LibRaw_dngfields_marks :: enum i32 {
	FORWARDMATRIX       = 1,
	ILLUMINANT          = 2,
	COLORMATRIX         = 4,
	CALIBRATION         = 8,
	ANALOGBALANCE       = 16,
	BLACK               = 32,
	WHITE               = 64,
	OPCODE2             = 128,
	LINTABLE            = 256,
	CROPORIGIN          = 512,
	CROPSIZE            = 1024,
	PREVIEWCS           = 2048,
	ASSHOTNEUTRAL       = 4096,
	BASELINEEXPOSURE    = 8192,
	LINEARRESPONSELIMIT = 16384,
	USERCROP            = 32768,
	OPCODE1             = 65536,
	OPCODE3             = 131072,
}

LibRaw_As_Shot_WB_Applied_codes :: enum i32 {
	APPLIED    = 1,
	CANON      = 2,
	NIKON      = 4,
	NIKON_SRAW = 8,
	PENTAX     = 16,
	SONY       = 32,
}

LibRaw_ExifTagTypes :: enum i32 {
	UNKNOWN   = 0,
	BYTE      = 1,
	ASCII     = 2,
	SHORT     = 3,
	LONG      = 4,
	RATIONAL  = 5,
	SBYTE     = 6,
	UNDEFINED = 7,
	SSHORT    = 8,
	SLONG     = 9,
	SRATIONAL = 10,
	FLOAT     = 11,
	DOUBLE    = 12,
	IFD       = 13,
	UNICODE   = 14,
	COMPLEX   = 15,
	LONG8     = 16,
	SLONG8    = 17,
	IFD8      = 18,
}

LIBRAW_LENS_NOT_SET :: 0xffffffffffffffff

LibRaw_whitebalance_code :: enum i32 {
	// clang-format off
	/*
	EXIF light sources
	12 = FL-D; Daylight fluorescent (D 5700K – 7100K) (F1,F5)
	13 = FL-N; Day white fluorescent (N 4600K – 5400K) (F7,F8)
	14 = FL-W; Cool white fluorescent (W 3900K – 4500K) (F2,F6, office, store, warehouse)
	15 = FL-WW; White fluorescent (WW 3200K – 3700K) (F3, residential)
	16 = FL-L; Soft/Warm white fluorescent (L 2600K - 3250K) (F4, kitchen, bath)
	*/
	//clang-format on
	Unknown         = 0,
	Daylight        = 1,
	Fluorescent     = 2,
	Tungsten        = 3,
	Flash           = 4,
	FineWeather     = 9,
	Cloudy          = 10,
	Shade           = 11,
	FL_D            = 12,
	FL_N            = 13,
	FL_W            = 14,
	FL_WW           = 15,
	FL_L            = 16,
	Ill_A           = 17,
	Ill_B           = 18,
	Ill_C           = 19,
	D55             = 20,
	D65             = 21,
	D75             = 22,
	D50             = 23,
	StudioTungsten  = 24,
	Sunset          = 64,
	Underwater      = 65,
	FluorescentHigh = 66,
	HT_Mercury      = 67,
	AsShot          = 81,
	Auto            = 82,
	Custom          = 83,
	Auto1           = 85,
	Auto2           = 86,
	Auto3           = 87,
	Auto4           = 88,
	Custom1         = 90,
	Custom2         = 91,
	Custom3         = 92,
	Custom4         = 93,
	Custom5         = 94,
	Custom6         = 95,
	PC_Set1         = 96,
	PC_Set2         = 97,
	PC_Set3         = 98,
	PC_Set4         = 99,
	PC_Set5         = 100,
	Measured        = 110,
	BW              = 120,
	Kelvin          = 254,
	Other           = 255,
	None            = 65535,
}

LibRaw_MultiExposure_related :: enum i32 {
	NONE    = 0,
	SIMPLE  = 1,
	OVERLAY = 2,
	HDR     = 3,
}

LibRaw_dng_processing :: enum i32 {
	NONE    = 0,
	FLOAT   = 1,
	LINEAR  = 2,
	DEFLATE = 4,
	XTRANS  = 8,
	OTHER   = 16,
	_8BIT   = 32,
	ALL     = 63,
	DEFAULT = 39,
}

LibRaw_output_flags :: enum i32 {
	NONE    = 0,
	PPMMETA = 1,
}

LibRaw_runtime_capabilities :: enum i32 {
	RAWSPEED      = 1,
	DNGSDK        = 2,
	GPRSDK        = 4,
	UNICODEPATHS  = 8,
	X3FTOOLS      = 16,
	RPI6BY9       = 32,
	ZLIB          = 64,
	JPEG          = 128,
	RAWSPEED3     = 256,
	RAWSPEED_BITS = 512,
}

LibRaw_colorspace :: enum i32 {
	NotFound          = 0,
	sRGB              = 1,
	AdobeRGB          = 2,
	WideGamutRGB      = 3,
	ProPhotoRGB       = 4,
	ICC               = 5,
	Uncalibrated      = 6, // Tag 0x0001 InteropIndex containing "R03" + LIBRAW_COLORSPACE_Uncalibrated = Adobe RGB
	CameraLinearUniWB = 7,
	CameraLinear      = 8,
	CameraGammaUniWB  = 9,
	CameraGamma       = 10,
	MonochromeLinear  = 11,
	MonochromeGamma   = 12,
	Rec2020           = 13,
	Unknown           = 255,
}

LibRaw_cameramaker_index :: enum i32 {
	Unknown      = 0,
	Agfa         = 1,
	Alcatel      = 2,
	Apple        = 3,
	Aptina       = 4,
	AVT          = 5,
	Baumer       = 6,
	Broadcom     = 7,
	Canon        = 8,
	Casio        = 9,
	CINE         = 10,
	Clauss       = 11,
	Contax       = 12,
	Creative     = 13,
	DJI          = 14,
	DXO          = 15,
	Epson        = 16,
	Foculus      = 17,
	Fujifilm     = 18,
	Generic      = 19,
	Gione        = 20,
	GITUP        = 21,
	Google       = 22,
	GoPro        = 23,
	Hasselblad   = 24,
	HTC          = 25,
	I_Mobile     = 26,
	Imacon       = 27,
	JK_Imaging   = 28,
	Kodak        = 29,
	Konica       = 30,
	Leaf         = 31,
	Leica        = 32,
	Lenovo       = 33,
	LG           = 34,
	Logitech     = 35,
	Mamiya       = 36,
	Matrix       = 37,
	Meizu        = 38,
	Micron       = 39,
	Minolta      = 40,
	Motorola     = 41,
	NGM          = 42,
	Nikon        = 43,
	Nokia        = 44,
	Olympus      = 45,
	OmniVison    = 46,
	Panasonic    = 47,
	Parrot       = 48,
	Pentax       = 49,
	PhaseOne     = 50,
	PhotoControl = 51,
	Photron      = 52,
	Pixelink     = 53,
	Polaroid     = 54,
	RED          = 55,
	Ricoh        = 56,
	Rollei       = 57,
	RoverShot    = 58,
	Samsung      = 59,
	Sigma        = 60,
	Sinar        = 61,
	SMaL         = 62,
	Sony         = 63,
	ST_Micro     = 64,
	THL          = 65,
	VLUU         = 66,
	Xiaomi       = 67,
	XIAOYI       = 68,
	YI           = 69,
	Yuneec       = 70,
	Zeiss        = 71,
	OnePlus      = 72,
	ISG          = 73,
	VIVO         = 74,
	HMD_Global   = 75,
	HUAWEI       = 76,
	RaspberryPi  = 77,
	OmDigital    = 78,

	// Insert additional indexes here
	TheLastOne   = 79,
}

LibRaw_camera_mounts :: enum i32 {
	Unknown         = 0,
	Alpa            = 1,
	C               = 2,  /* C-mount */
	Canon_EF_M      = 3,
	Canon_EF_S      = 4,
	Canon_EF        = 5,
	Canon_RF        = 6,
	Contax_N        = 7,
	Contax645       = 8,
	FT              = 9,  /* original 4/3 */
	mFT             = 10, /* micro 4/3 */
	Fuji_GF         = 11, /* Fujifilm GFX cameras, G mount */
	Fuji_GX         = 12, /* Fujifilm GX680 */
	Fuji_X          = 13,
	Hasselblad_H    = 14, /* Hasselblad Hn cameras, HC & HCD lenses */
	Hasselblad_V    = 15,
	Hasselblad_XCD  = 16, /* Hasselblad Xn cameras, XCD lenses */
	Leica_M         = 17, /* Leica rangefinder bayonet */
	Leica_R         = 18, /* Leica SLRs, 'R' for reflex */
	Leica_S         = 19, /* LIBRAW_FORMAT_LeicaS 'MF' */
	Leica_SL        = 20, /* lens, mounts on 'L' throat, FF */
	Leica_TL        = 21, /* lens, mounts on 'L' throat, APS-C */
	LPS_L           = 22, /* Leica/Panasonic/Sigma camera mount, takes L, SL and TL lenses */
	Mamiya67        = 23, /* Mamiya RB67, RZ67 */
	Mamiya645       = 24,
	Minolta_A       = 25,
	Nikon_CX        = 26, /* used in 'Nikon 1' series */
	Nikon_F         = 27,
	Nikon_Z         = 28,
	PhaseOne_iXM_MV = 29,
	PhaseOne_iXM_RS = 30,
	PhaseOne_iXM    = 31,
	Pentax_645      = 32,
	Pentax_K        = 33,
	Pentax_Q        = 34,
	RicohModule     = 35,
	Rollei_bayonet  = 36, /* Rollei Hy-6: Leaf AFi, Sinar Hy6- models */
	Samsung_NX_M    = 37,
	Samsung_NX      = 38,
	Sigma_X3F       = 39,
	Sony_E          = 40,
	LF              = 41,
	DigitalBack     = 42,
	FixedLens       = 43,
	IL_UM           = 44, /* Interchangeable lens, mount unknown */
	TheLastOne      = 45,
}

LibRaw_camera_formats :: enum i32 {
	Unknown      = 0,
	APSC         = 1,
	FF           = 2,
	MF           = 3,
	APSH         = 4,
	_1INCH       = 5,
	_1div2p3INCH = 6,  /* 1/2.3" */
	_1div1p7INCH = 7,  /* 1/1.7" */
	FT           = 8,  /* sensor size in FT & mFT cameras */
	CROP645      = 9,  /* 44x33mm */
	LeicaS       = 10, /* 'MF' Leicas */
	_645         = 11,
	_66          = 12,
	_69          = 13,
	LF           = 14,
	Leica_DMR    = 15,
	_67          = 16,
	SigmaAPSC    = 17, /* DP1, DP2, SD15, SD14, SD10, SD9 */
	SigmaMerrill = 18, /* SD1,  'SD1 Merrill',  'DP1 Merrill',  'DP2 Merrill' */
	SigmaAPSH    = 19, /* 'sd Quattro H' */
	_3648        = 20, /* DALSA FTF4052C (Mamiya ZD) */
	_68          = 21, /* Fujifilm GX680 */
	TheLastOne   = 22,
}

LibRawImageAspects :: enum i32 {
	UNKNOWN                   = 0,
	OTHER                     = 1,
	MINIMAL_REAL_ASPECT_VALUE = 99,    /* 1:10*/
	MAXIMAL_REAL_ASPECT_VALUE = 10000, /* 10: 1*/

	// Value:  width / height * 1000
	_3to2                     = 1500,
	_1to1                     = 1000,
	_4to3                     = 1333,
	_16to9                    = 1777,
	_5to4                     = 1250,
	_7to6                     = 1166,
	_6to5                     = 1200,
	_7to5                     = 1400,
}

/*
inch-based ID (diameter) -> diagonal, mm
ID	diagonal	aspect
1/4"	4.00	4:3
1/3.6"	5.00	4:3
1/3.4"	5.29	4:3
1/3.2"	5.62	4:3
1/3"	6.00	4:3
1/2.9"	6.20	4:3
1/2.7"	6.66	4:3
1/2.5"	7.19	4:3
1/2.4"	7.38	4:3
1/2.35"	7.54	4:3
1/2.33"	7.60	4:3
1/2.3"	7.70	4:3
1/2"	8.00	4:3
1/1.9"	8.42	4:3
1/1.8"	8.89	4:3
1/1.76"	9.09	4:3
1/1.75"	9.14	4:3
1/1.72"	9.30	4:3
1/1.7"	9.41	4:3
1/1.65"	9.69	4:3
1/1.63"	9.81	4:3
1/1.6"	10.00	4:3
2/3"	11.00	4:3
1"	15.86	3:2
4/3"	21.64	4:3
1.5"	23.36	4:3
*/
LibRaw_lens_focal_types :: enum i32 {
	UNDEFINED                   = 0,
	PRIME_LENS                  = 1,
	ZOOM_LENS                   = 2,
	ZOOM_LENS_CONSTANT_APERTURE = 3,
	ZOOM_LENS_VARIABLE_APERTURE = 4,
}

LibRaw_Canon_RecordModes :: enum i32 {
	UNDEFINED  = 0,
	JPEG       = 1,
	CRW_THM    = 2,
	AVI_THM    = 3,
	TIF        = 4,
	TIF_JPEG   = 5,
	CR2        = 6,
	CR2_JPEG   = 7,
	UNKNOWN    = 8,
	MOV        = 9,
	MP4        = 10,
	CRM        = 11,
	CR3        = 12,
	CR3_JPEG   = 13,
	HEIF       = 14,
	CR3_HEIF   = 15,
	TheLastOne = 16,
}

LibRaw_minolta_storagemethods :: enum i32 {
	UNPACKED = 82,
	PACKED   = 89,
}

LibRaw_minolta_bayerpatterns :: enum i32 {
	RGGB   = 1,
	G2BRG1 = 4,
}

LibRaw_sony_cameratypes :: enum i32 {
	DSC                = 1,
	DSLR               = 2,
	NEX                = 3,
	SLT                = 4,
	ILCE               = 5,
	ILCA               = 6,
	CameraType_UNKNOWN = 65535,
}

LibRaw_Sony_0x2010_Type :: enum i32 {
	Tag2010None = 0,
	Tag2010a    = 1,
	Tag2010b    = 2,
	Tag2010c    = 3,
	Tag2010d    = 4,
	Tag2010e    = 5,
	Tag2010f    = 6,
	Tag2010g    = 7,
	Tag2010h    = 8,
	Tag2010i    = 9,
}

LibRaw_Sony_0x9050_Type :: enum i32 {
	Tag9050None = 0,
	Tag9050a    = 1,
	Tag9050b    = 2,
	Tag9050c    = 3,
	Tag9050d    = 4,
}

LIBRAW_SONY_FOCUSMODEmodes :: enum i32 {
	MF           = 0,
	AF_S         = 2,
	AF_C         = 3,
	AF_A         = 4,
	DMF          = 6,
	AF_D         = 7,
	AF           = 101,
	PERMANENT_AF = 104,
	SEMI_MF      = 105,
	UNKNOWN      = -1,
}

LibRaw_KodakSensors :: enum i32 {
	UnknownSensor = 0,
	M1            = 1,
	M15           = 2,
	M16           = 3,
	M17           = 4,
	M2            = 5,
	M23           = 6,
	M24           = 7,
	M3            = 8,
	M5            = 9,
	M6            = 10,
	C14           = 11,
	X14           = 12,
	M11           = 13,
}

LibRaw_HasselbladFormatCodes :: enum i32 {
	Unknown                = 0,
	_3FR                   = 1,
	FFF                    = 2,
	Imacon                 = 3,
	HasselbladDNG          = 4,
	AdobeDNG               = 5,
	AdobeDNG_fromPhocusDNG = 6,
}

LibRaw_rawspecial_t :: enum i32 {
	SONYARW2_NONE          = 0,
	SONYARW2_BASEONLY      = 1,
	SONYARW2_DELTAONLY     = 2,
	SONYARW2_DELTAZEROBASE = 4,
	SONYARW2_DELTATOVALUE  = 8,
	SONYARW2_ALLFLAGS      = 15,
	NODP2Q_INTERPOLATERG   = 16,
	NODP2Q_INTERPOLATEAF   = 32,
	SRAW_NO_RGB            = 64,
	SRAW_NO_INTERPOLATE    = 128,
}

LibRaw_rawspeed_bits_t :: enum i32 {
	_1_USE           = 1,
	_1_FAILONUNKNOWN = 2,
	_1_IGNOREERRORS  = 4,

	/*  bits 3-7 are reserved*/
	_3_USE           = 256,
	_3_FAILONUNKNOWN = 512,
	_3_IGNOREERRORS  = 1024,
}

LibRaw_processing_options :: enum i32 {
	PENTAX_PS_ALLFRAMES                   = 1,
	CONVERTFLOAT_TO_INT                   = 2,
	ARQ_SKIP_CHANNEL_SWAP                 = 4,
	NO_ROTATE_FOR_KODAK_THUMBNAILS        = 8,
	USE_PPM16_THUMBS                      = 32,
	DONT_CHECK_DNG_ILLUMINANT             = 64,
	DNGSDK_ZEROCOPY                       = 128,
	ZEROFILTERS_FOR_MONOCHROMETIFFS       = 256,
	DNG_ADD_ENHANCED                      = 512,
	DNG_ADD_PREVIEWS                      = 1024,
	DNG_PREFER_LARGEST_IMAGE              = 2048,
	DNG_STAGE2                            = 4096,
	DNG_STAGE3                            = 8192,
	DNG_ALLOWSIZECHANGE                   = 16384,
	DNG_DISABLEWBADJUST                   = 32768,
	PROVIDE_NONSTANDARD_WB                = 65536,
	CAMERAWB_FALLBACK_TO_DAYLIGHT         = 131072,
	CHECK_THUMBNAILS_KNOWN_VENDORS        = 262144,
	CHECK_THUMBNAILS_ALL_VENDORS          = 524288,
	DNG_STAGE2_IFPRESENT                  = 1048576,
	DNG_STAGE3_IFPRESENT                  = 2097152,
	DNG_ADD_MASKS                         = 4194304,
	CANON_IGNORE_MAKERNOTES_ROTATION      = 8388608,
	ALLOW_JPEGXL_PREVIEWS                 = 16777216,
	CANON_CHECK_CAMERA_AUTO_ROTATION_MODE = 67108864,
	DNG_STAGE23_IFPRESENT_JPGJXL          = 134217728,
}

LibRaw_decoder_flags :: enum i32 {
	HASCURVE            = 16,
	SONYARW2            = 32,
	TRYRAWSPEED         = 64,
	OWNALLOC            = 128,
	FIXEDMAXC           = 256,
	ADOBECOPYPIXEL      = 512,
	LEGACY_WITH_MARGINS = 1024,
	_3CHANNEL           = 2048,
	SINAR4SHOT          = 2048,
	FLATDATA            = 4096,
	FLAT_BG2_SWAPPED    = 8192,
	UNSUPPORTED_FORMAT  = 16384,
	NOTSET              = 32768,
	TRYRAWSPEED3        = 65536,
}

LIBRAW_XTRANS :: 9

LibRaw_constructor_flags :: enum i32 {
	TIONS_NONE                = 0,
	TIONS_NO_DATAERR_CALLBACK = 2,

	/* Compatibility w/ years old typo */
	IONS_NO_DATAERR_CALLBACK  = 2,
}

LibRaw_warnings :: enum i32 {
	NONE                  = 0,
	BAD_CAMERA_WB         = 4,
	NO_METADATA           = 8,
	NO_JPEGLIB            = 16,
	NO_EMBEDDED_PROFILE   = 32,
	NO_INPUT_PROFILE      = 64,
	BAD_OUTPUT_PROFILE    = 128,
	NO_BADPIXELMAP        = 256,
	BAD_DARKFRAME_FILE    = 512,
	BAD_DARKFRAME_DIM     = 1024,
	RAWSPEED_PROBLEM      = 4096,
	RAWSPEED_UNSUPPORTED  = 8192,
	RAWSPEED_PROCESSED    = 16384,
	FALLBACK_TO_AHD       = 32768,
	PARSEFUJI_PROCESSED   = 65536,
	DNGSDK_PROCESSED      = 131072,
	DNG_IMAGES_REORDERED  = 262144,
	DNG_STAGE2_APPLIED    = 524288,
	DNG_STAGE3_APPLIED    = 1048576,
	RAWSPEED3_PROBLEM     = 2097152,
	RAWSPEED3_UNSUPPORTED = 4194304,
	RAWSPEED3_PROCESSED   = 8388608,
	RAWSPEED3_NOTLISTED   = 16777216,
	VENDOR_CROP_SUGGESTED = 33554432,
	DNG_NOT_PROCESSED     = 67108864,
	DNG_NOT_PARSED        = 134217728,
}

LibRaw_exceptions :: enum i32 {
	NONE                  = 0,
	ALLOC                 = 1,
	DECODE_RAW            = 2,
	DECODE_JPEG           = 3,
	IO_EOF                = 4,
	IO_CORRUPT            = 5,
	CANCELLED_BY_CALLBACK = 6,
	BAD_CROP              = 7,
	IO_BADFILE            = 8,
	DECODE_JPEG2000       = 9,
	TOOBIG                = 10,
	MEMPOOL               = 11,
	UNSUPPORTED_FORMAT    = 12,
}

LibRaw_progress :: enum i32 {
	START              = 0,
	OPEN               = 1,
	IDENTIFY           = 2,
	SIZE_ADJUST        = 4,
	LOAD_RAW           = 8,
	RAW2_IMAGE         = 16,
	REMOVE_ZEROES      = 32,
	BAD_PIXELS         = 64,
	DARK_FRAME         = 128,
	FOVEON_INTERPOLATE = 256,
	SCALE_COLORS       = 512,
	PRE_INTERPOLATE    = 1024,
	INTERPOLATE        = 2048,
	MIX_GREEN          = 4096,
	MEDIAN_FILTER      = 8192,
	HIGHLIGHTS         = 16384,
	FUJI_ROTATE        = 32768,
	FLIP               = 65536,
	APPLY_PROFILE      = 131072,
	CONVERT_RGB        = 262144,
	STRETCH            = 524288,

	/* reserved */
	STAGE20            = 1048576,
	STAGE21            = 2097152,
	STAGE22            = 4194304,
	STAGE23            = 8388608,
	STAGE24            = 16777216,
	STAGE25            = 33554432,
	STAGE26            = 67108864,
	STAGE27            = 134217728,
	THUMB_LOAD         = 268435456,
	TRESERVED1         = 536870912,
	TRESERVED2         = 1073741824,
}

LIBRAW_PROGRESS_THUMB_MASK :: 0x0fffffff

LibRaw_errors :: enum i32 {
	SUCCESS                           = 0,
	UNSPECIFIED_ERROR                 = -1,
	FILE_UNSUPPORTED                  = -2,
	REQUEST_FOR_NONEXISTENT_IMAGE     = -3,
	OUT_OF_ORDER_CALL                 = -4,
	NO_THUMBNAIL                      = -5,
	UNSUPPORTED_THUMBNAIL             = -6,
	INPUT_CLOSED                      = -7,
	NOT_IMPLEMENTED                   = -8,
	REQUEST_FOR_NONEXISTENT_THUMBNAIL = -9,
	UNSUFFICIENT_MEMORY               = -100007,
	DATA_ERROR                        = -100008,
	IO_ERROR                          = -100009,
	CANCELLED_BY_CALLBACK             = -100010,
	BAD_CROP                          = -100011,
	TOO_BIG                           = -100012,
	MEMPOOL_OVERFLOW                  = -100013,
}

LibRaw_internal_thumbnail_formats :: enum i32 {
	UNKNOWN     = 0,
	KODAK_THUMB = 1,
	KODAK_YCBCR = 2,
	KODAK_RGB   = 3,
	JPEG        = 4,
	LAYER       = 5,
	ROLLEI      = 6,
	PPM         = 7,
	PPM16       = 8,
	X3F         = 9,
	DNG_YCBCR   = 10,
	JPEGXL      = 11,
}

LibRaw_thumbnail_formats :: enum i32 {
	UNKNOWN  = 0,
	JPEG     = 1,
	BITMAP   = 2,
	BITMAP16 = 3,
	LAYER    = 4,
	ROLLEI   = 5,
	H265     = 6,
	JPEGXL   = 7,
}

LibRaw_image_formats :: enum i32 {
	JPEG   = 1,
	BITMAP = 2,
	JPEGXL = 3,
	H265   = 4,
}

