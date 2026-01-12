package com.example.flutter_ts_authentication

import android.app.Activity
import android.content.Context
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.FragmentActivity
import com.transmit.authentication.AuthenticationResult
import com.transmit.authentication.DeviceInfo
import com.transmit.authentication.RegistrationResult
import com.transmit.authentication.TSAuthCallback
import com.transmit.authentication.TSAuthentication
import com.transmit.authentication.TSAuthentication.approvalWebAuthn
import com.transmit.authentication.TSAuthentication.getDeviceInfo
import com.transmit.authentication.TSAuthentication.isWebAuthnSupported
import com.transmit.authentication.TSAuthenticationInitOptions
import com.transmit.authentication.TSWebAuthnApiPaths
import com.transmit.authentication.TSDeviceInfoError
import com.transmit.authentication.TSSignError
import com.transmit.authentication.TSSignResult
import com.transmit.authentication.TSWebAuthnApprovalError
import com.transmit.authentication.TSWebAuthnApprovalResult
import com.transmit.authentication.TSWebAuthnAuthenticationError
import com.transmit.authentication.TSWebAuthnRegistrationError
import com.transmit.authentication.biometrics.BiometricPromptTexts
import com.transmit.authentication.biometrics.TSBiometricsAuthError
import com.transmit.authentication.biometrics.TSBiometricsAuthResult
import com.transmit.authentication.biometrics.TSBiometricsRegistrationError
import com.transmit.authentication.biometrics.TSBiometricsRegistrationResult
import com.transmit.authentication.biometrics.TSBiometricsUnregistrationError
import com.transmit.authentication.biometrics.TSBiometricsUnregistrationResult
import com.transmit.authentication.biometrics.TSNativeBiometricsApprovalError
import com.transmit.authentication.biometrics.TSNativeBiometricsApprovalResult
import com.transmit.authentication.crpto.totp.ITSRegisterTOTPCallback
import com.transmit.authentication.crpto.totp.ITSTOTPGenerateTOTPCallback
import com.transmit.authentication.crpto.totp.TSTOTPError
import com.transmit.authentication.crpto.totp.TSTOTPRegistrationResult
import com.transmit.authentication.crpto.totp.TSTOTPSecurityType
import com.transmit.authentication.network.startauth.TSAllowCredentials
import com.transmit.authentication.network.startauth.TSCredentialRequestOptions
import com.transmit.authentication.network.startauth.TSWebAuthnAuthenticationData
import com.transmit.authentication.pincode.TSPinCodeAuthenticationError
import com.transmit.authentication.pincode.TSPinCodeAuthenticationResult
import com.transmit.authentication.pincode.TSPinCodeRegistrationContext
import com.transmit.authentication.pincode.TSPinCodeRegistrationError
import com.transmit.authentication.pincode.TSPinCodeRegistrationResult
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONArray
import org.json.JSONObject


enum class AuthenticationPluginError(val code: String) {
    INVALID_ARGUMENTS("invalidArguments"),
    SDK_INIT_ERROR("sdkInitError"),
    PIN_CODE("pinCode"),
    COMMIT_REGISTRATION("commitRegistration"),
    WEB_AUTHN("webAuthn"),
    NATIVE_BIOMETRICS("nativeBiometrics"),
    DEVICE_INFO("deviceInfo"),
    UNSUPPORTED_CONFIGURATION("unsupportedConfiguration"),
    TOTP("totp"),
    SIGN_WITH_DEVICE_KEY("signWithDeviceKey")
}

/** FlutterTsAuthenticationPlugin */
class FlutterTsAuthenticationPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private lateinit var applicationContext: Context
    private var activity: Activity? = null

    private val contextStore: MutableMap<String?, Any?> = HashMap<String?, Any?>()

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_ts_authentication")
        channel.setMethodCallHandler(this)
        applicationContext = flutterPluginBinding.applicationContext
    }

    // MARK: - Incoming Function Call Handler

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initializeSDK" -> handleInitializeSDK(call, result)
            "initialize" -> handleInitialize(call, result)
            "registerPinCode" -> handleRegisterPinCode(call, result)
            "commitPinRegistration" -> handleCommitPinRegistration(call, result)
            "authenticatePinCode" -> handleAuthenticatePinCode(call, result)
            "registerNativeBiometrics" -> handleRegisterNativeBiometrics(call, result)
            "unregisterNativeBiometrics" -> handleUnregisterNativeBiometrics(call, result)
            "authenticateNativeBiometrics" -> handleAuthenticateNativeBiometrics(call, result)
            "registerWebAuthn" -> handleRegisterWebAuthn(call, result)
            "authenticateWebAuthn" -> handleAuthenticateWebAuthn(call, result)
            "signWebauthnTransaction" -> handleSignWebauthnTransaction(call, result)
            "approvalWebAuthn" -> handleApprovalWebAuthn(call, result)
            "approvalWebAuthnWithData" -> handleApprovalWebAuthnWithData(call, result)
            "approvalNativeBiometrics" -> handleApprovalNativeBiometrics(call, result)
            "getDeviceInfo" -> handleGetDeviceInfo(call, result)
            "isWebAuthnSupported" -> handleIsWebAuthnSupported(call, result)
            "setLoggingEnabled" -> handleSetLoggingEnabled(call, result)
            "registerTOTP" -> handleRegisterTOTP(call, result)
            "generateTOTPCode" -> handleGenerateTOTPCode(call, result)
            "generateTOTPCodeWithChallenge" -> handleGenerateTOTPCodeWithChallenge(call, result)
            "signWithDeviceKey" -> handleSignWithDeviceKey(call, result)
            else -> result.notImplemented()
        }
    }

    // MARK: - API Implementation

    private fun handleInitializeSDK(call: MethodCall, result: Result) {
        try {
            TSAuthentication.initializeSDK(applicationContext)
            result.success(true)
        } catch (error: Exception) {
            result.error(
                AuthenticationPluginError.SDK_INIT_ERROR.code,
                "Error initializing the SDK",
                error.toString()
            )
        }
    }

    private fun handleInitialize(call: MethodCall, result: Result) {
        val arguments = call.arguments as? Map<String, Any>
        val clientId = arguments?.get("clientId") as? String
        val initOptionsMap = arguments?.get("initOptions") as? Map<String, Any>

        if (clientId == null) {
            result.error(
                AuthenticationPluginError.INVALID_ARGUMENTS.code,
                "Error initializing the SDK - missing clientId",
                null
            )
            return
        }

        val domain = arguments["domain"] as? String
        val baseUrl = arguments["baseUrl"] as? String ?: "https://api.transmitsecurity.io"

        var initOptions: TSAuthenticationInitOptions? = null;
        
        var webAuthnInitOptionsMap = initOptionsMap?.get("webAuthnInitOptions") as? Map<String, Any>
        val startAuthentication = webAuthnInitOptionsMap?.get("startAuthentication") as? String
        val startRegistration = webAuthnInitOptionsMap?.get("startRegistration") as? String

        if (!startAuthentication.isNullOrEmpty() && !startRegistration.isNullOrEmpty()) {
            val paths = TSWebAuthnApiPaths(
                startRegistration,
                startAuthentication
            )
            initOptions = TSAuthenticationInitOptions(webAuthnInitOptions = paths)
        }

        if (!startAuthentication.isNullOrEmpty() && !startRegistration.isNullOrEmpty()) {
            val paths = TSWebAuthnApiPaths(
                startRegistration,
                startAuthentication
            )
            initOptions = TSAuthenticationInitOptions(webAuthnInitOptions = paths)
        }

        try {
            if (domain !== null && domain.isNotEmpty()) {
                TSAuthentication.initialize(
                    applicationContext,
                    clientId,
                    baseUrl,
                    domain,
                    initOptions
                )
            } else {
                TSAuthentication.initialize(
                    applicationContext,
                    clientId,
                    baseUrl
                )
            }
            result.success(true)
        } catch (error: Exception) {
            result.error(
                AuthenticationPluginError.SDK_INIT_ERROR.code,
                "Error initializing the SDK",
                error.toString()
            )
        }
    }

    private fun handleRegisterPinCode(call: MethodCall, result: Result) {
        val arguments = call.arguments as? Map<String, Any>
        val username = arguments?.get("username") as? String
        val pinCode = arguments?.get("pinCode") as? String

        if (username == null || pinCode == null) {
            result.error(
                AuthenticationPluginError.PIN_CODE.code,
                "Missing username or pinCode",
                null
            )
            return
        }

        TSAuthentication.registerPinCode(username, pinCode,
            object: TSAuthCallback<TSPinCodeRegistrationResult, TSPinCodeRegistrationError>{
                override fun success(registrationResult: TSPinCodeRegistrationResult) {
                    val context: TSPinCodeRegistrationContext? = registrationResult.registrationContext()
                    val contextIdentifier: String = generateContextIdentifier()
                    storeContextWithIdentifier(contextIdentifier, context)

                    val resultMap = hashMapOf<String, Any>(
                        "publicKeyId" to registrationResult.keyId(),
                        "publicKey" to registrationResult.publicKey(),
                        "keyType" to registrationResult.keyType(),
                        "contextIdentifier" to contextIdentifier
                    )

                    result.success(resultMap);
                }

                override fun error(error: TSPinCodeRegistrationError) {
                    result.error(
                        AuthenticationPluginError.PIN_CODE.code,
                        "Error registering pic code",
                        error.toString()
                    )
                }
            }
        )
    }

    private fun handleCommitPinRegistration(call: MethodCall, result: Result) {
        val arguments = call.arguments as? Map<String, Any>
        val contextIdentifier = arguments?.get("contextIdentifier") as? String

        if (contextIdentifier == null) {
            result.error(
                AuthenticationPluginError.INVALID_ARGUMENTS.code,
                "Missing contextIdentifier",
                null
            )
            return
        }

        val context = getContextWithIdentifier(contextIdentifier) as TSPinCodeRegistrationContext?

        if (context == null) {
            result.error(
                AuthenticationPluginError.INVALID_ARGUMENTS.code,
                "Invalid contextIdentifier argument",
                "Unable to find PIN registration context with provided contextIdentifier: $contextIdentifier"
            )
            return
        }

        try {
            removeContextWithIdentifier(contextIdentifier)
            context.commit()
            result.success(null)
        } catch (error: Exception) {
            result.error(
                AuthenticationPluginError.COMMIT_REGISTRATION.code,
                "Error committing pin registration",
                error.toString()
            )
        }
    }

    private fun handleAuthenticatePinCode(call: MethodCall, result: Result) {
        val arguments = call.arguments as? Map<String, Any>
        val username = arguments?.get("username") as? String
        val pinCode = arguments?.get("pinCode") as? String
        val challenge = arguments?.get("challenge") as? String

        if (username == null || pinCode == null || challenge == null) {
            result.error(
                AuthenticationPluginError.INVALID_ARGUMENTS.code,
                "Missing username, pinCode, or challenge",
                null
            )
            return
        }

        TSAuthentication.authenticatePinCode(
            username,
            pinCode,
            challenge,
            object: TSAuthCallback<TSPinCodeAuthenticationResult, TSPinCodeAuthenticationError>{
                override fun success(authenticationResults: TSPinCodeAuthenticationResult) {
                    val resultMap = hashMapOf<String, Any>(
                        "publicKeyId" to authenticationResults.keyId(),
                        "signature" to authenticationResults.signature(),
                        "challenge" to authenticationResults.challenge()
                    )
                    result.success(resultMap);
                }

                override fun error(error: TSPinCodeAuthenticationError) {
                    result.error(
                        AuthenticationPluginError.PIN_CODE.code,
                        "Error authenticating using pic code",
                        error.toString()
                    )
                }
            }
        )
    }

    private fun handleRegisterWebAuthn(call: MethodCall, result: Result) {
        val arguments = call.arguments as? Map<String, Any>
        val username = arguments?.get("username") as? String
        val displayName = arguments?.get("displayName") as? String

        if (username == null || displayName == null) {
            result.error(
                AuthenticationPluginError.INVALID_ARGUMENTS.code,
                "Missing username or displayName",
                null
            )
            return
        }

        val isSupported = isWebAuthnSupported()
        if (!isSupported) {
            result.error(
                AuthenticationPluginError.WEB_AUTHN.code,
                "This device does not support WebAuthn",
                null
            )
            return
        }

        val fragmentActivity = getFragmentActivity()
        if (fragmentActivity == null) {
            result.error(
                AuthenticationPluginError.UNSUPPORTED_CONFIGURATION.code,
                "Unable to get Fragment activity",
                null
            )
            return
        }

        TSAuthentication.registerWebAuthn(
            fragmentActivity,
            username,
            displayName, object: TSAuthCallback<RegistrationResult, TSWebAuthnRegistrationError> {
            override fun success(registrationResult: RegistrationResult) {
                val encodedResult = registrationResult.result()
                val resultMap = hashMapOf<String, Any>(
                    "result" to encodedResult
                )
                result.success(resultMap)
            }

            override fun error(error: TSWebAuthnRegistrationError) {
                result.error(
                    AuthenticationPluginError.WEB_AUTHN.code,
                    "Error registering WebAuthn",
                    error.toString()
                )
            }
        })
    }

    private fun handleAuthenticateWebAuthn(call: MethodCall, result: Result) {
        val arguments = call.arguments as? Map<String, Any>
        val username = arguments?.get("username") as? String

        if (username == null) {
            result.error(
                AuthenticationPluginError.INVALID_ARGUMENTS.code,
                "Missing username",
                null
            )
            return
        }

        val fragmentActivity = getFragmentActivity()
        if (fragmentActivity == null) {
            result.error(
                AuthenticationPluginError.UNSUPPORTED_CONFIGURATION.code,
                "Unable to get Fragment activity",
                null
            )
            return
        }

        TSAuthentication.authenticateWebAuthn(
            fragmentActivity,
            username,
            object : TSAuthCallback<AuthenticationResult, TSWebAuthnAuthenticationError> {
                override fun success(authenticationRestults: AuthenticationResult) {
                    val encodedResult = authenticationRestults.result()
                    val resultMap = hashMapOf<String, Any>(
                        "result" to encodedResult
                    )
                    result.success(resultMap)
                }

                override fun error(error: TSWebAuthnAuthenticationError) {
                    result.error(
                        AuthenticationPluginError.WEB_AUTHN.code,
                        "Error authenticting using WebAuthn",
                        error.toString()
                    )
                }
            })
    }

    private fun handleSignWebauthnTransaction(call: MethodCall, result: Result) {
        val arguments = call.arguments as? Map<String, Any>
        val username = arguments?.get("username") as? String

        if (username == null) {
            result.error(
                AuthenticationPluginError.INVALID_ARGUMENTS.code,
                "Missing username",
                null
            )
            return
        }

        val fragmentActivity = getFragmentActivity()
        if (fragmentActivity == null) {
            result.error(
                AuthenticationPluginError.UNSUPPORTED_CONFIGURATION.code,
                "Unable to get Fragment activity",
                null
            )
            return
        }

        TSAuthentication.signTransactionWebAuthn(
            fragmentActivity,
            username,
            object : TSAuthCallback<AuthenticationResult, TSWebAuthnAuthenticationError> {
                override fun success(authenticationRestults: AuthenticationResult) {
                    val encodedResult = authenticationRestults.result()
                    val resultMap = hashMapOf<String, Any>(
                        "result" to encodedResult
                    )
                    result.success(resultMap)
                }

                override fun error(error: TSWebAuthnAuthenticationError) {
                    result.error(
                        AuthenticationPluginError.WEB_AUTHN.code,
                        "Error signing transaction WebAuthn",
                        error.toString()
                    )
                }
            })
    }

     private fun handleRegisterNativeBiometrics(call: MethodCall, result: Result) {
        val arguments = call.arguments as? Map<String, Any>
        val username = arguments?.get("username") as? String

        if (username == null) {
            result.error(
                AuthenticationPluginError.INVALID_ARGUMENTS.code,
                "Missing username",
                null
            )
            return
        }

        TSAuthentication.registerNativeBiometrics(
            this.applicationContext,
            username,
            object : TSAuthCallback<TSBiometricsRegistrationResult, TSBiometricsRegistrationError> {
                override fun success(registrationResult: TSBiometricsRegistrationResult) {

                    val resultMap = hashMapOf<String, Any?>(
                        "publicKeyId" to registrationResult.keyId(),
                        "publicKey" to registrationResult.publicKey(),
                        "keyType" to registrationResult.keyType(),
                        "os" to "Android",
                        "attestation" to null
                    )

                    result.success(resultMap);
                }

                override fun error(error: TSBiometricsRegistrationError) {
                    result.error(
                        AuthenticationPluginError.NATIVE_BIOMETRICS.code,
                        "Error registering native biometrics",
                        error.toString()
                    )
                }
            })
    }

    // MARK: - API Implementation | Unregister Native Biometrics

    private fun handleUnregisterNativeBiometrics(call: MethodCall, result: Result) {
        val arguments = call.arguments as? Map<String, Any>
        val userId = arguments?.get("userId") as? String

        if (userId == null) {
            result.error(
                AuthenticationPluginError.INVALID_ARGUMENTS.code,
                "Missing userId parameter",
                null
            )
            return
        }

        TSAuthentication.unregisterNativeBiometrics(
            this.applicationContext,
            userId,
            object : TSAuthCallback<TSBiometricsUnregistrationResult, TSBiometricsUnregistrationError> {
                override fun success(unregistrationResults: TSBiometricsUnregistrationResult) {

                    val resultMap = hashMapOf<String, Any?>(
                        "publicKeyId" to unregistrationResults.keyId()
                    )

                    result.success(resultMap);
                }

                override fun error(error: TSBiometricsUnregistrationError) {
                    result.error(
                        AuthenticationPluginError.NATIVE_BIOMETRICS.code,
                        "Error unregistering native biometrics",
                        error.toString()
                    )
                }
            }
        )
    }

    private fun handleAuthenticateNativeBiometrics(call: MethodCall, result: Result) {
        val arguments = call.arguments as? Map<String, Any>
        val username = arguments?.get("username") as? String
        val challenge = arguments?.get("challenge") as? String

        if (username == null || challenge == null) {
            result.error(
                AuthenticationPluginError.INVALID_ARGUMENTS.code,
                "Missing username or challenge",
                null
            )
            return
        }

        val fragmentActivity = getFragmentActivity()
        if (fragmentActivity == null) {
            result.error(
                AuthenticationPluginError.UNSUPPORTED_CONFIGURATION.code,
                "Unable to get Fragment activity",
                null
            )
            return
        }

        val biometricsString = getBiometricsStrings()

        TSAuthentication.authenticateNativeBiometrics(
            fragmentActivity,
            username,
            challenge,
            biometricsString,
            object : TSAuthCallback<TSBiometricsAuthResult, TSBiometricsAuthError> {
                override fun success(bioAuthResults: TSBiometricsAuthResult) {
                    val resultMap = hashMapOf<String, Any>(
                        "publicKeyId" to bioAuthResults.keyId(),
                        "signature" to bioAuthResults.signature()
                    )
                    result.success(resultMap);
                }

                override fun error(error: TSBiometricsAuthError) {
                    result.error(
                        AuthenticationPluginError.NATIVE_BIOMETRICS.code,
                        "Error authenticating native biometrics",
                        error.toString()
                    )
                }
            })
    }

    private fun handleApprovalWebAuthn(call: MethodCall, result: Result) {
        val arguments = call.arguments as? Map<String, Any>
        val approvalData = arguments?.get("approvalData") as? Map<String, String>
        val username = arguments?.get("username") as? String
        val options = arguments?.get("options") as? List<String>

        if (approvalData == null || options == null) {
            result.error(
                AuthenticationPluginError.INVALID_ARGUMENTS.code,
                "Missing approvalData or options",
                null
            )
            return
        }

        approvalWebAuthn(
            applicationContext,
            username,
            approvalData,
            object : TSAuthCallback<TSWebAuthnApprovalResult, TSWebAuthnApprovalError> {
                override fun success(approvalResults: TSWebAuthnApprovalResult) {
                    val encodedResult = approvalResults.result()
                    val resultMap = hashMapOf<String, Any>(
                        "result" to encodedResult
                    )
                    result.success(resultMap)
                }

                override fun error(error: TSWebAuthnApprovalError) {
                    result.error(
                        AuthenticationPluginError.WEB_AUTHN.code,
                        "Error during approval WebAuthn",
                        error.toString()
                    )
                }
            })
    }

    private fun handleApprovalWebAuthnWithData(call: MethodCall, result: Result) {
        val arguments = call.arguments as? Map<String, Any>
        val authDataMap = arguments?.get("rawAuthenticationData") as? Map<String, Any>
        val options = arguments?.get("options") as? List<String>

        if (authDataMap == null || options == null) {
            result.error(
                AuthenticationPluginError.INVALID_ARGUMENTS.code,
                "Missing rawAuthenticationData or options",
                null
            )
            return
        }

        val authData: TSWebAuthnAuthenticationData? =
            this.convertWebAuthnAuthenticationData(authDataMap)

        if (authData == null) {
            result.error(
                AuthenticationPluginError.INVALID_ARGUMENTS.code,
                "Error converting authentication data",
                null
            )
            return
        }

        TSAuthentication.approvalWebAuthn(
            applicationContext,
            authData,
            object : TSAuthCallback<TSWebAuthnApprovalResult, TSWebAuthnApprovalError> {
                override fun success(authenticationResult: TSWebAuthnApprovalResult) {
                    val encodedResult = authenticationResult.result()
                    val resultMap = hashMapOf<String, Any>(
                        "result" to encodedResult
                    )
                    result.success(resultMap)
                }

                override fun error(error: TSWebAuthnApprovalError) {
                    result.error(
                        AuthenticationPluginError.WEB_AUTHN.code,
                        "Error during approval WebAuthn with data",
                        error.toString()
                    )
                }
            })
    }

    private fun handleApprovalNativeBiometrics(call: MethodCall, result: Result) {
        val arguments = call.arguments as? Map<String, Any>
        val username = arguments?.get("username") as? String
        val challenge = arguments?.get("challenge") as? String

        if (username == null || challenge == null) {
            result.error(
                AuthenticationPluginError.INVALID_ARGUMENTS.code,
                "Missing username or challenge",
                null
            )
            return
        }

        val fragmentActivity = getFragmentActivity()
        if (fragmentActivity == null) {
            result.error(
                AuthenticationPluginError.UNSUPPORTED_CONFIGURATION.code,
                "Unable to get Fragment activity. Please follow the user guide.",
                null
            )
            return
        }

        val biometricsString = getBiometricsStrings()

        TSAuthentication.approvalNativeBiometrics(
            fragmentActivity,
            username,
            challenge,
            biometricsString,
            object :
                TSAuthCallback<TSNativeBiometricsApprovalResult, TSNativeBiometricsApprovalError> {
                override fun success(nativeBiometricsApprovalResults: TSNativeBiometricsApprovalResult) {

                    val resultMap = hashMapOf<String, Any>(
                        "publicKeyId" to nativeBiometricsApprovalResults.keyId(),
                        "signature" to nativeBiometricsApprovalResults.signature()
                    )
                    result.success(resultMap)
                }

                override fun error(error: TSNativeBiometricsApprovalError) {
                    result.error(
                        AuthenticationPluginError.WEB_AUTHN.code,
                        "Error during native biometrics approval",
                        error.toString()
                    )
                }
            })
    }

    private fun handleGetDeviceInfo(call: MethodCall, result: Result) {
        getDeviceInfo(
            applicationContext,
            object : TSAuthCallback<DeviceInfo, TSDeviceInfoError> {
                override fun success(deviceInfo: DeviceInfo) {
                    val resultMap = hashMapOf<String, Any>(
                        "publicKeyId" to deviceInfo.publicKeyId,
                        "publicKey" to deviceInfo.publicKey
                    )
                    result.success(resultMap)
                }

                override fun error(tsDeviceInfoError: TSDeviceInfoError) {
                    result.error(
                        AuthenticationPluginError.DEVICE_INFO.code,
                        "Error during getDeviceInfo",
                        tsDeviceInfoError.toString()
                    )
                }
            })
    }

    private fun handleIsWebAuthnSupported(call: MethodCall, result: Result) {
        val isSupported = TSAuthentication.isWebAuthnSupported()
        result.success(isSupported)
    }

    // MARK: - API Implementation | Set Logging Enabled

    private fun handleSetLoggingEnabled(call: MethodCall, result: Result) {
        val arguments = call.arguments as? Map<String, Any>
        val enabled = arguments?.get("enabled") as? Boolean

        if (enabled == null) {
            result.error(
                AuthenticationPluginError.INVALID_ARGUMENTS.code,
                "Missing enabled parameter - must be true or false",
                null
            )
            return
        }

        TSAuthentication.setLoggingEnabled(enabled)
        result.success(true)
    }

    // MARK: - API Implementation | Register TOTP

    private fun handleRegisterTOTP(call: MethodCall, result: Result) {
        val arguments = call.arguments as? Map<String, Any>
        val uri = arguments?.get("uri") as? String
        val securityTypeString = arguments?.get("securityType") as? String

        if (uri == null || securityTypeString == null) {
            result.error(
                AuthenticationPluginError.INVALID_ARGUMENTS.code,
                "Missing uri or securityType parameters",
                null
            )
            return
        }

        val securityType = when (securityTypeString) {
            "none" -> TSTOTPSecurityType.None
            else -> TSTOTPSecurityType.Biometric
        }

        val fragmentActivity = getFragmentActivity()
        if (fragmentActivity == null) {
            result.error(
                AuthenticationPluginError.UNSUPPORTED_CONFIGURATION.code,
                "Unable to get Fragment activity. Please follow the user guide.",
                null
            )
            return
        }

        TSAuthentication.registerTOTP(
            fragmentActivity,
            uri, securityType, object :
            ITSRegisterTOTPCallback {
            override fun onSuccess(registrationResult: TSTOTPRegistrationResult) {
                val resultMap = hashMapOf<String, Any?>(
                    "issuer" to registrationResult.issuer,
                    "label" to registrationResult.label,
                    "uuid" to registrationResult.uuid
                )
                result.success(resultMap)
            }
            override fun onFailed(error: TSTOTPError) {
                result.error(
                    AuthenticationPluginError.TOTP.code,
                    "Error during TOTP Registration",
                    error.toString()
                )
            }
        })
    }

    // MARK: - API Implementation | Generate TOTP Code

    private fun handleGenerateTOTPCode(call: MethodCall, result: Result) {
        val arguments = call.arguments as? Map<String, Any>
        val uuid = arguments?.get("uuid") as? String

        if (uuid == null) {
            result.error(
                AuthenticationPluginError.INVALID_ARGUMENTS.code,
                "Missing uuid parameter",
                null
            )
            return
        }

        val fragmentActivity = getFragmentActivity()
        if (fragmentActivity == null) {
            result.error(
                AuthenticationPluginError.UNSUPPORTED_CONFIGURATION.code,
                "Unable to get Fragment activity. Please follow the user guide.",
                null
            )
            return
        }

        TSAuthentication.generateTOTP(
            fragmentActivity,
            uuid,
            object :
                ITSTOTPGenerateTOTPCallback {
                override fun onSuccess(code: String) {
                    val resultMap = hashMapOf<String, Any>(
                        "code" to code
                    )
                    result.success(resultMap)
                }

                override fun onFailed(error: TSTOTPError) {
                    result.error(
                        AuthenticationPluginError.TOTP.code,
                        "Error during TOTP Registration",
                        error.toString()
                    )
                }
            }
        )
    }

    // MARK: - API Implementation | Generate TOTP Code With Challenge

    private fun handleGenerateTOTPCodeWithChallenge(call: MethodCall, result: Result) {
        val arguments = call.arguments as? Map<String, Any>
        val uuid = arguments?.get("uuid") as? String
        val challenge = arguments?.get("challenge") as? String

        if (uuid == null || challenge == null) {
            result.error(
                AuthenticationPluginError.INVALID_ARGUMENTS.code,
                "Missing uuid or challenge parameters",
                null
            )
            return
        }

        val fragmentActivity = getFragmentActivity()
        if (fragmentActivity == null) {
            result.error(
                AuthenticationPluginError.UNSUPPORTED_CONFIGURATION.code,
                "Unable to get Fragment activity. Please follow the user guide.",
                null
            )
            return
        }

        TSAuthentication.generateTOTPWithChallenge(
            fragmentActivity,
            uuid,
            challenge,
            object :
                ITSTOTPGenerateTOTPCallback {
                override fun onSuccess(code: String) {
                    val resultMap = hashMapOf<String, Any>(
                        "code" to code
                    )
                    result.success(resultMap)
                }

                override fun onFailed(error: TSTOTPError) {
                    result.error(
                        AuthenticationPluginError.TOTP.code,
                        "Error during TOTP Registration",
                        error.toString()
                    )
                }
            }
        )
    }

    // MARK: - Sign with Device Key

    private fun handleSignWithDeviceKey(call: MethodCall, result: Result) {
        val arguments = call.arguments as? Map<String, Any>
        val challenge = arguments?.get("challenge") as? String

        if (challenge == null) {
            result.error(
                AuthenticationPluginError.INVALID_ARGUMENTS.code,
                "Missing challenge parameter",
                null
            )
            return
        }

        TSAuthentication.signWithDeviceKey(
            this.applicationContext,
            challenge,
            object :
                TSAuthCallback<TSSignResult, TSSignError> {
                override fun success(results: TSSignResult) {
                    val resultMap = hashMapOf<String, Any>(
                        "signature" to results.signedData
                    )
                    result.success(resultMap)
                }

                override fun error(error: TSSignError) {
                    result.error(
                        AuthenticationPluginError.SIGN_WITH_DEVICE_KEY.code,
                        "Error during sign with device key",
                        error.toString()
                    )
                }
            }
        )
    }

    // MARK: - Helper Functions

    private fun getBiometricsStrings(): BiometricPromptTexts {
        val context: Context = applicationContext

        val defaultTitle = "Authenticate with Biometrics"
        val defaultSubtitle = "Use your device biometrics to authenticate."
        val defaultCancel = "Cancel"

        val titleTxt =
            getStringResourceByName(context, "BiometricPromptTitle", defaultTitle)
        val subtitleTxt = getStringResourceByName(context, "BiometricPromptSubtitle", defaultSubtitle)
        val cancelTxt = getStringResourceByName(context, "BiometricPromptCancel", defaultCancel)

        fun String?.orIfNullOrEmpty(default: String): String =
            if (this.isNullOrEmpty()) default else this

        return BiometricPromptTexts(
            titleTxt.orIfNullOrEmpty(defaultTitle),
            subtitleTxt.orIfNullOrEmpty(defaultSubtitle),
            cancelTxt.orIfNullOrEmpty(defaultCancel)
        )
    }

    private fun getStringResourceByName(
        context: Context,
        resourceName: String?,
        defaultValue: String?
    ): String? {
        val resId =
            context.getResources().getIdentifier(resourceName, "string", context.getPackageName())
        return if (resId != 0) context.getString(resId) else defaultValue
    }

    private fun convertWebAuthnAuthenticationData(
        rawData: Map<String, Any>
    ): TSWebAuthnAuthenticationData? {
        val webAuthnSessionId = rawData.get("webauthnSessionId") as String?
        if (webAuthnSessionId == null || webAuthnSessionId.isEmpty()) {
            return null
        }

        val rawCredentialRequestOptions =
            rawData.get("credentialRequestOptions") as MutableMap<String?, Any?>?
        if (rawCredentialRequestOptions == null) {
            return null
        }

        val challenge = rawCredentialRequestOptions["challenge"] as String?
        val rawChallenge = rawCredentialRequestOptions["rawChallenge"] as String?
        val userVerification = rawCredentialRequestOptions["userVerification"] as String?

        val allowCredentialObj = rawCredentialRequestOptions["allowCredentials"]
        var allowCredentials: Array<TSAllowCredentials>? = null
        if (allowCredentialObj is MutableList<*>) {
            val allowCredentialsList = allowCredentialObj
            allowCredentials = this.convertAllowCredentials(allowCredentialsList)
        }

        val rpId = rawCredentialRequestOptions["rpId"] as String?
        val timeout = rawCredentialRequestOptions["timeout"] as Double?

        val attestation = rawCredentialRequestOptions["attestation"] as String?

        val transportsObj = rawCredentialRequestOptions["transports"]
        var transportsJson: JSONObject? = null
        try {
            if (transportsObj is MutableList<*>) {
                val transportsList = transportsObj
                val transportsArray = JSONArray()
                for (t in transportsList) {
                    if (t is String) {
                        transportsArray.put(t)
                    }
                }
                transportsJson = JSONObject()
                transportsJson.put("transports", transportsArray)
            }
        } catch (e: java.lang.Exception) {
            transportsJson = null
        }

        val credentialRequestOptions = TSCredentialRequestOptions(
            if (challenge != null) challenge else "",
            rawChallenge,
            userVerification,
            transportsJson,
            allowCredentials,
            rpId,
            timeout,
            attestation
        )

        val authData = TSWebAuthnAuthenticationData(
            webAuthnSessionId,
            credentialRequestOptions
        )

        return authData
    }

    private fun convertAllowCredentials(allowCredentialsArray: MutableList<*>): Array<TSAllowCredentials>? {
        val result: MutableList<TSAllowCredentials> = ArrayList<TSAllowCredentials>()
        for (item in allowCredentialsArray) {
            if (item is MutableMap<*, *>) {
                val rawAllowCredential = item as MutableMap<String?, Any?>
                var transports: Array<String>? = null
                val transportsObj = rawAllowCredential["transports"]
                if (transportsObj is MutableList<*>) {
                    val transportsList = transportsObj
                    val transportsResult: MutableList<String> = ArrayList<String>()
                    for (transport in transportsList) {
                        if (transport is String) {
                            transportsResult.add(transport)
                        }
                    }
                    transports = transportsResult.toTypedArray()
                }
                val data = TSAllowCredentials(
                    rawAllowCredential["type"] as String?,
                    rawAllowCredential["id"] as String?,
                    transports
                )
                result.add(data)
            }
        }
        return result.toTypedArray()
    }

    private fun getFragmentActivity(): FragmentActivity? {
        return if (activity is FragmentActivity) {
            activity as FragmentActivity
        } else {
            null
        }
    }

    private fun generateContextIdentifier(): String {
        return java.util.UUID.randomUUID().toString()
    }

    private fun storeContextWithIdentifier(identifier: String?, context: Any?) {
        contextStore.put(identifier, context)
    }

    private fun removeContextWithIdentifier(identifier: String?) {
        contextStore.remove(identifier)
    }

    private fun getContextWithIdentifier(identifier: String?): Any? {
        return contextStore[identifier]
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    // ActivityAware interface methods
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}
