import Flutter
import UIKit
import TSAuthenticationSDK

enum AuthenticationPluginError: String {
    case invalidArguments
    case sdkInitError
    case pinCode
    case commitRegistration
    case nativeBioMetrics
    case webAuthn
    case deviceInfo
    case totp
    case signWithDeviceKey
}

public class FlutterTsAuthenticationPlugin: NSObject, FlutterPlugin {
    
    private var contextStore: [String: AnyObject] = [:]
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_ts_authentication", binaryMessenger: registrar.messenger())
        let instance = FlutterTsAuthenticationPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    // MARK: - Incoming Function Call Handler
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initializeSDK":
            handleInitializeSDK(call: call, result: result)
        case "initialize":
            handleInitialize(call: call, result: result)
        case "registerPinCode":
            handleRegisterPinCode(call: call, result: result)
        case "commitPinRegistration":
            handleCommitPinRegistration(call: call, result: result)
        case "authenticatePinCode":
            handleAuthenticatePinCode(call: call, result: result)
        case "registerNativeBiometrics":
            handleRegisterNativeBiometrics(call: call, result: result)
        case "unregisterNativeBiometrics":
            handleUnregisterNativeBiometrics(call: call, result: result)
        case "authenticateNativeBiometrics":
            handleAuthenticateNativeBiometrics(call: call, result: result)
        case "registerWebAuthn":
            handleRegisterWebAuthn(call: call, result: result)
        case "authenticateWebAuthn":
            handleAuthenticateWebAuthn(call: call, result: result)
        case "signWebauthnTransaction":
            handleSignWebauthnTransaction(call: call, result: result)
        case "approvalWebAuthn":
            handleApprovalWebAuthn(call: call, result: result)
        case "approvalWebAuthnWithData":
            handleApprovalWebAuthnWithData(call: call, result: result)
        case "approvalNativeBiometrics":
            handleApprovalNativeBiometrics(call: call, result: result)
        case "getDeviceInfo":
            handleGetDeviceInfo(call: call, result: result)
        case "isWebAuthnSupported":
            handleIsWebAuthnSupported(call: call, result: result)
        case "setLoggingEnabled":
            handleSetLoggingEnabled(call: call, result: result)
        case "registerTOTP":
            handleRegisterTOTP(call: call, result: result)
        case "generateTOTPCode":
            handleGenerateTOTPCode(call: call, result: result)
        case "generateTOTPCodeWithChallenge":
            handleGenerateTOTPCodeWithChallenge(call: call, result: result)
        case "signWithDeviceKey":
            handleSignWithDeviceKey(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - API Implementation | Initializ SDK
    
    private func handleInitializeSDK(call: FlutterMethodCall, result: @escaping FlutterResult) {
        do {
            let arguments = call.arguments as? [String: Any]
            let configurationFile = arguments?["configurationFile"] as? String
            
            if let configurationFile = configurationFile, !configurationFile.isEmpty {
                let configuration = TSAuthenticationConfiguration(configurationFileName: configurationFile)
                try? TSAuthentication.shared.initializeSDK(configuration: configuration)
            } else {
                try? TSAuthentication.shared.initializeSDK()
            }
            result(true)
        } catch {
            result(FlutterError(
                code: AuthenticationPluginError.sdkInitError.rawValue,
                message: "Error initializing the SDK",
                details: error.localizedDescription
            ))
        }
    }
    
    private func handleInitialize(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let clientId = arguments["clientId"] as? String else {
            result(FlutterError(
                code: AuthenticationPluginError.invalidArguments.rawValue,
                message: "Error initializing the SDK - missing clientId",
                details: nil
            ))
            return
        }
        
        let baseUrl = arguments["baseUrl"] as? String ?? "https://api.transmitsecurity.io"
        let domain = arguments["domain"] as? String
        
        var initOptions: TSAuthenticationSDK.TSAuthenticationInitOptions?
        
        // Handle optional initOptions
        if let initOptionsDict = arguments["initOptions"] as? [String: Any],
           let webAuthnInitOptionsDict = initOptionsDict["webAuthnInitOptions"] as? [String: Any] {
            
            if let startAuthentication = webAuthnInitOptionsDict["startAuthentication"] as? String,
               let startRegistration = webAuthnInitOptionsDict["startRegistration"] as? String {
                
                let webAuthnOptions = TSAuthenticationSDK.WebAuthnApis(
                    startAuthentication: startAuthentication,
                    startRegistration: startRegistration
                )
                
                initOptions = TSAuthenticationSDK.TSAuthenticationInitOptions(
                    webAuthnApiPaths: webAuthnOptions
                )
            }
        }
        
        do {
            TSAuthentication.shared.initialize(
                baseUrl: baseUrl,
                clientId: clientId,
                domain: domain,
                initOptions: initOptions
            )
            result(true)
        } catch {
            result(FlutterError(
                code: AuthenticationPluginError.sdkInitError.rawValue,
                message: "Error initializing the SDK",
                details: error.localizedDescription
            ))
        }
    }
    
    // MARK: - Authentication PIN Code
    
    private func handleRegisterPinCode(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let username = arguments["username"] as? String,
              let pinCode = arguments["pinCode"] as? String else {
            result(FlutterError(
                code: AuthenticationPluginError.invalidArguments.rawValue,
                message: "Missing username or pinCode",
                details: nil
            ))
            return
        }
        
        TSAuthentication.shared.registerPinCode(username: username, pinCode: pinCode) { [weak self] results in
            guard let self = self else { return }
            
            switch results {
            case .success(let response):
                let identifier = self.generateContextIdentifier()
                self.storeContextWithIdentifier(identifier, context: response.registrationContext)
                
                result([
                    "publicKeyId": response.publicKeyId,
                    "publicKey": response.publicKey,
                    "keyType": response.keyType,
                    "contextIdentifier": identifier
                ])
                
            case .failure(let error):
                result(FlutterError(
                    code: AuthenticationPluginError.pinCode.rawValue,
                    message: "Error registering pin code",
                    details: error.localizedDescription
                ))
            }
        }
    }
    
    private func handleCommitPinRegistration(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let contextIdentifier = arguments["contextIdentifier"] as? String,
              !contextIdentifier.isEmpty else {
            result(FlutterError(
                code: AuthenticationPluginError.invalidArguments.rawValue,
                message: "Missing contextIdentifier",
                details: nil
            ))
            return
        }
        
        guard var pinRegistrationContext = getContextWithIdentifier(contextIdentifier) as? TSAuthenticationSDK.TSRegistrationContext else {
            result(FlutterError(
                code: AuthenticationPluginError.invalidArguments.rawValue,
                message: "Invalid contextIdentifier argument",
                details: "Unable to find PIN registration context with provided contextIdentifier: \(contextIdentifier)"
            ))
            return
        }
        
        removeContextWithIdentifier(contextIdentifier)
        
        do {
            try pinRegistrationContext.commit()
            result(nil)
        } catch {
            result(FlutterError(
                code: AuthenticationPluginError.commitRegistration.rawValue,
                message: "Error during inRegistrationContext.commit()",
                details: error.localizedDescription
            ))
        }
    }
    
    // MARK: - Pin Code Authentication
    
    private func handleAuthenticatePinCode(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let username = arguments["username"] as? String,
              let pinCode = arguments["pinCode"] as? String,
              let challenge = arguments["challenge"] as? String else {
            result(FlutterError(
                code: AuthenticationPluginError.invalidArguments.rawValue,
                message: "Missing username, pinCode, or challenge",
                details: nil
            ))
            return
        }
        
        TSAuthentication.shared.authenticatePinCode(
            username: username,
            pinCode: pinCode,
            challenge: challenge
        ) { [weak self] authenticatePinCodeResponse in
            guard let self = self else { return }
            
            switch authenticatePinCodeResponse {
            case .success(let response):
                result([
                    "publicKeyId": response.publicKeyId,
                    "signature": response.signature,
                    "challenge": response.challenge
                ])
            case .failure(let error):
                result(FlutterError(
                    code: AuthenticationPluginError.pinCode.rawValue,
                    message: "Error during pin code authentication",
                    details: error.localizedDescription
                ))
            }
        }
    }
    
    // MARK: - WebAuthn
    
    private func handleRegisterWebAuthn(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let username = arguments["username"] as? String,
              let displayName = arguments["displayName"] as? String else {
            result(FlutterError(
                code: AuthenticationPluginError.invalidArguments.rawValue,
                message: "Missing username or displayName",
                details: nil
            ))
            return
        }
        
        TSAuthentication.shared.registerWebAuthn(
            username: username,
            displayName: displayName) { [weak self] registrationResults in
                guard let self = self else { return }
                switch registrationResults {
                case .success(let response):
                    result(["result": response.result])
                case .failure(let error):
                    result(FlutterError(
                        code: AuthenticationPluginError.webAuthn.rawValue,
                        message: "Missing username or displayName",
                        details: error.localizedDescription
                    ))
                }
            }
    }
    
    // MARK: - WebAuthn Authentication
    
    private func handleAuthenticateWebAuthn(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let username = arguments["username"] as? String else {
            result(FlutterError(
                code: AuthenticationPluginError.invalidArguments.rawValue,
                message: "Missing username",
                details: nil
            ))
            return
        }
        
        TSAuthentication.shared.authenticateWebAuthn(username: username) { [weak self] results in
            guard let self = self else { return }
            
            switch results {
            case .success(let response):
                result(["result": response.result])
            case .failure(let error):
                result(FlutterError(
                    code: AuthenticationPluginError.webAuthn.rawValue,
                    message: "Error authenticating using WebAuthn",
                    details: error.localizedDescription
                ))
            }
        }
    }
    
    // MARK: - WebAuthn Transaction Signing
    
    private func handleSignWebauthnTransaction(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let username = arguments["username"] as? String else {
            result(FlutterError(
                code: AuthenticationPluginError.invalidArguments.rawValue,
                message: "Missing username",
                details: nil
            ))
            return
        }
        
        TSAuthentication.shared.signWebauthnTransaction(username: username) { [weak self] results in
            guard let self = self else { return }
            
            switch results {
            case .success(let response):
                result(["result": response.result])
            case .failure(let error):
                result(FlutterError(
                    code: AuthenticationPluginError.webAuthn.rawValue,
                    message: "Error signing transaction using WebAuthn",
                    details: error.localizedDescription
                ))
            }
        }
    }
    
    // MARK: - Native Biometrics
    
    private func handleRegisterNativeBiometrics(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let username = arguments["username"] as? String else {
            result(FlutterError(
                code: AuthenticationPluginError.invalidArguments.rawValue,
                message: "Missing username",
                details: nil
            ))
            return
        }
        
        TSAuthentication.shared.registerNativeBiometrics(username: username) { [weak self] results in
            guard let self = self else { return }
            
            switch results {
            case .success(let response):
                let publicKey = response.publicKey
                let publicKeyId = response.publicKeyId
                
                result([
                    "publicKey": publicKey,
                    "publicKeyId": publicKeyId,
                    "os": "iOS",
                    "keyType": response.keyType,
                    "attestation": response.attestation as Any?
                ])
            case .failure(let error):
                result(FlutterError(
                    code: AuthenticationPluginError.nativeBioMetrics.rawValue,
                    message: "Error registering native biometrics",
                    details: error.localizedDescription
                ))
            }
        }
    }
    
    // MARK: - API Implementation | Unregister Native Biometrics
    
    private func handleUnregisterNativeBiometrics(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let userId = arguments["userId"] as? String else {
            result(FlutterError(
                code: AuthenticationPluginError.invalidArguments.rawValue,
                message: "Missing userId parameter",
                details: nil
            ))
            return
        }
        
        TSAuthentication.shared.unregistersNativeBiometrics(username: userId) { response in
            switch response {
            case .success(let response):
                let publicKeyId = response.publicKeyId
                result([
                    "publicKeyId": publicKeyId
                ])
            case .failure(let error):
                result(FlutterError(
                    code: AuthenticationPluginError.nativeBioMetrics.rawValue,
                    message: "Error unregistering native biometrics",
                    details: error.localizedDescription
                ))
            }
        }
    }
    
    // MARK: - Native Biometrics Authentication
    
    private func handleAuthenticateNativeBiometrics(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let username = arguments["username"] as? String,
              let challenge = arguments["challenge"] as? String else {
            result(FlutterError(
                code: AuthenticationPluginError.invalidArguments.rawValue,
                message: "Missing username or challenge",
                details: nil
            ))
            return
        }
        
        TSAuthentication.shared.authenticateNativeBiometrics(
            username: username, challenge: challenge
        ) { [weak self] authenticationResults in
            guard let self = self else { return }
            
            switch authenticationResults {
            case .success(let response):
                let publicKeyId = response.publicKeyId
                let signature = response.signature
                result([
                    "publicKeyId": publicKeyId,
                    "signature": signature
                ])
            case .failure(let error):
                result(FlutterError(
                    code: AuthenticationPluginError.nativeBioMetrics.rawValue,
                    message: "Error authenticating using native biometrics",
                    details: error.localizedDescription
                ))
            }
        }
    }
    
    // MARK: - WebAuthn Approval
    
    private func handleApprovalWebAuthn(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let approvalData = arguments["approvalData"] as? [String: String],
              let options = arguments["options"] as? [String] else {
            result(FlutterError(
                code: AuthenticationPluginError.invalidArguments.rawValue,
                message: "Missing approvalData or options",
                details: nil
            ))
            return
        }
        
        let username = arguments["username"] as? String
        
        TSAuthentication.shared.approvalWebAuthn(approvalData: approvalData, username: username, options: self.convertWebAuthnOptions(options)) { [weak self] approvalResults in
            guard let self = self else { return }
            
            switch approvalResults {
            case .success(let approvalResult):
                result([
                    "result": approvalResult.result
                ])
            case .failure(let error):
                result(FlutterError(
                    code: AuthenticationPluginError.webAuthn.rawValue,
                    message: "Error during approvalWebAuthn",
                    details: error.localizedDescription
                ))
            }
        }
    }
    
    // MARK: - WebAuthn Approval With Data
    
    private func handleApprovalWebAuthnWithData(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let rawAuthenticationData = arguments["rawAuthenticationData"] as? [String: AnyHashable],
              let options = arguments["options"] as? [String] else {
            result(FlutterError(
                code: AuthenticationPluginError.invalidArguments.rawValue,
                message: "Missing rawAuthenticationData or options",
                details: nil
            ))
            return
        }
        
        guard let authenticationData = convertWebAuthnAuthenticationData(rawAuthenticationData) else {
            result(FlutterError(
                code: AuthenticationPluginError.invalidArguments.rawValue,
                message: "Invalid rawAuthenticationData",
                details: nil
            ))
            return
        }
        
        TSAuthentication.shared.approvalWebAuthn(
            authenticationData,
            options: self.convertWebAuthnOptions(options)
        ) { [weak self] approvalResults in
            guard let self = self else { return }
            
            switch approvalResults {
            case .success(let approvalResult):
                result([
                    "result": approvalResult.result
                ])
            case .failure(let error):
                result(FlutterError(
                    code: AuthenticationPluginError.webAuthn.rawValue,
                    message: "Error during approvalWebAuthnWithData",
                    details: error.localizedDescription
                ))
            }
        }
    }
    
    // MARK: - Native Biometrics Approval
    
    private func handleApprovalNativeBiometrics(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let username = arguments["username"] as? String,
              let challenge = arguments["challenge"] as? String else {
            result(FlutterError(
                code: AuthenticationPluginError.invalidArguments.rawValue,
                message: "Missing username or challenge",
                details: nil
            ))
            return
        }
        
        TSAuthentication.shared.approvalNativeBiometrics(
            username: username,
            challenge: challenge
        )  { [weak self] approvalResults in
            guard let self = self else { return }
            
            switch approvalResults {
            case .success(let approvalResult):
                result([
                    "publicKeyId": approvalResult.publicKeyId,
                    "signature": approvalResult.signature
                ])
            case .failure(let error):
                result(FlutterError(
                    code: AuthenticationPluginError.nativeBioMetrics.rawValue,
                    message: "Error during approvalNativeBiometrics",
                    details: error.localizedDescription
                ))
            }
        }
    }
    
    // MARK: - Device Info
    
    private func handleGetDeviceInfo(call: FlutterMethodCall, result: @escaping FlutterResult) {
        TSAuthentication.shared.getDeviceInfo() { [weak self] deviceInfo in
            guard let self = self else { return }
            
            switch deviceInfo {
            case .success(let response):
                let info = [
                    "publicKeyId": response.publicKeyId,
                    "publicKey": response.publicKey
                ]
                result(info)
            case .failure(let error):
                result(FlutterError(
                    code: AuthenticationPluginError.deviceInfo.rawValue,
                    message: "Error during getDeviceInfo",
                    details: error.localizedDescription
                ))
            }
        }
    }
    
    // MARK: - WebAuthn Support
    
    private func handleIsWebAuthnSupported(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let isSupported = TSAuthentication.isWebAuthnSupported()
        result(isSupported)
    }
    
    // MARK: - API Implementation | Set Logging Enabled
    
    private func handleSetLoggingEnabled(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let enabled = arguments["enabled"] as? Bool else {
            result(FlutterError(
                code: AuthenticationPluginError.invalidArguments.rawValue,
                message: "Missing enabled parameter - must be true or false",
                details: nil
            ))
            return
        }
        
        if enabled {
            TSAuthentication.setLogLevel(.debug)
        } else {
            TSAuthentication.setLogLevel(.off)
        }
        result(true)
    }
    
    // MARK: - API Implementation | Register TOTP
    
    private func handleRegisterTOTP(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let uri = arguments["uri"] as? String,
              let securityTypeString = arguments["securityType"] as? String else {
            result(FlutterError(
                code: AuthenticationPluginError.invalidArguments.rawValue,
                message: "Missing uri or securityType parameters",
                details: nil
            ))
            return
        }
        
        let securityType: TSAuthenticationSDK.TSTOTPSecurityType = (securityTypeString == "none") ? .none : .biometric
                
        TSAuthentication.shared.registerTOTP(
            URI: uri,
            securityType: securityType) { totpRegistrationResults in
                switch totpRegistrationResults {
                case .success(let response):
                    let info = [
                        "issuer": response.issuer,
                        "label": response.label,
                        "uuid": response.uuid
                    ]
                    result(info)
                case .failure(let error):
                    result(FlutterError(
                        code: AuthenticationPluginError.totp.rawValue,
                        message: "Error during register TOTP",
                        details: error.localizedDescription
                    ))
                }
            }
    }
    
    // MARK: - API Implementation | Generate TOTP Code
    
    private func handleGenerateTOTPCode(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let uuid = arguments["uuid"] as? String else {
            result(FlutterError(
                code: AuthenticationPluginError.invalidArguments.rawValue,
                message: "Missing uuid parameter",
                details: nil
            ))
            return
        }
        
        TSAuthentication.shared.generateTOTPCode(UUID: uuid) { generateTOTPResponse in
            switch generateTOTPResponse {
            case .success(let response):
                let resultsMap = [
                    "code": response.code
                ]
                result(resultsMap)
            case .failure(let error):
                result(FlutterError(
                    code: AuthenticationPluginError.totp.rawValue,
                    message: "Error during generateTOTPCode",
                    details: error.localizedDescription
                ))
            }
        }
    }
    
    // MARK: - API Implementation | Generate TOTP Code With Challenge
    
    private func handleGenerateTOTPCodeWithChallenge(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let uuid = arguments["uuid"] as? String,
              let challenge = arguments["challenge"] as? String else {
            result(FlutterError(
                code: AuthenticationPluginError.invalidArguments.rawValue,
                message: "Missing uuid or challenge parameters",
                details: nil
            ))
            return
        }
        
        TSAuthentication.shared.generateTOTPCodeWithChallenge(UUID: uuid, challenge: challenge) { generateTOTPResponse in
            switch generateTOTPResponse {
            case .success(let response):
                let resultsMap = [
                    "code": response.code
                ]
                result(resultsMap)
            case .failure(let error):
                result(FlutterError(
                    code: AuthenticationPluginError.totp.rawValue,
                    message: "Error during generateTOTPCodeWithChallenge",
                    details: error.localizedDescription
                ))
            }
        }
    }
    
    // MARK: - Sign With Device Key
    
    private func handleSignWithDeviceKey(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let challenge = arguments["challenge"] as? String else {
            result(FlutterError(
                code: AuthenticationPluginError.invalidArguments.rawValue,
                message: "Missing challenge parameter",
                details: nil
            ))
            return
        }
        
        TSAuthentication.shared.signWithDeviceKey(challenge: challenge) { signWithDeviceKeyResults in
            switch signWithDeviceKeyResults {
            case .success(let response):
                let resultsMap = [
                    "signature": response.signature
                ]
                result(resultsMap)
            case .failure(let error):
                result(FlutterError(
                    code: AuthenticationPluginError.signWithDeviceKey.rawValue,
                    message: "Error during signWithDeviceKey",
                    details: error.localizedDescription
                ))
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func convertWebAuthnOptions(_ rawOptions: [String]) -> TSAuthenticationSDK.TSAuthentication.WebAuthnAuthenticationOptions {
        var options: TSAuthenticationSDK.TSAuthentication.WebAuthnAuthenticationOptions = []
        // TODO: Consult SDK developer regarding this parameter
        return options
    }
    
    private func convertWebAuthnAuthenticationData(_ rawData: [String: AnyHashable]) -> TSAuthenticationSDK.TSWebAuthnAuthenticationData? {
        guard let credentialRequestOptions = rawData["credentialRequestOptions"] as? [String: AnyHashable],
              let webauthnSessionId = rawData["webauthnSessionId"] as? String else {
            return nil
        }
        
        let rawUserData: [String: AnyHashable]? = credentialRequestOptions["userData"] as? [String: AnyHashable]
        
        let userData = TSAuthenticationSDK.TSWebAuthnUserData(
            id: rawUserData?["id"] as? String,
            name: rawUserData?["name"] as? String,
            displayName: rawUserData?["displayName"] as? String
        )
        
        let optionsData = TSWebAuthnAuthenticationCredentialRequestOptionsData(
            challenge: credentialRequestOptions["challenge"] as? String,
            allowCredentials: convertAllowCredentials(credentialRequestOptions),
            userVerification: credentialRequestOptions["userVerification"] as? String,
            rpId: credentialRequestOptions["rpId"] as? String,
            user: userData
        )
        
        let authenticationData = TSAuthenticationSDK.TSWebAuthnAuthenticationData(
            webauthnSessionId: webauthnSessionId,
            credentialRequestOptions: optionsData
        )
        
        return authenticationData
    }
    
    private func convertAllowCredentials(_ credentialRequestOptions: [String: AnyHashable]) -> [TSWebAuthnAllowCredentialsData]? {
        guard let allowCredentialsArray = credentialRequestOptions["allowCredentials"] as? [[String: AnyHashable]] else {
            return nil
        }
        
        return allowCredentialsArray.map { rawAllowCredential in
            TSWebAuthnAllowCredentialsData(
                id: rawAllowCredential["id"] as? String,
                name: rawAllowCredential["name"] as? String,
                displayName: rawAllowCredential["displayName"] as? String
            )}
    }
    
    private func generateContextIdentifier() -> String {
        return UUID().uuidString
    }
    
    private func storeContextWithIdentifier(_ identifier: String, context: AnyObject) {
      contextStore[identifier] = context
    }
    
    private func removeContextWithIdentifier(_ identifier: String) {
      contextStore[identifier] = nil
    }
    
    private func getContextWithIdentifier(_ identifier: String) -> AnyObject? {
      return contextStore[identifier] as AnyObject?
    }
}
