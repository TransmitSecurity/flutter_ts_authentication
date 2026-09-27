package com.example.flutter_ts_authentication

import com.transmit.authentication.biometrics.TSNativeBiometricsStatus

/**
 * Maps the Android biometric status onto the plugin's cross-platform
 * `TSBiometricsStatus` Dart enum.
 */
internal fun TSNativeBiometricsStatus.toPluginStatus(): String = when (this) {
    TSNativeBiometricsStatus.CanAuthenticate -> "available"
    TSNativeBiometricsStatus.NonEnrolled -> "notEnrolled"
    TSNativeBiometricsStatus.NoHarddware,
    TSNativeBiometricsStatus.HardwareNotAvailable -> "notAvailable"
    TSNativeBiometricsStatus.SecurityUpdateRequired -> "securityUpdateRequired"
    TSNativeBiometricsStatus.Unsupported -> "unsupported"
    TSNativeBiometricsStatus.StatusUnknown -> "unknown"
}

/**
 * Android exposes no API for the concrete biometric modality (the platform
 * intentionally hides whether face or fingerprint is used), so the plugin
 * reports the generic `biometric` value whenever biometrics are usable. This
 * mirrors iOS's `nativeBiometricsType()`, which can distinguish Face/Touch/Optic ID.
 */
internal fun TSNativeBiometricsStatus.toPluginBiometricsType(): String =
    if (this == TSNativeBiometricsStatus.CanAuthenticate) "biometric" else "none"
