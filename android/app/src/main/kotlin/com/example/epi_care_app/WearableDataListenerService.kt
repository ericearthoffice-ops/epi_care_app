package com.example.epi_care_app

import android.util.Log
import com.google.android.gms.wearable.DataEvent
import com.google.android.gms.wearable.DataEventBuffer
import com.google.android.gms.wearable.DataMapItem
import com.google.android.gms.wearable.WearableListenerService

/**
 * Wearable Data Layer API 리스너 서비스
 * seizurewatch-master 워치 앱에서 전송하는 센서 데이터를 수신합니다
 *
 * 수신 데이터 형식:
 * - 경로: /biometric
 * - accelX: Float (가속도계 X축)
 * - accelY: Float (가속도계 Y축)
 * - accelZ: Float (가속도계 Z축)
 * - bpm: Int (심박수)
 * - ts: Long (타임스탬프)
 */
class WearableDataListenerService : WearableListenerService() {

    companion object {
        private const val TAG = "WearableDataListener"
        private const val BIOMETRIC_PATH = "/biometric"

        // Static callback for Flutter EventChannel
        var onDataReceived: ((Map<String, Any>) -> Unit)? = null
    }

    override fun onDataChanged(dataEvents: DataEventBuffer) {
        Log.d(TAG, "onDataChanged called, ${dataEvents.count} events")

        for (event in dataEvents) {
            if (event.type == DataEvent.TYPE_CHANGED) {
                val path = event.dataItem.uri.path
                Log.d(TAG, "Data changed at path: $path")

                if (path == BIOMETRIC_PATH) {
                    val dataMap = DataMapItem.fromDataItem(event.dataItem).dataMap

                    val accelX = dataMap.getFloat("accelX", 0f)
                    val accelY = dataMap.getFloat("accelY", 0f)
                    val accelZ = dataMap.getFloat("accelZ", 0f)
                    val bpm = dataMap.getInt("bpm", -1)
                    val timestamp = dataMap.getLong("ts", System.currentTimeMillis())

                    Log.d(TAG, "Received biometric data: accel=($accelX, $accelY, $accelZ), bpm=$bpm, ts=$timestamp")

                    // Flutter로 전달할 데이터 맵 생성
                    val sensorData = mapOf(
                        "type" to "wearable_biometric",
                        "accelX" to accelX.toDouble(),
                        "accelY" to accelY.toDouble(),
                        "accelZ" to accelZ.toDouble(),
                        "bpm" to bpm,
                        "timestamp" to timestamp
                    )

                    // EventChannel로 데이터 전송
                    onDataReceived?.invoke(sensorData)

                    Log.d(TAG, "Data forwarded to Flutter")
                }
            }
        }

        dataEvents.release()
    }
}
