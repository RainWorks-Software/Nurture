########################################
# --- Protobuf + Mediapipe ---
-keep class com.google.protobuf.** { *; }
-keep class com.google.mediapipe.** { *; }

########################################
# --- AutoValue (annotation processor generated) ---
-keep class com.google.auto.value.** { *; }
-keep class autovalue.shaded.com.google** { *; }
-keep class autovalue.shaded.com.squareup.javapoet** { *; }

########################################
# --- JavaX compiler interfaces ---
-keep class javax.lang.model.** { *; }
-dontwarn javax.lang.model.**

-keep class javax.tools.** { *; }
-dontwarn javax.tools.**

########################################
# --- Security Providers (used by OkHttp) ---
-keep class org.bouncycastle.** { *; }
-keep class org.conscrypt.** { *; }
-keep class org.openjsse.** { *; }

########################################
# --- JNI/native ---
-keepclasseswithmembers class * {
    native <methods>;
}

########################################
# --- Keep all annotations ---
-keep @interface * { *; }

# Optional: helpful if you're seeing reflectively accessed classes being stripped
-keepattributes *Annotation*, EnclosingMethod, InnerClasses, Signature
