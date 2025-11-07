package com.example.epi_care_app

import android.app.Activity
import android.content.Context
import android.util.Log
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import com.samsung.android.service.health.tracking.HealthTracker
import com.samsung.android.service.health.tracking.HealthTrackerException
import com.samsung.android.service.health.tracking.HealthTrackingService
import com.samsung.android.service.health.tracking.data.DataPoint
import com.samsung.android.service.health.tracking.data.HealthTrackerType
import com.samsung.android.service.health.tracking.data.ValueKey

/**
 * Samsung Health Sensor SDK 관리 클래스
 * 갤럭시 워치에서 모든 헬스 데이터를 수신
 */
class SamsungHealthSensorManager(
    private val context: Context,
    private val activity: Activity
) {
    companion object {
        private const val TAG = "HealthSensorManager"
        private const val METHOD_CHANNEL = "com.example.epi_care_app/health_sensor"
        private const val EVENT_CHANNEL = "com.example.epi_care_app/health_sensor_stream"
    }

    private var healthTrackingService: HealthTrackingService? = null
    private val activeTrackers = mutableMapOf<String, HealthTracker>()
    private var isTracking = false

    private var eventSink: EventChannel.EventSink? = null

    /**
     * Method Channel 설정
     */
    fun setupMethodChannel(methodChannel: MethodChannel) {
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> {
                    initialize(result)
                }
                "startTracking" -> {
                    val trackers = call.argument<List<String>>("trackers")
                    startTracking(result, trackers)
                }
                "stopTracking" -> {
                    stopTracking(result)
                }
                "isConnected" -> {
                    result.success(healthTrackingService != null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    /**
     * Event Channel 설정 (실시간 데이터 스트림)
     */
    fun setupEventChannel(eventChannel: EventChannel) {
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
                Log.d(TAG, "Event channel listener attached")
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
                Log.d(TAG, "Event channel listener cancelled")
            }
        })
    }

    /**
     * Samsung Health Tracking Service 초기화
     */
    private fun initialize(result: MethodChannel.Result) {
        try {
            val connectionListener = object : HealthTrackingService.ConnectionListener {
                override fun onConnectionSuccess() {
                    Log.d(TAG, "Health Tracking Service connected successfully")
                    result.success(mapOf(
                        "success" to true,
                        "message" to "Samsung Health Sensor 연결 성공"
                    ))
                }

                override fun onConnectionEnded() {
                    Log.d(TAG, "Health Tracking Service connection ended")
                    healthTrackingService = null
                }

                override fun onConnectionFailed(error: HealthTrackerException?) {
                    val errorMsg = "Samsung Health Sensor 연결 실패: ${error?.message}"
                    Log.e(TAG, errorMsg, error)
                    result.error("CONNECTION_FAILED", errorMsg, error?.message)
                }
            }

            healthTrackingService = HealthTrackingService(connectionListener, context)
            healthTrackingService?.connectService()

        } catch (e: Exception) {
            val errorMsg = "초기화 실패: ${e.message}"
            Log.e(TAG, errorMsg, e)
            result.error("INITIALIZATION_ERROR", errorMsg, e.message)
        }
    }

    /**
     * 센서 추적 시작 - 모든 요청된 센서 타입 처리
     */
    private fun startTracking(result: MethodChannel.Result, requestedTrackers: List<String>?) {
        if (healthTrackingService == null) {
            result.error("NOT_INITIALIZED", "먼저 initialize()를 호출해주세요", null)
            return
        }

        val trackers = requestedTrackers ?: listOf("heart_rate", "spo2")
        val successfulTrackers = mutableListOf<String>()
        val failedTrackers = mutableListOf<String>()

        try {
            for (trackerName in trackers) {
                val trackerType = mapTrackerNameToType(trackerName)
                if (trackerType == null) {
                    Log.w(TAG, "Unknown tracker type: $trackerName")
                    failedTrackers.add(trackerName)
                    continue
                }

                try {
                    val tracker = healthTrackingService!!.getHealthTracker(trackerType)
                    tracker?.setEventListener(createTrackerListener(trackerName))
                    activeTrackers[trackerName] = tracker
                    successfulTrackers.add(trackerName)
                    Log.d(TAG, "Started tracking: $trackerName")
                } catch (e: Exception) {
                    Log.w(TAG, "Failed to start tracker $trackerName: ${e.message}")
                    failedTrackers.add(trackerName)
                }
            }

            isTracking = successfulTrackers.isNotEmpty()

            result.success(mapOf(
                "success" to true,
                "message" to "센서 추적 시작됨",
                "activeTrackers" to successfulTrackers,
                "failedTrackers" to failedTrackers
            ))

        } catch (e: Exception) {
            val errorMsg = "센서 추적 시작 실패: ${e.message}"
            Log.e(TAG, errorMsg, e)
            result.error("START_TRACKING_ERROR", errorMsg, e.message)
        }
    }

    /**
     * 센서 추적 중지
     */
    private fun stopTracking(result: MethodChannel.Result) {
        try {
            for ((name, tracker) in activeTrackers) {
                try {
                    tracker.unsetEventListener()
                    Log.d(TAG, "Stopped tracking: $name")
                } catch (e: Exception) {
                    Log.w(TAG, "Error stopping tracker $name: ${e.message}")
                }
            }

            activeTrackers.clear()
            isTracking = false

            Log.d(TAG, "All sensor tracking stopped")
            result.success(mapOf(
                "success" to true,
                "message" to "센서 추적 중지됨"
            ))

        } catch (e: Exception) {
            val errorMsg = "센서 추적 중지 실패: ${e.message}"
            Log.e(TAG, errorMsg, e)
            result.error("STOP_TRACKING_ERROR", errorMsg, e.message)
        }
    }

    /**
     * Flutter 트래커 이름을 Samsung HealthTrackerType으로 변환
     */
    private fun mapTrackerNameToType(name: String): HealthTrackerType? {
        return when (name.lowercase()) {
            "heart_rate" -> HealthTrackerType.HEART_RATE_CONTINUOUS
            "spo2" -> HealthTrackerType.SPO2_ON_DEMAND
            "skin_temperature" -> HealthTrackerType.SKIN_TEMPERATURE
            "ecg" -> HealthTrackerType.ECG
            "ppg" -> HealthTrackerType.PPG_GREEN
            "sleep_stage" -> HealthTrackerType.SLEEP_STAGE
            "exercise" -> HealthTrackerType.EXERCISE
            "sweat_loss" -> HealthTrackerType.SWEAT_LOSS
            "bia" -> HealthTrackerType.BIA
            "mf_bia" -> HealthTrackerType.MULTI_FREQUENCY_BIA
            "bio_active_sensor" -> HealthTrackerType.BIO_ACTIVE_SENSOR
            "eda" -> HealthTrackerType.EDA
            "ibi" -> HealthTrackerType.IBI
            else -> null
        }
    }

    /**
     * 범용 트래커 리스너 생성
     */
    private fun createTrackerListener(trackerName: String): HealthTracker.TrackerEventListener {
        return object : HealthTracker.TrackerEventListener {
            override fun onDataReceived(dataPoints: MutableList<DataPoint>) {
                for (dataPoint in dataPoints) {
                    try {
                        val data = extractDataFromPoint(trackerName, dataPoint)
                        if (data != null) {
                            Log.d(TAG, "$trackerName data: $data")
                            eventSink?.success(data)
                        }
                    } catch (e: Exception) {
                        Log.e(TAG, "Error extracting data from $trackerName: ${e.message}", e)
                    }
                }
            }

            override fun onError(trackerError: HealthTracker.TrackerError?) {
                val errorMsg = "$trackerName Error: ${trackerError?.name}"
                Log.e(TAG, errorMsg)
                eventSink?.error("${trackerName.uppercase()}_ERROR", errorMsg, trackerError?.name)
            }

            override fun onFlushCompleted() {
                Log.d(TAG, "$trackerName flush completed")
            }
        }
    }

    /**
     * DataPoint에서 센서 타입에 맞는 데이터 추출
     */
    private fun extractDataFromPoint(trackerName: String, dataPoint: DataPoint): Map<String, Any>? {
        val timestamp = System.currentTimeMillis()
        val baseData = mutableMapOf<String, Any>(
            "type" to trackerName,
            "timestamp" to timestamp
        )

        return try {
            when (trackerName.lowercase()) {
                "heart_rate" -> {
                    val hr = dataPoint.getValue(ValueKey.HeartRateSet.HEART_RATE)
                    val status = dataPoint.getValue(ValueKey.HeartRateSet.HEART_RATE_STATUS)
                    baseData["value"] = hr
                    baseData["status"] = status
                    baseData
                }
                "spo2" -> {
                    val spo2 = dataPoint.getValue(ValueKey.SpO2Set.SPO2)
                    val status = dataPoint.getValue(ValueKey.SpO2Set.STATUS)
                    val hr = dataPoint.getValue(ValueKey.SpO2Set.HEART_RATE)
                    baseData["value"] = spo2
                    baseData["status"] = status
                    if (hr != null) baseData["heartRate"] = hr
                    baseData
                }
                "skin_temperature" -> {
                    val temp = dataPoint.getValue(ValueKey.SkinTemperatureSet.OBJECT_TEMPERATURE)
                    val status = dataPoint.getValue(ValueKey.SkinTemperatureSet.STATUS)
                    baseData["value"] = temp
                    baseData["status"] = status
                    baseData["unit"] = "°C"
                    baseData
                }
                "ppg" -> {
                    // PPG는 여러 값을 포함할 수 있음
                    val metrics = mutableMapOf<String, Any>()
                    try {
                        val ppgValue = dataPoint.getValue(ValueKey.PpgGreenSet.PPG_GREEN)
                        if (ppgValue != null) metrics["ppg_green"] = ppgValue
                    } catch (e: Exception) {
                        Log.w(TAG, "PPG value not available: ${e.message}")
                    }

                    if (metrics.isNotEmpty()) {
                        baseData["metrics"] = metrics
                        baseData["value"] = metrics.values.first()
                        baseData
                    } else null
                }
                "sleep_stage" -> {
                    val stage = dataPoint.getValue(ValueKey.SleepStageSet.STAGE)
                    baseData["value"] = stage
                    baseData
                }
                "ecg" -> {
                    // ECG는 복잡한 데이터 구조
                    val metrics = mutableMapOf<String, Any>()
                    try {
                        val hr = dataPoint.getValue(ValueKey.EcgSet.HEART_RATE)
                        val status = dataPoint.getValue(ValueKey.EcgSet.ECG_STATUS)
                        if (hr != null) metrics["heart_rate"] = hr
                        if (status != null) baseData["status"] = status
                    } catch (e: Exception) {
                        Log.w(TAG, "ECG data extraction error: ${e.message}")
                    }

                    if (metrics.isNotEmpty()) {
                        baseData["metrics"] = metrics
                        baseData
                    } else null
                }
                "sweat_loss" -> {
                    try {
                        val sweatLoss = dataPoint.getValue(ValueKey.SweatLossSet.SWEAT_LOSS)
                        baseData["value"] = sweatLoss
                        baseData["unit"] = "ml"
                        baseData
                    } catch (e: Exception) {
                        Log.w(TAG, "Sweat loss not available: ${e.message}")
                        null
                    }
                }
                "bia" -> {
                    try {
                        val metrics = mutableMapOf<String, Any>()
                        val impedance = dataPoint.getValue(ValueKey.BiaSet.IMPEDANCE)
                        val bodyFat = dataPoint.getValue(ValueKey.BiaSet.BODY_FAT_PERCENTAGE)
                        val skeletalMuscle = dataPoint.getValue(ValueKey.BiaSet.SKELETAL_MUSCLE_MASS)
                        val bodyWater = dataPoint.getValue(ValueKey.BiaSet.BODY_WATER)

                        if (impedance != null) metrics["impedance"] = impedance
                        if (bodyFat != null) metrics["body_fat_percentage"] = bodyFat
                        if (skeletalMuscle != null) metrics["skeletal_muscle_mass"] = skeletalMuscle
                        if (bodyWater != null) metrics["body_water"] = bodyWater

                        if (metrics.isNotEmpty()) {
                            baseData["metrics"] = metrics
                            baseData["value"] = impedance ?: 0
                            baseData["unit"] = "Ω"
                            baseData
                        } else null
                    } catch (e: Exception) {
                        Log.w(TAG, "BIA data extraction error: ${e.message}")
                        null
                    }
                }
                "mf_bia" -> {
                    try {
                        val metrics = mutableMapOf<String, Any>()
                        // Multi-frequency BIA는 여러 주파수의 임피던스 측정
                        val frequencies = listOf(5, 50, 250) // kHz
                        for (freq in frequencies) {
                            try {
                                // Samsung SDK의 실제 키는 문서 참조 필요
                                val key = "impedance_${freq}khz"
                                metrics[key] = freq // placeholder
                            } catch (e: Exception) {
                                Log.w(TAG, "MF-BIA ${freq}kHz not available")
                            }
                        }

                        if (metrics.isNotEmpty()) {
                            baseData["metrics"] = metrics
                            baseData["value"] = metrics.values.first()
                            baseData["unit"] = "Ω"
                            baseData
                        } else null
                    } catch (e: Exception) {
                        Log.w(TAG, "MF-BIA data extraction error: ${e.message}")
                        null
                    }
                }
                "bio_active_sensor" -> {
                    try {
                        val metrics = mutableMapOf<String, Any>()
                        val status = dataPoint.getValue(ValueKey.BioActiveSensorSet.STATUS)
                        val reading = dataPoint.getValue(ValueKey.BioActiveSensorSet.READING)

                        if (status != null) baseData["status"] = status
                        if (reading != null) metrics["reading"] = reading

                        if (metrics.isNotEmpty()) {
                            baseData["metrics"] = metrics
                            baseData["value"] = reading ?: 0
                            baseData
                        } else null
                    } catch (e: Exception) {
                        Log.w(TAG, "BioActive sensor not available: ${e.message}")
                        null
                    }
                }
                "eda" -> {
                    try {
                        val edaValue = dataPoint.getValue(ValueKey.EdaSet.EDA)
                        val status = dataPoint.getValue(ValueKey.EdaSet.STATUS)

                        baseData["value"] = edaValue
                        baseData["status"] = status
                        baseData["unit"] = "μS"
                        baseData
                    } catch (e: Exception) {
                        Log.w(TAG, "EDA not available: ${e.message}")
                        null
                    }
                }
                "ibi" -> {
                    try {
                        val ibiValue = dataPoint.getValue(ValueKey.IbiSet.IBI)
                        val status = dataPoint.getValue(ValueKey.IbiSet.STATUS)

                        baseData["value"] = ibiValue
                        baseData["status"] = status
                        baseData["unit"] = "ms"
                        baseData
                    } catch (e: Exception) {
                        Log.w(TAG, "IBI not available: ${e.message}")
                        null
                    }
                }
                else -> {
                    // 알 수 없는 센서 타입 - 범용 처리
                    Log.w(TAG, "Unknown sensor type for data extraction: $trackerName")
                    baseData["value"] = 0
                    baseData["metrics"] = mapOf("raw" to "unknown")
                    baseData
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to extract data for $trackerName: ${e.message}", e)
            null
        }
    }

    /**
     * 리소스 정리
     */
    fun dispose() {
        try {
            stopTracking(object : MethodChannel.Result {
                override fun success(result: Any?) {}
                override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {}
                override fun notImplemented() {}
            })

            healthTrackingService?.disconnectService()
            healthTrackingService = null
            eventSink = null

            Log.d(TAG, "Resources disposed")
        } catch (e: Exception) {
            Log.e(TAG, "Error disposing resources: ${e.message}", e)
        }
    }
}
