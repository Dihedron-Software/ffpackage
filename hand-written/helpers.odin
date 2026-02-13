package ffmpeg

import "core:c"

// =============================================================================
// Constants that the bindgen can't auto-generate
// (cast expressions, compound literals, platform-specific values)
// =============================================================================

AV_NOPTS_VALUE :: min(i64)  // ((int64_t)UINT64_C(0x8000000000000000))
AV_TIME_BASE_Q :: AVRational{1, AV_TIME_BASE}

// EAGAIN errno differs between platforms
EAGAIN_ERRNO :: -35 when ODIN_OS == .Darwin else -11

// =============================================================================
// Helper functions (C macros/inline functions that can't be auto-generated)
// =============================================================================

av_q2d :: #force_inline proc(r: AVRational) -> f64 {
	return cast(f64)r.num / cast(f64)r.den
}

av_make_q :: #force_inline proc(num, den: c.int) -> AVRational {
	return AVRational{num, den}
}

av_inv_q :: #force_inline proc(q: AVRational) -> AVRational {
	return AVRational{q.den, q.num}
}

// =============================================================================
// Error handling (AVERROR macros are not simple #defines, they do bit-twiddling)
// =============================================================================

AVError_Int :: distinct i32

AVError :: enum i32 {
	BSF_NOT_FOUND,       ///< Bitstream filter not found
	BUG,                 ///< Internal bug, also see AVERROR_BUG2
	BUFFER_TOO_SMALL,    ///< Buffer too small
	DECODER_NOT_FOUND,   ///< Decoder not found
	DEMUXER_NOT_FOUND,   ///< Demuxer not found
	ENCODER_NOT_FOUND,   ///< Encoder not found
	EOF,                 ///< End of file
	EXIT,                ///< Immediate exit was requested; the called function should not be restarted
	EXTERNAL,            ///< Generic error in an external library
	FILTER_NOT_FOUND,    ///< Filter not found
	INVALIDDATA,         ///< Invalid data found when processing input
	MUXER_NOT_FOUND,     ///< Muxer not found
	OPTION_NOT_FOUND,    ///< Option not found
	PATCHWELCOME,        ///< Not yet implemented in FFmpeg, patches welcome
	PROTOCOL_NOT_FOUND,  ///< Protocol not found

	STREAM_NOT_FOUND,    ///< Stream not found
	BUG2,                ///< Semantically identical to AVERROR_BUG
	UNKNOWN,             ///< Unknown error, typically from an external library
	EXPERIMENTAL,        ///< Requested feature is flagged experimental
	INPUT_CHANGED,       ///< Input changed between calls. Reconfiguration is required.
	OUTPUT_CHANGED,      ///< Output changed between calls. Reconfiguration is required.
	/* HTTP & RTSP errors */
	HTTP_BAD_REQUEST,
	HTTP_UNAUTHORIZED,
	HTTP_FORBIDDEN,
	HTTP_NOT_FOUND,
	HTTP_OTHER_4XX,
	HTTP_SERVER_ERROR,

	// POSIX errno values (not in AVERROR defines)
	EAGAIN,
	ENOMEM,
	EINVAL,
	EPERM,
	ENOENT,
	ESRCH,
	EINTR,
	EIO,
	ENXIO,
	E2BIG,
	ENOEXEC,
	EBADF,
	ECHILD,
	EACCES,
	EFAULT,
	EBUSY,
	EEXIST,
	EXDEV,
	ENODEV,
	ENOTDIR,
	EISDIR,
	ENFILE,
	EMFILE,
	ENOTTY,
	EFBIG,
	ENOSPC,
	ESPIPE,
	EROFS,
	EMLINK,
	EPIPE,
	EDOM,
	EDEADLK,
	ENAMETOOLONG,
	ENOLCK,
	ENOSYS,
	ENOTEMPTY,
}

errbytes_to_int :: proc(bytes: [4]byte) -> i32 {
	return -transmute(i32)[4]byte{bytes[3], bytes[2], bytes[1], bytes[0]}
}

av_error :: proc(err_code: i32) -> AVError {
	if err_code == 0 {
		return nil
	}
	err_enum: AVError
	switch err_code {
		case errbytes_to_int({0xF8, 'B', 'S', 'F'}): err_enum = .BSF_NOT_FOUND
		case errbytes_to_int({'B', 'U', 'G', '!'}):   err_enum = .BUG
		case errbytes_to_int({'B', 'U', 'F', 'S'}):   err_enum = .BUFFER_TOO_SMALL
		case errbytes_to_int({0xF8, 'D', 'E', 'C'}): err_enum = .DECODER_NOT_FOUND
		case errbytes_to_int({0xF8, 'D', 'E', 'M'}): err_enum = .DEMUXER_NOT_FOUND
		case errbytes_to_int({0xF8, 'E', 'N', 'C'}): err_enum = .ENCODER_NOT_FOUND
		case errbytes_to_int({'E', 'O', 'F', ' '}):   err_enum = .EOF
		case errbytes_to_int({'E', 'X', 'I', 'T'}):   err_enum = .EXIT
		case errbytes_to_int({'E', 'X', 'T', ' '}):   err_enum = .EXTERNAL
		case errbytes_to_int({0xF8, 'F', 'I', 'L'}): err_enum = .FILTER_NOT_FOUND
		case errbytes_to_int({'I', 'N', 'D', 'A'}):   err_enum = .INVALIDDATA
		case errbytes_to_int({0xF8, 'M', 'U', 'X'}): err_enum = .MUXER_NOT_FOUND
		case errbytes_to_int({0xF8, 'O', 'P', 'T'}): err_enum = .OPTION_NOT_FOUND
		case errbytes_to_int({'P', 'A', 'W', 'E'}):   err_enum = .PATCHWELCOME
		case errbytes_to_int({0xF8, 'P', 'R', 'O'}): err_enum = .PROTOCOL_NOT_FOUND
		case errbytes_to_int({0xF8, 'S', 'T', 'R'}): err_enum = .STREAM_NOT_FOUND
		case errbytes_to_int({'B', 'U', 'G', ' '}):   err_enum = .BUG2
		case errbytes_to_int({'U', 'N', 'K', 'N'}):   err_enum = .UNKNOWN
		case -0x2bb2afa8:                              err_enum = .EXPERIMENTAL
		case -0x636e6701:                              err_enum = .INPUT_CHANGED
		case -0x636e6702:                              err_enum = .OUTPUT_CHANGED
		case errbytes_to_int({0xF8, '4', '0', '0'}): err_enum = .HTTP_BAD_REQUEST
		case errbytes_to_int({0xF8, '4', '0', '1'}): err_enum = .HTTP_UNAUTHORIZED
		case errbytes_to_int({0xF8, '4', '0', '3'}): err_enum = .HTTP_FORBIDDEN
		case errbytes_to_int({0xF8, '4', '0', '4'}): err_enum = .HTTP_NOT_FOUND
		case errbytes_to_int({0xF8, '4', 'X', 'X'}): err_enum = .HTTP_OTHER_4XX
		case errbytes_to_int({0xF8, '5', 'X', 'X'}): err_enum = .HTTP_SERVER_ERROR
		case EAGAIN_ERRNO: err_enum = .EAGAIN
		case -12:          err_enum = .ENOMEM
		case -22:          err_enum = .EINVAL
	}

	// @Note(Wassim): added fall through because asserting here is retarded.
	switch -err_code {
		case 1:  err_enum = .EPERM
		case 2:  err_enum = .ENOENT
		case 3:  err_enum = .ESRCH
		case 4:  err_enum = .EINTR
		case 5:  err_enum = .EIO
		case 6:  err_enum = .ENXIO
		case 7:  err_enum = .E2BIG
		case 8:  err_enum = .ENOEXEC
		case 9:  err_enum = .EBADF
		case 10: err_enum = .ECHILD
		case 11: err_enum = .EAGAIN
		case 12: err_enum = .ENOMEM
		case 13: err_enum = .EACCES
		case 14: err_enum = .EFAULT
		case 16: err_enum = .EBUSY
		case 17: err_enum = .EEXIST
		case 18: err_enum = .EXDEV
		case 19: err_enum = .ENODEV
		case 20: err_enum = .ENOTDIR
		case 21: err_enum = .EISDIR
		case 23: err_enum = .ENFILE
		case 24: err_enum = .EMFILE
		case 25: err_enum = .ENOTTY
		case 27: err_enum = .EFBIG
		case 28: err_enum = .ENOSPC
		case 29: err_enum = .ESPIPE
		case 30: err_enum = .EROFS
		case 31: err_enum = .EMLINK
		case 32: err_enum = .EPIPE
		case 33: err_enum = .EDOM
		case 36: err_enum = .EDEADLK
		case 38: err_enum = .ENAMETOOLONG
		case 39: err_enum = .ENOLCK
		case 40: err_enum = .ENOSYS
		case 41: err_enum = .ENOTEMPTY
	}

	return err_enum
}

averror_str :: proc(err_enum: AVError) -> string {
	switch err_enum {
	case .BSF_NOT_FOUND:     return "Bitstream filter not found"
	case .BUG:               return "Internal bug, should not have happened"
	case .BUG2:              return "Internal bug, should not have happened"
	case .BUFFER_TOO_SMALL:  return "Buffer too small"
	case .DECODER_NOT_FOUND: return "Decoder not found"
	case .DEMUXER_NOT_FOUND: return "Demuxer not found"
	case .ENCODER_NOT_FOUND: return "Encoder not found"
	case .EOF:               return "End of file"
	case .EXIT:              return "Immediate exit requested"
	case .EXTERNAL:          return "Generic error in an external library"
	case .FILTER_NOT_FOUND:  return "Filter not found"
	case .INPUT_CHANGED:     return "Input changed"
	case .INVALIDDATA:       return "Invalid data found when processing input"
	case .MUXER_NOT_FOUND:   return "Muxer not found"
	case .OPTION_NOT_FOUND:  return "Option not found"
	case .OUTPUT_CHANGED:    return "Output changed"
	case .PATCHWELCOME:      return "Not yet implemented in FFmpeg, patches welcome"
	case .PROTOCOL_NOT_FOUND: return "Protocol not found"
	case .STREAM_NOT_FOUND:  return "Stream not found"
	case .UNKNOWN:           return "Unknown error occurred"
	case .EXPERIMENTAL:      return "Experimental feature"
	case .HTTP_BAD_REQUEST:  return "Server returned 400 Bad Request"
	case .HTTP_UNAUTHORIZED: return "Server returned 401 Unauthorized"
	case .HTTP_FORBIDDEN:    return "Server returned 403 Forbidden"
	case .HTTP_NOT_FOUND:    return "Server returned 404 Not Found"
	case .HTTP_OTHER_4XX:    return "Server returned 4XX Client Error"
	case .HTTP_SERVER_ERROR: return "Server returned 5XX Server Error"
	case .E2BIG:             return "Argument list too long"
	case .EACCES:            return "Permission denied"
	case .EAGAIN:            return "Resource temporarily unavailable"
	case .EBADF:             return "Bad file descriptor"
	case .EBUSY:             return "Device or resource busy"
	case .ECHILD:            return "No child processes"
	case .EDEADLK:           return "Resource deadlock avoided"
	case .EDOM:              return "Numerical argument out of domain"
	case .EEXIST:            return "File exists"
	case .EFAULT:            return "Bad address"
	case .EFBIG:             return "File too large"
	case .EINTR:             return "Interrupted system call"
	case .EINVAL:            return "Invalid argument"
	case .EIO:               return "I/O error"
	case .EISDIR:            return "Is a directory"
	case .EMFILE:            return "Too many open files"
	case .EMLINK:            return "Too many links"
	case .ENAMETOOLONG:      return "File name too long"
	case .ENFILE:            return "Too many open files in system"
	case .ENODEV:            return "No such device"
	case .ENOENT:            return "No such file or directory"
	case .ENOEXEC:           return "Exec format error"
	case .ENOLCK:            return "No locks available"
	case .ENOMEM:            return "Cannot allocate memory"
	case .ENOSPC:            return "No space left on device"
	case .ENOSYS:            return "Function not implemented"
	case .ENOTDIR:           return "Not a directory"
	case .ENOTEMPTY:         return "Directory not empty"
	case .ENOTTY:            return "Inappropriate I/O control operation"
	case .ENXIO:             return "No such device or address"
	case .EPERM:             return "Operation not permitted"
	case .EPIPE:             return "Broken pipe"
	case .EROFS:             return "Read-only file system"
	case .ESPIPE:            return "Illegal seek"
	case .ESRCH:             return "No such process"
	case .EXDEV:             return "Cross-device link"
	}
	return ""
}
