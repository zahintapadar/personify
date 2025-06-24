# Keep TensorFlow Lite classes
-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.lite.gpu.** { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory$Options { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegate { *; }

# Keep Google Play Core classes (for Flutter)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Keep all classes that are referenced by TensorFlow Lite
-keepclassmembers class * {
    @org.tensorflow.lite.annotations.UsedByReflection *;
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Flutter and Dart related classes
-keep class io.flutter.** { *; }
-keep class androidx.** { *; }
-keep class com.Personify.Zahin.** { *; }

# Keep notification classes
-keep class com.dexterous.** { *; }
-keep class androidx.work.** { *; }

# Keep audio player classes
-keep class xyz.luan.audioplayers.** { *; }

# Keep all plugin classes
-keep class io.flutter.plugins.** { *; }

# Disable warnings for missing classes that we don't use
-dontwarn org.tensorflow.lite.gpu.GpuDelegateFactory$Options
-dontwarn org.tensorflow.lite.gpu.GpuDelegate
-dontwarn com.google.android.play.**
