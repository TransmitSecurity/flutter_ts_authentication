import 'package:flutter/services.dart';

/// Stable, cross-platform error identifiers reported by the native SDKs.
///
/// The plugin maps each native error onto one of these identifiers so callers
/// can branch on the failure reason without parsing platform-specific
/// descriptions. Unrecognized natives errors map to [unknown].
enum TSAuthenticationErrorCode {
  // TOTP
  devicePinNotAvailable,
  devicePinOrBiometricNotAvailable,
  nativeBiometricsNotAvailable,
  incorrectUriFormat,
  invalidSecret,
  invalidAlgorithm,
  invalidPeriod,
  invalidDigits,
  notRegistered,

  // Native biometrics
  nativeBiometricsNotEnrolled,
  userCanceled,
  authenticationFailed,
  lockedOut,
  permissionDenied,

  // PIN code
  duplicateCommitRegistration,

  // Argument validation, raised by the plugin itself rather than mapped from a
  // native error. The plugin rejects an argument the native SDK would either
  // misinterpret or silently ignore — an unrecognized WebAuthn option name, or
  // an unrecognized TOTP security type.
  invalidArguments,

  // Generic
  apiNotSupported,
  internalError,
  unknown;

  static TSAuthenticationErrorCode fromName(String? name) {
    return TSAuthenticationErrorCode.values.firstWhere(
      (code) => code.name == name,
      orElse: () => TSAuthenticationErrorCode.unknown,
    );
  }
}

/// Structured `details` payload attached to every [PlatformException] the
/// plugin throws.
///
/// Native bridges report `details` as a map of `{'code': ..., 'description':
/// ...}`. [TSAuthenticationErrorDetails.fromPlatformException] tolerates the
/// legacy plain-string form as well, mapping it to
/// [TSAuthenticationErrorCode.unknown] with the string as the description.
class TSAuthenticationErrorDetails {
  final TSAuthenticationErrorCode code;
  final String? description;

  TSAuthenticationErrorDetails({required this.code, this.description});

  /// Extracts the structured details from [exception], never throwing.
  factory TSAuthenticationErrorDetails.fromPlatformException(
    PlatformException exception,
  ) {
    final details = exception.details;

    if (details is Map) {
      return TSAuthenticationErrorDetails(
        code: TSAuthenticationErrorCode.fromName(details['code'] as String?),
        description: details['description'] as String?,
      );
    }

    return TSAuthenticationErrorDetails(
      code: TSAuthenticationErrorCode.unknown,
      description: details?.toString(),
    );
  }
}
