package id.uangku.app

import android.os.Build
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                PING_METHOD -> result.success(
                    mapOf(
                        "message" to PONG_MESSAGE,
                        "platform" to PLATFORM_NAME,
                        "sdkInt" to Build.VERSION.SDK_INT,
                    ),
                )
                else -> result.notImplemented()
            }
        }
    }

    private companion object {
        const val CHANNEL_NAME = "id.uangku/spike01"
        const val PING_METHOD = "ping"
        const val PONG_MESSAGE = "Pong dari Kotlin!"
        const val PLATFORM_NAME = "Android Native"
    }
}
