package com.example.transaction

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.telephony.SmsMessage
import android.util.Log

/**
 * Listens for [android.provider.Telephony.Sms.Intents.SMS_RECEIVED_ACTION]
 * broadcasts, extracts sender and timestamp from the first SMS message,
 * and delegates to [SmsEventChannel.sendSmsReceived] which constructs
 * and sends the JSON payload to the Flutter layer.
 *
 * This receiver has NO direct communication with Flutter.
 * Its ONLY responsibility is:
 *   1. Receive the SMS intent
 *   2. Extract metadata (sender, timestamp)
 *   3. Call SmsEventChannel.sendSmsReceived(sender, timestamp)
 *
 * SmsReceiver must NEVER serialize JSON.
 */
class SmsReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "SMS"
    }

    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "[SMS] SMS intent received")

        try {
            // Extract raw PDUs from the intent
            val bundle: Bundle? = intent.extras
            if (bundle == null) {
                Log.w(TAG, "[SMS] Intent extras are null — ignoring")
                return
            }

            val pdus = bundle.get("pdus") as? Array<*>
            if (pdus.isNullOrEmpty()) {
                Log.w(TAG, "[SMS] No PDUs found in intent — ignoring")
                return
            }

            // Parse PDUs into SmsMessage objects
            val messages = pdus.mapNotNull { pdu ->
                try {
                    SmsMessage.createFromPdu(pdu as ByteArray)
                } catch (e: Exception) {
                    Log.e(TAG, "[SMS][ERROR] Failed to parse PDU: ${e.message}", e)
                    null
                }
            }

            if (messages.isEmpty()) {
                Log.w(TAG, "[SMS] No valid SMS messages parsed — ignoring")
                return
            }

            // Extract sender, timestamp, and body from the first message
            val firstMessage = messages.first()
            val sender = firstMessage.displayOriginatingAddress ?: "unknown"
            val timestamp = firstMessage.timestampMillis
            val body = firstMessage.messageBody ?: ""

            Log.d(TAG, "[SMS] Sender extracted: $sender")
            Log.d(TAG, "[SMS] Timestamp extracted: $timestamp")
            Log.d(TAG, "[SMS] Body length: ${body.length} chars")

            // Broadcast the metadata to the EventChannel
            Log.d(TAG, "[SMS] Broadcasting Flutter event")
            SmsEventChannel.sendSmsReceived(sender, timestamp, body)
            Log.d(TAG, "[SMS] Event sent successfully")

        } catch (e: Exception) {
            Log.e(TAG, "[SMS][ERROR] Receiver crashed: ${e.message}", e)
        }
    }
}
