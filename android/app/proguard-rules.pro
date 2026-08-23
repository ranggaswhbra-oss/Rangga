# Aturan Proguard/R8 untuk GAAFTBLL
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class com.gaaftbll.game.** { *; }

# Flutter Play Store Split/Deferred Components — tidak dipakai app ini
# Suppress R8 "missing class" warning untuk Play Core classes
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
