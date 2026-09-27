import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_ts_authentication_platform_interface.dart';
import 'flutter_ts_authentication.dart';

/// An implementation of [FlutterTsAuthenticationPlatform] that uses method channels.
class MethodChannelFlutterTsAuthentication
    extends FlutterTsAuthenticationPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_ts_authentication');

  @override
  Future<void> initializeSDK() async {
    await methodChannel.invokeMethod<void>('initializeSDK');
  }

  @override
  Future<void> initialize(
    String clientId,
    String domain,
    String baseUrl,
    TSInitOptions? initOptions,
  ) async {
    await methodChannel.invokeMethod<void>('initialize', {
      'clientId': clientId,
      'domain': domain,
      'baseUrl': baseUrl,
      'initOptions': initOptions?.toMap(),
    });
  }

  @override
  Future<TSPinCodeRegistrationCompletion> registerPinCode(
    String username,
    String pinCode,
  ) async {
    final result = await methodChannel.invokeMethod('registerPinCode', {
      'username': username,
      'pinCode': pinCode,
    });

    if (result == null) {
      throw PlatformException(
        code: 'NULL_RESULT',
        message: 'registerPinCode returned null',
      );
    }

    // Convert the result to Map<String, dynamic>
    final Map<String, dynamic> resultMap = Map<String, dynamic>.from(
      result as Map,
    );

    return TSPinCodeRegistrationCompletion.fromMap(resultMap);
  }

  @override
  Future<void> commitPinRegistration(String contextIdentifier) async {
    await methodChannel.invokeMethod<void>('commitPinRegistration', {
      'contextIdentifier': contextIdentifier,
    });
  }

  @override
  Future<TSPinCodeAuthenticationCompletion> authenticatePinCode(
    String username,
    String pinCode,
    String challenge,
  ) async {
    final result = await methodChannel.invokeMethod('authenticatePinCode', {
      'username': username,
      'pinCode': pinCode,
      'challenge': challenge,
    });

    if (result == null) {
      throw PlatformException(
        code: 'NULL_RESULT',
        message: 'authenticatePinCode returned null',
      );
    }

    // Convert the result to Map<String, dynamic>
    final Map<String, dynamic> resultMap = Map<String, dynamic>.from(
      result as Map,
    );

    return TSPinCodeAuthenticationCompletion.fromMap(resultMap);
  }

  @override
  Future<TSPinCodeUnregistrationCompletion> unregisterPinCode(
    String username,
  ) async {
    final result = await methodChannel.invokeMethod('unregisterPinCode', {
      'username': username,
    });

    if (result == null) {
      throw PlatformException(
        code: 'NULL_RESULT',
        message: 'unregisterPinCode returned null',
      );
    }

    // Convert the result to Map<String, dynamic>
    final Map<String, dynamic> resultMap = Map<String, dynamic>.from(
      result as Map,
    );

    return TSPinCodeUnregistrationCompletion.fromMap(resultMap);
  }

  @override
  Future<void> commitPinUnregistration(String contextIdentifier) async {
    await methodChannel.invokeMethod<void>('commitPinUnregistration', {
      'contextIdentifier': contextIdentifier,
    });
  }

  @override
  Future<TSBiometricsStatus> nativeBiometricsStatus() async {
    final result = await methodChannel.invokeMethod<String>(
      'nativeBiometricsStatus',
    );

    if (result == null) {
      throw PlatformException(
        code: 'NULL_RESULT',
        message: 'nativeBiometricsStatus returned null',
      );
    }

    return TSBiometricsStatus.fromName(result);
  }

  @override
  Future<TSBiometricsType> nativeBiometricsType() async {
    final result = await methodChannel.invokeMethod<String>(
      'nativeBiometricsType',
    );

    if (result == null) {
      throw PlatformException(
        code: 'NULL_RESULT',
        message: 'nativeBiometricsType returned null',
      );
    }

    return TSBiometricsType.fromName(result);
  }

  @override
  Future<TSBiometricsRegistrationResult> registerNativeBiometrics(
    String username,
  ) async {
    final result = await methodChannel.invokeMethod(
      'registerNativeBiometrics',
      {'username': username},
    );

    if (result == null) {
      throw PlatformException(
        code: 'NULL_RESULT',
        message: 'registerNativeBiometrics returned null',
      );
    }

    // Convert the result to Map<String, dynamic>
    final Map<String, dynamic> resultMap = Map<String, dynamic>.from(
      result as Map,
    );

    return TSBiometricsRegistrationResult.fromMap(resultMap);
  }

  @override
  Future<TSNativeBiometricsUnregisterResult> unregisterNativeBiometrics(
    String userId,
  ) async {
    final result = await methodChannel.invokeMethod(
      'unregisterNativeBiometrics',
      {'userId': userId},
    );

    if (result == null) {
      throw PlatformException(
        code: 'NULL_RESULT',
        message: 'unregisterNativeBiometrics returned null',
      );
    }

    // Convert the result to Map<String, dynamic>
    final Map<String, dynamic> resultMap = Map<String, dynamic>.from(result);
    return TSNativeBiometricsUnregisterResult.fromMap(resultMap);
  }

  @override
  Future<TSWebAuthnRegistrationResults> registerWebAuthn(
    String username,
    String displayName,
  ) async {
    final result = await methodChannel.invokeMethod('registerWebAuthn', {
      'username': username,
      'displayName': displayName,
    });

    if (result == null) {
      throw PlatformException(
        code: 'NULL_RESULT',
        message: 'registerWebAuthn returned null',
      );
    }

    // Convert the result to Map<String, dynamic>
    final Map<String, dynamic> resultMap = Map<String, dynamic>.from(
      result as Map,
    );

    return TSWebAuthnRegistrationResults.fromMap(resultMap);
  }

  @override
  Future<TSWebAuthnAuthenticationResults> authenticateWebAuthn(
    String username,
  ) async {
    final result = await methodChannel.invokeMethod('authenticateWebAuthn', {
      'username': username,
    });

    if (result == null) {
      throw PlatformException(
        code: 'NULL_RESULT',
        message: 'authenticateWebAuthn returned null',
      );
    }

    // Convert the result to Map<String, dynamic>
    final Map<String, dynamic> resultMap = Map<String, dynamic>.from(
      result as Map,
    );

    return TSWebAuthnAuthenticationResults.fromMap(resultMap);
  }

  @override
  Future<TSWebAuthnAuthenticationResults> signWebauthnTransaction(
    String username,
  ) async {
    final result = await methodChannel.invokeMethod('signWebauthnTransaction', {
      'username': username,
    });

    if (result == null) {
      throw PlatformException(
        code: 'NULL_RESULT',
        message: 'signWebauthnTransaction returned null',
      );
    }

    // Convert the result to Map<String, dynamic>
    final Map<String, dynamic> resultMap = Map<String, dynamic>.from(
      result as Map,
    );

    return TSWebAuthnAuthenticationResults.fromMap(resultMap);
  }

  @override
  Future<TSWebAuthnRegistrationResults> registerWebAuthnWithData(
    TSWebAuthnRegistrationData rawRegistrationData,
  ) async {
    final result = await methodChannel.invokeMethod(
      'registerWebAuthnWithData',
      {'rawRegistrationData': rawRegistrationData.toMap()},
    );

    if (result == null) {
      throw PlatformException(
        code: 'NULL_RESULT',
        message: 'registerWebAuthnWithData returned null',
      );
    }

    // Convert the result to Map<String, dynamic>
    final Map<String, dynamic> resultMap = Map<String, dynamic>.from(
      result as Map,
    );

    return TSWebAuthnRegistrationResults.fromMap(resultMap);
  }

  @override
  Future<TSWebAuthnAuthenticationResults> authenticateWebAuthnWithData(
    TSWebAuthnAuthenticationData rawAuthenticationData,
    List<TSWebAuthnAuthenticationOptions> options,
  ) async {
    final result = await methodChannel.invokeMethod(
      'authenticateWebAuthnWithData',
      {
        'rawAuthenticationData': rawAuthenticationData.toMap(),
        'options': options,
      },
    );

    if (result == null) {
      throw PlatformException(
        code: 'NULL_RESULT',
        message: 'authenticateWebAuthnWithData returned null',
      );
    }

    // Convert the result to Map<String, dynamic>
    final Map<String, dynamic> resultMap = Map<String, dynamic>.from(
      result as Map,
    );

    return TSWebAuthnAuthenticationResults.fromMap(resultMap);
  }

  @override
  Future<TSWebAuthnAuthenticationResults> signWebauthnTransactionWithData(
    TSWebAuthnAuthenticationData rawAuthenticationData,
    List<TSWebAuthnAuthenticationOptions> options,
  ) async {
    final result = await methodChannel.invokeMethod(
      'signWebauthnTransactionWithData',
      {
        'rawAuthenticationData': rawAuthenticationData.toMap(),
        'options': options,
      },
    );

    if (result == null) {
      throw PlatformException(
        code: 'NULL_RESULT',
        message: 'signWebauthnTransactionWithData returned null',
      );
    }

    // Convert the result to Map<String, dynamic>
    final Map<String, dynamic> resultMap = Map<String, dynamic>.from(
      result as Map,
    );

    return TSWebAuthnAuthenticationResults.fromMap(resultMap);
  }

  @override
  Future<TSBiometricsAuthenticationResult> authenticateNativeBiometrics(
    String username,
    String challenge,
  ) async {
    final result = await methodChannel.invokeMethod(
      'authenticateNativeBiometrics',
      {'username': username, 'challenge': challenge},
    );

    if (result == null) {
      throw PlatformException(
        code: 'NULL_RESULT',
        message: 'authenticateNativeBiometrics returned null',
      );
    }

    // Convert the result to Map<String, dynamic>
    final Map<String, dynamic> resultMap = Map<String, dynamic>.from(
      result as Map,
    );

    return TSBiometricsAuthenticationResult.fromMap(resultMap);
  }

  @override
  Future<TSApprovalResults> approvalWebAuthn(
    Map<String, String> approvalData,
    String? username,
    List<TSWebAuthnAuthenticationOptions> options,
  ) async {
    final result = await methodChannel.invokeMethod('approvalWebAuthn', {
      'approvalData': approvalData,
      'username': username,
      'options': options,
    });

    if (result == null) {
      throw PlatformException(
        code: 'NULL_RESULT',
        message: 'approvalWebAuthn returned null',
      );
    }

    // Convert the result to Map<String, dynamic>
    final Map<String, dynamic> resultMap = Map<String, dynamic>.from(
      result as Map,
    );

    return TSApprovalResults.fromMap(resultMap);
  }

  @override
  Future<TSApprovalResults> approvalWebAuthnWithData(
    TSWebAuthnAuthenticationData rawAuthenticationData,
    List<TSWebAuthnAuthenticationOptions> options,
  ) async {
    final result = await methodChannel.invokeMethod(
      'approvalWebAuthnWithData',
      {
        'rawAuthenticationData': rawAuthenticationData.toMap(),
        'options': options,
      },
    );

    if (result == null) {
      throw PlatformException(
        code: 'NULL_RESULT',
        message: 'approvalWebAuthnWithData returned null',
      );
    }

    // Convert the result to Map<String, dynamic>
    final Map<String, dynamic> resultMap = Map<String, dynamic>.from(
      result as Map,
    );

    return TSApprovalResults.fromMap(resultMap);
  }

  @override
  Future<TSBiometricsAuthenticationResult> approvalNativeBiometrics(
    String username,
    String challenge,
  ) async {
    final result = await methodChannel.invokeMethod(
      'approvalNativeBiometrics',
      {'username': username, 'challenge': challenge},
    );

    if (result == null) {
      throw PlatformException(
        code: 'NULL_RESULT',
        message: 'approvalNativeBiometrics returned null',
      );
    }

    // Convert the result to Map<String, dynamic>
    final Map<String, dynamic> resultMap = Map<String, dynamic>.from(
      result as Map,
    );

    return TSBiometricsAuthenticationResult.fromMap(resultMap);
  }

  @override
  Future<DeviceInfo> getDeviceInfo() async {
    final result = await methodChannel.invokeMethod('getDeviceInfo');

    if (result == null) {
      throw PlatformException(
        code: 'NULL_RESULT',
        message: 'getDeviceInfo returned null',
      );
    }

    // Convert the result to Map<String, dynamic>
    final Map<String, dynamic> resultMap = Map<String, dynamic>.from(
      result as Map,
    );

    return DeviceInfo.fromMap(resultMap);
  }

  @override
  Future<bool> isWebAuthnSupported() async {
    final result = await methodChannel.invokeMethod<bool>(
      'isWebAuthnSupported',
    );

    if (result == null) {
      throw PlatformException(
        code: 'NULL_RESULT',
        message: 'isWebAuthnSupported returned null',
      );
    }

    return result;
  }

  @override
  Future<bool> setLoggingEnabled(bool enabled) async {
    final result = await methodChannel.invokeMethod<bool>('setLoggingEnabled', {
      'enabled': enabled,
    });

    if (result == null) {
      throw PlatformException(
        code: 'NULL_RESULT',
        message: 'setLoggingEnabled returned null',
      );
    }

    return result;
  }

  @override
  Future<TSTOTPRegistrationCompletion> registerTOTP(
    String uri,
    TSTOTPSecurityType securityType,
  ) async {
    final result = await methodChannel.invokeMethod('registerTOTP', {
      'uri': uri,
      'securityType': securityType.name,
    });

    if (result == null) {
      throw PlatformException(
        code: 'NULL_RESULT',
        message: 'registerTOTP returned null',
      );
    }

    // Convert the result to Map<String, dynamic>
    final Map<String, dynamic> resultMap = Map<String, dynamic>.from(result);
    return TSTOTPRegistrationCompletion.fromMap(resultMap);
  }

  @override
  Future<TSTOTPGenerateCodeCompletion> generateTOTPCode(String uuid) async {
    final result = await methodChannel.invokeMethod('generateTOTPCode', {
      'uuid': uuid,
    });

    if (result == null) {
      throw PlatformException(
        code: 'NULL_RESULT',
        message: 'generateTOTPCode returned null',
      );
    }

    // Convert the result to Map<String, dynamic>
    final Map<String, dynamic> resultMap = Map<String, dynamic>.from(result);
    return TSTOTPGenerateCodeCompletion.fromMap(resultMap);
  }

  @override
  Future<TSTOTPGenerateCodeCompletion> generateTOTPCodeWithChallenge(
    String uuid,
    String challenge,
  ) async {
    final result = await methodChannel.invokeMethod(
      'generateTOTPCodeWithChallenge',
      {'uuid': uuid, 'challenge': challenge},
    );

    if (result == null) {
      throw PlatformException(
        code: 'NULL_RESULT',
        message: 'generateTOTPCodeWithChallenge returned null',
      );
    }

    // Convert the result to Map<String, dynamic>
    final Map<String, dynamic> resultMap = Map<String, dynamic>.from(result);
    return TSTOTPGenerateCodeCompletion.fromMap(resultMap);
  }

  @override
  Future<TSSignChallengeResult> signWithDeviceKey(String challenge) async {
    final result = await methodChannel.invokeMethod('signWithDeviceKey', {
      'challenge': challenge,
    });

    if (result == null) {
      throw PlatformException(
        code: 'NULL_RESULT',
        message: 'signWithDeviceKey returned null',
      );
    }

    // Convert the result to Map<String, dynamic>
    final Map<String, dynamic> resultMap = Map<String, dynamic>.from(result);
    return TSSignChallengeResult.fromMap(resultMap);
  }
}
