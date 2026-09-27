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
        case "unregisterPinCode":
            handleUnregisterPinCode(call: call, result: result)
        case "commitPinUnregistration":
            handleCommitPinUnregistration(call: call, result: result)
        case "registerNativeBiometrics":
            handleRegisterNativeBiometrics(call: call, result: result)
        case "unregisterNativeBiometrics":
            handleUnregisterNativeBiometrics(call: call, result: result)
        case "authenticateNativeBiometrics":
            handleAuthenticateNativeBiometrics(call: call, result: result)
        case "nativeBiometricsStatus":
            handleNativeBiometricsStatus(call: call, result: result)
        case "nativeBiometricsType":
            handleNativeBiometricsType(call: call, result: result)
        case "registerWebAuthn":
            handleRegisterWebAuthn(call: call, result: result)
        case "registerWebAuthnWithData":
            handleRegisterWebAuthnWithData(call: call, result: result)
        case "authenticateWebAuthn":
            handleAuthenticateWebAuthn(call: call, result: result)
        case "authenticateWebAuthnWithData":
            handleAuthenticateWebAuthnWithData(call: call, result: result)
        case "signWebauthnTransaction":
            handleSignWebauthnTransaction(call: call, result: result)
        case "signWebauthnTransactionWithData":
            handleSignWebauthnTransactionWithData(call: call, result: result)
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
                details: pluginErrorDetails(error)
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
        // An empty domain means "not configured" — map it to nil, matching Android. Native declares
        // `domain: String? = nil`, so "" would arrive as a present-but-invalid origin (the SDK
        // expects scheme + host, e.g. "https://example.com") rather than as an absent value.
        let domain = (arguments["domain"] as? String).flatMap { $0.isEmpty ? nil : $0 }
        
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
                details: pluginErrorDetails(error)
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
                    details: pluginErrorDetails(error)
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
                details: pluginErrorDetails(error)
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
                    details: pluginErrorDetails(error)
                ))
            }
        }
    }
    
    // MARK: - Pin Code Unregistration

    private func handleUnregisterPinCode(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let username = arguments["username"] as? String else {
            result(FlutterError(
                code: AuthenticationPluginError.invalidArguments.rawValue,
                message: "Missing username",
                details: nil
            ))
            return
        }

        TSAuthentication.shared.unregisterPinCode(username: username) { [weak self] results in
            guard let self = self else { return }

            switch results {
            case .success(let response):
                let identifier = self.generateContextIdentifier()
                self.storeContextWithIdentifier(identifier, context: response.unregistrationContext)

                result([
                    "publicKeyId": response.publicKeyId,
                    "contextIdentifier": identifier
                ])
            case .failure(let error):
                result(FlutterError(
                    code: AuthenticationPluginError.pinCode.rawValue,
                    message: "Error unregistering pin code",
                    details: pluginErrorDetails(error)
                ))
            }
        }
    }

    private func handleCommitPinUnregistration(call: FlutterMethodCall, result: @escaping FlutterResult) {
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

        guard var unregistrationContext = getContextWithIdentifier(contextIdentifier) as? TSAuthenticationSDK.TSRegistrationContext else {
            result(FlutterError(
                code: AuthenticationPluginError.invalidArguments.rawValue,
                message: "Invalid contextIdentifier argument",
                details: "Unable to find PIN unregistration context with provided contextIdentifier: \(contextIdentifier)"
            ))
            return
        }

        removeContextWithIdentifier(contextIdentifier)

        do {
            try unregistrationContext.commit()
            result(nil)
        } catch {
            result(FlutterError(
                code: AuthenticationPluginError.commitRegistration.rawValue,
                message: "Error during unregistrationContext.commit()",
                details: pluginErrorDetails(error)
            ))
        }
    }

    // MARK: - Native Biometrics Availability

    private func handleNativeBiometricsStatus(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(pluginBiometricsStatus(TSAuthentication.nativeBiometricsStatus()))
    }

    private func handleNativeBiometricsType(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(pluginBiometricsType(TSAuthentication.nativeBiometricsType()))
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
                        details: pluginErrorDetails(error)
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
                    details: pluginErrorDetails(error)
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
                    details: pluginErrorDetails(error)
                ))
            }
        }
    }
    
    // MARK: - WebAuthn With Data

    private func handleRegisterWebAuthnWithData(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let rawRegistrationData = arguments["rawRegistrationData"] as? [String: AnyHashable] else {
            result(FlutterError(
                code: AuthenticationPluginError.invalidArguments.rawValue,
                message: "Missing rawRegistrationData",
                details: nil
            ))
            return
        }

        guard let registrationData = convertWebAuthnRegistrationData(rawRegistrationData) else {
            result(FlutterError(
                code: AuthenticationPluginError.invalidArguments.rawValue,
                message: "Invalid rawRegistrationData",
                details: nil
            ))
            return
        }

        TSAuthentication.shared.registerWebAuthn(registrationData) { registrationResults in
            switch registrationResults {
            case .success(let response):
                result(["result": response.result])
            case .failure(let error):
                result(FlutterError(
                    code: AuthenticationPluginError.webAuthn.rawValue,
                    message: "Error during registerWebAuthnWithData",
                    details: pluginErrorDetails(error)
                ))
            }
        }
    }

    private func handleAuthenticateWebAuthnWithData(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let (authenticationData, options) = webAuthnAuthenticationArguments(call: call, result: result) else {
            return
        }

        TSAuthentication.shared.authenticateWebAuthn(authenticationData, options: options) { results in
            switch results {
            case .success(let response):
                result(["result": response.result])
            case .failure(let error):
                result(FlutterError(
                    code: AuthenticationPluginError.webAuthn.rawValue,
                    message: "Error during authenticateWebAuthnWithData",
                    details: pluginErrorDetails(error)
                ))
            }
        }
    }

    private func handleSignWebauthnTransactionWithData(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let (authenticationData, options) = webAuthnAuthenticationArguments(call: call, result: result) else {
            return
        }

        TSAuthentication.shared.signWebauthnTransaction(authenticationData, options: options) { results in
            switch results {
            case .success(let response):
                result(["result": response.result])
            case .failure(let error):
                result(FlutterError(
                    code: AuthenticationPluginError.webAuthn.rawValue,
                    message: "Error during signWebauthnTransactionWithData",
                    details: pluginErrorDetails(error)
                ))
            }
        }
    }

    /// Reads and converts the `rawAuthenticationData` and `options` arguments,
    /// reporting the matching argument error and returning `nil` when either is
    /// missing or invalid.
    private func webAuthnAuthenticationArguments(
        call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) -> (TSAuthenticationSDK.TSWebAuthnAuthenticationData, TSAuthenticationSDK.TSAuthentication.WebAuthnAuthenticationOptions)? {
        guard let arguments = call.arguments as? [String: Any],
              let rawAuthenticationData = arguments["rawAuthenticationData"] as? [String: AnyHashable],
              let options = arguments["options"] as? [String] else {
            result(FlutterError(
                code: AuthenticationPluginError.invalidArguments.rawValue,
                message: "Missing rawAuthenticationData or options",
                details: nil
            ))
            return nil
        }

        guard let authenticationData = convertWebAuthnAuthenticationData(rawAuthenticationData) else {
            result(FlutterError(
                code: AuthenticationPluginError.invalidArguments.rawValue,
                message: "Invalid rawAuthenticationData",
                details: nil
            ))
            return nil
        }

        guard let webAuthnOptions = convertWebAuthnOptions(options) else {
            result(FlutterError(
                code: AuthenticationPluginError.invalidArguments.rawValue,
                message: "Unrecognized WebAuthn option in \(options)",
                details: errorDetails(
                    .invalidArguments,
                    "Unrecognized WebAuthn option in \(options). Supported: preferLocalCredentials."
                )
            ))
            return nil
        }

        return (authenticationData, webAuthnOptions)
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
                    details: pluginErrorDetails(error)
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
                    details: pluginErrorDetails(error)
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
                    details: pluginErrorDetails(error)
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

        guard let webAuthnOptions = convertWebAuthnOptions(options) else {
            result(FlutterError(
                code: AuthenticationPluginError.invalidArguments.rawValue,
                message: "Unrecognized WebAuthn option in \(options)",
                details: errorDetails(
                    .invalidArguments,
                    "Unrecognized WebAuthn option in \(options). Supported: preferLocalCredentials."
                )
            ))
            return
        }

        TSAuthentication.shared.approvalWebAuthn(approvalData: approvalData, username: username, options: webAuthnOptions) { [weak self] approvalResults in
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
                    details: pluginErrorDetails(error)
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
        
        guard let webAuthnOptions = convertWebAuthnOptions(options) else {
            result(FlutterError(
                code: AuthenticationPluginError.invalidArguments.rawValue,
                message: "Unrecognized WebAuthn option in \(options)",
                details: errorDetails(
                    .invalidArguments,
                    "Unrecognized WebAuthn option in \(options). Supported: preferLocalCredentials."
                )
            ))
            return
        }

        TSAuthentication.shared.approvalWebAuthn(
            authenticationData,
            options: webAuthnOptions
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
                    details: pluginErrorDetails(error)
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
                    details: pluginErrorDetails(error)
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
                    details: pluginErrorDetails(error)
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
        
        guard let securityType = totpSecurityType(fromName: securityTypeString) else {
            result(FlutterError(
                code: AuthenticationPluginError.invalidArguments.rawValue,
                message: "Unsupported securityType: \(securityTypeString)",
                details: nil
            ))
            return
        }


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
                        details: pluginErrorDetails(error)
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
                    details: pluginErrorDetails(error)
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
                    details: pluginErrorDetails(error)
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
                    details: pluginErrorDetails(error)
                ))
            }
        }
    }
    
    // MARK: - Helper Functions
    
    /// Maps the WebAuthn option names sent from Dart onto the native `OptionSet`.
    ///
    /// Returns `nil` for an unrecognized name so the caller can report an argument error rather
    /// than silently proceeding with a weaker option set than the integrator asked for. This
    /// mirrors `totpSecurityTypeFromName` on the Android side, where a silent fallback was
    /// deliberately replaced with an explicit `invalidArguments` failure.
    ///
    /// The SDK exposes exactly one option, spelled `preferLocalCredantials` (a typo in the native
    /// SDK). The plugin accepts the correctly spelled `preferLocalCredentials` as its public
    /// contract and also tolerates the SDK's spelling, so callers who copied the native name still
    /// work. Both map to the same option.
    private func convertWebAuthnOptions(
        _ rawOptions: [String]
    ) -> TSAuthenticationSDK.TSAuthentication.WebAuthnAuthenticationOptions? {
        var options: TSAuthenticationSDK.TSAuthentication.WebAuthnAuthenticationOptions = []

        for rawOption in rawOptions {
            switch rawOption {
            case "preferLocalCredentials", "preferLocalCredantials":
                options.insert(.preferLocalCredantials)
            default:
                return nil
            }
        }

        return options
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
