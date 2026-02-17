# Flutter TS Authentication Plugin Internal ProGuard Rules
# These rules apply to the plugin itself during development

# Keep the main plugin class
-keep public class com.example.flutter_ts_authentication.FlutterTsAuthenticationPlugin {
    public *;
}

# Keep Flutter plugin registration methods
-keep class * implements io.flutter.plugin.common.PluginRegistry$Registrar {
    public *;
}

-keep class * implements io.flutter.embedding.engine.plugins.FlutterPlugin {
    public *;
}
