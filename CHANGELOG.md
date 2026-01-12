# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.1] - 2026-01-05

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
