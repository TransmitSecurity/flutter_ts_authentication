import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_ts_authentication_method_channel.dart';
import 'flutter_ts_authentication.dart';

abstract class FlutterTsAuthenticationPlatform extends PlatformInterface {
  /// Constructs a FlutterTsAuthenticationPlatform.
  FlutterTsAuthenticationPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterTsAuthenticationPlatform _instance =
      MethodChannelFlutterTsAuthentication();

  /// The default instance of [FlutterTsAuthenticationPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterTsAuthentication].
  static FlutterTsAuthenticationPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterTsAuthenticationPlatform] when
  /// they register themselves.
  static set instance(FlutterTsAuthenticationPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> initializeSDK() {
    throw UnimplementedError('initializeSDK() has not been implemented.');
  }

  Future<void> initialize(
    String clientId,
    String domain,
    String baseUrl,
    TSInitOptions? initOptions,
  ) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  Future<TSPinCodeRegistrationCompletion> registerPinCode(
    String username,
    String pinCode,
  ) {
    throw UnimplementedError('registerPinCode() has not been implemented.');
  }

  Future<void> commitPinRegistration(String contextIdentifier) {
    throw UnimplementedError(
      'commitPinRegistration() has not been implemented.',
    );
  }

  Future<TSPinCodeAuthenticationCompletion> authenticatePinCode(
    String username,
    String pinCode,
    String challenge,
  ) {
    throw UnimplementedError('authenticatePinCode() has not been implemented.');
  }

  Future<TSPinCodeUnregistrationCompletion> unregisterPinCode(String username) {
    throw UnimplementedError('unregisterPinCode() has not been implemented.');
  }

  Future<void> commitPinUnregistration(String contextIdentifier) {
    throw UnimplementedError(
      'commitPinUnregistration() has not been implemented.',
    );
  }

  Future<TSBiometricsRegistrationResult> registerNativeBiometrics(
    String username,
  ) {
    throw UnimplementedError(
      'registerNativeBiometrics() has not been implemented.',
    );
  }

  Future<TSBiometricsStatus> nativeBiometricsStatus() {
    throw UnimplementedError(
      'nativeBiometricsStatus() has not been implemented.',
    );
  }

  Future<TSBiometricsType> nativeBiometricsType() {
    throw UnimplementedError(
      'nativeBiometricsType() has not been implemented.',
    );
  }

  Future<TSWebAuthnRegistrationResults> registerWebAuthnWithData(
    TSWebAuthnRegistrationData rawRegistrationData,
  ) {
    throw UnimplementedError(
      'registerWebAuthnWithData() has not been implemented.',
    );
  }

  Future<TSWebAuthnAuthenticationResults> authenticateWebAuthnWithData(
    TSWebAuthnAuthenticationData rawAuthenticationData,
    List<TSWebAuthnAuthenticationOptions> options,
  ) {
    throw UnimplementedError(
      'authenticateWebAuthnWithData() has not been implemented.',
    );
  }

  Future<TSWebAuthnAuthenticationResults> signWebauthnTransactionWithData(
    TSWebAuthnAuthenticationData rawAuthenticationData,
    List<TSWebAuthnAuthenticationOptions> options,
  ) {
    throw UnimplementedError(
      'signWebauthnTransactionWithData() has not been implemented.',
    );
  }

  Future<TSNativeBiometricsUnregisterResult> unregisterNativeBiometrics(
    String userId,
  ) {
    throw UnimplementedError(
      'unregisterNativeBiometrics() has not been implemented.',
    );
  }

  Future<TSWebAuthnRegistrationResults> registerWebAuthn(
    String username,
    String displayName,
  ) {
    throw UnimplementedError('registerWebAuthn() has not been implemented.');
  }

  Future<TSWebAuthnAuthenticationResults> authenticateWebAuthn(
    String username,
  ) {
    throw UnimplementedError(
      'authenticateWebAuthn() has not been implemented.',
    );
  }

  Future<TSWebAuthnAuthenticationResults> signWebauthnTransaction(
    String username,
  ) {
    throw UnimplementedError(
      'signWebauthnTransaction() has not been implemented.',
    );
  }

  Future<TSBiometricsAuthenticationResult> authenticateNativeBiometrics(
    String username,
    String challenge,
  ) {
    throw UnimplementedError(
      'authenticateNativeBiometrics() has not been implemented.',
    );
  }

  Future<TSApprovalResults> approvalWebAuthn(
    Map<String, String> approvalData,
    String? username,
    List<TSWebAuthnAuthenticationOptions> options,
  ) {
    throw UnimplementedError('approvalWebAuthn() has not been implemented.');
  }

  Future<TSApprovalResults> approvalWebAuthnWithData(
    TSWebAuthnAuthenticationData rawAuthenticationData,
    List<TSWebAuthnAuthenticationOptions> options,
  ) {
    throw UnimplementedError(
      'approvalWebAuthnWithData() has not been implemented.',
    );
  }

  Future<TSBiometricsAuthenticationResult> approvalNativeBiometrics(
    String username,
    String challenge,
  ) {
    throw UnimplementedError(
      'approvalNativeBiometrics() has not been implemented.',
    );
  }

  Future<DeviceInfo> getDeviceInfo() {
    throw UnimplementedError('getDeviceInfo() has not been implemented.');
  }

  Future<bool> isWebAuthnSupported() {
    throw UnimplementedError('isWebAuthnSupported() has not been implemented.');
  }

  Future<bool> setLoggingEnabled(bool enabled) {
    throw UnimplementedError('setLoggingEnabled() has not been implemented.');
  }

  Future<TSTOTPRegistrationCompletion> registerTOTP(
    String uri,
    TSTOTPSecurityType securityType,
  ) {
    throw UnimplementedError('registerTOTP() has not been implemented.');
  }

  Future<TSTOTPGenerateCodeCompletion> generateTOTPCode(String uuid) {
    throw UnimplementedError('generateTOTPCode() has not been implemented.');
  }

  Future<TSTOTPGenerateCodeCompletion> generateTOTPCodeWithChallenge(
    String uuid,
    String challenge,
  ) {
    throw UnimplementedError(
      'generateTOTPCodeWithChallenge() has not been implemented.',
    );
  }

  Future<TSSignChallengeResult> signWithDeviceKey(String challenge) {
    throw UnimplementedError('signWithDeviceKey() has not been implemented.');
  }
}
