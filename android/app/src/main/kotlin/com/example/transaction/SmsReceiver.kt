package com.example.transaction

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.telephony.SmsMessage
import android.util.Log

/**
 * Listens for [android.provider.Telephony.Sms.Intents.SMS_RECEIVED_ACTION]
 * broadcasts and forwards a simple "SMS_RECEIVED" signal to the Flutter
 * layer via [SmsEventChannel].
 *
 * This is PHASE 1 only — NO body, NO sender, NO timestamp is transmitted
 * to Flutter. Only the string "SMS_RECEIVED" is sent.
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

            // Build the first SmsMessage to confirm this is real SMS data
            // (we still do NOT send the body or sender across the bridge)
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

            // At least one valid SMS message confirmed — broadcast the signal
            Log.d(TAG, "[SMS] Broadcasting Flutter event")
            SmsEventChannel.sendSmsReceived()
            Log.d(TAG, "[SMS] Event sent successfully")

        } catch (e: Exception) {
            Log.e(TAG, "[SMS][ERROR] Receiver crashed: ${e.message}", e)
        }
    }
}
