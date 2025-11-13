package com.example.epi_care_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import android.util.Log

class MainActivity : FlutterActivity() {
    private var healthSensorManager: SamsungHealthSensorManager? = null
    private var wearableEventSink: EventChannel.EventSink? = null

    companion object {
        private const val TAG = "MainActivity"
        private const val METHOD_CHANNEL = "com.example.epi_care_app/health_sensor"
        private const val EVENT_CHANNEL = "com.example.epi_care_app/health_sensor_stream"
        private const val WEARABLE_EVENT_CHANNEL = "com.example.epi_care_app/wearable_data_stream"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Samsung Health Sensor Manager 초기화
        healthSensorManager = SamsungHealthSensorManager(applicationContext, this)

        // Method Channel 설정
        val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
        healthSensorManager?.setupMethodChannel(methodChannel)

        // Event Channel 설정 (실시간 데이터 스트림)
        val eventChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
        healthSensorManager?.setupEventChannel(eventChannel)

        // Wearable Event Channel 설정 (seizurewatch-master 데이터 스트림)
        setupWearableEventChannel(flutterEngine)
    }

    private fun setupWearableEventChannel(flutterEngine: FlutterEngine) {
        val wearableEventChannel = EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            WEARABLE_EVENT_CHANNEL
        )

        wearableEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                wearableEventSink = events
                Log.d(TAG, "Wearable event channel listener attached")

                // WearableDataListenerService에 콜백 등록
                WearableDataListenerService.onDataReceived = { data ->
                    wearableEventSink?.success(data)
                }
            }

            override fun onCancel(arguments: Any?) {
                wearableEventSink = null
                WearableDataListenerService.onDataReceived = null
                Log.d(TAG, "Wearable event channel listener cancelled")
            }
        })
    }

    override fun onDestroy() {
        super.onDestroy()
        healthSensorManager?.dispose()
        healthSensorManager = null
        wearableEventSink = null
        WearableDataListenerService.onDataReceived = null
    }
}
