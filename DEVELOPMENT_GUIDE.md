# Epi Care App Development Guide

This guide summarizes the current seizure-monitoring prototype, the Samsung Health integration path, and outstanding tasks for production readiness.

---

## 1. Project Snapshot

```
epi_care_app/
├── android/…                                 # Android host + Wear OS native bridge
├── docs/
│   └── backend_payload.md                    # REST contract for health data batches
├── lib/
│   ├── main.dart                             # Flutter entry point & navigation
│   ├── models/
│   │   ├── health_sensor_data.dart           # Canonical Samsung sensor reading model
│   │   └── seizure_prediction_data.dart      # Prediction summary used by alerts
│   ├── services/
│   │   ├── galaxy_watch_service.dart         # Method/Event channel bridge to Wear OS
│   │   └── seizure_prediction_service.dart   # Buffer + POST health data to backend
│   ├── utils/                                # Helpers (loading utilities, etc.)
│   └── widgets/
│       ├── health_monitor_screen.dart        # Live monitoring UI + control buttons
│       └── seizure_alert_screen.dart         # Seizure alert and feedback dialog
└── pubspec.yaml
```

`HealthMonitorScreen` is not the landing page; navigate to it through the app’s router to access monitoring controls.

---

## 2. Core Flutter Components

### 2.1 `HealthSensorData`
- Normalizes Samsung Health payloads for every tracker we plan to use (`heart_rate`, `spo2`, `bia`, `mf_bia`, `bio_active_sensor`, `ecg`, `eda`, `ibi`, `ppg`, `skin_temperature`, `sleep_stage`, etc.).
- Stores multi-metric readings (`metrics`, `units`) plus raw payloads for debugging.
- Provides helper getters for status text, and nominal range checks for heart rate and SpO₂.

### 2.2 `GalaxyWatchService`
- Exposes `initialize`, `startTracking`, `stopTracking`, `measureOnce`, `isConnected` over a MethodChannel.
- Streams sensor events via an EventChannel, converting native maps into `HealthSensorData`.
- Publishes a default tracker list so the UI requests the full Samsung Health data set.
- **Requires** a Wear OS counterpart (`SamsungHealthSensorManager.kt`) that talks to the Samsung Health Sensor SDK.

### 2.3 `SeizurePredictionService`
- Buffers incoming readings and sends batches every 10 seconds (`metadata` + `data` payload).
- `flushBufferedData()` lets the UI force an immediate POST when monitoring stops.
- Stubbed `_baseUrl` and endpoints must be replaced once the backend is available.

### 2.4 `HealthMonitorScreen`
- Shows connection status and the “갤럭시워치 연결” button until the watch is paired.
- Offers `모니터링 시작 / 중지` toggles with feedback snack bars.
- Displays heart-rate and SpO₂ cards, plus an “추가 센서 데이터” section for all other trackers.
- Pipes every reading into `SeizurePredictionService` for backend delivery.

---

## 3. Samsung Health Integration Checklist

1. **Wear OS native layer**
   - Import `samsung-health-sensor-sdk-v1.4.1` (AAR) into the Wear OS module.
   - Implement `SamsungHealthSensorManager.kt` to handle MethodChannel calls and forward sensor events through the EventChannel.
   - Register all required tracker types (BIA, MF-BIA, BioActive Sensor, ECG, EDA, IBI, PPG, skin temperature, sleep stage, …).
   - Manage runtime permissions, Samsung partner authentication, and foreground service requirements for continuous sampling.

2. **Device validation**
   - Install the Wear OS module on a Galaxy Watch running Wear OS Powered by Samsung.
   - Run the Flutter app on an Android device, open `HealthMonitorScreen`, and confirm real-time updates for each tracker.

---

## 4. Backend Contract & TODOs

- Sensor batches are POSTed to `$_baseUrl$_healthDataEndpoint` (see `SeizurePredictionService`).
- The exact payload is documented in `docs/backend_payload.md`:
  - `metadata` (batch size, tracker list, time window, sentAt).
  - `data[]` with `type`, `timestamp`, `metrics`, optional `value/unit/heartRate`, and the raw payload snapshot.
- Backend responsibilities:
  1. Validate and persist incoming batches (schema-on-read recommended).
  2. Trigger seizure prediction and respond with `{ "predictionProbability": <double>, "modelVersion": "...", ... }` when available.
  3. Return 200/201 on success so the client clears its buffer; non-2xx responses are retried.
  4. Add authentication/authorization (Bearer token, API key, etc.) and update the Flutter headers accordingly.

---

## 5. Running the App

```bash
cd epi_care_app
flutter pub get
flutter run   # Use an Android device or emulator for monitoring features
```

- The live monitoring UI depends on Android-specific services. It will not function on the web (`flutter run -d chrome`).
- Navigate to `HealthMonitorScreen` inside the app to access the connection and tracking controls.

---

## 6. Testing Checklist

- Initialize the watch, start monitoring, confirm cards update, stop monitoring, and check that `flushBufferedData()` fires.
- Trigger every tracker (BIA, ECG, EDA, IBI, PPG, skin temperature, sleep stage) and ensure values appear under “추가 센서 데이터”.
- Inspect outgoing HTTP payloads with a mock server to verify metadata, timestamps, and units.
- Return a response containing `predictionProbability` from the backend and confirm notifications + alert screen behavior.
- Exercise failure paths: disconnected watch, backend 5xx, malformed payload; the buffer should retry and the UI should show an error.

---

## 7. Next Steps

1. Finish the Wear OS native implementation and obtain Samsung Health Sensor SDK partner approval.
2. Deploy the backend ingestion endpoint and plug the real URL/token into `SeizurePredictionService`.
3. Automate end-to-end tests once the wearable, Flutter app, and backend are wired together.
