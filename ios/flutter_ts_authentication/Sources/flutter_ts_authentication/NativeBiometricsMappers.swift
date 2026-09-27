import Foundation
import TSAuthenticationSDK

/// Maps the iOS biometric status onto the plugin's cross-platform
/// `TSBiometricsStatus` Dart enum.
func pluginBiometricsStatus(_ status: TSBiometricStatus) -> String {
    switch status {
    case .available: return "available"
    case .notEnrolled: return "notEnrolled"
    case .notAvailable: return "notAvailable"
    case .permissionDenied: return "permissionDenied"
    case .lockedOut: return "lockedOut"
    // Keeps compiling against status values added by future native SDK versions.
    @unknown default: return "unknown"
    }
}

/// Maps the iOS biometric modality onto the plugin's cross-platform
/// `TSBiometricsType` Dart enum.
func pluginBiometricsType(_ type: TSBiometricType) -> String {
    switch type {
    case .faceID: return "faceId"
    case .touchID: return "touchId"
    case .opticID: return "opticId"
    case .none: return "none"
    @unknown default: return "none"
    }
}

/// Maps the `TSTOTPSecurityType` name sent from Dart onto the native enum.
///
/// Returns `nil` for unrecognized values so the caller can report an argument
/// error instead of silently falling back to a different protection level than
/// the one the integrator asked for.
func totpSecurityType(fromName name: String) -> TSAuthenticationSDK.TSTOTPSecurityType? {
    switch name {
    case "none": return TSAuthenticationSDK.TSTOTPSecurityType.none
    case "biometric": return .biometric
    case "devicePin": return .devicePin
    case "devicePinOrBiometric": return .devicePinOrBiometric
    default: return nil
    }
}
