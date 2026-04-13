# Flutter Engine Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.** { *; }

# Firebase Rules
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-keep class com.google.firebase.** { *; }
-keep interface com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keepclassmembers class com.google.firebase.** {
    *;
}

# Firebase Analytics
-keepclassmembers class com.google.android.gms.measurement.** {
    *;
}

# Firebase Auth
-keep class com.google.firebase.auth.** { *; }
-keep class com.google.firebase.internal.api.** { *; }

# Firestore
-keep class com.google.firebase.firestore.** { *; }
-keep class com.google.firebase.firestore.IgnoreExtraProperties.** { *; }

# Remote Config
-keep class com.google.firebase.remoteconfig.** { *; }

# Google Mobile Ads
-keep class com.google.android.gms.** { *; }
-keep interface com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
-keepclassmembers class com.google.android.gms.ads.** {
    *;
}

# Google Play Services
-keep class com.google.android.gms.common.api.** { *; }
-keep class com.google.android.gms.base.** { *; }
-keep class com.google.android.gms.basement.** { *; }

# Flame Engine
-keep class flame.** { *; }
-keep class com.flutter_games.** { *; }
-dontwarn flame.**

# Spine Animation
-keep class com.esotericsoftware.spine.** { *; }
-keep class com.esotericsoftware.spine.attachments.** { *; }

# Provider (State Management)
-keep class provider.** { *; }

# Image package
-keep class io.image.** { *; }

# SharedPreferences
-keep class android.content.SharedPreferences.** { *; }

# Get It (Service Locator)
-keep class get_it.** { *; }

# Logger
-keep class logger.** { *; }

# Native libraries
-keepclasseswithmembernames class * {
    native <methods>;
}

# Reflective serialization
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }

# Enum serialization
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Parcelable
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

# Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Remove Android logging in release
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# ============================================
# R8 Optimization Settings (Full Mode)
# ============================================
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-dontpreverify
-verbose

# Optimization algorithms - aggressive for smaller APK
-optimizations !code/simplification/arithmetic,!field/*,!class/merging/*

# Keep line numbers for crash reporting
-keepattributes SourceFile,LineNumberTable

# Preserve generics signatures for serialization
-keepattributes Signature

# Preserve annotations for dependency injection
-keepattributes *Annotation*

# Keep custom exceptions
-keep class * extends java.lang.Throwable {
    *;
}

# ============================================
# Size Reduction Optimization
# ============================================
# Remove logging in release builds
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Remove Assert statements
-assumenosideeffects class kotlin.AssertionError {
    public <init>(java.lang.String);
}

# ============================================
# Resource Optimization
# ============================================
# Keep only required resources
-dontwarn io.flutter.embedding.engine.**
-dontwarn io.flutter.plugin.common.**
-dontwarn com.google.android.gms.internal.**
-dontwarn com.google.common.**

# Unused native library removal
-keepclasseswithmembernames class * {
    native <methods>;
}

# Play Core SplitCompat (added for build fix)
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep interface com.google.android.play.core.splitcompat.** { *; }
-dontwarn com.google.android.play.core.splitcompat.**
