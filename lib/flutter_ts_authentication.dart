import 'flutter_ts_authentication_platform_interface.dart';
import 'src/models/ts_native_biometrics.dart';
import 'src/models/ts_pin_code_unregistration_completion.dart';
import 'src/models/ts_webauthn_registration_data.dart';

export 'src/models/ts_native_biometrics.dart';
export 'src/models/ts_pin_code_unregistration_completion.dart';
export 'src/models/ts_webauthn_registration_data.dart';
export 'src/ts_authentication_error_details.dart';

class TSWebAuthnInitOptions {
  final String startAuthentication;
  final String startRegistration;

  TSWebAuthnInitOptions({
    required this.startAuthentication,
    required this.startRegistration,
  });

  Map<String, dynamic> toMap() {
    return {
      'startAuthentication': startAuthentication,
      'startRegistration': startRegistration,
    };
  }

  factory TSWebAuthnInitOptions.fromMap(Map<String, dynamic> map) {
    return TSWebAuthnInitOptions(
      startAuthentication: map['startAuthentication'] as String,
      startRegistration: map['startRegistration'] as String,
    );
  }
}

class TSInitOptions {
  final TSWebAuthnInitOptions webAuthnInitOptions;

  TSInitOptions({required this.webAuthnInitOptions});

  Map<String, dynamic> toMap() {
    return {'webAuthnInitOptions': webAuthnInitOptions.toMap()};
  }

  factory TSInitOptions.fromMap(Map<String, dynamic> map) {
    return TSInitOptions(
      webAuthnInitOptions: TSWebAuthnInitOptions.fromMap(
        map['webAuthnInitOptions'] as Map<String, dynamic>,
      ),
    );
  }
}

class TSPinCodeRegistrationCompletion {
  final String publicKeyId;
  final String publicKey;
  final String keyType;
  final String contextIdentifier;

  TSPinCodeRegistrationCompletion({
    required this.publicKeyId,
    required this.publicKey,
    required this.keyType,
    required this.contextIdentifier,
  });

  factory TSPinCodeRegistrationCompletion.fromMap(Map<String, dynamic> map) {
    return TSPinCodeRegistrationCompletion(
      publicKeyId: map['publicKeyId'] as String,
      publicKey: map['publicKey'] as String,
      keyType: map['keyType'] as String,
      contextIdentifier: map['contextIdentifier'] as String,
    );
  }
}

class TSPinCodeAuthenticationCompletion {
  final String publicKeyId;
  final String signature;
  final String challenge;

  TSPinCodeAuthenticationCompletion({
    required this.publicKeyId,
    required this.signature,
    required this.challenge,
  });

  factory TSPinCodeAuthenticationCompletion.fromMap(Map<String, dynamic> map) {
    return TSPinCodeAuthenticationCompletion(
      publicKeyId: map['publicKeyId'] as String,
      signature: map['signature'] as String,
      challenge: map['challenge'] as String,
    );
  }
}

class DeviceInfo {
  final String publicKeyId;
  final String publicKey;

  DeviceInfo({required this.publicKeyId, required this.publicKey});

  factory DeviceInfo.fromMap(Map<String, dynamic> map) {
    return DeviceInfo(
      publicKeyId: map['publicKeyId'] as String,
      publicKey: map['publicKey'] as String,
    );
  }
}

class TSBiometricsRegistrationResult {
  final String publicKey;
  final String publicKeyId;
  final String os;
  final String keyType;
  final String? attestation;

  TSBiometricsRegistrationResult({
    required this.publicKey,
    required this.publicKeyId,
    required this.os,
    required this.keyType,
    this.attestation,
  });

  factory TSBiometricsRegistrationResult.fromMap(Map<String, dynamic> map) {
    return TSBiometricsRegistrationResult(
      publicKey: map['publicKey'] as String,
      publicKeyId: map['publicKeyId'] as String,
      os: map['os'] as String,
      keyType: map['keyType'] as String,
      attestation: map['attestation'] as String?,
    );
  }
}

class TSWebAuthnRegistrationResults {
  final String result;

  TSWebAuthnRegistrationResults({required this.result});

  factory TSWebAuthnRegistrationResults.fromMap(Map<String, dynamic> map) {
    return TSWebAuthnRegistrationResults(result: map['result'] as String);
  }
}

class TSWebAuthnAuthenticationResults {
  final String result;

  TSWebAuthnAuthenticationResults({required this.result});

  factory TSWebAuthnAuthenticationResults.fromMap(Map<String, dynamic> map) {
    return TSWebAuthnAuthenticationResults(result: map['result'] as String);
  }
}

class TSBiometricsAuthenticationResult {
  final String publicKeyId;
  final String signature;

  TSBiometricsAuthenticationResult({
    required this.publicKeyId,
    required this.signature,
  });

  factory TSBiometricsAuthenticationResult.fromMap(Map<String, dynamic> map) {
    return TSBiometricsAuthenticationResult(
      publicKeyId: map['publicKeyId'] as String,
      signature: map['signature'] as String,
    );
  }
}

class TSNativeBiometricsUnregisterResult {
  final String publicKeyId;

  TSNativeBiometricsUnregisterResult({required this.publicKeyId});

  factory TSNativeBiometricsUnregisterResult.fromMap(Map<String, dynamic> map) {
    return TSNativeBiometricsUnregisterResult(
      publicKeyId: map['publicKeyId'] as String,
    );
  }
}

class TSSignChallengeResult {
  final String signature;

  TSSignChallengeResult({required this.signature});

  factory TSSignChallengeResult.fromMap(Map<String, dynamic> map) {
    return TSSignChallengeResult(signature: map['signature'] as String);
  }
}

/// Protection applied to a registered TOTP secret.
enum TSTOTPSecurityType {
  /// The secret is protected by biometric authentication.
  biometric,

  /// The secret is not protected by a user presence check.
  none,

  /// The secret is protected by the device PIN / passcode.
  ///
  /// Requires native Authentication SDK Android 1.0.30 / iOS 1.2.1 or later.
  devicePin,

  /// The secret is protected by the device PIN / passcode or biometrics,
  /// whichever the user chooses.
  ///
  /// Requires native Authentication SDK Android 1.0.30 / iOS 1.2.1 or later.
  devicePinOrBiometric,
}

class TSTOTPRegistrationCompletion {
  final String? issuer;
  final String? label;
  final String uuid;

  TSTOTPRegistrationCompletion({this.issuer, this.label, required this.uuid});

  factory TSTOTPRegistrationCompletion.fromMap(Map<String, dynamic> map) {
    return TSTOTPRegistrationCompletion(
      issuer: map['issuer'] as String?,
      label: map['label'] as String?,
      uuid: map['uuid'] as String,
    );
  }
}

class TSTOTPGenerateCodeCompletion {
  final String code;

  TSTOTPGenerateCodeCompletion({required this.code});

  factory TSTOTPGenerateCodeCompletion.fromMap(Map<String, dynamic> map) {
    return TSTOTPGenerateCodeCompletion(code: map['code'] as String);
  }
}

// Type alias for TSWebAuthnAuthenticationOptions
typedef TSWebAuthnAuthenticationOptions = String;

/// The recognized values for [TSWebAuthnAuthenticationOptions].
///
/// The type is a bare `String` alias, so nothing in the type system constrains what a caller may
/// pass. These constants are the supported set; anything else is rejected with `invalidArguments`
/// on both platforms.
///
/// **Platform behavior differs.** `options` is honored on iOS only — the native iOS SDK accepts a
/// `WebAuthnAuthenticationOptions` OptionSet, while the Android SDK's equivalent methods declare
/// no options parameter. On Android the values are validated (so an unrecognized name fails the
/// same way on both platforms) and then have no effect. See `UserGuide.md`.
abstract final class TSWebAuthnAuthenticationOptionValues {
  /// Prefer credentials already present on the device over server-provided ones.
  ///
  /// iOS only; no effect on Android. Note the native iOS SDK spells this option
  /// `preferLocalCredantials`; that spelling is also accepted for callers who copied the native
  /// name, but this correctly spelled constant is the plugin's contract.
  static const String preferLocalCredentials = 'preferLocalCredentials';

  /// Every recognized option name.
  static const List<String> all = <String>[preferLocalCredentials];
}

class TSWebAuthnAuthenticationData {
  final Map<String, dynamic> data;

  TSWebAuthnAuthenticationData({required this.data});

  factory TSWebAuthnAuthenticationData.fromMap(Map<String, dynamic> map) {
    return TSWebAuthnAuthenticationData(data: map);
  }

  Map<String, dynamic> toMap() {
    return data;
  }
}

class TSApprovalResults {
  final String result;

  TSApprovalResults({required this.result});

  factory TSApprovalResults.fromMap(Map<String, dynamic> map) {
    return TSApprovalResults(result: map['result'] as String);
  }
}

class FlutterTsAuthentication {
  Future<void> initializeSDK() {
    return FlutterTsAuthenticationPlatform.instance.initializeSDK();
  }

  Future<void> initialize(
    String clientId,
    String domain,
    String baseUrl,
    TSInitOptions? initOptions,
  ) {
    return FlutterTsAuthenticationPlatform.instance.initialize(
      clientId,
      domain,
      baseUrl,
      initOptions,
    );
  }

  Future<TSPinCodeRegistrationCompletion> registerPinCode(
    String username,
    String pinCode,
  ) {
    return FlutterTsAuthenticationPlatform.instance.registerPinCode(
      username,
      pinCode,
    );
  }

  Future<void> commitPinRegistration(String contextIdentifier) {
    return FlutterTsAuthenticationPlatform.instance.commitPinRegistration(
      contextIdentifier,
    );
  }

  Future<TSPinCodeAuthenticationCompletion> authenticatePinCode(
    String username,
    String pinCode,
    String challenge,
  ) {
    return FlutterTsAuthenticationPlatform.instance.authenticatePinCode(
      username,
      pinCode,
      challenge,
    );
  }

  /// Unregisters the PIN code authenticator for [username].
  ///
  /// The returned context must be committed with [commitPinUnregistration]
  /// once your backend acknowledged the unregistration.
  Future<TSPinCodeUnregistrationCompletion> unregisterPinCode(String username) {
    return FlutterTsAuthenticationPlatform.instance.unregisterPinCode(username);
  }

  /// Commits a pending PIN code unregistration returned by
  /// [unregisterPinCode].
  Future<void> commitPinUnregistration(String contextIdentifier) {
    return FlutterTsAuthenticationPlatform.instance.commitPinUnregistration(
      contextIdentifier,
    );
  }

  Future<TSBiometricsRegistrationResult> registerNativeBiometrics(
    String username,
  ) {
    return FlutterTsAuthenticationPlatform.instance.registerNativeBiometrics(
      username,
    );
  }

  /// Returns whether native biometrics can currently be used on this device.
  Future<TSBiometricsStatus> nativeBiometricsStatus() {
    return FlutterTsAuthenticationPlatform.instance.nativeBiometricsStatus();
  }

  /// Returns the biometric modality available on this device.
  ///
  /// Android reports [TSBiometricsType.biometric] when biometrics are usable,
  /// since the platform does not expose the concrete modality.
  Future<TSBiometricsType> nativeBiometricsType() {
    return FlutterTsAuthenticationPlatform.instance.nativeBiometricsType();
  }

  Future<TSNativeBiometricsUnregisterResult> unregisterNativeBiometrics(
    String userId,
  ) {
    return FlutterTsAuthenticationPlatform.instance.unregisterNativeBiometrics(
      userId,
    );
  }

  Future<TSWebAuthnRegistrationResults> registerWebAuthn(
    String username,
    String displayName,
  ) {
    return FlutterTsAuthenticationPlatform.instance.registerWebAuthn(
      username,
      displayName,
    );
  }

  Future<TSWebAuthnAuthenticationResults> authenticateWebAuthn(
    String username,
  ) {
    return FlutterTsAuthenticationPlatform.instance.authenticateWebAuthn(
      username,
    );
  }

  Future<TSWebAuthnAuthenticationResults> signWebauthnTransaction(
    String username,
  ) {
    return FlutterTsAuthenticationPlatform.instance.signWebauthnTransaction(
      username,
    );
  }

  /// Registers a WebAuthn credential using registration data obtained from
  /// your backend, without the SDK performing the `start registration` call.
  Future<TSWebAuthnRegistrationResults> registerWebAuthnWithData(
    TSWebAuthnRegistrationData rawRegistrationData,
  ) {
    return FlutterTsAuthenticationPlatform.instance.registerWebAuthnWithData(
      rawRegistrationData,
    );
  }

  /// Authenticates using authentication data obtained from your backend,
  /// without the SDK performing the `start authentication` call.
  Future<TSWebAuthnAuthenticationResults> authenticateWebAuthnWithData(
    TSWebAuthnAuthenticationData rawAuthenticationData,
    List<TSWebAuthnAuthenticationOptions> options,
  ) {
    return FlutterTsAuthenticationPlatform.instance
        .authenticateWebAuthnWithData(rawAuthenticationData, options);
  }

  /// Signs a transaction using authentication data obtained from your backend,
  /// without the SDK performing the `start authentication` call.
  Future<TSWebAuthnAuthenticationResults> signWebauthnTransactionWithData(
    TSWebAuthnAuthenticationData rawAuthenticationData,
    List<TSWebAuthnAuthenticationOptions> options,
  ) {
    return FlutterTsAuthenticationPlatform.instance
        .signWebauthnTransactionWithData(rawAuthenticationData, options);
  }

  Future<TSBiometricsAuthenticationResult> authenticateNativeBiometrics(
    String username,
    String challenge,
  ) {
    return FlutterTsAuthenticationPlatform.instance
        .authenticateNativeBiometrics(username, challenge);
  }

  Future<TSApprovalResults> approvalWebAuthn(
    Map<String, String> approvalData,
    String? username,
    List<TSWebAuthnAuthenticationOptions> options,
  ) {
    return FlutterTsAuthenticationPlatform.instance.approvalWebAuthn(
      approvalData,
      username,
      options,
    );
  }

  Future<TSApprovalResults> approvalWebAuthnWithData(
    TSWebAuthnAuthenticationData rawAuthenticationData,
    List<TSWebAuthnAuthenticationOptions> options,
  ) {
    return FlutterTsAuthenticationPlatform.instance.approvalWebAuthnWithData(
      rawAuthenticationData,
      options,
    );
  }

  Future<TSBiometricsAuthenticationResult> approvalNativeBiometrics(
    String username,
    String challenge,
  ) {
    return FlutterTsAuthenticationPlatform.instance.approvalNativeBiometrics(
      username,
      challenge,
    );
  }

  Future<DeviceInfo> getDeviceInfo() {
    return FlutterTsAuthenticationPlatform.instance.getDeviceInfo();
  }

  Future<bool> isWebAuthnSupported() {
    return FlutterTsAuthenticationPlatform.instance.isWebAuthnSupported();
  }

  Future<bool> setLoggingEnabled(bool enabled) {
    return FlutterTsAuthenticationPlatform.instance.setLoggingEnabled(enabled);
  }

  Future<TSTOTPRegistrationCompletion> registerTOTP(
    String uri,
    TSTOTPSecurityType securityType,
  ) {
    return FlutterTsAuthenticationPlatform.instance.registerTOTP(
      uri,
      securityType,
    );
  }

  Future<TSTOTPGenerateCodeCompletion> generateTOTPCode(String uuid) {
    return FlutterTsAuthenticationPlatform.instance.generateTOTPCode(uuid);
  }

  Future<TSTOTPGenerateCodeCompletion> generateTOTPCodeWithChallenge(
    String uuid,
    String challenge,
  ) {
    return FlutterTsAuthenticationPlatform.instance
        .generateTOTPCodeWithChallenge(uuid, challenge);
  }

  Future<TSSignChallengeResult> signWithDeviceKey(String challenge) {
    return FlutterTsAuthenticationPlatform.instance.signWithDeviceKey(
      challenge,
    );
  }
}
