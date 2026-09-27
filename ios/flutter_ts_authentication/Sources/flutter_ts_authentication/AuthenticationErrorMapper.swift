import Foundation
import TSAuthenticationSDK

/// Stable, cross-platform error identifiers reported to the Dart layer.
///
/// These values are part of the plugin's public contract: they are sent as the
/// `code` entry of the structured `details` map on every plugin error, and are
/// parsed on the Dart side by `TSAuthenticationErrorCode`. Keep them in sync
/// with the Android bridge and with the Dart enum.
enum AuthenticationErrorCode: String {
    case devicePinNotAvailable
    case devicePinOrBiometricNotAvailable
    case nativeBiometricsNotAvailable
    case nativeBiometricsNotEnrolled
    case incorrectUriFormat
    case invalidSecret
    case invalidAlgorithm
    case invalidPeriod
    case invalidDigits
    case notRegistered
    case userCanceled
    case authenticationFailed
    case lockedOut
    case permissionDenied
    case duplicateCommitRegistration
    /// Raised by the plugin itself, not mapped from a native error: an argument
    /// the native SDK would misinterpret or silently ignore.
    case invalidArguments
    case apiNotSupported
    case internalError
    case unknown
}

/// Builds the structured `details` payload attached to a Flutter error.
///
/// `description` keeps the native error's localized description so nothing that
/// was previously reported is lost.
func errorDetails(_ code: AuthenticationErrorCode, _ description: String?) -> [String: String?] {
    return ["code": code.rawValue, "description": description]
}

/// Single entry point used by every plugin handler: maps a native error onto a
/// structured payload, falling back to `unknown` for error types the plugin
/// does not model individually.
func pluginErrorDetails(_ error: Error) -> [String: String?] {
    guard let authenticationError = error as? TSAuthenticationError else {
        return errorDetails(.unknown, error.localizedDescription)
    }
    return errorDetails(authenticationError.pluginErrorCode, error.localizedDescription)
}

private extension TSAuthenticationError {
    var pluginErrorCode: AuthenticationErrorCode {
        switch self {
        case .totpError(let totpError):
            return totpError.pluginErrorCode
        case .nativeBiometricsError(let biometricsError):
            return biometricsError.pluginErrorCode
        case .pinCodeError(let pinCodeError):
            return pinCodeError.pluginErrorCode
        case .webAuthnError(let webAuthnError):
            return webAuthnError.pluginErrorCode
        case .unsupportedOSVersion:
            return .apiNotSupported
        case .notInitialized, .requestIsRunning, .networkError, .initializationError, .internal:
            return .internalError
        // Keeps compiling against error cases added by future native SDK versions.
        @unknown default:
            return .unknown
        }
    }
}

private extension TSTOTPError {
    var pluginErrorCode: AuthenticationErrorCode {
        switch self {
        case .devicePinNotAvailable: return .devicePinNotAvailable
        case .devicePinOrBiometricNotAvailable: return .devicePinOrBiometricNotAvailable
        case .nativeBiometricsNotAvailable: return .nativeBiometricsNotAvailable
        case .incorrectURIFormat: return .incorrectUriFormat
        case .invalidSecret: return .invalidSecret
        case .invalidAlgorithm: return .invalidAlgorithm
        case .invalidPeriod: return .invalidPeriod
        case .invalidDigits: return .invalidDigits
        case .notRegistered: return .notRegistered
        case .userCanceled: return .userCanceled
        case .authenticationFailed: return .authenticationFailed
        case .internal: return .internalError
        @unknown default: return .unknown
        }
    }
}

private extension TSNativeBiometricsError {
    var pluginErrorCode: AuthenticationErrorCode {
        switch self {
        case .nativeBiometricsNotAvailable: return .nativeBiometricsNotAvailable
        case .nativeBiometricsNotEnrolled: return .nativeBiometricsNotEnrolled
        case .notRegistered: return .notRegistered
        case .userCanceled, .canceled: return .userCanceled
        case .failure: return .authenticationFailed
        case .lockedOut: return .lockedOut
        case .permissionDenied: return .permissionDenied
        case .internal: return .internalError
        @unknown default: return .unknown
        }
    }
}

private extension TSPinCodeError {
    var pluginErrorCode: AuthenticationErrorCode {
        switch self {
        case .notRegistered: return .notRegistered
        case .duplicateCommitRegistration: return .duplicateCommitRegistration
        case .internal: return .internalError
        @unknown default: return .unknown
        }
    }
}

private extension TSWebAuthnError {
    var pluginErrorCode: AuthenticationErrorCode {
        switch self {
        case .canceled: return .userCanceled
        case .userNotFound: return .notRegistered
        case .failed, .invalidResponse, .notHandled, .notInteractive:
            return .authenticationFailed
        case .invalidDomain, .invalidWebAuthnSession, .internal:
            return .internalError
        @unknown default: return .unknown
        }
    }
}
