plugins {
    // Plugin Kotlin omesso intenzionalmente: i file .kt in src/main/kotlin/
    // non devono essere compilati. L'implementazione è in libs/plugin.jar.
    id("com.android.library")
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://jitpack.io") }
    }
}

android {
    namespace = "com.synapseslab.bluegps_sdk_flutter"
    compileSdk = 35

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        minSdk = 21
    }
}

dependencies {
    // Bytecode del plugin pre-compilato (sorgenti Kotlin non distribuiti).
    // Nota: si usa .jar invece di .aar perché il Gradle Plugin Android non
    // permette .aar locali come dipendenze quando compila un altro AAR.
    // api (not implementation) so the app module can compile GeneratedPluginRegistrant.java
    api(files("libs/plugin.jar"))

    // Dipendenze transitive richieste dal plugin
    implementation("com.github.synapseslab:android-bluegps-sdk-public:6.0.7")
    implementation("com.google.code.gson:gson:2.11.0")
}
