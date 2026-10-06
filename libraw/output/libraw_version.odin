// Odin bindings for LibRaw 0.22.2, generated from the LibRaw headers by
// generate_bindings.ps1 (https://github.com/Dihedron-Software/ffpackage, libraw/).
//
// LibRaw: Copyright (C) 2008-2025 LibRaw LLC (http://www.libraw.org, info@libraw.org)
// Generated bindings: Dihedron Software GmbH
//
// This file is distributed under the COMMON DEVELOPMENT AND DISTRIBUTION LICENSE (CDDL)
// Version 1.0, which is one of the two licenses LibRaw offers. See LICENSE.CDDL and COPYRIGHT.
/* -*- C++ -*-
 * File: libraw_version.h
 * Copyright 2008-2025 LibRaw LLC (info@libraw.org)
 * Created: Mon Sept  8, 2008
 *
 * LibRaw C++ interface
 *

LibRaw is free software; you can redistribute it and/or modify
it under the terms of the one of two licenses as you choose:

1. GNU LESSER GENERAL PUBLIC LICENSE version 2.1
(See the file LICENSE.LGPL provided in LibRaw distribution archive for details).

2. COMMON DEVELOPMENT AND DISTRIBUTION LICENSE (CDDL) Version 1.0
(See the file LICENSE.CDDL provided in LibRaw distribution archive for details).

 */
package libraw

when ODIN_OS == .Windows {
    foreign import lib "libraw.lib"
} else when ODIN_OS == .Darwin {
    foreign import lib { "libraw.a", "system:c++" }
}

LIBRAW_MAJOR_VERSION  :: 0
LIBRAW_MINOR_VERSION  :: 22
LIBRAW_PATCH_VERSION  :: 2
LIBRAW_SHLIB_CURRENT  :: 25
LIBRAW_SHLIB_REVISION :: 0
LIBRAW_SHLIB_AGE      :: 0
LIBRAW_VERSION                                                         :: (((LIBRAW_MAJOR_VERSION)<<16)|((LIBRAW_MINOR_VERSION)<<8)|(LIBRAW_PATCH_VERSION))

