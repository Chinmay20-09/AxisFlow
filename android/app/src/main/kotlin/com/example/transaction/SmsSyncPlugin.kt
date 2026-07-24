package com.example.transaction

import android.content.ContentResolver
import android.content.Context
import android.database.Cursor
import android.net.Uri
import android.provider.Telephony
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

/**
 * Bridges SMS inbox queries from the Flutter layer to the Android
 * ContentResolver via a MethodChannel named "com.example.transaction/sms_sync".
 *
 * Methods:
 *   - scanSmsSince(timestamp: Long) -> JSON string array of
 *     {"sender": "...", "timestamp": 123, "body": "..."}
 *
 * Requires READ_SMS permission.
 */
class SmsSyncPlugin(
    private val flutterEngine: FlutterEngine,
    private val context: Context,
) {

    companion object {
        private const val TAG = "SMS_SYNC"
        private const val CHANNEL = "com.example.transaction/sms_sync"

        /**
         * Query the SMS inbox for messages newer than sinceTimestamp.
         */
        fun scanSmsSince(
            sinceTimestamp: Long,
            contentResolver: ContentResolver,
        ): String {

            Log.d(TAG, "[SMS_SYNC] scanSmsSince(sinceTimestamp=$sinceTimestamp)")

            val uri: Uri = Telephony.Sms.Inbox.CONTENT_URI

            val projection = arrayOf(
                Telephony.Sms.Inbox.ADDRESS,
                Telephony.Sms.Inbox.DATE,
                Telephony.Sms.Inbox.BODY,
            )

            val selection = "${Telephony.Sms.Inbox.DATE} > ?"
            val selectionArgs = arrayOf(sinceTimestamp.toString())
            val sortOrder = "${Telephony.Sms.Inbox.DATE} ASC"

            val results = JSONArray()
            var cursor: Cursor? = null

            try {
                cursor = contentResolver.query(
                    uri,
                    projection,
                    selection,
                    selectionArgs,
                    sortOrder,
                )

                if (cursor == null || !cursor.moveToFirst()) {
                    Log.d(TAG, "[SMS_SYNC] No SMS found since timestamp $sinceTimestamp")
                    return results.toString()
                }

                val senderIdx = cursor.getColumnIndex(Telephony.Sms.Inbox.ADDRESS)
                val dateIdx = cursor.getColumnIndex(Telephony.Sms.Inbox.DATE)
                val bodyIdx = cursor.getColumnIndex(Telephony.Sms.Inbox.BODY)

                var count = 0

                do {
                    val sender =
                        if (senderIdx >= 0)
                            cursor.getString(senderIdx) ?: "unknown"
                        else
                            "unknown"

                    val timestamp =
                        if (dateIdx >= 0)
                            cursor.getLong(dateIdx)
                        else
                            0L

                    val body =
                        if (bodyIdx >= 0)
                            cursor.getString(bodyIdx) ?: ""
                        else
                            ""

                    if (body.isBlank()) continue

                    val message = JSONObject().apply {
                        put("sender", sender)
                        put("timestamp", timestamp)
                        put("body", body)
                    }

                    results.put(message)
                    count++

                } while (cursor.moveToNext())

                Log.d(TAG, "[SMS_SYNC] Found $count SMS messages")

            } catch (e: Exception) {
                Log.e(TAG, "[SMS_SYNC] Error querying SMS inbox", e)
            } finally {
                cursor?.close()
            }

            return results.toString()
        }
    }

    /**
     * Register MethodChannel.
     */
    fun setup() {

        Log.d(TAG, "[SMS_SYNC] Setting up MethodChannel")

        val channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL,
        )

        channel.setMethodCallHandler { call, result ->

            when (call.method) {

                "scanSmsSince" -> {

                    val sinceTimestamp =
                        call.argument<Long>("sinceTimestamp") ?: 0L

                    val jsonResult = scanSmsSince(
                        sinceTimestamp,
                        context.contentResolver,
                    )

                    result.success(jsonResult)
                }

                else -> result.notImplemented()
            }
        }

        Log.d(TAG, "[SMS_SYNC] MethodChannel ready")
    }
}