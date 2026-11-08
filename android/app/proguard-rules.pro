# Flutter Enterprise ProGuard / R8 Optimization Rules
# Preserve Flutter engine, plugins, and bindings
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**

# Preserve annotations, signatures, and line numbers for crash reporting
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes SourceFile,LineNumberTable

# Preserve native JNI methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Preserve enum mappings
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

