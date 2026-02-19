package com.synapseslab.bluegps_sdk_flutter

import io.flutter.embedding.engine.plugins.FlutterPlugin

// Stub class required by Flutter's plugin toolchain.
// Flutter reads this file to detect the embedding version (v1 vs v2) via the
// import above. Without "io.flutter.embedding.engine.plugins.FlutterPlugin",
// Flutter treats the plugin as v1-only and omits it from GeneratedPluginRegistrant.
// This file is NOT compiled (no Kotlin Gradle plugin in build.gradle.kts).
// The actual implementation is provided by plugin.jar in libs/.
class BlueGpsSdkFlutterPlugin : FlutterPlugin {
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {}
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {}
}
