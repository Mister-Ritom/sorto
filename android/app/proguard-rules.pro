# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Google Services / Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Supabase / Realtime / Gotrue (if needed, usually they are fine with default R8)
-keep class io.github.jan.supabase.** { *; }

# RevenueCat
-keep class com.revenuecat.purchases.** { *; }

# Video Player
-keep class com.google.android.exoplayer2.** { *; }

# Image Picker
-keep class com.baseflow.imagepicker.** { *; }

# Custom models
-keep class me.ritom.sorto.models.** { *; }
