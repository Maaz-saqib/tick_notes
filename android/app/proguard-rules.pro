# Proguard rules for TickNotes

# -------------------------------------------------------------
# Flutter Local Notifications rules
# -------------------------------------------------------------
-keep class com.dexterous.** { *; }

# -------------------------------------------------------------
# Gson rules (required by flutter_local_notifications)
# -------------------------------------------------------------
-keepattributes Signature, *Annotation*, InnerClasses
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keep class * extends com.google.gson.TypeAdapter
-keepclassmembers,allowobfuscation class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# -------------------------------------------------------------
# SQLite / Drift database rules
# -------------------------------------------------------------
-keep class com.sqlite.jni.** { *; }
-keep class org.sqlite.** { *; }
-dontwarn org.sqlite.**
-dontwarn com.sqlite.jni.**
