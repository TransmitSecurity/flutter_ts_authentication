package com.example.flutter_ts_authentication

import com.transmit.authentication.crpto.totp.TSTOTPSecurityType

/**
 * Maps the `TSTOTPSecurityType` name sent from Dart onto the native enum.
 *
 * Returns `null` for unrecognized values so the caller can report an argument
 * error instead of silently falling back to a different protection level than
 * the one the integrator asked for.
 */
internal fun totpSecurityTypeFromName(name: String): TSTOTPSecurityType? = when (name) {
    "none" -> TSTOTPSecurityType.None
    "biometric" -> TSTOTPSecurityType.Biometric
    "devicePin" -> TSTOTPSecurityType.DevicePin
    "devicePinOrBiometric" -> TSTOTPSecurityType.DevicePinOrBiometric
    else -> null
}
