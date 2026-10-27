# Flutter's own engine classes are kept by the engine's bundled rules; these
# cover the plugins this app ships with.
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Keep annotations and line numbers so Play Console crash reports stay readable.
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
