package com.paulomkenya.mkenyasmspro

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Required by Android to be declared as the default SMS app.
 * The telephony Flutter plugin handles the actual message processing.
 */
class SmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        // Handled by telephony plugin
    }
}
