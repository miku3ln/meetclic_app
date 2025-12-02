import java.util.Properties
import java.io.FileInputStream
plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.meetclic.meetclic_movile"
    compileSdk = flutter.compileSdkVersion
   // ndkVersion = flutter.ndkVersion
    ndkVersion = "27.0.12077973"
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.meetclic.meetclic_movile"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
       // minSdk = flutter.minSdkVersion TODO NEW CHANGE
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    signingConfigs {
        create("release") {
            // ruta relativa a android/app
            storeFile = file("keystore/meetclic.keystore")
            storePassword = "st+-963852"
            keyAlias = "meetclic_key"
            keyPassword = "st+-963852"
        }
    }
    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            getByName("release") {
                // Por ahora firmas con debug, solo para pruebas
                signingConfig = signingConfigs.getByName("debug")

                // TODO FIX ERROR RELEASE Desactivar R8 y shrink para evitar el error de Sceneform
                isMinifyEnabled = false
                isShrinkResources = false
            }
        }
    }
}

flutter {
    source = "../.."
}
