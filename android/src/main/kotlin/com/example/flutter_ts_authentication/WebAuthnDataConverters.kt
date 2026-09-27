package com.example.flutter_ts_authentication

import com.transmit.authentication.network.startauth.TSAllowCredentials
import com.transmit.authentication.network.startauth.TSCredentialRequestOptions
import com.transmit.authentication.network.startauth.TSWebAuthnAuthenticationData
import com.transmit.authentication.network.startregister.TSCredentialCreationOptions
import com.transmit.authentication.network.startregister.TSWebAuthnAuthenticatorSelection
import com.transmit.authentication.network.startregister.TSWebAuthnCredParams
import com.transmit.authentication.network.startregister.TSWebAuthnRp
import com.transmit.authentication.network.startregister.TSWebAuthnUser
import com.transmit.authentication.webauthn.TSWebAuthnRegistrationData
import org.json.JSONArray
import org.json.JSONObject

/**
 * Converts the raw authentication data sent from Dart into the native type.
 *
 * Returns `null` when a required field is missing, so the caller can surface an
 * argument error rather than starting a request that is guaranteed to fail.
 */
internal fun convertWebAuthnAuthenticationData(
    rawData: Map<String, Any>
): TSWebAuthnAuthenticationData? {
    val webAuthnSessionId = rawData["webauthnSessionId"] as? String
    if (webAuthnSessionId.isNullOrEmpty()) {
        return null
    }

    val rawCredentialRequestOptions =
        rawData["credentialRequestOptions"] as? Map<*, *> ?: return null

    val challenge = rawCredentialRequestOptions["challenge"] as? String
    val rawChallenge = rawCredentialRequestOptions["rawChallenge"] as? String
    val userVerification = rawCredentialRequestOptions["userVerification"] as? String

    val allowCredentials =
        (rawCredentialRequestOptions["allowCredentials"] as? List<*>)?.let {
            convertAllowCredentials(it)
        }

    val rpId = rawCredentialRequestOptions["rpId"] as? String
    val timeout = rawCredentialRequestOptions["timeout"] as? Double
    val attestation = rawCredentialRequestOptions["attestation"] as? String

    val transportsJson = convertTransports(rawCredentialRequestOptions["transports"])

    val credentialRequestOptions = TSCredentialRequestOptions(
        challenge ?: "",
        rawChallenge,
        userVerification,
        transportsJson,
        allowCredentials,
        rpId,
        timeout,
        attestation
    )

    return TSWebAuthnAuthenticationData(webAuthnSessionId, credentialRequestOptions)
}

/**
 * Converts the raw registration data sent from Dart into the native type.
 *
 * Returns `null` when a required field is missing or has an unexpected type.
 * All of `rp`, `user`, `challenge`, `pubKeyCredParams`, `timeout`,
 * `authenticatorSelection` and `attestation` are required by the native SDK.
 */
internal fun convertWebAuthnRegistrationData(
    rawData: Map<String, Any>
): TSWebAuthnRegistrationData? {
    val webAuthnSessionId = rawData["webauthnSessionId"] as? String
    if (webAuthnSessionId.isNullOrEmpty()) {
        return null
    }

    val rawOptions = rawData["credentialCreationOptions"] as? Map<*, *> ?: return null

    val rawRp = rawOptions["rp"] as? Map<*, *> ?: return null
    val rpName = rawRp["name"] as? String ?: return null
    val rpId = rawRp["id"] as? String ?: return null

    val rawUser = rawOptions["user"] as? Map<*, *> ?: return null
    val userName = rawUser["name"] as? String ?: return null
    val userId = rawUser["id"] as? String ?: return null
    val userDisplayName = rawUser["displayName"] as? String ?: return null

    val challenge = rawOptions["challenge"] as? String ?: return null
    val attestation = rawOptions["attestation"] as? String ?: return null

    // Flutter's standard codec decodes JSON numbers as Int or Double depending
    // on magnitude, so accept any Number here.
    val timeout = (rawOptions["timeout"] as? Number)?.toDouble() ?: return null

    val rawCredParams = rawOptions["pubKeyCredParams"] as? List<*> ?: return null
    val credParams = rawCredParams.mapNotNull { rawParam ->
        val param = rawParam as? Map<*, *> ?: return@mapNotNull null
        val type = param["type"] as? String ?: return@mapNotNull null
        val alg = (param["alg"] as? Number)?.toInt() ?: return@mapNotNull null
        TSWebAuthnCredParams(type, alg)
    }
    if (credParams.isEmpty()) {
        return null
    }

    val rawSelection = rawOptions["authenticatorSelection"] as? Map<*, *> ?: return null
    val authenticatorAttachment = rawSelection["authenticatorAttachment"] as? String ?: return null
    val authenticatorSelection = TSWebAuthnAuthenticatorSelection(
        authenticatorAttachment,
        rawSelection["userVerification"] as? String,
        rawSelection["residentKey"] as? String,
        rawSelection["requireResidentKey"] as? Boolean
    )

    val credentialCreationOptions = TSCredentialCreationOptions(
        TSWebAuthnRp(rpName, rpId),
        TSWebAuthnUser(userName, userId, userDisplayName),
        challenge,
        credParams.toTypedArray(),
        timeout,
        authenticatorSelection,
        attestation
    )

    return TSWebAuthnRegistrationData(webAuthnSessionId, credentialCreationOptions)
}

private fun convertTransports(transportsObj: Any?): JSONObject? {
    val transportsList = transportsObj as? List<*> ?: return null
    return try {
        val transportsArray = JSONArray()
        for (transport in transportsList) {
            if (transport is String) {
                transportsArray.put(transport)
            }
        }
        JSONObject().put("transports", transportsArray)
    } catch (e: Exception) {
        null
    }
}

private fun convertAllowCredentials(allowCredentialsArray: List<*>): Array<TSAllowCredentials> {
    val result = ArrayList<TSAllowCredentials>()
    for (item in allowCredentialsArray) {
        val rawAllowCredential = item as? Map<*, *> ?: continue
        val transports = (rawAllowCredential["transports"] as? List<*>)
            ?.filterIsInstance<String>()
            ?.toTypedArray()

        result.add(
            TSAllowCredentials(
                rawAllowCredential["type"] as? String,
                rawAllowCredential["id"] as? String,
                transports
            )
        )
    }
    return result.toTypedArray()
}
