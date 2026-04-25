# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# image_picker – keep Pigeon-generated channel classes
-keep class dev.flutter.pigeon.** { *; }
-keep class io.flutter.plugins.imagepicker.** { *; }

# Supabase / Realtime / WebSocket
-keep class io.github.jan.supabase.** { *; }
-dontwarn io.github.jan.supabase.**

# General – keep annotations used by plugins
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes EnclosingMethod
