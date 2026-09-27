# Flutter TS Authentication Plugin ProGuard Rules
# Keep all TSAuthentication SDK classes and interfaces
-keep class com.transmit.authentication.** { *; }
-keep interface com.transmit.authentication.** { *; }

# Keep TSAuthentication SDK enums
-keepclassmembers enum com.transmit.authentication.** {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Kotlin default implementations for interfaces
-keep class com.transmit.authentication.**$DefaultImpls { *; }

# Keep callback interfaces and their implementations
-keep class * implements com.transmit.authentication.TSAuthCallback { *; }
-keep class * implements com.transmit.authentication.crpto.totp.ITSRegisterTOTPCallback { *; }
-keep class * implements com.transmit.authentication.crpto.totp.ITSTOTPGenerateTOTPCallback { *; }

# Keep data classes and their constructors
-keepclassmembers class com.transmit.authentication.** {
    <init>(...);
    public <methods>;
}

# Keep serialization related methods
-keepclassmembers class com.transmit.authentication.** {
    private static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep Flutter plugin classes
-keep class com.example.flutter_ts_authentication.** { *; }

# Keep any native method implementations
-keepclasseswithmembernames class * {
    native <methods>;
}

# Prevent obfuscation of authentication result classes
-keep class com.transmit.authentication.*Result { *; }
-keep class com.transmit.authentication.*Response { *; }
-keep class com.transmit.authentication.*Data { *; }
-keep class com.transmit.authentication.*Info { *; }
-keep class com.transmit.authentication.*Error { *; }
-keep class com.transmit.authentication.*Exception { *; }

# Keep WebAuthn related classes
-keep class com.transmit.authentication.network.** { *; }
-keep class com.transmit.authentication.TSWebAuthn** { *; }

# Keep biometrics related classes
-keep class com.transmit.authentication.biometrics.** { *; }

# Keep PIN code related classes
-keep class com.transmit.authentication.pincode.** { *; }

# Keep TOTP related classes
-keep class com.transmit.authentication.crpto.totp.** { *; }

# Preserve annotations
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Keep line numbers for debugging
-keepattributes SourceFile,LineNumberTable

# Prevent warnings about missing classes
-dontwarn com.transmit.authentication.**

# ---------------------------------------------------------------------------
# Shared core SDK (com.ts.coresdk) keeps — carried on core's behalf.
#
# Neither of the SDKs below the plugin ships consumer ProGuard rules:
#   * the core SDK declares no `consumerProguardFiles` at all;
#   * the +A native SDK declares one, but the file is empty.
# So THIS file is the only keep set that reaches an integrating app, and it has
# to carry keeps for classes the plugin does not own and never references
# directly — core arrives purely transitively via com.ts.sdk:authentication.
#
# Source of truth for what must survive: the core SDK's own obfuscation
# config. The rules below are a deliberately NARROW subset of it — the crypto,
# error, logging and network paths that the +A TOTP / PIN / native-biometrics
# flows actually route through. Core 1.0.30 raised its own keep set by 64 lines
# (device-data collectors, user agent), and core is at 1.0.24 -> 1.0.30 here.
#
# NOT added, deliberately (keeps are not added defensively):
#   * com.ts.coresdk.device.**      — device-data collectors
#   * com.ts.coresdk.geolocation.** — geolocation providers
#   * com.google.android.gms.location.**
# The +A plugin exposes no API that reaches these; they are DRS/IDO surface.
# Keeping them here would force permanent, unnecessary `-keep ... { *; }` rules
# on every +A integrator. Shipping consumer rules for them is the core SDK's
# responsibility.
#
# NOT YET VERIFIED against a `mapping.txt` from a shrunk release build. Treat
# this set as justified by core's own config rather than empirically minimal.
# ---------------------------------------------------------------------------

# Kotlin metadata and coroutines infrastructure — resolved by name/reflection.
-keep @interface kotlin.Metadata { *; }
-keepkotlinmetadata
-dontwarn kotlin.**
-dontwarn kotlinx.**
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-keepclassmembers class kotlinx.** {
    volatile <fields>;
}
-keepclassmembers class * {
    synthetic <methods>;
}
-keepclassmembers class **$WhenMappings {
    <fields>;
}

# Core error types — surfaced through the plugin's error mapper by name.
-keep class com.ts.coresdk.errors.TransmitSecurityError { *; }
-keep class com.ts.coresdk.errors.TransmitSecurityError$** { *; }
-keep class com.ts.coresdk.errors.TSErrorFactory { <methods>; }

# Core crypto — the TOTP, PIN code and native-biometrics key paths.
-keep interface com.ts.coresdk.crypto.TSCryptographyManager { *; }
-keep class com.ts.coresdk.crypto.TSCryptographyManagerImp { *; }
-keep interface com.ts.coresdk.crypto.TSPairKeyResult { *; }
-keep class com.ts.coresdk.crypto.TSPairKeyResult$** { *; }
-keep interface com.ts.coresdk.crypto.TSBiometricPairKeyResult { *; }
-keep class com.ts.coresdk.crypto.TSBiometricPairKeyResult$** { *; }
-keep interface com.ts.coresdk.crypto.SignatureAuthenticatorResult { *; }
-keep class com.ts.coresdk.crypto.SignatureAuthenticatorResult$** { *; }
-keep interface com.ts.coresdk.crypto.SignatureAuthenticator { *; }
-keep class com.ts.coresdk.crypto.api.** { *; }
-keep interface com.ts.coresdk.crypto.logic.SignWithKeyResult { *; }
-keep class com.ts.coresdk.crypto.logic.SignWithKeyResult$** { *; }
-keep class com.ts.coresdk.crypto.logic.CryptographyActionError { *; }
-keep class com.ts.coresdk.crypto.logic.CryptographyActionError$** { *; }
-keep class com.ts.coresdk.crypto.util.UUIDUtils { *; }

# Core biometrics — backs nativeBiometricsStatus() / nativeBiometricsType().
-keep interface com.ts.coresdk.crypto.biometrcis.TSBiometricResult { *; }
-keep class com.ts.coresdk.crypto.biometrcis.TSBiometricResult$** { *; }
-keep class com.ts.coresdk.crypto.biometrcis.TSBiometricError { *; }
-keep class com.ts.coresdk.crypto.biometrcis.TSBiometricSupportChecker { *; }
-keep interface com.ts.coresdk.crypto.biometrcis.TSBiometricSupportChecker$TSBiometricSupportResult { *; }
-keep class com.ts.coresdk.crypto.biometrcis.TSBiometricSupportChecker$TSBiometricSupportResult$* { *; }

# Core session / network response — Gson-deserialized by field name.
-keep interface com.ts.coresdk.TSNetworkResponse { *; }
-keep class com.ts.coresdk.TSNetworkResponse$** { *; }
-keep class com.ts.coresdk.crypto.session.ServerResponseFormat { *; }
-keep class com.ts.coresdk.crypto.session.TSCryptoSessionError { *; }
-keep class com.ts.coresdk.crypto.session.TSCryptoSessionErrorCode { *; }
-keep class com.ts.coresdk.crypto.session.TSHeader { *; }
-keep class com.ts.coresdk.network.exceptions.TSNoConnectivityException { *; }
-keep class com.ts.coresdk.JsonStringConvertor { *; }

# Core logging.
-keep class com.ts.coresdk.TSLog { <methods>; }
