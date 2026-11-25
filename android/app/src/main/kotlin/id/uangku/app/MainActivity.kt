package id.uangku.app

import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import id.uangku.finance.Finance
import org.json.JSONObject
import java.util.concurrent.Executors
import java.util.concurrent.RejectedExecutionException

class MainActivity : FlutterActivity() {
    private val financeExecutor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

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
                SUMMARY_METHOD -> handleSummary(call, result)
                else -> result.notImplemented()
            }
        }
    }

    private fun handleSummary(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val transactionsJson = call.argument<String>(TRANSACTIONS_JSON_ARGUMENT)
        if (transactionsJson == null) {
            result.error(
                INVALID_ARGUMENT_CODE,
                "A JSON transaction list is required.",
                null,
            )
            return
        }

        try {
            financeExecutor.execute {
                try {
                    val response = JSONObject(Finance.calculateSummary(transactionsJson))
                    val summary = mapOf(
                        INCOME_TOTAL_KEY to response.getLong(INCOME_TOTAL_KEY),
                        EXPENSE_TOTAL_KEY to response.getLong(EXPENSE_TOTAL_KEY),
                        NET_BALANCE_KEY to response.getLong(NET_BALANCE_KEY),
                    )
                    mainHandler.post { result.success(summary) }
                } catch (error: Exception) {
                    val code = if (error.message?.startsWith(INVALID_ARGUMENT_PREFIX) == true) {
                        INVALID_ARGUMENT_CODE
                    } else {
                        GO_BRIDGE_ERROR_CODE
                    }
                    val message = if (code == INVALID_ARGUMENT_CODE) {
                        "Go rejected the transaction data."
                    } else {
                        "The Go finance calculation could not be completed."
                    }
                    mainHandler.post { result.error(code, message, null) }
                }
            }
        } catch (_: RejectedExecutionException) {
            result.error(
                GO_BRIDGE_UNAVAILABLE_CODE,
                "The Go finance bridge is unavailable.",
                null,
            )
        }
    }

    override fun onDestroy() {
        financeExecutor.shutdown()
        super.onDestroy()
    }

    private companion object {
        const val CHANNEL_NAME = "id.uangku/spike01"
        const val PING_METHOD = "ping"
        const val SUMMARY_METHOD = "summarize"
        const val TRANSACTIONS_JSON_ARGUMENT = "transactionsJson"
        const val INVALID_ARGUMENT_PREFIX = "INVALID_ARGUMENT:"
        const val INVALID_ARGUMENT_CODE = "INVALID_ARGUMENT"
        const val GO_BRIDGE_ERROR_CODE = "GO_BRIDGE_ERROR"
        const val GO_BRIDGE_UNAVAILABLE_CODE = "GO_BRIDGE_UNAVAILABLE"
        const val INCOME_TOTAL_KEY = "incomeTotal"
        const val EXPENSE_TOTAL_KEY = "expenseTotal"
        const val NET_BALANCE_KEY = "netBalance"
        const val PONG_MESSAGE = "Pong dari Kotlin!"
        const val PLATFORM_NAME = "Android Native"
    }
}
