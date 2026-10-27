import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing details live in android/key.properties, which is git-ignored
// and never committed. See store/RELEASE.md for how to create it. Without that
// file the release build falls back to the debug key so `flutter run --release`
// still works locally — such a build can NOT be uploaded to Play.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKeystore = keystorePropertiesFile.exists()
if (hasReleaseKeystore) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
} else {
    logger.lifecycle(
        "WARNING: android/key.properties not found. The release build will be " +
            "signed with the DEBUG key and Play will reject it. " +
            "See store/RELEASE.md.",
    )
}

android {
    namespace = "com.cool531.luxuryfinance"
    compileSdk = flutter.compileSdkVersion
    // shared_preferences_android needs 27.x; the Flutter default is still 26.x
    // and the mismatch breaks the release strip step.
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // Permanent once the first build is uploaded to Play Console: Google
        // identifies the app by this string forever. Change it here, in
        // `namespace` above, and in the kotlin/ source folder before the first
        // upload if you want a different one.
        applicationId = "com.cool531.luxuryfinance"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        resourceConfigurations += listOf("en", "th")
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = keystoreProperties["storeFile"]?.let { file(it) }
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

flutter {
    source = "../.."
}
