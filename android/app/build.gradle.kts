import java.util.Properties
import java.io.FileInputStream

plugins {
  id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    load(FileInputStream(keystorePropertiesFile))
}



android {


    namespace ="altu.ace.dimp.flutter.parentapp"
    compileSdk= 35
   // ndkVersion = "27.0.12077973"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility =JavaVersion.VERSION_17
        targetCompatibility= JavaVersion.VERSION_17

    }


  
   

    signingConfigs {
         create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = file("$rootDir/upload-keystore.jks")
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId= "altu.ace.dimp.flutter.parentapp"
        // You can update the following values to match your application needs.
        // For more information, see: https://docs.flutter.dev/deployment/android#reviewing-the-gradle-build-configuration.
        minSdk =23
        targetSdk= 35

        versionCode = flutter.versionCode
        versionName = flutter.versionName

    }


          buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

}
 kotlin {
        jvmToolchain(17)
    }
flutter {
    source ="../.."
}

dependencies {
   coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
