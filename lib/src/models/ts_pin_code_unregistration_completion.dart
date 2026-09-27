/// Result of a PIN code unregistration request.
///
/// Unregistration is a two-step flow, mirroring registration: the native SDK
/// returns an unregistration context that must be committed once the server
/// acknowledged the unregistration. Pass [contextIdentifier] to
/// `commitPinUnregistration` to complete the flow.
class TSPinCodeUnregistrationCompletion {
  final String publicKeyId;
  final String contextIdentifier;

  TSPinCodeUnregistrationCompletion({
    required this.publicKeyId,
    required this.contextIdentifier,
  });

  factory TSPinCodeUnregistrationCompletion.fromMap(Map<String, dynamic> map) {
    return TSPinCodeUnregistrationCompletion(
      publicKeyId: map['publicKeyId'] as String,
      contextIdentifier: map['contextIdentifier'] as String,
    );
  }
}
