# Flutter default rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Supabase / Realtime
-keep class io.supabase.** { *; }
-dontwarn io.supabase.**

# Play Core (deferred components) — referenced by Flutter's
# FlutterPlayStoreSplitApplication but not bundled; we don't use
# deferred components, so silencing R8 is safe.
-dontwarn com.google.android.play.core.**
