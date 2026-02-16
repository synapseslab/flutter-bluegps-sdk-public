package com.synapseslab.flutter_bluegps_sdk

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterBluegpsSdkPlugin */
class FlutterBluegpsSdkPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel : MethodChannel
  private var config: Map<String, Any>? = null
  private var isPositioning: Boolean = false

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_bluegps_sdk")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      "initialize" -> {
        try {
          config = call.arguments as? Map<String, Any>
          if (config != null) {
            // Initialize BlueGPS SDK here with config
            result.success(null)
          } else {
            result.error("INVALID_CONFIG", "Configuration is required", null)
          }
        } catch (e: Exception) {
          result.error("INITIALIZATION_ERROR", e.message, null)
        }
      }
      "startPositioning" -> {
        try {
          if (config == null) {
            result.error("NOT_INITIALIZED", "SDK not initialized", null)
            return
          }
          isPositioning = true
          // Start positioning logic here
          result.success(null)
        } catch (e: Exception) {
          result.error("START_ERROR", e.message, null)
        }
      }
      "stopPositioning" -> {
        try {
          isPositioning = false
          // Stop positioning logic here
          result.success(null)
        } catch (e: Exception) {
          result.error("STOP_ERROR", e.message, null)
        }
      }
      "getCurrentPosition" -> {
        try {
          if (!isPositioning) {
            result.success(null)
            return
          }
          // Get current position from BlueGPS SDK
          // For now, return a mock position
          val position = mapOf(
            "x" to 0.0,
            "y" to 0.0,
            "floor" to 0,
            "timestamp" to System.currentTimeMillis(),
            "accuracy" to 1.0
          )
          result.success(position)
        } catch (e: Exception) {
          result.error("POSITION_ERROR", e.message, null)
        }
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
