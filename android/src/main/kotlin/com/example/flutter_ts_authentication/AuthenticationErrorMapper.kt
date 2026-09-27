package com.example.flutter_ts_authentication

import com.transmit.authentication.biometrics.TSBiometricsAuthError
import com.transmit.authentication.crpto.totp.TSTOTPError
import com.transmit.authentication.pincode.TSPinCodeRegistrationError
import com.transmit.authentication.pincode.TSPinCodeUnregistrationError

/**
 * Stable, cross-platform error identifiers reported to the Dart layer.
 *
 * These values are part of the plugin's public contract: they are sent as the
 * `code` entry of the structured `details` map on every plugin error, and are
 * parsed on the Dart side by `TSAuthenticationErrorCode`. Keep them in sync
 * with the iOS bridge and with the Dart enum.
 */
internal object AuthenticationErrorCode {
    const val DEVICE_PIN_NOT_AVAILABLE = "devicePinNotAvailable"
    const val DEVICE_PIN_OR_BIOMETRIC_NOT_AVAILABLE = "devicePinOrBiometricNotAvailable"
    const val NATIVE_BIOMETRICS_NOT_AVAILABLE = "nativeBiometricsNotAvailable"
    const val NATIVE_BIOMETRICS_NOT_ENROLLED = "nativeBiometricsNotEnrolled"
    const val INCORRECT_URI_FORMAT = "incorrectUriFormat"
    const val INVALID_SECRET = "invalidSecret"
    const val INVALID_ALGORITHM = "invalidAlgorithm"
    const val INVALID_PERIOD = "invalidPeriod"
    const val INVALID_DIGITS = "invalidDigits"
    const val NOT_REGISTERED = "notRegistered"
    const val USER_CANCELED = "userCanceled"
    const val AUTHENTICATION_FAILED = "authenticationFailed"
    const val LOCKED_OUT = "lockedOut"
    const val API_NOT_SUPPORTED = "apiNotSupported"
    const val INTERNAL_ERROR = "internalError"

    /**
     * Raised by the plugin itself, not mapped from a native error: an argument
     * the native SDK would misinterpret or silently ignore.
     */
    const val INVALID_ARGUMENTS = "invalidArguments"

    const val UNKNOWN = "unknown"
}

/**
 * Builds the structured `details` payload attached to a Flutter error.
 *
 * [description] keeps the native error's `toString()` so nothing that was
 * previously reported is lost.
 */
internal fun errorDetails(code: String, description: String?): Map<String, String?> =
    mapOf("code" to code, "description" to description)

/**
 * Single entry point used by every plugin handler: dispatches on the concrete
 * native error type and always produces a structured payload, so no call site
 * needs to know which error families have a dedicated mapping.
 */
internal fun pluginErrorDetails(error: Any?): Map<String, String?> = when (error) {
    is TSTOTPError -> error.toErrorDetails()
    is TSBiometricsAuthError -> error.toErrorDetails()
    is TSPinCodeUnregistrationError -> error.toErrorDetails()
    is TSPinCodeRegistrationError -> error.toErrorDetails()
    else -> genericErrorDetails(error)
}

internal fun TSTOTPError.toErrorDetails(): Map<String, String?> =
    errorDetails(toErrorCode(), toString())

private fun TSTOTPError.toErrorCode(): String = when (this) {
    is TSTOTPError.DevicePinNotAvailable -> AuthenticationErrorCode.DEVICE_PIN_NOT_AVAILABLE
    is TSTOTPError.DevicePinOrBiometricNotAvailable ->
        AuthenticationErrorCode.DEVICE_PIN_OR_BIOMETRIC_NOT_AVAILABLE
    is TSTOTPError.NativeBiometricsNotAvailable ->
        AuthenticationErrorCode.NATIVE_BIOMETRICS_NOT_AVAILABLE
    is TSTOTPError.IncorrectURIFormat -> AuthenticationErrorCode.INCORRECT_URI_FORMAT
    is TSTOTPError.InvalidSecret -> AuthenticationErrorCode.INVALID_SECRET
    is TSTOTPError.InvalidAlgorithm -> AuthenticationErrorCode.INVALID_ALGORITHM
    is TSTOTPError.InvalidPeriod -> AuthenticationErrorCode.INVALID_PERIOD
    is TSTOTPError.InvalidDigits -> AuthenticationErrorCode.INVALID_DIGITS
    is TSTOTPError.NotRegistered -> AuthenticationErrorCode.NOT_REGISTERED
    is TSTOTPError.UserCanceled,
    is TSTOTPError.Canceled,
    is TSTOTPError.NegativeButton -> AuthenticationErrorCode.USER_CANCELED
    is TSTOTPError.NoMatch -> AuthenticationErrorCode.AUTHENTICATION_FAILED
    is TSTOTPError.Lockout,
    is TSTOTPError.LockoutPermanent -> AuthenticationErrorCode.LOCKED_OUT
    is TSTOTPError.ApiNotSupported -> AuthenticationErrorCode.API_NOT_SUPPORTED
    is TSTOTPError.SDKNotInitialized,
    is TSTOTPError.InternalError,
    is TSTOTPError.LoadKeyFailed,
    is TSTOTPError.GenerateKeyFailed,
    is TSTOTPError.UnableToProcess,
    is TSTOTPError.TimeOut,
    is TSTOTPError.NoSpace -> AuthenticationErrorCode.INTERNAL_ERROR
    // Covers cases added by future native SDK versions without failing the call.
    else -> AuthenticationErrorCode.UNKNOWN
}

internal fun TSBiometricsAuthError.toErrorDetails(): Map<String, String?> =
    errorDetails(toErrorCode(), toString())

private fun TSBiometricsAuthError.toErrorCode(): String = when (this) {
    is TSBiometricsAuthError.BiometricErrorNonEnrolled ->
        AuthenticationErrorCode.NATIVE_BIOMETRICS_NOT_ENROLLED
    is TSBiometricsAuthError.BiometricErrorNoHardware,
    is TSBiometricsAuthError.BiometricErrorHWUnavailable,
    is TSBiometricsAuthError.BiometricErrorUnsupported ->
        AuthenticationErrorCode.NATIVE_BIOMETRICS_NOT_AVAILABLE
    is TSBiometricsAuthError.NOT_REGISTERED -> AuthenticationErrorCode.NOT_REGISTERED
    else -> genericBiometricsErrorCode(this::class.java.simpleName)
}

internal fun TSPinCodeUnregistrationError.toErrorDetails(): Map<String, String?> {
    val code = when (this) {
        is TSPinCodeUnregistrationError.NotRegistered -> AuthenticationErrorCode.NOT_REGISTERED
        is TSPinCodeUnregistrationError.InternalError -> AuthenticationErrorCode.INTERNAL_ERROR
        else -> AuthenticationErrorCode.UNKNOWN
    }
    return errorDetails(code, toString())
}

internal fun TSPinCodeRegistrationError.toErrorDetails(): Map<String, String?> =
    errorDetails(AuthenticationErrorCode.INTERNAL_ERROR, toString())

/**
 * Fallback for biometric error variants that carry no dedicated code. Matching
 * on the class name keeps the mapping resilient to sealed-class additions in
 * the native SDK.
 */
private fun genericBiometricsErrorCode(variantName: String): String = when (variantName) {
    "UserCanceled", "Canceled", "NegativeButton" -> AuthenticationErrorCode.USER_CANCELED
    "NoMatch" -> AuthenticationErrorCode.AUTHENTICATION_FAILED
    "Lockout", "LockoutPermanent" -> AuthenticationErrorCode.LOCKED_OUT
    "InternalError", "SDKNotInitialized", "NetworkError", "UnableToProcess",
    "TimeOut", "NoSpace" -> AuthenticationErrorCode.INTERNAL_ERROR
    else -> AuthenticationErrorCode.UNKNOWN
}

/** Generic mapping for error types that expose no structured variants. */
internal fun genericErrorDetails(error: Any?): Map<String, String?> =
    errorDetails(AuthenticationErrorCode.UNKNOWN, error?.toString())
