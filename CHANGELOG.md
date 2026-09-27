# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.5] - September 2026

### Added
- **Native SDK upgrade**: Android `com.ts.sdk:authentication` 1.0.29 → **1.0.30**, iOS `authentication-ios-sdk` 1.2.0 → **1.2.2**
  - Shared core moves with it: Android `com.ts.sdk:core` 1.0.24 → **1.0.30**, iOS `TSCoreSDK` floor
    `from: "1.1.0"` → **`from: "1.1.5"`**
  - **New transitive Android dependency**: core 1.0.30 adds
    `com.google.android.gms:play-services-location:20.0.0`, which now reaches every Android app
    consuming this plugin. Apps already depending on Play Services should check for a version
    conflict
  - iOS 1.2.2 introduces no public API change over 1.2.1; it corrects the SDK's own declared
    platform floor. The plugin continues to declare `iOS 15.0` deliberately — see the UserGuide
  - The iOS pin remains `exact:`, so an integrator cannot select a different
    `TSAuthenticationSDK` version without forking the plugin. Deliberate: a loose constraint could
    resolve to a version untested across the platform channel
- **WebAuthn `options` now actually take effect (iOS)**:
  `TSWebAuthnAuthenticationOptionValues.preferLocalCredentials` is a named constant for the one
  option the native SDK supports. Previously the plugin accepted an `options` list and discarded
  it on both platforms, so the option never reached the SDK. **iOS only** — the native Android SDK
  declares no options parameter, so on Android the values are validated and then a documented
  no-op
- **TOTP device PIN protection**: `TSTOTPSecurityType.devicePin` and `TSTOTPSecurityType.devicePinOrBiometric`
- **Native biometrics availability**:
  - `nativeBiometricsStatus()` returns a normalized `TSBiometricsStatus`
  - `nativeBiometricsType()` returns a normalized `TSBiometricsType`. Android reports the generic
    `biometric` value, since the platform does not expose the concrete modality
- **PIN code unregistration**: `unregisterPinCode()` and `commitPinUnregistration()`, mirroring the
  existing register/commit flow
- **WebAuthn with server-provided data**: `registerWebAuthnWithData()`,
  `authenticateWebAuthnWithData()` and `signWebauthnTransactionWithData()`, complementing the
  existing `approvalWebAuthnWithData()`
- **Structured error codes**: `TSAuthenticationErrorCode` and
  `TSAuthenticationErrorDetails.fromPlatformException()` expose a stable, cross-platform identifier
  for each native failure, including the new `devicePinNotAvailable` /
  `devicePinOrBiometricNotAvailable` TOTP errors and the enhanced iOS biometrics errors

### Changed
- `PlatformException.details` is now a map of `{'code': <stable code>, 'description': <native
  description>}` instead of a plain string. `code` and `message` are unchanged. Callers that read
  `details` as a `String` must migrate; use `TSAuthenticationErrorDetails.fromPlatformException()`,
  which also tolerates the legacy string form.
- **An unrecognized WebAuthn `options` value is now an error.** `approvalWebAuthn()`,
  `approvalWebAuthnWithData()`, `authenticateWebAuthnWithData()` and
  `signWebauthnTransactionWithData()` reject any name other than `preferLocalCredentials` with
  `invalidArguments`, on both platforms. Previously any string was accepted and silently ignored,
  so a call that passed an arbitrary value succeeded and did nothing; it now raises. Callers
  passing placeholder values (including the `['option1', 'option2']` example in earlier versions of
  the UserGuide) must pass an empty list or a value from
  `TSWebAuthnAuthenticationOptionValues`. Consistent with the `registerTOTP()` change below — a
  silently ignored option is indistinguishable from a typo.
- **Consumer ProGuard rules now cover shared core.** `android/consumer-rules.pro` carries keeps for
  a narrow set of `com.ts.coresdk.**` crypto, biometrics, error, logging and network classes.
  Neither the native Authentication SDK nor `core-android-sdk` ships consumer rules, so the
  plugin's file is the only keep set that reaches an integrating app. Affects release (R8) builds
  only; debug builds never exercised these paths.

### Fixed
- `registerTOTP()` no longer silently falls back to biometric protection for an unrecognized
  security type; it now reports an `invalidArguments` error instead.

## [0.0.1] - January 2026

### Added
- **Initial release** of Flutter TS Authentication plugin
- **Core SDK Integration**:
  - SDK initialization with client ID and configuration options
  - Configuration file support for SDK setup
  - WebAuthn endpoint configuration for custom server integration
- **PIN Code Authentication**:
  - Register PIN codes with username and PIN
  - Authenticate using PIN codes with challenge verification
  - Commit PIN registration with context management
- **Biometric Authentication**:
  - Register native biometric authentication
  - Unregister biometric authentication
  - Authenticate using device biometrics (Face ID, Touch ID, Fingerprint)
  - Biometric approval workflows with challenge verification
- **WebAuthn Support**:
  - Check WebAuthn platform support availability
  - Register WebAuthn credentials with username and display name
  - Authenticate using WebAuthn credentials
  - WebAuthn transaction signing capabilities
  - WebAuthn approval workflows with custom data and options
  - Support for raw authentication data handling
- **TOTP (Time-based One-Time Password)**:
  - Register TOTP with URI and security type configuration
  - Generate TOTP codes with issuer and label management
  - Biometric-secured and non-secured TOTP options
- **Device Management**:
  - Retrieve device information including public key data
  - Device public key ID and key extraction
- **Developer Tools**:
  - Logging control with `setLoggingEnabled()` for debugging
  - Comprehensive error handling and exception management
- **Platform Support**:
  - iOS support (minimum iOS 15.0+)
  - Android support (minimum API level 23+)
  - Swift Package Manager (SPM) integration for iOS
  - Maven repository support for Android dependencies
- **Plugin Architecture**:
  - Platform interface for cross-platform consistency
  - Method channel implementation for native communication
  - Robust error handling and type-safe API responses
- **Security Features**:
  - Biometric permission management
  - Secure credential storage and retrieval
  - Challenge-based authentication flows
  - Transaction approval mechanisms
- **Documentation**:
  - Comprehensive User Guide with setup instructions
  - Platform-specific configuration examples
  - API reference with code examples
  - Native SDK integration guides
  - Troubleshooting and best practices guide

### Technical Requirements
- Flutter 3.3.0 or higher
- Dart SDK 2.17.0 or higher (via SDK ^3.8.1)
- iOS 15.0+ with Xcode 14+
- Android API level 23+ (Android 6.0)

### Dependencies
- `plugin_platform_interface: ^2.0.2`
- Transmit Security native SDKs (automatically managed)
