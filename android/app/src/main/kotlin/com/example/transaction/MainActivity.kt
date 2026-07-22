package com.example.transaction

import android.Manifest
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    companion object {
        private const val TAG = "SMS"
        private const val SMS_PERMISSION_REQUEST = 1001
    }

    private lateinit var smsEventChannel: SmsEventChannel
    private var smsReceiver: SmsReceiver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        Log.d(TAG, "[SMS] Setting up EventChannel")

        smsEventChannel = SmsEventChannel(flutterEngine)
        smsEventChannel.setup()
    }

    override fun onResume() {
        super.onResume()
        registerSmsReceiver()
    }

    override fun onPause() {
        super.onPause()
        unregisterSmsReceiver()
    }

    // ── Permission helpers ────────────────────────────────────────────────

    /**
     * Register the [SmsReceiver] if RECEIVE_SMS is granted.
     * If permission is missing, request it from the user.
     */
    private fun registerSmsReceiver() {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECEIVE_SMS)
            != PackageManager.PERMISSION_GRANTED
        ) {
            Log.w(TAG, "[SMS][ERROR] RECEIVE_SMS permission missing")
            requestPermissions(
                arrayOf(Manifest.permission.RECEIVE_SMS),
                SMS_PERMISSION_REQUEST,
            )
            return
        }

        if (smsReceiver != null) return // already registered

        try {
            val receiver = SmsReceiver()
            smsReceiver = receiver
            Log.d(TAG, "[SMS] Receiver created")

            val filter = IntentFilter("android.provider.Telephony.SMS_RECEIVED")

            // Android 14+ requires RECEIVER_EXPORTED/RECEIVER_NOT_EXPORTED
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                registerReceiver(receiver, filter, RECEIVER_EXPORTED)
            } else {
                @Suppress("UnsafeRegisteredReceiver")
                registerReceiver(receiver, filter)
            }

            Log.d(TAG, "[SMS] Receiver registered")
        } catch (e: Exception) {
            Log.e(TAG, "[SMS][ERROR] Receiver registration failed: ${e.message}", e)
        }
    }

    private fun unregisterSmsReceiver() {
        try {
            smsReceiver?.let {
                unregisterReceiver(it)
                smsReceiver = null
                Log.d(TAG, "[SMS] Receiver unregistered")
            }
        } catch (e: Exception) {
            Log.e(TAG, "[SMS][ERROR] Failed to unregister receiver: ${e.message}", e)
        }
    }

    /**
     * Called after the system permission dialog completes.
     * If granted, the receiver will be picked up on the next [onResume].
     */
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == SMS_PERMISSION_REQUEST) {
            if (grantResults.isNotEmpty()
                && grantResults[0] == PackageManager.PERMISSION_GRANTED
            ) {
                Log.d(TAG, "[SMS] Permission granted")
                // onResume will be called, so registerSmsReceiver will retry
            } else {
                Log.w(TAG, "[SMS][ERROR] RECEIVE_SMS permission denied")
            }
        }
    }
}
