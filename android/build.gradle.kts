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

// key.properties n'existe qu'en local (exclu par .gitignore).
// En CI (GitHub Actions) il est absent : on ne doit donc PAS le lire en dur.
val keyPropertiesFile = rootProject.file("key.properties")
val keyProperties = Properties()
val hasKeyProperties = keyPropertiesFile.exists()
if (hasKeyProperties) {
    keyProperties.load(FileInputStream(keyPropertiesFile))
}

android {
    namespace = "dj.velox.client"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "dj.velox.client"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // La config de signature "release" n'est créée QUE si la clé existe.
    signingConfigs {
        if (hasKeyProperties) {
            create("release") {
                keyAlias = keyProperties["keyAlias"] as String
                keyPassword = keyProperties["keyPassword"] as String
                storeFile = (keyProperties["storeFile"] as String?)?.let { file(it) }
                storePassword = keyProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Avec clé (local) -> signé release. Sans clé (CI) -> signé debug,
            // ce qui produit un APK installable pour tester.
            signingConfig = if (hasKeyProperties)
                signingConfigs.getByName("release")
            else
                signingConfigs.getByName("debug")

            // Minify/shrink désactivés : évite les échecs R8 avec Firebase.
            // À réactiver pour une release Play Store (avec règles proguard).
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.2")
}
