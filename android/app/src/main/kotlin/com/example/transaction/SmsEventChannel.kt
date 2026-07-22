package com.example.transaction

import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import org.json.JSONObject

/**
 * Bridges SMS arrival events from the Android native layer to the Flutter
 * [EventChannel] named `"com.example.transaction/sms"`.
 *
 * PHASE 2 payload is a JSON string `{"version": 1, "event": "sms_received"}`
 * designed for forward-compatibility — future phases can extend the JSON
 * object with additional keys without breaking existing consumers.
 */
class SmsEventChannel(private val flutterEngine: FlutterEngine) {

    companion object {
        private const val TAG = "SMS"
        private const val CHANNEL = "com.example.transaction/sms"

        /** The active [EventChannel.EventSink], set when Flutter subscribes. */
        private var eventSink: EventChannel.EventSink? = null

        /**
         * Called by [SmsReceiver] when an SMS arrives.
         * Builds a JSON object, serializes it to a string, and sends it
         * across the EventChannel.
         */
        fun sendSmsReceived() {
            val sink = eventSink
            if (sink == null) {
                Log.w(TAG, "[SMS][ERROR] EventSink is null")
                return
            }
            try {
                Log.d(TAG, "[SMS] Creating JSON payload")

                // Future-proof JSON — new keys can be added in later phases
                // without changing this call site.
                val payload = JSONObject()
                payload.put("version", 1)
                payload.put("event", "sms_received")

                val jsonString = payload.toString()

                Log.d(TAG, "[SMS] Payload: $jsonString")

                Log.d(TAG, "[SMS] Sending payload")
                sink.success(jsonString)
            } catch (e: Exception) {
                Log.e(TAG, "[SMS][ERROR] Failed to send event: ${e.message}", e)
            }
        }
    }

    /** Register the EventChannel and set up the streaming handler. */
    fun setup() {
        Log.d(TAG, "[SMS] Setting up EventChannel")

        val channel = EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL,
        )

        channel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, sink: EventChannel.EventSink) {
                Log.d(TAG, "[SMS] Flutter connected — storing EventSink")
                eventSink = sink
            }

            override fun onCancel(arguments: Any?) {
                Log.d(TAG, "[SMS] Flutter disconnected — clearing EventSink")
                eventSink = null
            }
        })

        Log.d(TAG, "[SMS] EventChannel ready")
    }
}
