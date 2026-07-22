package com.example.transaction

import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

/**
 * Bridges SMS arrival events from the Android native layer to the Flutter
 * [EventChannel] named `"com.example.transaction/sms"`.
 *
 * This is PHASE 1 only — only the string `"SMS_RECEIVED"` is sent across
 * the bridge. No message body, sender, or metadata is transmitted.
 */
class SmsEventChannel(private val flutterEngine: FlutterEngine) {

    companion object {
        private const val TAG = "SMS"
        private const val CHANNEL = "com.example.transaction/sms"

        /** The active [EventChannel.EventSink], set when Flutter subscribes. */
        private var eventSink: EventChannel.EventSink? = null

        /**
         * Called by [SmsReceiver] when an SMS arrives.
         * Forwards the "SMS_RECEIVED" signal to the Flutter layer.
         */
        fun sendSmsReceived() {
            val sink = eventSink
            if (sink == null) {
                Log.w(TAG, "[SMS][ERROR] EventSink is null")
                return
            }
            try {
                sink.success("SMS_RECEIVED")
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
