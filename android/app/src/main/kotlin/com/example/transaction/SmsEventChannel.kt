package com.example.transaction

import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import org.json.JSONObject

/**
 * Bridges SMS arrival events from the Android native layer to the Flutter
 * [EventChannel] named `"com.example.transaction/sms"`.
 *
 * PHASE 3 payload is a JSON string:
 * `{"version": 1, "event": "sms_received", "data": {"sender": "...", "timestamp": 1234567890}}`
 *
 * SmsEventChannel must NEVER parse SMS — it only builds and sends JSON.
 *
 * Thread safety note:
 * eventSink is a companion object field because SmsReceiver.onReceive() runs
 * on the BroadcastReceiver's main thread and needs to access it without an
 * instance reference. However, this creates a problem when the Activity is
 * recreated and configureFlutterEngine() creates a new SmsEventChannel bound
 * to a NEW FlutterEngine — the old eventSink from the destroyed engine may
 * persist. This is safe ONLY because onCancel() always fires before a new
 * onListen() when the Flutter framework re-subscribes after engine restart.
 *
 * If onCancel does NOT fire (e.g., engine destroyed without notification),
 * set eventSink = null BEFORE calling setup() on the new channel.
 */
class SmsEventChannel(private val flutterEngine: FlutterEngine) {

    companion object {
        private const val TAG = "SMS"
        private const val CHANNEL = "com.example.transaction/sms"

        /**
         * The active [EventChannel.EventSink], set when Flutter subscribes.
         *
         * This is a companion object field so SmsReceiver can send events
         * without holding a reference to SmsEventChannel or MainActivity.
         *
         * WARNING: When configureFlutterEngine() creates a new SmsEventChannel
         * with a new FlutterEngine, the old eventSink may still reference a
         * sink bound to the OLD engine. Always null it out before registering
         * the new stream handler.
         */
        private var eventSink: EventChannel.EventSink? = null

        /**
         * Called by [SmsReceiver] when an SMS arrives.
         * Builds a JSON object with sender, timestamp, and body, serializes
         * it to a string, and sends it across the EventChannel.
         */
        fun sendSmsReceived(sender: String, timestamp: Long, body: String) {
            val sink = eventSink
            if (sink == null) {
                Log.w(TAG, "[SMS][ERROR] EventSink is null")
                return
            }
            try {
                Log.d(TAG, "[TRACE] sendSmsReceived() — sender=$sender, timestamp=$timestamp, body.length=${body.length}")
                Log.d(TAG, "[TRACE] eventSink is NOT null ✓")

                Log.d(TAG, "[SMS] Creating JSON payload")

                val data = JSONObject()
                data.put("sender", sender)
                data.put("timestamp", timestamp)
                data.put("body", body)

                val payload = JSONObject()
                payload.put("version", 1)
                payload.put("event", "sms_received")
                payload.put("data", data)

                val jsonString = payload.toString(2)
                Log.d(TAG, "[TRACE] JSON payload length=${jsonString.length}")
                Log.d(TAG, "[SMS] Payload:\n$jsonString")

                Log.d(TAG, "[SMS] Sending payload")
                Log.d(TAG, "[TRACE] >>> sink.success(jsonString) — calling...")
                sink.success(jsonString)
                Log.d(TAG, "[TRACE] <<< sink.success() returned (no exception)")
            } catch (e: Exception) {
                Log.e(TAG, "[SMS][ERROR] Failed to send event: ${e.message}", e)
            }
        }
    }

    /** Register the EventChannel and set up the streaming handler. */
    fun setup() {
        Log.d(TAG, "[SMS] Setting up EventChannel")
        Log.d(TAG, "[TRACE] SmsEventChannel.setup() — creating EventChannel($CHANNEL)")

        // Safety: clear any stale eventSink from a previous engine before
        // registering a new StreamHandler. If onCancel() didn't fire for the
        // old engine, eventSink would still point to a destroyed sink.
        if (eventSink != null) {
            Log.w(TAG, "[SMS][WARN] Clearing stale eventSink from previous engine")
            eventSink = null
        }

        val channel = EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL,
        )

        channel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, sink: EventChannel.EventSink) {
                Log.d(TAG, "[SMS] Flutter connected — storing EventSink")
                Log.d(TAG, "[TRACE] onListen() called — eventSink set!")
                eventSink = sink
            }

            override fun onCancel(arguments: Any?) {
                Log.d(TAG, "[SMS] Flutter disconnected — clearing EventSink")
                Log.d(TAG, "[TRACE] onCancel() called — eventSink cleared!")
                eventSink = null
            }
        })

        Log.d(TAG, "[SMS] EventChannel ready")
        Log.d(TAG, "[TRACE] StreamHandler registered, waiting for Flutter subscription...")
    }
}
