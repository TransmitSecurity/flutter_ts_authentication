/// Raw WebAuthn registration data, as returned by your backend's
/// `start registration` call.
///
/// The map is passed through to the native SDKs unchanged and is expected to
/// contain `webauthnSessionId` plus a `credentialCreationOptions` object with
/// the standard WebAuthn `rp`, `user`, `challenge`, `pubKeyCredParams`,
/// `timeout`, `authenticatorSelection` and `attestation` fields.
///
/// This is the registration counterpart of [TSWebAuthnAuthenticationData].
class TSWebAuthnRegistrationData {
  final Map<String, dynamic> data;

  TSWebAuthnRegistrationData({required this.data});

  factory TSWebAuthnRegistrationData.fromMap(Map<String, dynamic> map) {
    return TSWebAuthnRegistrationData(data: map);
  }

  Map<String, dynamic> toMap() {
    return data;
  }
}
