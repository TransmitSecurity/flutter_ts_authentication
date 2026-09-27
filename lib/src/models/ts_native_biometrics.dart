/// Availability of native biometrics on the current device.
///
/// The values are normalized across platforms: each platform bridge maps its
/// native status onto this shared set. Values that only one platform can
/// report are documented below.
enum TSBiometricsStatus {
  /// Biometrics are enrolled and can be used to authenticate.
  available,

  /// No biometric (or device credential) is enrolled.
  notEnrolled,

  /// No suitable hardware, or the hardware is temporarily unavailable.
  notAvailable,

  /// The user denied the app permission to use biometrics. iOS only.
  permissionDenied,

  /// Biometrics are locked out after too many failed attempts. iOS only.
  lockedOut,

  /// A security update is required before the sensor can be used. Android only.
  securityUpdateRequired,

  /// Biometrics are not supported on this OS version. Android only.
  unsupported,

  /// The status could not be determined.
  unknown;

  static TSBiometricsStatus fromName(String? name) {
    return TSBiometricsStatus.values.firstWhere(
      (status) => status.name == name,
      orElse: () => TSBiometricsStatus.unknown,
    );
  }
}

/// The biometric modality currently available on the device.
///
/// Android cannot report the concrete modality, so it reports
/// [TSBiometricsType.biometric] whenever biometrics are usable and
/// [TSBiometricsType.none] otherwise.
enum TSBiometricsType {
  faceId,
  touchId,
  opticId,

  /// Biometrics are available but the concrete modality is unknown. Android only.
  biometric,

  /// No biometric modality is available.
  none;

  static TSBiometricsType fromName(String? name) {
    return TSBiometricsType.values.firstWhere(
      (type) => type.name == name,
      orElse: () => TSBiometricsType.none,
    );
  }
}
