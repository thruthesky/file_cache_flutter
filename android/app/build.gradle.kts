import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// 개발자가 플러터 앱 버전을 변경 할 때, 버전 지정이나, 각종 설정을 ./android/local.properties 에서 지정하고,
// 여기에서 반영한다.
// 이 설정을 하지 않으면, 기본 값이 적용된다.
val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")

if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { localProperties.load(it) }
}
// Keysotre 파일을 읽는다
var keystoreProperties = Properties()
var keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
//    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}


val flutterVersionCode = localProperties.getProperty("flutter.versionCode")?.toInt() ?: 1
val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0.0"
val flutterMinSdkVersion = localProperties.getProperty("flutter.minSdkVersion")?.toInt() ?: 24
val flutterTargetSdkVersion = localProperties.getProperty("flutter.targetSdkVersion")?.toInt() ?: 36
val flutterCompileSdkVersion =
        localProperties.getProperty("flutter.compileSdkVersion")?.toInt() ?: 36
val flutterNdkVersion = localProperties.getProperty("flutter.ndkVersion") ?: "28.2.13676358"

android {
    namespace = "com.withcenter.philgo"
    compileSdk = flutterCompileSdkVersion
    ndkVersion = flutterNdkVersion // from local.properties, fallback above

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions { 
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    // Flutter Appstore Key: android { ... } 안쪽에 아래의 내용 추가
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = keystoreProperties.getProperty("storeFile")?.let { file(it) }
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    defaultConfig {
        applicationId = "com.withcenter.philgo"
        minSdk = flutterMinSdkVersion
        targetSdk = flutterTargetSdkVersion
        versionCode = flutterVersionCode
        versionName = flutterVersionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
