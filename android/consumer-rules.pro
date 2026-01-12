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
