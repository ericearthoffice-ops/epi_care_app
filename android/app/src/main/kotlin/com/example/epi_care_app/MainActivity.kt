package com.example.epi_care_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {
    private var healthSensorManager: SamsungHealthSensorManager? = null

    companion object {
        private const val METHOD_CHANNEL = "com.example.epi_care_app/health_sensor"
        private const val EVENT_CHANNEL = "com.example.epi_care_app/health_sensor_stream"
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
    }

    override fun onDestroy() {
        super.onDestroy()
        healthSensorManager?.dispose()
        healthSensorManager = null
    }
}
