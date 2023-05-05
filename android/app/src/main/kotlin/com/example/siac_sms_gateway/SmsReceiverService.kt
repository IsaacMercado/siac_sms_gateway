package com.example.siac_sms_gateway

import android.app.Service
import android.content.Intent
import android.content.IntentFilter
import android.os.IBinder
import com.shounakmulay.telephony.sms.IncomingSmsReceiver

class SmsReceiverService : Service() {
    private val TAG = this.javaClass.simpleName
    private var smsReceiver: IncomingSmsReceiver? = null
    private var intentFilter: IntentFilter? = null

    override fun onCreate() {
        super.onCreate()
        smsReceiver = IncomingSmsReceiver()
        intentFilter = IntentFilter()
        intentFilter!!.addAction("android.provider.Telephony.SMS_RECEIVED")
        intentFilter!!.priority = 2147483647
        registerReceiver(smsReceiver, intentFilter)
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterReceiver(smsReceiver)
    }

    override fun onBind(arg0: Intent): IBinder? {
        return null
    }
}
