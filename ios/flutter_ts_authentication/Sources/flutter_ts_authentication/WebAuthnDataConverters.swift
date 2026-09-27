import Foundation
import TSAuthenticationSDK

/// Converts the raw authentication data sent from Dart into the native type.
///
/// Returns `nil` when a required field is missing, so the caller can surface an
/// argument error rather than starting a request that is guaranteed to fail.
func convertWebAuthnAuthenticationData(
    _ rawData: [String: AnyHashable]
) -> TSAuthenticationSDK.TSWebAuthnAuthenticationData? {
    guard let credentialRequestOptions = rawData["credentialRequestOptions"] as? [String: AnyHashable],
          let webauthnSessionId = rawData["webauthnSessionId"] as? String else {
        return nil
    }

    let rawUserData = credentialRequestOptions["userData"] as? [String: AnyHashable]

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

    return TSAuthenticationSDK.TSWebAuthnAuthenticationData(
        webauthnSessionId: webauthnSessionId,
        credentialRequestOptions: optionsData
    )
}

/// Converts the raw registration data sent from Dart into the native type.
///
/// `webauthnSessionId` and the relying-party object are required; the remaining
/// credential creation options are optional on iOS and are forwarded when present.
func convertWebAuthnRegistrationData(
    _ rawData: [String: AnyHashable]
) -> TSAuthenticationSDK.TSWebAuthnRegistrationData? {
    guard let webauthnSessionId = rawData["webauthnSessionId"] as? String,
          !webauthnSessionId.isEmpty,
          let rawOptions = rawData["credentialCreationOptions"] as? [String: AnyHashable],
          let rawRp = rawOptions["rp"] as? [String: AnyHashable] else {
        return nil
    }

    let rp = TSWebAuthnRPData(
        id: rawRp["id"] as? String,
        name: rawRp["name"] as? String
    )

    let rawUser = rawOptions["user"] as? [String: AnyHashable]
    let user = TSAuthenticationSDK.TSWebAuthnUserData(
        id: rawUser?["id"] as? String,
        name: rawUser?["name"] as? String,
        displayName: rawUser?["displayName"] as? String
    )

    let rawSelection = rawOptions["authenticatorSelection"] as? [String: AnyHashable]
    let authenticatorSelection = TSWebAuthnAuthenticatorSelectionData(
        authenticatorAttachment: rawSelection?["authenticatorAttachment"] as? String,
        requireResidentKey: rawSelection?["requireResidentKey"] as? Bool,
        userVerification: rawSelection?["userVerification"] as? String
    )

    let pubKeyCredParams = (rawOptions["pubKeyCredParams"] as? [[String: AnyHashable]])?
        .map { rawParam in
            TSWebAuthnPubKeyCredParamsData(
                type: rawParam["type"] as? String,
                alg: (rawParam["alg"] as? NSNumber)?.intValue
            )
        }

    let credentialCreationOptions = TSWebAuthnCredentialRequestOptionsData(
        challenge: rawOptions["challenge"] as? String,
        pubKeyCredParams: pubKeyCredParams,
        attestation: rawOptions["attestation"] as? String,
        excludeCredentials: rawOptions["excludeCredentials"] as? [String],
        authenticatorSelection: authenticatorSelection,
        timeout: (rawOptions["timeout"] as? NSNumber)?.intValue,
        user: user,
        rp: rp
    )

    return TSAuthenticationSDK.TSWebAuthnRegistrationData(
        webauthnSessionId: webauthnSessionId,
        credentialCreationOptions: credentialCreationOptions
    )
}

private func convertAllowCredentials(
    _ credentialRequestOptions: [String: AnyHashable]
) -> [TSWebAuthnAllowCredentialsData]? {
    guard let allowCredentialsArray =
            credentialRequestOptions["allowCredentials"] as? [[String: AnyHashable]] else {
        return nil
    }

    return allowCredentialsArray.map { rawAllowCredential in
        TSWebAuthnAllowCredentialsData(
            id: rawAllowCredential["id"] as? String,
            name: rawAllowCredential["name"] as? String,
            displayName: rawAllowCredential["displayName"] as? String
        )
    }
}
